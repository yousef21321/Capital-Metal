<?php

namespace App\Http\Controllers;

use App\Models\Notification;
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
