<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\AddressController;
use App\Http\Controllers\WishlistController;
use App\Http\Controllers\ReviewController;
use App\Http\Controllers\CouponController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\AffiliateController;
use App\Http\Controllers\AnalyticsController;
use App\Http\Controllers\TicketController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\SubscriptionController;
use App\Http\Controllers\IndustorDesignerController;
use App\Http\Controllers\StoreController;
use App\Http\Controllers\PayMobController;
use App\Http\Controllers\SavedCardController;
use App\Http\Controllers\ExchangeRateController;
use App\Http\Controllers\HeroController;
use App\Http\Controllers\PaymentMethodController;
use App\Http\Controllers\TesterProductController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/products', [ProductController::class, 'index']);
Route::get('/products/{slug}', [ProductController::class, 'show']);
Route::get('/products/{slug}/reviews', [ReviewController::class, 'index']);
Route::post('/coupons/verify', [CouponController::class, 'verify']);

Route::get('/plans', [SubscriptionController::class, 'plans']);
Route::post('/plans', [SubscriptionController::class, 'storePlan'])->middleware(['auth:sanctum', 'role:admin']);
Route::put('/plans/{id}', [SubscriptionController::class, 'updatePlan'])->middleware(['auth:sanctum', 'role:admin']);
Route::delete('/plans/{id}', [SubscriptionController::class, 'destroyPlan'])->middleware(['auth:sanctum', 'role:admin']);
Route::get('/store', [StoreController::class, 'index']);
Route::get('/store/{id}', [StoreController::class, 'show']);

// Hero images (public read)
Route::get('/hero-images', [HeroController::class, 'index']);

// Contact form (no auth)
Route::post('/contact', [App\Http\Controllers\ContactController::class, 'store']);

// Exchange rate (public)
Route::get('/exchange-rate', [ExchangeRateController::class, 'show']);
Route::get('/payment-methods', [PaymentMethodController::class, 'index']);

// PayMob webhook (no auth)
Route::post('/paymob/callback', [PayMobController::class, 'callback']);

// Cart (public — supports guest_token)
Route::get('/cart', [CartController::class, 'show']);
Route::post('/cart/items', [CartController::class, 'addItem']);
Route::put('/cart/items/{itemId}', [CartController::class, 'updateItem']);
Route::delete('/cart/items/{itemId}', [CartController::class, 'removeItem']);
Route::delete('/cart', [CartController::class, 'clear']);

// Checkout & orders (public — supports guest checkout)
Route::post('/checkout', [OrderController::class, 'checkout']);
Route::get('/orders', [OrderController::class, 'index']);
Route::get('/orders/my', [OrderController::class, 'myOrders']);
Route::get('/orders/{id}', [OrderController::class, 'show']);
Route::get('/orders/{orderId}/items/{itemId}/download', [OrderController::class, 'downloadItem']);
Route::middleware(['auth:sanctum', 'role:admin'])->put('/orders/{id}/status', [OrderController::class, 'updateStatus']);
Route::middleware(['auth:sanctum', 'role:admin'])->delete('/orders/{id}', [OrderController::class, 'destroy']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/me', [AuthController::class, 'updateProfile']);
    Route::put('/me/currency', [AuthController::class, 'updateCurrency']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Products (admin)
    Route::middleware('role:admin')->group(function () {
        Route::put('/exchange-rate', [ExchangeRateController::class, 'update']);
        Route::post('/products', [ProductController::class, 'store']);
        Route::put('/products/{id}', [ProductController::class, 'update']);
        Route::delete('/products/{id}', [ProductController::class, 'destroy']);
        Route::post('/products/{id}/images', [ProductController::class, 'uploadImage']);
        Route::put('/products/{id}/images/reorder', [ProductController::class, 'reorderImages']);
        Route::delete('/products/{id}/images/{imageId}', [ProductController::class, 'destroyImage']);
        Route::put('/products/{id}/inventory', [ProductController::class, 'updateInventory']);
        Route::post('/products/{id}/digital-files', [ProductController::class, 'addDigitalFile']);
        Route::post('/hero-images', [HeroController::class, 'store']);
        Route::delete('/hero-images/{id}', [HeroController::class, 'destroy']);
    });

    // Addresses
    Route::get('/addresses', [AddressController::class, 'index']);
    Route::post('/addresses', [AddressController::class, 'store']);
    Route::put('/addresses/{id}', [AddressController::class, 'update']);
    Route::delete('/addresses/{id}', [AddressController::class, 'destroy']);

    // Wishlist
    Route::get('/wishlist', [WishlistController::class, 'index']);
    Route::post('/wishlist/toggle', [WishlistController::class, 'toggle']);

    // Reviews
    Route::post('/reviews', [ReviewController::class, 'store']);
    Route::delete('/reviews/{id}', [ReviewController::class, 'destroy']);

    // Payments
    Route::get('/payments', [PaymentController::class, 'index']);
    Route::post('/payments', [PaymentController::class, 'store']);

    // PayMob payment initiation
    Route::post('/paymob/intent', [PayMobController::class, 'initiatePayment']);
    Route::get('/paymob/redirect', [PayMobController::class, 'redirect']);

    // Saved payment cards (Paymob tokenization)
    Route::get('/saved-cards', [SavedCardController::class, 'index']);
    Route::post('/saved-cards', [SavedCardController::class, 'store']);
    Route::put('/saved-cards/{id}/default', [SavedCardController::class, 'setDefault']);
    Route::delete('/saved-cards/{id}', [SavedCardController::class, 'destroy']);

    // Coupons (admin)
    Route::middleware('role:admin')->group(function () {
        Route::get('/coupons', [CouponController::class, 'index']);
        Route::post('/coupons', [CouponController::class, 'store']);
        Route::put('/coupons/{id}', [CouponController::class, 'update']);
        Route::delete('/coupons/{id}', [CouponController::class, 'destroy']);
    });

    // Affiliates
    Route::post('/affiliates/register', [AffiliateController::class, 'register']);
    Route::get('/affiliates/profile', [AffiliateController::class, 'myProfile']);
    Route::get('/affiliates/earnings', [AffiliateController::class, 'earnings']);

    // Analytics
    Route::get('/analytics/dashboard', [AnalyticsController::class, 'dashboard']);
    Route::get('/analytics/products/{id}', [AnalyticsController::class, 'productAnalytics']);
    Route::get('/analytics/customer', [AnalyticsController::class, 'customerAnalytics']);
    Route::get('/analytics/daily-reports', [AnalyticsController::class, 'dailyReports']);

    // Role dashboards
    Route::middleware('role:admin')->get('/admin/dashboard', function () {
        return response()->json([
            'message' => 'Admin Dashboard',
            'stats' => ['users' => 1250, 'orders' => 340, 'revenue' => 45200],
        ]);
    });

    Route::middleware('role:user')->get('/user/dashboard', function () {
        return response()->json([
            'message' => 'User Dashboard',
            'stats' => ['orders' => 12, 'wishlist' => 5],
        ]);
    });

    Route::middleware('role:tester')->get('/tester/dashboard', function () {
        return response()->json([
            'message' => 'Tester Dashboard',
            'stats' => ['assigned_tests' => 8, 'completed' => 3],
        ]);
    });

    Route::middleware('role:designer')->get('/designer/dashboard', function () {
        return response()->json([
            'message' => 'Designer Dashboard',
            'stats' => ['projects' => 15, 'pending_review' => 4],
        ]);
    });

    Route::middleware('role:industor')->get('/industor/dashboard', function () {
        return response()->json([
            'message' => 'Industor Dashboard',
            'stats' => ['factories' => 6, 'production_orders' => 22],
        ]);
    });

    // Tickets — static routes MUST come before {id}
    Route::get('/tickets', [TicketController::class, 'index']);
    Route::post('/tickets', [TicketController::class, 'store'])->middleware('role:industor');
    Route::get('/tickets/available', [TicketController::class, 'available'])->middleware('role:designer,admin');
    Route::get('/tickets/pending-negotiations', [TicketController::class, 'pendingTickets'])->middleware('role:tester,admin');
    Route::get('/tickets/qa-queue', [TicketController::class, 'qaQueue'])->middleware('role:tester,admin');
    Route::get('/tickets/{id}', [TicketController::class, 'show']);
    Route::put('/tickets/{id}', [TicketController::class, 'update'])->middleware('role:industor');
    Route::get('/tickets/{id}/attachments/{attachmentId}/download', [TicketController::class, 'downloadAttachment']);
Route::delete('/tickets/{id}/attachments/{attachmentId}', [TicketController::class, 'destroyAttachment']);
    Route::post('/tickets/{id}/cancel', [TicketController::class, 'cancel']);

    Route::middleware('role:tester')->group(function () {
        Route::post('/tickets/{id}/suggest', [TicketController::class, 'testerPropose']);
        Route::post('/tickets/{id}/accept-counter', [TicketController::class, 'testerAccept']);
        Route::post('/tickets/{id}/accept-initial', [TicketController::class, 'testerAcceptInitial']);
        Route::delete('/tickets/{id}/cancel-negotiation', [TicketController::class, 'cancelNegotiation']);
        Route::post('/tickets/{id}/qa/claim', [TicketController::class, 'qaClaim']);
        Route::post('/tickets/{id}/qa/approve', [TicketController::class, 'qaApprove']);
        Route::post('/tickets/{id}/qa/reject', [TicketController::class, 'qaReject']);
        Route::get('/tester/products/pending', [TesterProductController::class, 'index']);
        Route::get('/tester/products/pending-count', [TesterProductController::class, 'pendingCount']);
        Route::get('/tester/products/{id}/download', [TesterProductController::class, 'downloadDesignFile']);
        Route::post('/tester/products/{id}/approve', [TesterProductController::class, 'approve']);
        Route::post('/tester/products/{id}/return', [TesterProductController::class, 'returnWithFeedback']);
        Route::post('/tester/tickets/{ticketId}/convert-to-product', [TesterProductController::class, 'convertTicketToProduct']);
    });

    Route::middleware('role:industor')->group(function () {
        Route::post('/tickets/{id}/accept-suggestion', [TicketController::class, 'industorAccept']);
        Route::post('/tickets/{id}/counter-suggestion', [TicketController::class, 'industorCounter']);
        Route::post('/tickets/{id}/attachments', [TicketController::class, 'uploadRequirement']);
        Route::delete('/tickets/{id}/cancel-negotiation', [TicketController::class, 'cancelNegotiation']);
        Route::post('/tickets/{id}/modification/approve', [TicketController::class, 'approveModification']);
        Route::post('/tickets/{id}/modification/reject', [TicketController::class, 'rejectModification']);
        Route::post('/tickets/{id}/publish', [TicketController::class, 'publish']);
        Route::delete('/tickets/{id}/publish', [TicketController::class, 'unpublish']);
    });

    Route::middleware('role:designer')->group(function () {
        Route::post('/tickets/{id}/accept', [TicketController::class, 'accept']);
        Route::post('/tickets/{id}/modification', [TicketController::class, 'requestModification']);
        Route::post('/tickets/{id}/deadline', [TicketController::class, 'setDeadline']);
        Route::post('/tickets/{id}/upload', [TicketController::class, 'upload']);
        Route::post('/designer/products', [TicketController::class, 'storeDesignerProduct']);
        Route::get('/designer/products', [TicketController::class, 'myDesignerProducts']);
        Route::get('/designer/products/modification-count', function (\Illuminate\Http\Request $r) {
            return response()->json([
                'count' => \App\Models\Product::where('designer_id', $r->user()->id)
                    ->where('status', 'modification_requested')->count(),
            ]);
        });
        Route::get('/designer/products/{id}', [TicketController::class, 'showDesignerProduct']);
        Route::post('/designer/products/{id}', [TicketController::class, 'updateDesignerProduct']);
    });

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
    Route::post('/notifications/broadcast', [NotificationController::class, 'broadcast'])->middleware('role:admin');

    // Subscriptions & admin approvals
    Route::get('/subscriptions/me', [SubscriptionController::class, 'mine']);
    Route::post('/subscriptions', [SubscriptionController::class, 'subscribe']);

    Route::middleware('role:admin')->group(function () {
        Route::get('/admin/subscriptions/pending', [SubscriptionController::class, 'pendingApprovals']);
        Route::post('/admin/subscriptions/{id}/approve', [SubscriptionController::class, 'approve']);
        Route::post('/admin/subscriptions/{id}/reject', [SubscriptionController::class, 'reject']);
    });
});
