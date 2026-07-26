<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Models\Product;
use App\Models\StoreListing;
use App\Models\Ticket;
use App\Models\TicketAttachment;
use App\Models\TicketDeadlineNegotiation;
use App\Models\TicketModificationRequest;
use App\Models\TicketPriceHistory;
use App\Models\User;
use App\Models\UserSubscription;
use App\Services\ImageOptimizer;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class TicketController extends Controller
{
    private const TRANSITIONS = [
        'tester_propose' => [
            'pending_tester_review' => 'waiting_industor_approval',
            'waiting_tester_review' => 'waiting_industor_approval',
        ],
        'industor_accept' => [
            'waiting_industor_approval' => 'approved_by_tester',
        ],
        'industor_accept_single' => [
            'waiting_industor_approval' => 'pending_payment',
        ],
        'industor_counter' => [
            'waiting_industor_approval' => 'waiting_tester_review',
        ],
        'tester_accept' => [
            'waiting_tester_review' => 'approved_by_tester',
        ],
        'tester_accept_single' => [
            'waiting_tester_review' => 'pending_payment',
        ],
        'tester_accept_initial' => [
            'pending_tester_review' => 'approved_by_tester',
        ],
        'tester_accept_initial_single' => [
            'pending_tester_review' => 'pending_payment',
        ],
        'single_paid' => ['pending_payment' => 'approved_by_tester'],
        'accept' => ['approved_by_tester' => 'accepted'],
        'set_deadline' => ['accepted' => 'in_progress'],
        'resume_after_mod' => ['modification_requested' => 'accepted'],
        'upload' => ['accepted' => 'awaiting_qa', 'in_progress' => 'awaiting_qa', 'rejected_qa' => 'awaiting_qa'],
        'qa_approve' => ['awaiting_qa' => 'completed'],
        'qa_reject' => ['awaiting_qa' => 'rejected_qa'],
        'cancel' => [
            'pending_tester_review' => 'cancelled',
            'waiting_industor_approval' => 'cancelled',
            'waiting_tester_review' => 'cancelled',
            'approved_by_tester' => 'cancelled',
            'accepted' => 'cancelled',
            'modification_requested' => 'cancelled',
            'in_progress' => 'cancelled',
        ],
    ];

    private const STATUS_TIMESTAMP = [
        'approved_by_tester' => 'reviewed_at',
        'pending_payment' => 'reviewed_at',
        'accepted' => 'accepted_at',
        'in_progress' => 'started_at',
        'awaiting_qa' => 'uploaded_at',
        'completed' => 'completed_at',
    ];

    public function index(Request $request)
    {
        $user = $request->user();
        $role = $user->role->name;

        $query = Ticket::with(['industor', 'tester', 'designer', 'reviewer', 'attachments', 'modificationRequests', 'deadlineNegotiations.creator'])
            ->latest();

        $query = match ($role) {
            'admin' => $query,
            'industor' => $query->where('industor_id', $user->id),
            'designer' => $query->where('designer_id', $user->id),
            'tester' => $query->where(fn ($q) => $q
                ->where('tester_id', $user->id)
                ->orWhere('status', Ticket::STATUS_AWAITING_QA)
                ->orWhere('status', Ticket::STATUS_PENDING_TESTER_REVIEW)
                ->orWhere('status', Ticket::STATUS_WAITING_INDUSTOR_APPROVAL)
                ->orWhere('status', Ticket::STATUS_WAITING_TESTER_REVIEW)),
            default => $query->whereRaw('1=0'),
        };

        if ($request->status) {
            $query->where('status', $request->status);
        }

        $tickets = $query->paginate($request->per_page ?? 20);
        $tickets->through(fn ($t) => $this->applyPriceVisibility($user, $t->toArray()));

        return response()->json($tickets);
    }

    public function available(Request $request)
    {
        $user = $request->user();
        abort_unless($user->hasRole('designer') || $user->hasRole('admin'), 403, 'Only designers can view the available queue.');

        $tickets = Ticket::with(['industor', 'subscription.plan', 'reviewer'])
            ->where('status', Ticket::STATUS_APPROVED_BY_TESTER)
            ->whereNull('designer_id')
            ->orderByRaw('CASE WHEN deadline IS NOT NULL AND deadline < NOW() THEN 0 ELSE 1 END')
            ->orderBy('deadline', 'asc')
            ->paginate($request->per_page ?? 20);

        $tickets->getCollection()->each(fn ($t) => $this->applyUrgentPriceIncrease($t));
        $tickets->through(fn ($t) => $this->applyPriceVisibility($user, $t->toArray()));

        return response()->json($tickets);
    }

    protected function applyUrgentPriceIncrease(Ticket $ticket): void
    {
        if (! $ticket->deadline || ! $ticket->reviewed_at || ! $ticket->designer_price) {
            return;
        }

        if ($ticket->urgent_price_applied) {
            return;
        }

        if ($ticket->remaining_percentage > 50) {
            return;
        }

        $newDesignerPrice = round((float) $ticket->designer_price * 1.10, 2);

        $ticket->update([
            'designer_price' => $newDesignerPrice,
            'urgent_price_applied' => true,
            'price_updated_at' => now(),
        ]);

        TicketPriceHistory::create([
            'ticket_id' => $ticket->id,
            'original_price' => $ticket->original_price,
            'industor_price' => $ticket->industor_price,
            'designer_price' => $newDesignerPrice,
            'change_reason' => 'urgent_increase',
        ]);

        $this->notifyRole('designer', 'ticket.price_increased', 'Ticket price increased 10% (urgent)', [
            'ticket_id' => $ticket->id,
            'title' => $ticket->title,
            'new_price' => $newDesignerPrice,
        ]);

        $this->notifyRole('tester', 'ticket.urgent', 'Ticket became urgent & price adjusted', [
            'ticket_id' => $ticket->id,
            'title' => $ticket->title,
        ]);

        $ticket->refresh();
    }

    public function pendingTickets(Request $request)
    {
        $user = $request->user();
        abort_unless($user->hasRole('tester') || $user->hasRole('admin'), 403, 'Only testers can view the negotiation queue.');

        $tickets = Ticket::with(['industor', 'subscription.plan'])
            ->whereIn('status', [
                Ticket::STATUS_PENDING_TESTER_REVIEW,
                Ticket::STATUS_WAITING_TESTER_REVIEW,
            ])
            ->latest()
            ->paginate($request->per_page ?? 20);

        return response()->json($tickets);
    }

    public function qaQueue(Request $request)
    {
        $user = $request->user();
        abort_unless($user->hasRole('tester') || $user->hasRole('admin'), 403, 'Only testers can view the QA queue.');

        $query = Ticket::with(['industor', 'designer', 'attachments'])
            ->where('status', Ticket::STATUS_AWAITING_QA)
            ->latest();

        return response()->json($query->paginate($request->per_page ?? 20));
    }

    public function show(Request $request, $id)
    {
        $user = $request->user();
        $ticket = Ticket::with([
            'industor', 'tester', 'designer', 'reviewer', 'subscription.plan',
            'attachments.uploadedBy', 'histories.changedBy',
            'modificationRequests.designer', 'storeListing', 'payments', 'priceHistory',
            'deadlineNegotiations.creator', 'product',
        ])->findOrFail($id);

        $this->authorizeView($user, $ticket);

        $data = $this->applyPriceVisibility($user, $ticket->toArray());

        return response()->json($data);
    }

    public function store(Request $request)
    {
        $user = $request->user();
        abort_unless($user->hasRole('industor'), 403, 'Only industors can create tickets.');

        $data = $request->validate([
            'title' => 'required|string|max:200',
            'num_order' => 'nullable|integer|min:0',
            'description' => 'required|string',
            'expected_deadline' => 'required|date|after:now',
            'expected_price' => 'required|numeric|min:0',
            'single_purchase' => 'nullable|boolean',
        ]);

        $isSingle = (bool) ($data['single_purchase'] ?? false);

        return DB::transaction(function () use ($user, $data, $isSingle) {
            $sub = UserSubscription::where('user_id', $user->id)
                ->lockForUpdate()
                ->where('status', 'active')
                ->where('approval_status', 'approved')
                ->where(fn ($q) => $q->whereNull('end_date')->orWhere('end_date', '>', now()))
                ->latest('id')->first();

            if (! $sub && ! $isSingle) {
                abort(422, 'You have no active subscription. Subscribe to a plan or create a single-purchase ticket.');
            }

            if ($sub && ! $isSingle) {
                if ($sub->tickets_remaining <= 0) {
                    abort(422, 'You have no tickets remaining in your plan. Please upgrade or create a single-purchase ticket.');
                }
                $sub->decrement('tickets_remaining');
                $sub->increment('tickets_used');
            }

            $ticket = Ticket::create([
                'industor_id' => $user->id,
                'subscription_id' => $sub && ! $isSingle ? $sub->id : null,
                'title' => $data['title'],
                'num_order' => $data['num_order'] ?? null,
                'description' => $data['description'],
                'status' => Ticket::STATUS_PENDING_TESTER_REVIEW,
                'is_single_purchase' => $isSingle,
                'industor_expected_deadline' => $data['expected_deadline'],
                'industor_expected_price' => $data['expected_price'],
                'negotiation_status' => 'waiting_tester_review',
                'current_negotiation_round' => 0,
            ]);

            $this->createProposal($ticket, 'industor', $data['expected_deadline'], $data['expected_price'], null, $user);

            $note = $isSingle
                ? 'Single-purchase ticket submitted for tester review with proposed deadline & price'
                : 'Ticket submitted for tester review with proposed deadline & price';

            $ticket->histories()->create([
                'to_status' => Ticket::STATUS_PENDING_TESTER_REVIEW,
                'changed_by' => $user->id,
                'note' => $note,
            ]);

            $this->notifyRole('tester', 'ticket.pending_review', 'New ticket awaiting review', [
                'ticket_id' => $ticket->id,
                'title' => $ticket->title,
            ]);

            return response()->json($ticket->load(['subscription.plan', 'deadlineNegotiations.creator']), 201);
        });
    }

    public function update(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('industor'), 403, 'Only the industor can edit a ticket.');

        $data = $request->validate([
            'title' => 'sometimes|required|string|max:200',
            'description' => 'sometimes|required|string',
        ]);

        $ticket = Ticket::where('id', $id)->where('industor_id', $user->id)->firstOrFail();
        abort_unless($ticket->status === Ticket::STATUS_PENDING_TESTER_REVIEW, 422, 'Ticket can only be edited while awaiting tester review.');

        $ticket->update($data);
        $ticket->update(['rejection_reason' => null]);

        return response()->json($ticket->fresh(['industor', 'reviewer']));
    }

    public function testerPropose(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('tester'), 403, 'Only testers can send proposals.');

        $data = $request->validate([
            'suggested_deadline' => 'required|date|after:now',
            'suggested_price' => 'required|numeric|min:0',
            'reason' => 'nullable|string',
        ]);

        $ticket = Ticket::where('id', $id)
            ->whereIn('status', [Ticket::STATUS_PENDING_TESTER_REVIEW, Ticket::STATUS_WAITING_TESTER_REVIEW])
            ->firstOrFail();

        $ticket->update([
            'tester_suggested_deadline' => $data['suggested_deadline'],
            'tester_suggested_price' => $data['suggested_price'],
            'negotiation_status' => 'waiting_industor_approval',
            'current_negotiation_round' => $ticket->current_negotiation_round + 1,
        ]);

        $this->createProposal($ticket, 'tester', $data['suggested_deadline'], $data['suggested_price'], $data['reason'] ?? null, $user);

        $ticket = $this->transition($ticket, 'tester_propose', changedBy: $user);

        $this->notify($ticket->industor_id, 'ticket.suggestion_received', 'Tester sent a price & deadline proposal', [
            'ticket_id' => $ticket->id,
            'deadline' => $ticket->tester_suggested_deadline,
            'price' => $ticket->tester_suggested_price,
            'reason' => $data['reason'] ?? null,
        ]);

        return response()->json($ticket->fresh(['deadlineNegotiations.creator', 'histories']));
    }

    public function industorAccept(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('industor'), 403, 'Only the industor can accept proposals.');

        $ticket = Ticket::where('id', $id)->where('industor_id', $user->id)
            ->where('status', Ticket::STATUS_WAITING_INDUSTOR_APPROVAL)->firstOrFail();
        abort_unless($ticket->tester_suggested_deadline && $ticket->tester_suggested_price, 422, 'No tester proposal to accept.');

        $this->finalizeAgreement($ticket, $ticket->tester_suggested_deadline, $ticket->tester_suggested_price, $user, 'tester');

        $action = $ticket->is_single_purchase ? 'industor_accept_single' : 'industor_accept';
        $ticket = $this->transition($ticket, $action, changedBy: $user);

        $this->notifyPostAgreement($ticket);

        return response()->json($ticket->fresh(['reviewer', 'deadlineNegotiations.creator', 'histories', 'priceHistory']));
    }

    public function industorCounter(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('industor'), 403, 'Only the industor can counter proposals.');

        $data = $request->validate([
            'counter_deadline' => 'required|date|after:now',
            'counter_price' => 'required|numeric|min:0',
            'reason' => 'nullable|string',
        ]);

        $ticket = Ticket::where('id', $id)->where('industor_id', $user->id)
            ->where('status', Ticket::STATUS_WAITING_INDUSTOR_APPROVAL)->firstOrFail();

        $this->resolveLatestProposal($ticket, 'tester', 'rejected');

        $ticket->update([
            'industor_counter_deadline' => $data['counter_deadline'],
            'industor_counter_price' => $data['counter_price'],
            'tester_suggested_deadline' => null,
            'tester_suggested_price' => null,
            'negotiation_status' => 'waiting_tester_review',
            'current_negotiation_round' => $ticket->current_negotiation_round + 1,
        ]);

        $this->createProposal($ticket, 'industor', $data['counter_deadline'], $data['counter_price'], $data['reason'] ?? null, $user);

        $ticket = $this->transition($ticket, 'industor_counter', changedBy: $user);

        $this->notifyRole('tester', 'ticket.counter_received', 'Industor sent a counter-proposal', [
            'ticket_id' => $ticket->id,
            'deadline' => $ticket->industor_counter_deadline,
            'price' => $ticket->industor_counter_price,
            'reason' => $data['reason'] ?? null,
        ]);

        return response()->json($ticket->fresh(['deadlineNegotiations.creator', 'histories']));
    }

    public function testerAccept(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('tester'), 403, 'Only testers can accept counter-proposals.');

        $ticket = Ticket::where('id', $id)
            ->where('status', Ticket::STATUS_WAITING_TESTER_REVIEW)->firstOrFail();
        abort_unless($ticket->industor_counter_deadline && $ticket->industor_counter_price, 422, 'No industor counter to accept.');

        $this->finalizeAgreement($ticket, $ticket->industor_counter_deadline, $ticket->industor_counter_price, $user, 'industor');

        $action = $ticket->is_single_purchase ? 'tester_accept_single' : 'tester_accept';
        $ticket = $this->transition($ticket, $action, changedBy: $user);

        $this->notifyPostAgreement($ticket);

        return response()->json($ticket->fresh(['reviewer', 'deadlineNegotiations.creator', 'histories', 'priceHistory']));
    }

    public function testerAcceptInitial(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('tester'), 403, 'Only testers can accept proposals.');

        $ticket = Ticket::where('id', $id)
            ->where('status', Ticket::STATUS_PENDING_TESTER_REVIEW)->firstOrFail();
        abort_unless($ticket->industor_expected_deadline && $ticket->industor_expected_price, 422, 'No industor proposal to accept.');

        $this->finalizeAgreement($ticket, $ticket->industor_expected_deadline, $ticket->industor_expected_price, $user, 'industor');

        $action = $ticket->is_single_purchase ? 'tester_accept_initial_single' : 'tester_accept_initial';
        $ticket = $this->transition($ticket, $action, changedBy: $user);

        $this->notifyPostAgreement($ticket);

        return response()->json($ticket->fresh(['reviewer', 'deadlineNegotiations.creator', 'histories', 'priceHistory']));
    }

    public function cancelNegotiation(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('industor') || $user->hasRole('tester'), 403, 'Only industors or testers can cancel negotiations.');

        $data = $request->validate(['reason' => 'nullable|string']);

        $query = Ticket::where('id', $id)->whereIn('status', [
            Ticket::STATUS_PENDING_TESTER_REVIEW,
            Ticket::STATUS_WAITING_INDUSTOR_APPROVAL,
            Ticket::STATUS_WAITING_TESTER_REVIEW,
        ]);

        if ($user->hasRole('industor')) {
            $query->where('industor_id', $user->id);
        }

        $ticket = $query->firstOrFail();

        $rejectedStatus = $user->hasRole('industor')
            ? Ticket::STATUS_REJECTED_BY_INDUSTOR
            : Ticket::STATUS_REJECTED_BY_TESTER;

        $ticket->update([
            'status' => $rejectedStatus,
            'negotiation_status' => 'rejected',
            'rejection_reason' => $data['reason'] ?? null,
        ]);

        $ticket->histories()->create([
            'from_status' => $ticket->status,
            'to_status' => $rejectedStatus,
            'changed_by' => $user->id,
            'note' => 'Negotiation cancelled by '.$user->role->name.($data['reason'] ? ': '.$data['reason'] : ''),
        ]);

        $notifyUserId = $user->hasRole('industor') ? null : $ticket->industor_id;
        if ($user->hasRole('industor')) {
            $this->notifyRole('tester', 'ticket.negotiation_cancelled', 'Industor cancelled the negotiation', [
                'ticket_id' => $ticket->id,
                'reason' => $data['reason'] ?? null,
            ]);
        } else {
            $this->notify($ticket->industor_id, 'ticket.negotiation_cancelled', 'Tester cancelled the negotiation', [
                'ticket_id' => $ticket->id,
                'reason' => $data['reason'] ?? null,
            ]);
        }

        return response()->json($ticket->fresh(['histories']));
    }

    public function uploadRequirement(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('industor'), 403, 'Only the industor can upload project files.');

        $request->validate([
            'file' => 'required|file|mimes:pdf,png,jpg,jpeg,zip|max:20480',
        ]);

        $ticket = Ticket::where('id', $id)->where('industor_id', $user->id)->firstOrFail();
        abort_unless(in_array($ticket->status, [
            Ticket::STATUS_PENDING_TESTER_REVIEW,
            Ticket::STATUS_WAITING_INDUSTOR_APPROVAL,
            Ticket::STATUS_WAITING_TESTER_REVIEW,
            Ticket::STATUS_ACCEPTED,
            Ticket::STATUS_IN_PROGRESS,
            Ticket::STATUS_AWAITING_QA,
            Ticket::STATUS_REJECTED_QA,
        ]), 422, 'Project files can only be attached during negotiation.');

        $attachment = $this->storeAttachment($ticket, $user, $request->file('file'), 'requirement');

        return response()->json($attachment->load('uploadedBy'), 201);
    }

    public function accept(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('designer'), 403, 'Only designers can accept tickets.');

        $updated = Ticket::where('id', $id)
            ->where('status', Ticket::STATUS_APPROVED_BY_TESTER)
            ->whereNull('designer_id')
            ->update([
                'designer_id' => $user->id,
                'status' => Ticket::STATUS_ACCEPTED,
                'accepted_at' => now(),
            ]);

        abort_if(! $updated, 409, 'Ticket already accepted by another designer.');

        $ticket = Ticket::findOrFail($id);
        $ticket->histories()->create([
            'from_status' => Ticket::STATUS_APPROVED_BY_TESTER,
            'to_status' => Ticket::STATUS_ACCEPTED,
            'changed_by' => $user->id,
            'note' => 'Ticket accepted by designer',
        ]);

        $this->notify($ticket->industor_id, 'ticket.accepted', 'A designer accepted your ticket', [
            'ticket_id' => $ticket->id,
            'designer_id' => $user->id,
            'designer' => $user->name,
        ]);

        return response()->json($ticket->fresh(['designer', 'histories']));
    }

    public function requestModification(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('designer'), 403);

        $data = $request->validate(['description' => 'required|string']);

        $ticket = Ticket::where('id', $id)->where('designer_id', $user->id)->firstOrFail();
        abort_unless($ticket->status === Ticket::STATUS_ACCEPTED, 422, 'Can only request modifications on an accepted ticket.');

        $mod = TicketModificationRequest::create([
            'ticket_id' => $ticket->id,
            'designer_id' => $user->id,
            'description' => $data['description'],
            'status' => 'pending',
        ]);

        $ticket->update(['status' => Ticket::STATUS_MODIFICATION_REQUESTED]);
        $ticket->histories()->create([
            'from_status' => Ticket::STATUS_ACCEPTED,
            'to_status' => Ticket::STATUS_MODIFICATION_REQUESTED,
            'changed_by' => $user->id,
            'note' => 'Modification requested',
        ]);

        $this->notify($ticket->industor_id, 'ticket.modification_requested', 'Designer requested modifications', [
            'ticket_id' => $ticket->id,
            'modification_id' => $mod->id,
        ]);

        return response()->json($ticket->fresh(['modificationRequests', 'histories']));
    }

    public function approveModification(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('industor'), 403);

        $ticket = Ticket::where('id', $id)->where('industor_id', $user->id)->firstOrFail();
        abort_unless($ticket->status === Ticket::STATUS_MODIFICATION_REQUESTED, 422, 'Ticket is not awaiting modification approval.');

        $mod = $ticket->modificationRequests()->where('status', 'pending')->latest('id')->first();
        $mod?->update(['status' => 'approved', 'industor_response' => 'Approved', 'handled_at' => now()]);

        $ticket = $this->transition($ticket, 'resume_after_mod', changedBy: $user);

        $this->notify($ticket->designer_id, 'ticket.modification.approved', 'Your modification request was approved', [
            'ticket_id' => $ticket->id,
        ]);

        return response()->json($ticket->fresh(['modificationRequests', 'histories']));
    }

    public function rejectModification(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('industor'), 403);

        $data = $request->validate(['industor_response' => 'nullable|string']);
        $ticket = Ticket::where('id', $id)->where('industor_id', $user->id)->firstOrFail();
        abort_unless($ticket->status === Ticket::STATUS_MODIFICATION_REQUESTED, 422, 'Ticket is not awaiting modification approval.');

        $mod = $ticket->modificationRequests()->where('status', 'pending')->latest('id')->first();
        $mod?->update(['status' => 'rejected', 'industor_response' => $data['industor_response'] ?? 'Rejected', 'handled_at' => now()]);

        $ticket->update(['status' => Ticket::STATUS_APPROVED_BY_TESTER, 'designer_id' => null, 'accepted_at' => null]);
        $ticket->histories()->create([
            'from_status' => Ticket::STATUS_MODIFICATION_REQUESTED,
            'to_status' => Ticket::STATUS_APPROVED_BY_TESTER,
            'changed_by' => $user->id,
            'note' => 'Modification rejected; ticket reopened',
        ]);

        $this->notify($ticket->designer_id, 'ticket.modification.rejected', 'Your modification request was rejected', [
            'ticket_id' => $ticket->id,
        ]);

        return response()->json($ticket->fresh(['designer', 'histories']));
    }

    public function setDeadline(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('designer'), 403, 'Only designers can set deadlines.');

        $data = $request->validate(['deadline' => 'required|date|after:now']);

        $ticket = Ticket::where('id', $id)->where('designer_id', $user->id)->firstOrFail();

        $ticket = $this->transition($ticket, 'set_deadline', function (Ticket $t) use ($data) {
            $t->deadline = $data['deadline'];
        }, changedBy: $user);

        $this->notify($ticket->industor_id, 'ticket.deadline_set', 'Designer set a delivery deadline', [
            'ticket_id' => $ticket->id,
            'deadline' => $ticket->deadline,
        ]);

        return response()->json($ticket->fresh(['designer', 'histories']));
    }

    public function upload(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('designer'), 403, 'Only designers can upload deliverables.');

        $request->validate([
            'files' => 'required|array|min:1|max:10',
            'files.*' => 'required|file|mimes:pdf,png,jpg,jpeg|max:20480',
            'notes' => 'nullable|string|max:1000',
        ]);

        $ticket = Ticket::where('id', $id)->where('designer_id', $user->id)->firstOrFail();
        abort_unless(in_array($ticket->status, [Ticket::STATUS_ACCEPTED, Ticket::STATUS_IN_PROGRESS, Ticket::STATUS_REJECTED_QA]), 422, 'Cannot upload in current status.');

        return DB::transaction(function () use ($ticket, $user, $request) {
            $from = $ticket->status;
            $isLate = $ticket->deadline !== null
                && $ticket->deadline < now()
                && ! in_array($ticket->status, [Ticket::STATUS_COMPLETED, Ticket::STATUS_CANCELLED]);

            $ticket = $this->transition($ticket, 'upload', function (Ticket $t) use ($isLate) {
                $t->is_late = $t->is_late || $isLate;
            }, changedBy: $user);

            $attachments = [];
            foreach ($request->file('files') as $file) {
                $attachments[] = $this->storeAttachment($ticket, $user, $file);
            }

            $note = $request->notes ?: ($isLate
                ? 'Deliverable uploaded after deadline; awaiting QA'
                : 'Deliverable uploaded; awaiting QA');

            $ticket->histories()->create([
                'from_status' => $from,
                'to_status' => Ticket::STATUS_AWAITING_QA,
                'changed_by' => $user->id,
                'note' => $note,
            ]);

            $this->notify($ticket->industor_id, 'ticket.uploaded', 'New deliverables have been uploaded', [
                'ticket_id' => $ticket->id,
            ]);
            $this->notifyRole('tester', 'ticket.awaiting_qa', 'New design awaiting review', [
                'ticket_id' => $ticket->id,
            ]);

            return response()->json($ticket->fresh(['attachments', 'histories']), 201);
        });
    }

    public function qaClaim(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('tester'), 403, 'Only testers can claim QA reviews.');

        $ticket = Ticket::where('id', $id)->where('status', Ticket::STATUS_AWAITING_QA)->firstOrFail();

        abort_if($ticket->tester_id && $ticket->tester_id !== $user->id, 422, 'Ticket already claimed by another tester.');

        $ticket->update(['tester_id' => $user->id, 'qa_claimed_at' => now()]);

        $this->notify($ticket->industor_id, 'ticket.qa_claimed', 'Your design is under QA review', [
            'ticket_id' => $ticket->id,
        ]);

        return response()->json($ticket->fresh(['tester', 'attachments']));
    }

    public function qaApprove(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('tester'), 403);

        $ticket = Ticket::where('id', $id)->where('status', Ticket::STATUS_AWAITING_QA)->firstOrFail();
        $this->ensureTester($user, $ticket);

        $ticket = $this->transition($ticket, 'qa_approve', changedBy: $user);

        $this->notify($ticket->industor_id, 'ticket.completed', 'Your design was approved and delivered', [
            'ticket_id' => $ticket->id,
        ]);
        $this->notify($ticket->designer_id, 'ticket.completed', 'Your design was approved by QA', [
            'ticket_id' => $ticket->id,
        ]);

        return response()->json($ticket->fresh(['tester', 'histories']));
    }

    public function qaReject(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('tester'), 403);

        $data = $request->validate([
            'rejection_reason' => 'required|string',
            'penalty' => 'nullable|numeric|min:0',
            'penalty_reason' => 'nullable|string',
        ]);

        $ticket = Ticket::where('id', $id)->where('status', Ticket::STATUS_AWAITING_QA)->firstOrFail();
        $this->ensureTester($user, $ticket);

        $ticket = $this->transition($ticket, 'qa_reject', function (Ticket $t) use ($data) {
            $t->rejection_reason = $data['rejection_reason'];
            if (isset($data['penalty'])) {
                $t->penalty = $data['penalty'];
                $t->penalty_reason = $data['penalty_reason'] ?? null;
            }
        }, changedBy: $user);

        $this->notify($ticket->designer_id, 'ticket.qa_rejected', 'Your design was rejected by QA - please revise', [
            'ticket_id' => $ticket->id,
            'reason' => $data['rejection_reason'],
            'penalty' => $ticket->penalty,
        ]);

        return response()->json($ticket->fresh(['tester', 'histories']));
    }

    public function cancel(Request $request, $id)
    {
        $user = $request->user();
        $ticket = Ticket::findOrFail($id);

        $isOwner = $ticket->industor_id === $user->id;
        abort_unless($isOwner || $user->hasRole('admin'), 403, 'You may only cancel your own tickets.');

        // Industors can only cancel within first 10% of deadline
        if ($isOwner && $ticket->deadline && $ticket->created_at) {
            $total = $ticket->deadline->diffInSeconds($ticket->created_at);
            $elapsed = now()->diffInSeconds($ticket->created_at);
            if ($total > 0 && ($elapsed / $total) > 0.10) {
                abort(422, 'Cancellation is only allowed within the first 10% of the deadline period.');
            }
        }

        return DB::transaction(function () use ($ticket, $user) {
            $from = $ticket->status;
            $ticket = $this->transition($ticket, 'cancel', changedBy: $user);

            if ($from === Ticket::STATUS_APPROVED_BY_TESTER && $ticket->subscription_id) {
                $sub = $ticket->subscription()->lockForUpdate()->first();
                $sub?->increment('tickets_remaining');
            }

            $other = $ticket->designer_id ?? $ticket->tester_id;
            if ($other) {
                $this->notify($other, 'ticket.cancelled', 'A ticket you were working on was cancelled', [
                    'ticket_id' => $ticket->id,
                ]);
            }

            return response()->json($ticket->fresh(['histories']));
        });
    }

    public function publish(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('industor'), 403);

        $ticket = Ticket::where('id', $id)->where('industor_id', $user->id)->firstOrFail();

        abort_if($ticket->status !== Ticket::STATUS_COMPLETED, 422, 'Only completed tickets can be published.');
        abort_if($ticket->is_published_to_store, 422, 'Ticket is already published.');
        abort_if(! $ticket->can_publish_to_store, 403, 'Your plan does not allow publishing to the store.');

        $data = $request->validate([
            'title' => 'required|string|max:200',
            'description' => 'nullable|string',
            'price' => 'nullable|numeric|min:0',
            'attachment_id' => 'nullable|exists:ticket_attachments,id',
        ]);

        $listing = StoreListing::create([
            'ticket_id' => $ticket->id,
            'industor_id' => $user->id,
            'attachment_id' => $data['attachment_id'] ?? $ticket->attachments()->latest('id')->value('id'),
            'title' => $data['title'],
            'description' => $data['description'] ?? null,
            'price' => $data['price'] ?? 0,
            'status' => 'active',
        ]);

        $ticket->update(['is_published_to_store' => true, 'store_listing_id' => $listing->id]);

        return response()->json($ticket->fresh(['storeListing', 'attachments']), 201);
    }

    public function unpublish(Request $request, $id)
    {
        $user = $request->user();
        $ticket = Ticket::where('id', $id)->where('industor_id', $user->id)->firstOrFail();
        abort_if(! $ticket->is_published_to_store, 422, 'Ticket is not published.');

        $ticket->storeListing?->delete();
        $ticket->update(['is_published_to_store' => false, 'store_listing_id' => null]);

        return response()->json($ticket->fresh());
    }

    public function downloadAttachment(Request $request, $id, $attachmentId)
    {
        $user = $request->user();
        $ticket = Ticket::findOrFail($id);
        $this->authorizeView($user, $ticket);

        $attachment = $ticket->attachments()->findOrFail($attachmentId);
        abort_unless(Storage::disk('public')->exists($attachment->file_path), 404, 'File not found.');

        return response()->download(Storage::disk('public')->path($attachment->file_path), $attachment->file_name);
    }

    public function destroyAttachment(Request $request, $id, $attachmentId)
    {
        $user = $request->user();
        $ticket = Ticket::findOrFail($id);
        $this->authorizeView($user, $ticket);

        $attachment = $ticket->attachments()->findOrFail($attachmentId);

        if ($attachment->uploaded_by !== $user->id && ! $user->hasRole('admin')) {
            abort(403, 'You can only delete your own files.');
        }

        if (Storage::disk('public')->exists($attachment->file_path)) {
            Storage::disk('public')->delete($attachment->file_path);
        }

        $attachment->delete();

        return response()->json(['message' => 'File deleted.']);
    }

    public function storeDesignerProduct(Request $request)
    {
        $user = $request->user();
        abort_unless($user->hasRole('designer'), 403, 'Only designers can create products.');

        $data = $request->validate([
            'name' => 'required|string|max:255',
            'slug' => 'required|string|max:255|unique:products',
            'description' => 'nullable|string',
            'price_egp' => 'nullable|numeric|min:0',
            'price_usd' => 'nullable|numeric|min:0',
            'platform_commission_egp' => 'nullable|numeric|min:0',
            'platform_commission_usd' => 'nullable|numeric|min:0',
            'designer_price_egp' => 'nullable|numeric|min:0',
            'designer_price_usd' => 'nullable|numeric|min:0',
            'status' => 'nullable|string|max:50',
            'material' => 'nullable|string|max:100',
            'manufacturing_method' => 'nullable|string|max:100',
            'tags' => 'nullable|array',
            'tags.*' => 'string|max:50',
            'images' => 'nullable|array|max:2',
            'images.*' => 'file|mimes:jpg,jpeg,png,webp,gif|max:5120',
            'design_file' => 'nullable|file|mimes:pdf,zip,ai,eps,svg,dxf,psd,png,jpg,jpeg|max:51200',
        ]);

        $product = Product::create(array_merge($data, [
            'designer_id' => $user->id,
            'product_type' => 'digital',
            'status' => $data['status'] ?? 'pending_tester_review',
            'publish_date' => now(),
        ]));

        if ($request->hasFile('images')) {
            $optimizer = app(ImageOptimizer::class);
            foreach ($request->file('images') as $i => $image) {
                $path = $optimizer->optimizeUploadedFile($image, "products/{$product->id}");
                $product->images()->create([
                    'image_url' => $path,
                    'sort_order' => $i,
                ]);
            }
        }

        if ($request->hasFile('design_file')) {
            $path = $request->file('design_file')->store("products/{$product->id}/design", 'public');
            $product->update(['design_file_path' => $path]);
        }

        return response()->json($product->load('images', 'inventory'), 201);
    }

    protected function transition(Ticket $ticket, string $action, ?\Closure $mutate = null, ?User $changedBy = null): Ticket
    {
        $from = $ticket->status;
        $to = self::TRANSITIONS[$action][$from] ?? null;
        abort_if(! $to, 422, "Cannot {$action} a ticket in status ({$from}).");

        if ($mutate) {
            $mutate($ticket);
        }

        $update = ['status' => $to];
        if (isset(self::STATUS_TIMESTAMP[$to])) {
            $update[self::STATUS_TIMESTAMP[$to]] = now();
        }
        $ticket->update($update);

        $ticket->histories()->create([
            'from_status' => $from,
            'to_status' => $to,
            'changed_by' => $changedBy?->id ?? auth()->id(),
        ]);

        return $ticket->fresh();
    }

    protected function ensureTester(User $user, Ticket $ticket): void
    {
        abort_if($ticket->tester_id && $ticket->tester_id !== $user->id, 403, 'You are not the assigned tester for this ticket.');
    }

    protected function applyPriceVisibility(User $user, array $data): array
    {
        $isIndustor = $user->hasRole('industor');
        $isDesigner = $user->hasRole('designer');

        if ($isIndustor) {
            unset($data['designer_price']);
        }

        if ($isDesigner) {
            unset($data['industor_price'], $data['original_price'], $data['price']);
        }

        if (! empty($data['price_history'])) {
            foreach ($data['price_history'] as &$ph) {
                if ($isIndustor) {
                    unset($ph['designer_price']);
                }
                if ($isDesigner) {
                    unset($ph['industor_price'], $ph['original_price']);
                }
            }
            unset($ph);
        }

        return $data;
    }

    protected function authorizeView(User $user, Ticket $ticket): void
    {
        if ($user->hasRole('admin')) {
            return;
        }
        $allowed = $ticket->industor_id === $user->id
            || $ticket->tester_id === $user->id
            || $ticket->designer_id === $user->id
            || ($user->hasRole('designer') && $ticket->status === Ticket::STATUS_APPROVED_BY_TESTER)
            || ($user->hasRole('tester') && in_array($ticket->status, [
                Ticket::STATUS_PENDING_TESTER_REVIEW,
                Ticket::STATUS_WAITING_INDUSTOR_APPROVAL,
                Ticket::STATUS_WAITING_TESTER_REVIEW,
                Ticket::STATUS_PENDING_PAYMENT,
                Ticket::STATUS_APPROVED_BY_TESTER,
            ]));

        abort_unless($allowed, 403, 'You are not authorized to view this ticket.');
    }

    protected function storeAttachment(Ticket $ticket, User $user, UploadedFile $file, string $kind = 'delivery'): TicketAttachment
    {
        $path = $file->store("tickets/{$ticket->id}", 'public');

        return TicketAttachment::create([
            'ticket_id' => $ticket->id,
            'uploaded_by' => $user->id,
            'file_name' => $file->getClientOriginalName(),
            'file_path' => $path,
            'mime_type' => $file->getMimeType(),
            'file_size' => $file->getSize(),
            'kind' => $kind,
        ]);
    }

    protected function createProposal(Ticket $ticket, string $proposedBy, $deadline, $price, ?string $reason, User $by): TicketDeadlineNegotiation
    {
        $negotiation = TicketDeadlineNegotiation::create([
            'ticket_id' => $ticket->id,
            'round_number' => $ticket->current_negotiation_round ?? 0,
            'proposed_by' => $proposedBy,
            'proposed_deadline' => $deadline,
            'proposed_price' => $price,
            'reason' => $reason,
            'status' => 'pending',
            'created_by' => $by->id,
        ]);

        $this->syncNegotiationHistory($ticket);

        return $negotiation;
    }

    protected function resolveLatestProposal(Ticket $ticket, string $proposedBy, string $status, ?string $reason = null): void
    {
        $negotiation = $ticket->deadlineNegotiations()
            ->where('proposed_by', $proposedBy)
            ->where('status', 'pending')
            ->latest('id')
            ->first();

        if ($negotiation) {
            $negotiation->update([
                'status' => $status,
                'reason' => $reason ?? $negotiation->reason,
            ]);
        }

        $this->syncNegotiationHistory($ticket);
    }

    protected function syncNegotiationHistory(Ticket $ticket): void
    {
        $ticket->load('deadlineNegotiations');

        $history = $ticket->deadlineNegotiations
            ->sortBy('id')
            ->map(fn ($n) => [
                'round_number' => $n->round_number,
                'proposed_by' => $n->proposed_by,
                'proposed_deadline' => $n->proposed_deadline?->toIso8601String(),
                'proposed_price' => $n->proposed_price !== null ? (float) $n->proposed_price : null,
                'reason' => $n->reason,
                'status' => $n->status,
                'created_by' => $n->created_by,
                'created_at' => $n->created_at?->toIso8601String(),
            ])
            ->values()
            ->toArray();

        $ticket->deadline_negotiation_history = $history;
        $ticket->save();
    }

    protected function finalizeAgreement(Ticket $ticket, $deadline, $price, User $user, string $acceptedFrom): void
    {
        $finalPrice = round((float) $price, 2);
        $industorPrice = $finalPrice;
        $designerPrice = round($finalPrice * 0.70, 2);

        $ticket->update([
            'final_deadline' => $deadline,
            'final_price' => $finalPrice,
            'deadline' => $deadline,
            'price' => $finalPrice,
            'original_price' => $finalPrice,
            'industor_price' => $industorPrice,
            'designer_price' => $designerPrice,
            'urgent_price_applied' => false,
            'price_updated_at' => now(),
            'reviewed_by' => $user->id,
            'negotiation_status' => 'approved',
        ]);

        $this->resolveLatestProposal($ticket, $acceptedFrom, 'accepted');

        TicketPriceHistory::create([
            'ticket_id' => $ticket->id,
            'original_price' => $finalPrice,
            'industor_price' => $industorPrice,
            'designer_price' => $designerPrice,
            'change_reason' => 'negotiation_agreed',
        ]);
    }

    protected function notifyPostAgreement(Ticket $ticket): void
    {
        if ($ticket->is_single_purchase) {
            $this->notify($ticket->industor_id, 'ticket.negotiation_agreed', 'Price & deadline agreed - payment required', [
                'ticket_id' => $ticket->id,
                'price' => $ticket->industor_price,
                'deadline' => $ticket->final_deadline,
            ]);
        } else {
            $this->notify($ticket->industor_id, 'ticket.negotiation_agreed', 'Price & deadline agreed - ticket is now available', [
                'ticket_id' => $ticket->id,
                'price' => $ticket->industor_price,
                'deadline' => $ticket->final_deadline,
            ]);

            $this->notifyRole('designer', 'ticket.opened', 'New ticket available', [
                'ticket_id' => $ticket->id,
                'title' => $ticket->title,
            ]);
        }
    }

    protected function notify(int $userId, string $type, string $title, array $data = []): void
    {
        Notification::create([
            'user_id' => $userId,
            'type' => $type,
            'title' => $title,
            'data' => $data,
        ]);
    }

    protected function notifyRole(string $roleName, string $type, string $title, array $data = []): void
    {
        User::whereHas('role', fn ($q) => $q->where('name', $roleName))->get(['id'])
            ->each(fn ($u) => $this->notify($u->id, $type, $title, $data));
    }

    public function myDesignerProducts()
    {
        $products = Product::with('images')
            ->where('designer_id', request()->user()->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($products);
    }

    public function showDesignerProduct($id)
    {
        $product = Product::with('images')
            ->where('designer_id', request()->user()->id)
            ->findOrFail($id);

        return response()->json($product);
    }

    public function updateDesignerProduct(Request $request, $id)
    {
        $user = $request->user();
        $product = Product::where('designer_id', $user->id)->findOrFail($id);

        abort_unless($product->status === 'modification_requested', 422,
            'Only products returned for modification can be resubmitted.');

        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'slug' => 'sometimes|string|max:255|unique:products,slug,'.$id,
            'description' => 'nullable|string',
            'price_egp' => 'nullable|numeric|min:0',
            'price_usd' => 'nullable|numeric|min:0',
            'platform_commission_egp' => 'nullable|numeric|min:0',
            'platform_commission_usd' => 'nullable|numeric|min:0',
            'designer_price_egp' => 'nullable|numeric|min:0',
            'designer_price_usd' => 'nullable|numeric|min:0',
            'material' => 'nullable|string|max:100',
            'manufacturing_method' => 'nullable|string|max:100',
            'tags' => 'nullable|array',
            'tags.*' => 'string|max:50',
            'images' => 'nullable|array',
            'images.*' => 'file|mimes:jpg,jpeg,png,webp,gif|max:5120',
            'design_file' => 'nullable|file|mimes:pdf,zip,ai,eps,svg,dxf,psd,png,jpg,jpeg|max:51200',
        ]);

        $product->update(array_merge($data, [
            'status' => 'pending_tester_review',
        ]));

        if ($request->hasFile('images')) {
            $request->validate(['images' => 'nullable|array|max:2']);
            $product->images()->delete();
            $optimizer = app(ImageOptimizer::class);
            foreach ($request->file('images') as $i => $image) {
                $path = $optimizer->optimizeUploadedFile($image, "products/{$product->id}");
                $product->images()->create([
                    'image_url' => $path,
                    'sort_order' => $i,
                ]);
            }
        }

        if ($request->hasFile('design_file')) {
            $path = $request->file('design_file')->store("products/{$product->id}/design", 'public');
            $product->update(['design_file_path' => $path]);
        }

        return response()->json($product->fresh()->load('images'));
    }
}
