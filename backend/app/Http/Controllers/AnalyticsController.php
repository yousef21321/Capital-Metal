<?php

namespace App\Http\Controllers;

use App\Models\CustomerAnalytics;
use App\Models\DailyReport;
use App\Models\Order;
use App\Models\Product;
use App\Models\ProductAnalytics;
use App\Models\User;
use Illuminate\Http\Request;

class AnalyticsController extends Controller
{
    public function dashboard()
    {
        return response()->json([
            'total_users' => User::count(),
            'total_products' => Product::count(),
            'total_orders' => Order::count(),
            'revenue' => Order::where('payment_status', 'paid')->sum('total_amount'),
            'pending_orders' => Order::where('order_status', 'pending')->count(),
            'recent_orders' => Order::with('user')
                ->latest()
                ->take(5)
                ->get(),
        ]);
    }

    public function productAnalytics($id)
    {
        $analytics = ProductAnalytics::where('product_id', $id)->firstOrFail();

        return response()->json($analytics);
    }

    public function customerAnalytics(Request $request)
    {
        $analytics = CustomerAnalytics::where('user_id', $request->user()->id)->firstOrFail();

        return response()->json($analytics);
    }

    public function dailyReports(Request $request)
    {
        $query = DailyReport::latest('report_date');

        if ($request->from) {
            $query->where('report_date', '>=', $request->from);
        }

        if ($request->to) {
            $query->where('report_date', '<=', $request->to);
        }

        return response()->json($query->paginate($request->per_page ?? 31));
    }
}
