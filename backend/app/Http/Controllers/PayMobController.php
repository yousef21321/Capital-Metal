<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Models\Order;
use App\Models\Payment;
use App\Models\SavedCard;
use App\Models\Ticket;
use App\Models\User;
use App\Models\UserSubscription;
use App\Services\LemonSqueezyService;
use App\Services\PaymobService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class PayMobController extends Controller
{
    public function __construct(
        protected PaymobService $paymob
    ) {}

    public function initiatePayment(Request $request)
    {
        $validated = $request->validate([
            'order_id' => 'nullable|exists:orders,id',
            'subscription_id' => 'nullable|exists:user_subscriptions,id',
            'ticket_id' => 'nullable|exists:tickets,id',
        ]);

        $user = $request->user() ?? auth('sanctum')->user();
        $guestToken = $request->header('X-Guest-Token', $request->input('guest_token'));

        if (! isset($validated['order_id']) && ! isset($validated['subscription_id']) && ! isset($validated['ticket_id'])) {
            return response()->json(['message' => 'Provide order_id, subscription_id, or ticket_id.'], 422);
        }

        if (isset($validated['ticket_id']) || isset($validated['subscription_id'])) {
            if (! $user) {
                return response()->json(['message' => 'Authentication required.'], 401);
            }
        }

        if (isset($validated['ticket_id'])) {
            return $this->initiateTicketPayment($user, $validated['ticket_id']);
        }

        if (isset($validated['order_id'])) {
            $order = Order::with('user')->findOrFail($validated['order_id']);

            if (! $this->canManageOrder($order, $user, $guestToken)) {
                return response()->json(['message' => 'Forbidden.'], 403);
            }

            if ($order->payment_status === 'paid') {
                return response()->json(['message' => 'Order is already paid.'], 422);
            }

            // USD orders go through LemonSqueezy
            if ($order->currency === 'USD') {
                return app(LemonSqueezyController::class)->initiatePayment($request);
            }

            $amountCents = (int) (round($order->total_amount, 2) * 100);
            $currency = $order->currency;
            $billingData = $this->buildBillingData($user, $order);

            $onRegistered = function ($intentionOrderId) use ($order) {
                $order->update(['payment_status' => 'processing']);
                Payment::create([
                    'order_id' => $order->id,
                    'amount' => $order->total_amount,
                    'currency' => $order->currency,
                    'payment_status' => 'pending',
                    'paymob_order_id' => (string) $intentionOrderId,
                    'created_at' => now(),
                ]);
            };

            $onResult = function ($success, $txn, $intentionOrderId) use ($order) {
                Payment::where('paymob_order_id', (string) $intentionOrderId)->update([
                    'transaction_id' => (string) ($txn['id'] ?? ''),
                    'payment_status' => $success ? 'paid' : 'failed',
                ]);

                $order->update([
                    'payment_status' => $success ? 'paid' : 'failed',
                    'order_status' => $success ? 'confirmed' : 'pending',
                ]);

                $this->notifyUser($order->user_id, $success ? 'payment.success' : 'payment.failed', $success ? 'Payment received' : 'Payment failed', [
                    'order_id' => $order->id,
                    'order_number' => $order->order_number,
                ]);
            };

            $savedCard = $user?->defaultSavedCard;

            if ($savedCard) {
                return $this->chargeWithSavedCard($savedCard, $amountCents, $currency, $billingData, $onRegistered, $onResult);
            }

            return $this->createPaymobSession($amountCents, $currency, $billingData, function ($intentionOrderId) use ($order) {
                $order->update(['payment_status' => 'processing']);

                Payment::create([
                    'order_id' => $order->id,
                    'amount' => $order->total_amount,
                    'currency' => $order->currency,
                    'payment_status' => 'pending',
                    'paymob_order_id' => (string) $intentionOrderId,
                    'created_at' => now(),
                ]);
            });
        }

        if (isset($validated['subscription_id'])) {
            $subscription = UserSubscription::with('plan', 'user')->findOrFail($validated['subscription_id']);

            if ($subscription->user_id !== $user->id) {
                return response()->json(['message' => 'Forbidden.'], 403);
            }

            if ($subscription->approval_status === 'approved') {
                return response()->json(['message' => 'Subscription is already approved.'], 422);
            }

            $plan = $subscription->plan;
            $amountCents = (int) (round($plan->price, 2) * 100);
            $currency = $plan->currency ?? 'EGP';
            $billingData = $this->buildBillingData($user);

            $onRegistered = function ($intentionOrderId) use ($subscription) {
                $subscription->update(['paymob_transaction_id' => (string) $intentionOrderId]);
            };

            $onResult = function ($success, $txn, $intentionOrderId) use ($subscription) {
                if ($success) {
                    $subscription->update([
                        'approval_status' => 'approved',
                        'approved_at' => now(),
                    ]);

                    Payment::create([
                        'order_id' => null,
                        'amount' => ($txn['amount_cents'] ?? 0) / 100,
                        'currency' => $txn['currency'] ?? 'EGP',
                        'transaction_id' => (string) ($txn['id'] ?? ''),
                        'paymob_order_id' => (string) $intentionOrderId,
                        'payment_status' => 'paid',
                        'created_at' => now(),
                    ]);

                    $this->notifyUser($subscription->user_id, 'subscription.approved', 'Subscription approved & payment received', [
                        'subscription_id' => $subscription->id,
                        'plan_name' => $subscription->plan?->name,
                    ]);

                    $this->notifyRole('admin', 'subscription.paid', 'Subscription paid & auto-approved', [
                        'subscription_id' => $subscription->id,
                        'user_id' => $subscription->user_id,
                    ]);
                } else {
                    $subscription->update([
                        'approval_status' => 'rejected',
                        'status' => 'cancelled',
                        'rejection_reason' => 'Payment failed',
                    ]);

                    $this->notifyUser($subscription->user_id, 'subscription.rejected', 'Subscription payment failed', [
                        'subscription_id' => $subscription->id,
                    ]);
                }
            };

            $savedCard = $user->defaultSavedCard;

            if ($savedCard) {
                return $this->chargeWithSavedCard($savedCard, $amountCents, $currency, $billingData, $onRegistered, $onResult);
            }

            return $this->createPaymobSession($amountCents, $currency, $billingData, function ($intentionOrderId) use ($subscription) {
                $subscription->update(['paymob_transaction_id' => (string) $intentionOrderId]);
            });
        }
    }

    protected function initiateTicketPayment(User $user, int $ticketId)
    {
        $ticket = Ticket::findOrFail($ticketId);

        if ($ticket->industor_id !== $user->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        if ($ticket->status !== Ticket::STATUS_PENDING_PAYMENT) {
            return response()->json(['message' => 'Ticket is not awaiting payment.'], 422);
        }

        $amountCents = (int) (round((float) $ticket->price, 2) * 100);
        $currency = 'EGP';
        $billingData = $this->buildBillingData($user);

        $onRegistered = function ($intentionOrderId) use ($ticket) {
            Payment::create([
                'ticket_id' => $ticket->id,
                'order_id' => null,
                'amount' => $ticket->price,
                'currency' => 'EGP',
                'payment_status' => 'pending',
                'paymob_order_id' => (string) $intentionOrderId,
                'created_at' => now(),
            ]);
        };

        $onResult = function ($success, $txn, $intentionOrderId) use ($ticket) {
            Payment::where('paymob_order_id', (string) $intentionOrderId)->update([
                'transaction_id' => (string) ($txn['id'] ?? ''),
                'payment_status' => $success ? 'paid' : 'failed',
            ]);

            if ($success) {
                $ticket->update([
                    'status' => Ticket::STATUS_APPROVED_BY_TESTER,
                    'reviewed_at' => now(),
                ]);
                $ticket->histories()->create([
                    'from_status' => Ticket::STATUS_PENDING_PAYMENT,
                    'to_status' => Ticket::STATUS_APPROVED_BY_TESTER,
                    'changed_by' => $ticket->industor_id,
                    'note' => 'Ticket payment confirmed',
                ]);

                $this->notifyUser($ticket->industor_id, 'ticket.paid', 'Ticket payment confirmed', [
                    'ticket_id' => $ticket->id,
                ]);

                $this->notifyRole('designer', 'ticket.opened', 'New ticket available', [
                    'ticket_id' => $ticket->id,
                    'title' => $ticket->title,
                ]);
            } else {
                $this->notifyUser($ticket->industor_id, 'ticket.payment_failed', 'Ticket payment failed', [
                    'ticket_id' => $ticket->id,
                ]);
            }
        };

            $savedCard = $user?->defaultSavedCard;

            if ($savedCard) {
            return $this->chargeWithSavedCard($savedCard, $amountCents, $currency, $billingData, $onRegistered, $onResult);
        }

        return $this->createPaymobSession($amountCents, $currency, $billingData, function ($intentionOrderId) use ($ticket) {
            Payment::create([
                'ticket_id' => $ticket->id,
                'order_id' => null,
                'amount' => $ticket->price,
                'currency' => 'EGP',
                'payment_status' => 'pending',
                'paymob_order_id' => (string) $intentionOrderId,
                'created_at' => now(),
            ]);
        });
    }

    protected function chargeWithSavedCard(SavedCard $card, int $amountCents, string $currency, array $billingData, callable $onRegistered, callable $onResult)
    {
        try {
            $intention = $this->paymob->createIntention(
                $amountCents,
                $currency,
                $billingData,
                [],
                config('services.paymob.callback_url'),
                config('services.paymob.redirect_url'),
            );

            $intentionOrderId = $intention['intention_order_id'] ?? $intention['id'] ?? null;
            $clientSecret = $intention['client_secret'] ?? null;

            if (! $intentionOrderId || ! $clientSecret) {
                throw new \RuntimeException('Paymob did not return intention data.');
            }

            $onRegistered($intentionOrderId);

            $txn = $this->paymob->chargeSavedCard(
                $amountCents,
                $currency,
                $clientSecret,
                $billingData,
                $card->paymob_token
            );

            $success = (bool) ($txn['success'] ?? false);
            $redirect = $txn['redirect_url'] ?? null;
            $pending = (bool) ($txn['pending'] ?? false);

            $onResult($success, $txn, $intentionOrderId);

            if ($redirect && ($pending || ! $success)) {
                return response()->json([
                    'payment_url' => $redirect,
                    'paymob_order_id' => $intentionOrderId,
                    'requires_action' => true,
                ]);
            }

            return response()->json([
                'paid' => $success,
                'payment_status' => $success ? 'paid' : 'failed',
                'paymob_order_id' => $intentionOrderId,
                'message' => $success
                    ? 'Payment completed using saved card.'
                    : 'Payment was declined. Try another card or use the manual payment page.',
            ], $success ? 200 : 422);
        } catch (\RuntimeException $e) {
            Log::error('PayMob not configured', ['error' => $e->getMessage()]);

            return response()->json(['message' => $e->getMessage()], 503);
        } catch (\Exception $e) {
            Log::error('PayMob saved-card charge failed', [
                'error' => $e->getMessage(),
                'amount_cents' => $amountCents,
                'currency' => $currency,
            ]);

            return response()->json([
                'message' => 'Failed to charge saved card.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    protected function createPaymobSession(int $amountCents, string $currency, array $billingData, callable $onBeforeRedirect)
    {
        try {
            $intention = $this->paymob->createIntention(
                $amountCents,
                $currency,
                $billingData,
                [],
                config('services.paymob.callback_url'),
                config('services.paymob.redirect_url'),
            );

            $intentionOrderId = $intention['intention_order_id'] ?? $intention['id'] ?? null;
            $clientSecret = $intention['client_secret'] ?? null;

            if (! $intentionOrderId || ! $clientSecret) {
                throw new \RuntimeException('Paymob did not return intention data.');
            }

            $onBeforeRedirect($intentionOrderId);

            return response()->json([
                'payment_url' => $this->paymob->getCheckoutUrl($clientSecret),
                'paymob_order_id' => $intentionOrderId,
            ]);
        } catch (\RuntimeException $e) {
            Log::error('PayMob not configured', ['error' => $e->getMessage()]);

            return response()->json(['message' => $e->getMessage()], 503);
        } catch (\Exception $e) {
            Log::error('PayMob payment initiation failed', [
                'error' => $e->getMessage(),
                'amount_cents' => $amountCents,
                'currency' => $currency,
            ]);

            return response()->json([
                'message' => 'Failed to initiate payment.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    public function callback(Request $request)
    {
        $data = $request->all();

        Log::info('PayMob callback received', $data);

        $transaction = $this->paymob->processCallback($data);

        if (! $transaction) {
            Log::warning('PayMob callback verification failed');

            return response()->json(['message' => 'Invalid callback'], 400);
        }

        $paymobOrderId = $transaction['order']['id'] ?? $transaction['order_id'] ?? $transaction['order'] ?? null;
        $success = $transaction['success'] ?? false;
        $txnId = $transaction['id'] ?? null;
        $amountCents = $transaction['amount_cents'] ?? 0;
        $currency = $transaction['currency'] ?? 'EGP';

        if (! $paymobOrderId) {
            Log::warning('PayMob callback missing order ID');

            return response()->json(['message' => 'Missing order ID'], 400);
        }

        DB::transaction(function () use ($paymobOrderId, $success, $txnId, $amountCents, $currency) {
            $payment = Payment::where('paymob_order_id', $paymobOrderId)->first();

            if ($payment) {
                $payment->update([
                    'transaction_id' => (string) $txnId,
                    'payment_status' => $success ? 'paid' : 'failed',
                ]);

                if ($payment->ticket_id) {
                    $ticket = $payment->ticket;

                    if ($success && $ticket && $ticket->status === Ticket::STATUS_PENDING_PAYMENT) {
                        $ticket->update([
                            'status' => Ticket::STATUS_APPROVED_BY_TESTER,
                            'reviewed_at' => now(),
                        ]);
                        $ticket->histories()->create([
                            'from_status' => Ticket::STATUS_PENDING_PAYMENT,
                            'to_status' => Ticket::STATUS_APPROVED_BY_TESTER,
                            'changed_by' => $ticket->industor_id,
                            'note' => 'Ticket payment confirmed (callback)',
                        ]);

                        $this->notifyUser($ticket->industor_id, 'ticket.paid', 'Ticket payment confirmed', [
                            'ticket_id' => $ticket->id,
                        ]);

                        $this->notifyRole('designer', 'ticket.opened', 'New ticket available', [
                            'ticket_id' => $ticket->id,
                            'title' => $ticket->title,
                        ]);
                    } elseif (! $success) {
                        $this->notifyUser($ticket?->industor_id, 'ticket.payment_failed', 'Ticket payment failed', [
                            'ticket_id' => $ticket?->id,
                        ]);
                    }

                    return;
                }

                if ($success) {
                    $payment->order->update([
                        'payment_status' => 'paid',
                        'order_status' => 'confirmed',
                    ]);

                    $this->notifyUser($payment->order->user_id, 'payment.success', 'Payment received', [
                        'order_id' => $payment->order_id,
                        'order_number' => $payment->order->order_number,
                    ]);
                } else {
                    $payment->order->update([
                        'payment_status' => 'failed',
                        'order_status' => 'pending',
                    ]);

                    $this->notifyUser($payment->order->user_id, 'payment.failed', 'Payment failed', [
                        'order_id' => $payment->order_id,
                        'order_number' => $payment->order->order_number,
                    ]);
                }

                return;
            }

            $subscription = UserSubscription::where('paymob_transaction_id', $paymobOrderId)->first();

            if ($subscription) {
                if ($success) {
                    $subscription->update([
                        'approval_status' => 'approved',
                        'approved_by' => null,
                        'approved_at' => now(),
                    ]);

                    Payment::create([
                        'order_id' => null,
                        'amount' => $amountCents / 100,
                        'currency' => $currency,
                        'transaction_id' => (string) $txnId,
                        'paymob_order_id' => (string) $paymobOrderId,
                        'payment_status' => 'paid',
                        'created_at' => now(),
                    ]);

                    $this->notifyUser($subscription->user_id, 'subscription.approved', 'Subscription approved & payment received', [
                        'subscription_id' => $subscription->id,
                        'plan_name' => $subscription->plan?->name,
                    ]);

                    $this->notifyRole('admin', 'subscription.paid', 'Subscription paid & auto-approved', [
                        'subscription_id' => $subscription->id,
                        'user_id' => $subscription->user_id,
                    ]);
                } else {
                    $subscription->update([
                        'approval_status' => 'rejected',
                        'status' => 'cancelled',
                        'rejection_reason' => 'Payment failed',
                    ]);

                    $this->notifyUser($subscription->user_id, 'subscription.rejected', 'Subscription payment failed', [
                        'subscription_id' => $subscription->id,
                    ]);
                }
            }
        });

        return response()->json(['message' => 'OK']);
    }

    public function redirect(Request $request)
    {
        $success = $request->query('success', false);
        $orderId = $request->query('order', $request->query('order_id'));
        $txnId = $request->query('txn_id');

        $payment = null;
        if ($orderId) {
            $payment = Payment::where('paymob_order_id', $orderId)->with('order')->first();
        }

        return response()->json([
            'success' => $success === 'true' || $success === true,
            'order_id' => $payment?->order_id,
            'order_number' => $payment?->order?->order_number,
            'payment_status' => $payment?->payment_status,
        ]);
    }

    protected function canManageOrder(Order $order, $user, ?string $guestToken): bool
    {
        if ($user) {
            return $order->user_id === $user->id;
        }

        return $order->user_id === null
            && $order->guest_token !== null
            && $order->guest_token === $guestToken;
    }

    protected function buildBillingData($user, $order = null): array
    {
        $address = $order?->address ?? $user?->addresses()?->where('is_default', true)?->first();

        if ($user) {
            return $this->paymob->buildBillingData([
                'first_name' => $user->name ?? explode(' ', $user->email)[0],
                'last_name' => $user->name ?? 'User',
                'email' => $user->email,
                'phone_number' => $user->phone ?? '0000000000',
                'city' => $address?->city ?? 'Cairo',
                'country' => $address?->country ?? 'EG',
                'state' => $address?->governorate ?? 'Cairo',
                'street' => $address?->address_line ?? 'N/A',
                'postal_code' => $address?->postal_code ?? 'N/A',
            ]);
        }

        return $this->paymob->buildBillingData([
            'first_name' => $order?->guest_name ?? 'Guest',
            'last_name' => 'Guest',
            'email' => $order?->guest_email ?? 'guest@capital-metal.first-link-logistics.com',
            'phone_number' => $order?->guest_phone ?? '0000000000',
            'city' => $order?->guest_city ?? 'Cairo',
            'country' => 'EG',
            'state' => $order?->guest_governorate ?? 'Cairo',
            'street' => $order?->guest_address_line ?? 'N/A',
            'postal_code' => $order?->guest_postal_code ?? 'N/A',
        ]);
    }

    protected function notifyUser(int $userId, string $type, string $title, array $data = []): void
    {
        if (! $userId) {
            return;
        }

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
            ->each(fn ($u) => $this->notifyUser($u->id, $type, $title, $data));
    }
}
