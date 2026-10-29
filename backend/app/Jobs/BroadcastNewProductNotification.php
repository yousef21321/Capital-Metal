<?php

namespace App\Jobs;

use App\Models\Notification;
use App\Models\Product;
use App\Models\PushSubscription;
use App\Models\User;
use App\Services\WebPushNotificationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Str;

class BroadcastNewProductNotification implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;

    public function __construct(public int $productId) {}

    public function backoff(): array
    {
        return [30, 120, 300];
    }

    public function handle(): void
    {
        $product = Product::query()
            ->whereKey($this->productId)
            ->where('status', 'published')
            ->first();

        if (! $product) {
            return;
        }

        $title = 'منتج جديد: '.Str::limit($product->name, 165, '…');
        $url = '/products/'.$product->slug;
        $data = json_encode([
            'product_id' => $product->id,
            'product_slug' => $product->slug,
            'url' => $url,
        ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

        User::query()
            ->select('id')
            ->chunkById(200, function ($users) use ($title, $data, $product) {
                $createdAt = now();
                $userIds = $users->pluck('id');
                $alreadyNotifiedIds = Notification::query()
                    ->where('type', 'new_product')
                    ->where('data->product_id', $product->id)
                    ->whereIn('user_id', $userIds)
                    ->pluck('user_id')
                    ->map(fn ($id) => (int) $id)
                    ->all();
                $alreadyNotifiedIds = array_flip($alreadyNotifiedIds);

                $newUsers = $users
                    ->reject(fn (User $user) => isset($alreadyNotifiedIds[$user->id]))
                    ->values();

                $rows = $newUsers
                    ->map(fn (User $user) => [
                        'user_id' => $user->id,
                        'type' => 'new_product',
                        'title' => $title,
                        'body' => 'تمت إضافة منتج جديد إلى المتجر. اضغط لعرض التفاصيل.',
                        'data' => $data,
                        'read_at' => null,
                        'created_at' => $createdAt,
                    ])->all();

                if ($rows !== []) {
                    Notification::query()->insert($rows);

                    $subscriptions = PushSubscription::query()
                        ->whereIn('user_id', $newUsers->pluck('id'))
                        ->get();

                    if ($subscriptions->isNotEmpty()) {
                        app(WebPushNotificationService::class)->sendToUsers(
                            $subscriptions,
                            $title,
                            'تمت إضافة منتج جديد إلى المتجر. اضغط لعرض التفاصيل.',
                            $url
                        );
                    }
                }
            });
    }
}
