<?php

namespace Database\Seeders;

use App\Models\Notification;
use App\Models\Product;
use App\Models\Role;
use App\Models\StoreListing;
use App\Models\SubscriptionPlan;
use App\Models\Ticket;
use App\Models\TicketAttachment;
use App\Models\TicketModificationRequest;
use App\Models\TicketStatusHistory;
use App\Models\User;
use App\Models\UserSubscription;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;

class TicketWorkflowSeeder extends Seeder
{
    public function run(): void
    {
        $adminRole = Role::where('name', 'admin')->first();
        $testerRole = Role::where('name', 'tester')->first();
        $designerRole = Role::where('name', 'designer')->first();
        $industorRole = Role::where('name', 'industor')->first();

        $basic = SubscriptionPlan::updateOrCreate(
            ['name' => 'Basic'],
            ['price' => 0, 'currency' => 'EGP', 'duration_days' => 30, 'ticket_limit' => 5, 'can_publish_to_store' => false]
        );
        $premium = SubscriptionPlan::updateOrCreate(
            ['name' => 'Premium'],
            ['price' => 299, 'currency' => 'EGP', 'duration_days' => 30, 'ticket_limit' => 20, 'can_publish_to_store' => true]
        );
        $enterprise = SubscriptionPlan::updateOrCreate(
            ['name' => 'Enterprise'],
            ['price' => 999, 'currency' => 'EGP', 'duration_days' => 30, 'ticket_limit' => 100, 'can_publish_to_store' => true]
        );

        $admin = $this->createUser('admin@flfl.com', 'Admin', $adminRole);
        $tester1 = $this->createUser('tester1@flfl.com', 'Tester One', $testerRole);
        $tester2 = $this->createUser('tester2@flfl.com', 'Tester Two', $testerRole);

        $designer1 = $this->createUser('designer1@flfl.com', 'Designer Ahmed', $designerRole);
        $designer2 = $this->createUser('designer2@flfl.com', 'Designer Sara', $designerRole);
        $designer3 = $this->createUser('designer3@flfl.com', 'Designer Omar', $designerRole);

        $industor1 = $this->createUser('industor1@flfl.com', 'Industor Khaled', $industorRole);
        $industor2 = $this->createUser('industor2@flfl.com', 'Industor Mona', $industorRole);
        $industor3 = $this->createUser('industor3@flfl.com', 'Industor Ali', $industorRole);

        // Subscriptions with approval workflow
        $sub1 = $this->createSubscription($industor1, $premium, approvalStatus: 'approved', ticketsRemaining: 17, ticketsUsed: 3);
        $sub2 = $this->createSubscription($industor2, $enterprise, approvalStatus: 'approved', ticketsRemaining: 96, ticketsUsed: 4);
        $sub3pending = $this->createSubscription($industor3, $basic, approvalStatus: 'pending', ticketsRemaining: 5, ticketsUsed: 0);
        $sub3rejected = $this->createSubscription($industor3, $premium, approvalStatus: 'rejected', ticketsRemaining: 20, ticketsUsed: 0, status: 'cancelled');

        // Tickets across every status (new flow)
        $this->createTicket($industor1, $sub1, 'Logo design for new brand', 'Need a minimalist logo for a startup brand...', 'approved_by_tester');
        $this->createTicket($industor1, $sub1, 'Product packaging concept', 'Box design for premium tea product...', 'approved_by_tester');
        $this->createTicket($industor1, $sub1, 'Social media template pack', '10 Instagram post templates for marketing...', 'accepted', designer: $designer1);
        $this->createTicket($industor2, $sub2, 'Brochure tri-fold design', 'Marketing brochure for factory tour...', 'accepted', designer: $designer2);
        $this->createTicket($industor1, $sub1, '3D product render', 'Photorealistic render of a modern chair...', 'in_progress', designer: $designer3, withDeadline: true);
        $this->createTicket($industor2, $sub2, 'UI kit for mobile app', 'Complete Figma UI kit with 50 screens...', 'in_progress', designer: $designer1, withDeadline: true);
        $this->createTicket($industor1, $sub1, 'Vector icon set', '50 line-style icons for a dashboard...', 'awaiting_qa', designer: $designer2, tester: $tester1, withDeadline: true, withAttachment: true);
        $this->createTicket($industor2, $sub2, 'Brand guideline document', 'Full brand book with colors and fonts...', 'awaiting_qa', designer: $designer3, withDeadline: true, withAttachment: true);
        $this->createTicket($industor1, $sub1, 'Catalog layout design', '32-page product catalog...', 'completed', designer: $designer1, tester: $tester2, withDeadline: true, withAttachment: true);
        $this->createTicket($industor2, $sub2, 'Safety signage set', 'Industrial safety signs for a factory...', 'completed', designer: $designer3, tester: $tester1, withDeadline: true, withAttachment: true, publishToStore: true);
        $this->createTicket($industor1, $sub1, 'Rejected sample design', 'Test design that got rejected by QA...', 'rejected_qa', designer: $designer2, tester: $tester2, withDeadline: true, withAttachment: true, rejectionReason: 'Colors do not match brand guidelines. Please use the official palette.');

        // Ticket with modification request (awaiting industor approval)
        $modTicket = $this->createTicket($industor2, $sub2, 'Poster design for event', 'Event poster for a tech conference...', 'modification_requested', designer: $designer1);
        TicketModificationRequest::create([
            'ticket_id' => $modTicket->id,
            'designer_id' => $designer1->id,
            'description' => 'Please provide the event date, venue, and logo to include in the poster design.',
            'status' => 'pending',
        ]);

        // Designer standalone products (Path B)
        $this->createDesignerProduct($designer1, 'Modern Logo Pack', 'premium-logo-pack', 'A collection of 20 modern logo templates...', 499, 14.99);
        $this->createDesignerProduct($designer2, 'Icon Bundle Pro', 'icon-bundle-pro', '500 vector icons in multiple styles...', 299, 8.99);
        $this->createDesignerProduct($designer3, 'Brochure Templates', 'brochure-templates-vol1', '15 editable brochure templates...', 199, 5.99);

        // Notifications for all participants
        $this->createNotifications($industor1);
        $this->createNotifications($industor2);
        $this->createNotifications($tester1);
        $this->createNotifications($designer1);
        $this->createNotifications($admin);
    }

    private function createUser(string $email, string $name, ?Role $role): User
    {
        return User::firstOrCreate(
            ['email' => $email],
            [
                'name' => $name,
                'password' => 'password',
                'role_id' => $role?->id,
                'phone' => '010'.random_int(10000000, 99999999),
                'is_verified' => true,
                'is_active' => true,
            ]
        );
    }

    private function createSubscription(User $industor, SubscriptionPlan $plan, string $approvalStatus, int $ticketsRemaining, int $ticketsUsed, string $status = 'active'): UserSubscription
    {
        $data = [
            'user_id' => $industor->id,
            'plan_id' => $plan->id,
            'start_date' => now()->subDays(5),
            'end_date' => now()->addDays(25),
            'status' => $status,
            'approval_status' => $approvalStatus,
            'tickets_remaining' => $ticketsRemaining,
            'tickets_used' => $ticketsUsed,
        ];

        if ($approvalStatus === 'approved') {
            $admin = User::whereHas('role', fn ($q) => $q->where('name', 'admin'))->first();
            $data['approved_by'] = $admin?->id;
            $data['approved_at'] = now()->subDays(4);
        } elseif ($approvalStatus === 'rejected') {
            $admin = User::whereHas('role', fn ($q) => $q->where('name', 'admin'))->first();
            $data['approved_by'] = $admin?->id;
            $data['approved_at'] = now()->subDays(3);
            $data['rejection_reason'] = 'Please upgrade to a paid plan for production use.';
        }

        return UserSubscription::firstOrCreate(
            ['user_id' => $industor->id, 'plan_id' => $plan->id, 'approval_status' => $approvalStatus],
            $data
        );
    }

    private function createTicket(
        User $industor,
        UserSubscription $sub,
        string $title,
        string $description,
        string $status,
        ?User $tester = null,
        ?User $designer = null,
        bool $withDeadline = false,
        bool $withAttachment = false,
        bool $publishToStore = false,
        ?string $rejectionReason = null,
    ): Ticket {
        $now = now();
        $times = $this->statusTimestamps($status, $now);

        $ticket = Ticket::firstOrCreate(
            ['title' => $title, 'industor_id' => $industor->id],
            array_filter([
                'subscription_id' => $sub->id,
                'title' => $title,
                'description' => $description,
                'status' => $status,
                'tester_id' => $tester?->id,
                'designer_id' => $designer?->id,
                'deadline' => $withDeadline ? $now->copy()->addDays(3) : null,
                'reviewed_at' => $times['reviewed_at'] ?? null,
                'approved_at' => $times['approved_at'] ?? null,
                'assigned_at' => $times['assigned_at'] ?? null,
                'started_at' => $times['started_at'] ?? null,
                'uploaded_at' => $times['uploaded_at'] ?? null,
                'completed_at' => $times['completed_at'] ?? null,
                'accepted_at' => $times['accepted_at'] ?? null,
                'qa_claimed_at' => $times['qa_claimed_at'] ?? null,
                'rejection_reason' => $rejectionReason,
                'is_published_to_store' => $publishToStore,
            ], fn ($v) => ! is_null($v))
        );

        $this->createHistory($ticket, $industor, null, 'approved_by_tester', 'Ticket approved and opened for designers', $now->copy()->subHours(8));

        if (in_array($status, ['accepted', 'modification_requested', 'in_progress', 'awaiting_qa', 'completed', 'rejected_qa']) && $designer) {
            $this->createHistory($ticket, $designer, 'approved_by_tester', 'accepted', 'Ticket accepted by designer', $now->copy()->subHours(7));
        }
        if (in_array($status, ['in_progress', 'awaiting_qa', 'completed', 'rejected_qa']) && $designer) {
            $this->createHistory($ticket, $designer, 'accepted', 'in_progress', 'Deadline set, work started', $now->copy()->subHours(6));
        }
        if (in_array($status, ['awaiting_qa', 'completed', 'rejected_qa']) && $designer) {
            $this->createHistory($ticket, $designer, 'in_progress', 'awaiting_qa', 'Deliverable uploaded', $now->copy()->subHours(4));
        }
        if ($status === 'rejected_qa' && $tester) {
            $this->createHistory($ticket, $tester, 'awaiting_qa', 'rejected_qa', $rejectionReason ?? 'Rejected by QA', $now->copy()->subHours(2));
        }
        if ($status === 'completed' && $tester) {
            $this->createHistory($ticket, $tester, 'awaiting_qa', 'completed', 'Approved by QA', $now->copy()->subHour());
        }

        if ($withAttachment) {
            TicketAttachment::firstOrCreate(
                ['ticket_id' => $ticket->id, 'file_name' => 'delivery-'.$ticket->id.'.pdf'],
                [
                    'uploaded_by' => $designer?->id ?? $industor->id,
                    'file_name' => 'delivery-'.$ticket->id.'.pdf',
                    'file_path' => 'tickets/'.$ticket->id.'/delivery-'.$ticket->id.'.pdf',
                    'mime_type' => 'application/pdf',
                    'file_size' => random_int(50000, 500000),
                    'kind' => 'delivery',
                ]
            );
        }

        if ($publishToStore) {
            $listing = StoreListing::firstOrCreate(
                ['ticket_id' => $ticket->id],
                [
                    'industor_id' => $industor->id,
                    'attachment_id' => $ticket->attachments()->latest('id')->value('id'),
                    'title' => $title,
                    'description' => $description,
                    'price' => 199.00,
                    'status' => 'active',
                ]
            );
            $ticket->update(['store_listing_id' => $listing->id, 'is_published_to_store' => true]);
        }

        return $ticket;
    }

    private function statusTimestamps(string $status, Carbon $now): array
    {
        $map = [
            'accepted' => ['accepted_at' => $now->copy()->subHours(7)],
            'modification_requested' => ['accepted_at' => $now->copy()->subHours(7)],
            'in_progress' => ['accepted_at' => $now->copy()->subHours(7), 'started_at' => $now->copy()->subHours(6)],
            'awaiting_qa' => ['accepted_at' => $now->copy()->subHours(7), 'started_at' => $now->copy()->subHours(6), 'uploaded_at' => $now->copy()->subHours(4), 'qa_claimed_at' => $now->copy()->subHours(3)],
            'completed' => ['accepted_at' => $now->copy()->subHours(7), 'started_at' => $now->copy()->subHours(6), 'uploaded_at' => $now->copy()->subHours(4), 'qa_claimed_at' => $now->copy()->subHours(3), 'completed_at' => $now->copy()->subHour()],
            'rejected_qa' => ['accepted_at' => $now->copy()->subHours(7), 'started_at' => $now->copy()->subHours(6), 'uploaded_at' => $now->copy()->subHours(4), 'qa_claimed_at' => $now->copy()->subHours(3)],
        ];

        return $map[$status] ?? [];
    }

    private function createHistory(Ticket $ticket, User $by, ?string $from, string $to, string $note, Carbon $at): void
    {
        TicketStatusHistory::firstOrCreate(
            ['ticket_id' => $ticket->id, 'to_status' => $to, 'changed_by' => $by->id],
            [
                'from_status' => $from,
                'note' => $note,
                'created_at' => $at,
            ]
        );
    }

    private function createDesignerProduct(User $designer, string $name, string $slug, string $description, float $priceEgp, float $priceUsd): Product
    {
        return Product::firstOrCreate(
            ['slug' => $slug],
            [
                'name' => $name,
                'designer_id' => $designer->id,
                'description' => $description,
                'product_type' => 'digital',
                'price_egp' => $priceEgp,
                'price_usd' => $priceUsd,
                'cost' => 0,
                'status' => 'published',
                'publish_date' => now(),
            ]
        );
    }

    private function createNotifications(User $user): void
    {
        $samples = [
            ['ticket.opened', 'New ticket available'],
            ['ticket.accepted', 'A designer accepted your ticket'],
            ['ticket.deadline_set', 'Designer set a delivery deadline'],
            ['ticket.uploaded', 'Deliverable uploaded - awaiting QA'],
            ['subscription.approved', 'Your subscription was approved'],
        ];

        foreach ($samples as [$type, $title]) {
            Notification::firstOrCreate(
                ['user_id' => $user->id, 'type' => $type, 'title' => $title],
                [
                    'body' => $title.' - check your dashboard for details.',
                    'data' => ['ticket_id' => random_int(1, 11)],
                    'read_at' => random_int(0, 1) ? now() : null,
                    'created_at' => now()->subHours(random_int(1, 24)),
                ]
            );
        }
    }
}
