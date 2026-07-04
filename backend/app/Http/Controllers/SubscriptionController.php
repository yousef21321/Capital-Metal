<?php

namespace App\Http\Controllers;

use App\Models\SubscriptionPlan;
use App\Models\UserSubscription;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SubscriptionController extends Controller
{
    public function plans()
    {
        return response()->json(SubscriptionPlan::orderBy('price')->get());
    }

    public function mine(Request $request)
    {
        $sub = $request->user()->activeSubscription()->with('plan', 'approver')->first();

        if (!$sub) {
            return response()->json(['message' => 'No active subscription.'], 404);
        }

        return response()->json([
            'subscription'         => $sub,
            'tickets_remaining'   => $sub->tickets_remaining,
            'tickets_used'        => $sub->tickets_used,
            'can_publish_to_store' => $sub->canPublishToStore(),
            'is_active'           => $sub->isActive(),
            'approval_status'    => $sub->approval_status,
            'expires_at'         => $sub->end_date,
        ]);
    }

    public function subscribe(Request $request)
    {
        $user = $request->user();
        abort_unless($user->hasRole('industor'), 403, 'Only industors can subscribe to plans.');

        $data = $request->validate(['plan_id' => 'required|exists:subscription_plans,id']);
        $plan = SubscriptionPlan::findOrFail($data['plan_id']);

        return DB::transaction(function () use ($user, $plan) {
            $existing = $user->activeSubscription()->lockForUpdate()->first();

            if ($existing && $existing->approval_status === 'approved' && $existing->tickets_remaining > 0) {
                abort(422, 'You already have an approved subscription with remaining tickets.');
            }

            // Expire previous subscription whether pending (unpaid) or already used up
            if ($existing) {
                $existing->update(['status' => 'expired']);
            }

            $start = now();
            $end = $plan->duration_days ? $start->copy()->addDays($plan->duration_days) : null;

            $subscription = UserSubscription::create([
                'user_id'           => $user->id,
                'plan_id'           => $plan->id,
                'start_date'        => $start,
                'end_date'          => $end,
                'status'            => 'active',
                'approval_status'   => 'pending',
                'tickets_remaining' => $plan->ticket_limit,
                'tickets_used'      => 0,
            ]);

            $this->notifyRole('admin', 'subscription.pending', 'New subscription awaiting approval', [
                'subscription_id' => $subscription->id,
                'user_id'         => $user->id,
            ]);

            return response()->json($subscription->load('plan'), 201);
        });
    }

    public function pendingApprovals(Request $request)
    {
        $user = $request->user();
        abort_unless($user->hasRole('admin'), 403);

        $subs = UserSubscription::with(['user', 'plan'])
            ->where('approval_status', 'pending')
            ->latest('start_date')
            ->paginate($request->per_page ?? 20);

        return response()->json($subs);
    }

    public function approve(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('admin'), 403);

        $sub = UserSubscription::where('approval_status', 'pending')->findOrFail($id);

        $sub->update([
            'approval_status' => 'approved',
            'approved_by'    => $user->id,
            'approved_at'    => now(),
        ]);

        $this->notify($sub->user_id, 'subscription.approved', 'Your subscription was approved', [
            'subscription_id' => $sub->id,
        ]);

        return response()->json($sub->fresh(['user', 'plan', 'approver']));
    }

    public function reject(Request $request, $id)
    {
        $user = $request->user();
        abort_unless($user->hasRole('admin'), 403);

        $data = $request->validate(['rejection_reason' => 'nullable|string']);
        $sub = UserSubscription::where('approval_status', 'pending')->findOrFail($id);

        $sub->update([
            'approval_status'  => 'rejected',
            'approved_by'      => $user->id,
            'approved_at'      => now(),
            'rejection_reason' => $data['rejection_reason'] ?? null,
            'status'           => 'cancelled',
        ]);

        $this->notify($sub->user_id, 'subscription.rejected', 'Your subscription was rejected', [
            'subscription_id' => $sub->id,
            'reason'          => $data['rejection_reason'] ?? null,
        ]);

        return response()->json($sub->fresh(['user', 'plan', 'approver']));
    }

    protected function notify(int $userId, string $type, string $title, array $data = []): void
    {
        \App\Models\Notification::create([
            'user_id' => $userId,
            'type'    => $type,
            'title'   => $title,
            'data'    => $data,
        ]);
    }

    protected function notifyRole(string $roleName, string $type, string $title, array $data = []): void
    {
        User::whereHas('role', fn ($q) => $q->where('name', $roleName))->get(['id'])
            ->each(fn ($u) => $this->notify($u->id, $type, $title, $data));
    }
}
