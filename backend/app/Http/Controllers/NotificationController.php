<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Models\PushSubscription;
use App\Models\User;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $query = Notification::where('user_id', $request->user()->id)->latest();

        if ($request->boolean('unread')) {
            $query->whereNull('read_at');
        }

        return response()->json($query->paginate($request->per_page ?? 20));
    }

    public function unreadCount(Request $request)
    {
        $count = Notification::where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->count();

        return response()->json(['unread_count' => $count]);
    }

    public function pushKey()
    {
        return response()->json(['public_key' => config('services.webpush.public_key')]);
    }

    public function savePushSubscription(Request $request)
    {
        $validated = $request->validate([
            'endpoint' => 'required|url|max:4096',
            'keys.p256dh' => 'required|string|max:255',
            'keys.auth' => 'required|string|max:255',
            'contentEncoding' => 'nullable|string|in:aes128gcm,aesgcm',
        ]);
        $endpoint = $validated['endpoint'];

        PushSubscription::query()->updateOrCreate(
            ['endpoint_hash' => hash('sha256', $endpoint)],
            [
                'user_id' => $request->user()->id,
                'endpoint' => $endpoint,
                'public_key' => $validated['keys']['p256dh'],
                'auth_token' => $validated['keys']['auth'],
                'content_encoding' => $validated['contentEncoding'] ?? 'aes128gcm',
            ]
        );

        return response()->json(['message' => 'Device notifications enabled.']);
    }

    public function deletePushSubscription(Request $request)
    {
        $validated = $request->validate(['endpoint' => 'required|url|max:4096']);

        PushSubscription::query()
            ->where('user_id', $request->user()->id)
            ->where('endpoint_hash', hash('sha256', $validated['endpoint']))
            ->delete();

        return response()->json(['message' => 'Device notifications disabled.']);
    }

    public function markAsRead(Request $request, $id)
    {
        $notification = Notification::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        $notification->update(['read_at' => $notification->read_at ?? now()]);

        return response()->json($notification);
    }

    public function markAllAsRead(Request $request)
    {
        Notification::where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        return response()->json(['message' => 'All notifications marked as read.']);
    }

    /**
     * Send a system-wide notification to all users (admin only).
     */
    public function broadcast(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:200',
            'body' => 'nullable|string',
            'type' => 'nullable|string|max:100',
        ]);

        $userIds = User::pluck('id');

        $notifications = $userIds->map(fn ($id) => [
            'user_id' => $id,
            'type' => $validated['type'] ?? 'system',
            'title' => $validated['title'],
            'body' => $validated['body'] ?? null,
            'data' => json_encode(['system' => true]),
            'read_at' => null,
            'created_at' => now(),
        ]);

        Notification::insert($notifications->toArray());

        $count = $notifications->count();

        return response()->json([
            'message' => "Notification sent to {$count} users.",
            'users_count' => $count,
        ]);
    }
}
