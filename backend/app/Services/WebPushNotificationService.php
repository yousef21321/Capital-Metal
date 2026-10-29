<?php

namespace App\Services;

use App\Models\PushSubscription;
use Illuminate\Support\Facades\Log;
use Minishlink\WebPush\Subscription;
use Minishlink\WebPush\WebPush;
use Throwable;

class WebPushNotificationService
{
    public function sendToUsers(iterable $subscriptions, string $title, string $body, string $url): void
    {
        $publicKey = config('services.webpush.public_key');
        $privateKey = config('services.webpush.private_key');

        if (! $publicKey || ! $privateKey) {
            return;
        }

        $webPush = new WebPush([
            'VAPID' => [
                'subject' => config('services.webpush.subject'),
                'publicKey' => $publicKey,
                'privateKey' => $privateKey,
            ],
        ]);

        foreach ($subscriptions as $subscription) {
            try {
                $webPush->queueNotification(
                    Subscription::create([
                        'endpoint' => $subscription->endpoint,
                        'publicKey' => $subscription->public_key,
                        'authToken' => $subscription->auth_token,
                        'contentEncoding' => $subscription->content_encoding,
                    ]),
                    json_encode([
                        'title' => $title,
                        'body' => $body,
                        'url' => $url,
                        'tag' => 'product-'.hash('sha256', $url),
                    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)
                );
            } catch (Throwable $exception) {
                Log::warning('Unable to queue web push notification.', [
                    'subscription_id' => $subscription->id,
                    'error' => $exception->getMessage(),
                ]);
            }
        }

        try {
            foreach ($webPush->flush() as $report) {
                if ($report->isSuccess()) {
                    continue;
                }

                $endpoint = $report->getRequest()->getUri()->__toString();
                Log::warning('Web push delivery failed.', [
                    'endpoint_host' => parse_url($endpoint, PHP_URL_HOST),
                    'reason' => $report->getReason(),
                ]);

                if ($report->isSubscriptionExpired()) {
                    PushSubscription::query()
                        ->where('endpoint_hash', hash('sha256', $endpoint))
                        ->delete();
                }
            }
        } catch (Throwable $exception) {
            Log::warning('Web push delivery batch failed.', ['error' => $exception->getMessage()]);
        }
    }
}
