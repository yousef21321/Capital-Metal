<?php

namespace App\Http\Controllers;

use App\Models\Address;
use App\Models\Cart;
use App\Models\Coupon;
use App\Models\Order;
use App\Models\ShippingRate;
use App\Models\User;
use App\Services\StoxService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\PersonalAccessToken;
use ZipArchive;

class OrderController extends Controller
{
    protected function guestToken(Request $request): ?string
    {
        return $request->header('X-Guest-Token', $request->input('guest_token'));
    }

    protected function resolveUser(Request $request): ?int
    {
        $userId = $request->user()?->id;

        if (! $userId) {
            $token = $request->bearerToken();
            if ($token) {
                $accessToken = PersonalAccessToken::findToken($token);
                $userId = $accessToken?->tokenable?->id;
            }
        }

        return $userId;
    }

    protected function cartIdentifier(Request $request): array
    {
        $userId = $this->resolveUser($request);

        if ($userId) {
            return ['user_id' => $userId];
        }

        $guestToken = $this->guestToken($request);

        if ($guestToken) {
            return ['guest_token' => $guestToken];
        }

        return [];
    }

    public function index(Request $request)
    {
        $query = Order::with(['items.product', 'items.variant', 'payments.paymentMethod', 'user', 'address']);

        $userId = $this->resolveUser($request);
        $user = $userId ? User::with('role')->find($userId) : null;

        if ($user) {
            if (optional($user->role)->name !== 'admin') {
                $query->where('user_id', $user->id);
            }
        } else {
            $guestToken = $this->guestToken($request);

            if ($guestToken) {
                $query->whereNull('user_id')->where('guest_name', '!=', '');
            } else {
                return response()->json(['data' => [], 'meta' => ['current_page' => 1, 'last_page' => 1]]);
            }
        }

        $this->applyFilters($query, $request);

        return response()->json($query->latest()->paginate($request->per_page ?? 50));
    }

    public function export(Request $request)
    {
        $query = Order::with(['items.product', 'items.variant', 'payments.paymentMethod', 'user', 'address']);

        $userId = $this->resolveUser($request);
        $user = $userId ? User::with('role')->find($userId) : null;

        if (! $user || optional($user->role)->name !== 'admin') {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        $this->applyFilters($query, $request);

        $orders = $query->latest()->get();

        $rows = [[
            'Order #', 'Date', 'Customer Name', 'Phone', 'Email',
            'Governorate', 'City', 'Address', 'Postal Code',
            'Payment Method', 'Order Status', 'Payment Status',
            'Product Name', 'Product Type', 'Variant', 'Qty', 'Item Price',
            'Subtotal', 'Shipping', 'Discount', 'Total',
            'Currency', 'Tracking', 'Notes',
        ]];

        foreach ($orders as $order) {
            $phone = $order->address?->phone ?? $order->user?->phone ?? $order->guest_phone ?? '';
            $gov = $order->address?->governorate ?? $order->guest_governorate ?? '';
            $city = $order->address?->city ?? $order->guest_city ?? '';
            $addrLine = $order->address?->address_line ?? $order->guest_address_line ?? '';
            $postal = $order->address?->postal_code ?? $order->guest_postal_code ?? '';
            $paymentMethod = $order->payments->first()?->paymentMethod?->name ?? 'N/A';
            $customerName = $order->user?->name ?? $order->guest_name ?? '';
            $email = $order->user?->email ?? $order->guest_email ?? '';

            $items = $order->items->isEmpty() ? [null] : $order->items;

            foreach ($items as $item) {
                $rows[] = [
                    $order->order_number,
                    $order->created_at->format('Y-m-d H:i'),
                    $customerName,
                    $phone,
                    $email,
                    $gov,
                    $city,
                    $addrLine,
                    $postal,
                    $paymentMethod,
                    $order->order_status,
                    $order->payment_status,
                    $item?->product?->name ?? '',
                    $item?->product?->product_type ?? '',
                    $item?->variant?->name ?? '',
                    $item?->quantity ?? 0,
                    $item?->price ?? 0,
                    $order->subtotal,
                    $order->shipping_cost,
                    $order->discount,
                    $order->total_amount,
                    $order->currency,
                    $order->shipping_tracking_number ?? '',
                    $order->notes ?? '',
                ];
            }
        }

        $file = $this->buildXlsx($rows);

        return response($file, 200, [
            'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'Content-Disposition' => 'attachment; filename="orders_'.date('Ymd_His').'.xlsx"',
        ]);
    }

    /**
     * Build a real .xlsx file (no external library) from a [][] of rows.
     * Phone / postal code columns are kept as text so leading zeros survive.
     */
    private function buildXlsx(array $rows): string
    {
        $forceTextCols = [3, 8]; // Phone, Postal Code
        $numericCols = [15, 16, 17, 18, 19, 20]; // Qty, Item Price, Subtotal, Shipping, Discount, Total

        $shared = [];
        $sharedMap = [];
        $sheetXml = '';

        foreach ($rows as $rowIndex => $row) {
            $cells = '';
            foreach ($row as $colIndex => $value) {
                $value = $value ?? '';
                if ($value === '') {
                    $cells .= '<c/>';
                    continue;
                }

                if (! in_array($colIndex, $forceTextCols, true) && in_array($colIndex, $numericCols, true) && is_numeric($value)) {
                    $cells .= '<c t="n"><v>'.$value.'</v></c>';
                    continue;
                }

                $value = (string) $value;
                if (! isset($sharedMap[$value])) {
                    $sharedMap[$value] = count($shared);
                    $shared[] = $value;
                }
                $cells .= '<c t="s"><v>'.$sharedMap[$value].'</v></c>';
            }
            $sheetXml .= '<row>'.$cells.'</row>';
        }

        $esc = fn ($s) => htmlspecialchars($s, ENT_XML1 | ENT_QUOTES, 'UTF-8');

        $contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            .'<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
            .'<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
            .'<Default Extension="xml" ContentType="application/xml"/>'
            .'<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
            .'<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
            .'<Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>'
            .'</Types>';

        $rootRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            .'<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            .'<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
            .'</Relationships>';

        $workbook = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            .'<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
            .'<sheets><sheet name="Orders" sheetId="1" r:id="rId1"/></sheets>'
            .'</workbook>';

        $workbookRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            .'<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            .'<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
            .'<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>'
            .'</Relationships>';

        $worksheet = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            .'<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>'
            .$sheetXml
            .'</sheetData></worksheet>';

        $sharedStrings = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            .'<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="'.count($shared).'" uniqueCount="'.count($shared).'">'
            .implode('', array_map(fn ($s) => '<si><t xml:space="preserve">'.$esc($s).'</t></si>', $shared))
            .'</sst>';

        $tmpPath = tempnam(sys_get_temp_dir(), 'orders_');

        $zip = new ZipArchive;
        $zip->open($tmpPath, ZipArchive::OVERWRITE);
        $zip->addFromString('[Content_Types].xml', $contentTypes);
        $zip->addFromString('_rels/.rels', $rootRels);
        $zip->addFromString('xl/workbook.xml', $workbook);
        $zip->addFromString('xl/_rels/workbook.xml.rels', $workbookRels);
        $zip->addFromString('xl/worksheets/sheet1.xml', $worksheet);
        $zip->addFromString('xl/sharedStrings.xml', $sharedStrings);
        $zip->close();

        $xlsx = file_get_contents($tmpPath);
        @unlink($tmpPath);

        return $xlsx;
    }

    private function applyFilters($query, Request $request): void
    {
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->whereHas('user', fn ($uq) => $uq->where('name', 'like', "%{$search}%"))
                    ->orWhere('guest_name', 'like', "%{$search}%")
                    ->orWhere('order_number', 'like', "%{$search}%");
            });
        }

        if ($request->filled('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        if ($request->filled('status')) {
            $query->where('order_status', $request->status);
        }

        if ($request->filled('payment_status')) {
            $query->where('payment_status', $request->payment_status);
        }
    }

    public function show($id, Request $request)
    {
        $order = Order::with([
            'items.product.images', 'items.variant.images', 'payments.paymentMethod',
            'refunds', 'user', 'affiliate',
        ])->findOrFail($id);

        $userId = $this->resolveUser($request);
        $user = $userId ? User::with('role')->find($userId) : null;

        if ($user?->role?->name === 'admin') {
            return response()->json($order);
        }

        if ($user && $order->user_id !== $user->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        if (! $user && $order->user_id !== null) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        return response()->json($order);
    }

    public function checkout(Request $request)
    {
        $validated = $request->validate([
            'currency' => 'required|in:EGP,USD',
            'exchange_rate' => 'nullable|numeric|min:0.01',
            'shipping_cost' => 'nullable|numeric|min:0',
            'notes' => 'nullable|string',
            'address_id' => 'nullable|exists:addresses,id',
            'coupon_code' => 'nullable|string|max:100',
            'payment_method_id' => 'nullable|exists:payment_methods,id',
            'guest_name' => 'nullable|string|max:255',
            'guest_email' => 'nullable|email|max:255',
            'guest_phone' => 'nullable|string|max:50',
            'guest_governorate' => 'nullable|string|max:100',
            'guest_city' => 'nullable|string|max:100',
            'guest_address_line' => 'nullable|string|max:255',
            'guest_postal_code' => 'nullable|string|max:20',
        ]);

        $userId = $this->resolveUser($request);

        if (! $userId && ! $this->guestToken($request)) {
            return response()->json(['message' => 'Authentication required. Please login or provide guest details.'], 401);
        }

        $identifier = $this->cartIdentifier($request);

        if (empty($identifier)) {
            return response()->json(['message' => 'Cart identifier required.'], 400);
        }

        $cart = Cart::with('items.product', 'items.variant')
            ->where($identifier)
            ->first();

        if (! $cart || $cart->items->isEmpty()) {
            return response()->json(['message' => 'Cart is empty.'], 400);
        }

        $hasPhysical = $cart->items->contains(function ($item) {
            return ($item->product->product_type ?? null) === 'physical';
        });
        $isDigitalOnly = ! $hasPhysical;

        if ($isDigitalOnly && ! $userId) {
            return response()->json([
                'message' => 'المنتجات الرقمية تتطلب تسجيل الدخول لإتمام الشراء. سلة التسوق الخاصة بك محفوظة. / Digital products require an account to purchase. Your cart has been saved.',
            ], 401);
        }

        if ($hasPhysical && $validated['currency'] === 'USD') {
            return response()->json([
                'message' => 'المنتجات المادية متاحة للشراء في مصر فقط / Physical products can only be purchased in Egypt (EGP).',
            ], 422);
        }

        if ($hasPhysical) {
            $hasAddressId = ! empty($validated['address_id']);
            $hasGuestFields = ! empty($validated['guest_name'])
                && ! empty($validated['guest_phone'])
                && ! empty($validated['guest_governorate'])
                && ! empty($validated['guest_city'])
                && ! empty($validated['guest_address_line']);

            $hasValidAddress = false;
            if ($userId && $hasAddressId) {
                $addr = Address::find($validated['address_id']);
                $user = User::find($userId);
                $hasValidAddress = $addr
                    && ! empty($addr->governorate)
                    && ! empty($addr->city)
                    && ! empty($addr->address_line)
                    && (! empty(trim($user->name ?? '')) || ! empty($addr->full_name))
                    && (! empty($user->phone) || ! empty($addr->phone));
            }

            if (! $hasAddressId && ! $hasGuestFields) {
                return response()->json([
                    'message' => 'Shipping address is required for physical products. Please select a saved address or enter a shipping address.',
                ], 422);
            }

            if ($hasAddressId && ! $hasValidAddress) {
                return response()->json([
                    'message' => 'The selected address is incomplete. Please choose a valid address with name, phone, and full details.',
                ], 422);
            }
        }

        $orderNumber = 'ORD-'.strtoupper(uniqid());
        $subtotal = 0;
        $orderItems = [];

        $exchangeRate = (float) \App\Models\Setting::getValue('egp_to_usd_rate', 30);
        if ($validated['currency'] === 'USD' && ! empty($validated['exchange_rate'])) {
            $exchangeRate = (float) $validated['exchange_rate'];
        }

        foreach ($cart->items as $item) {
            $source = $item->variant ?? $item->product;
            $price = $validated['currency'] === 'EGP'
                ? (float) $source->price_egp
                : (float) $source->price_egp / $exchangeRate;
            $subtotal += $price * $item->quantity;
            $orderItems[] = [
                'product_id' => $item->product_id,
                'variant_id' => $item->variant_id,
                'quantity' => $item->quantity,
                'price' => $price,
                'license_type' => $item->license_type,
            ];
        }

        $shippingCost = 0;
        if (! $isDigitalOnly) {
            $governorate = null;
            if (! empty($validated['address_id'])) {
                $addr = Address::find($validated['address_id']);
                $governorate = $addr?->governorate;
            }
            if (! $governorate) {
                $governorate = $validated['guest_governorate'] ?? null;
            }
            if ($governorate) {
                $rate = ShippingRate::where('governorate', $governorate)->first();
                $shippingCost = $rate ? (float) $rate->cost : 0;
            }
            if ($validated['currency'] === 'USD' && $shippingCost > 0) {
                $shippingCost = $shippingCost / $exchangeRate;
            }
        }

        [$discount, $couponId] = $this->resolveCoupon(
            $validated['coupon_code'] ?? null,
            $subtotal
        );

        $totalAmount = max(0, ($subtotal + $shippingCost) - $discount);

        $order = DB::transaction(function () use (
            $request, $validated, $userId, $orderNumber, $subtotal,
            $shippingCost, $discount, $couponId, $totalAmount, $orderItems, $cart
        ) {
            $guestToken = $this->guestToken($request);

            $orderData = [
                'user_id' => $userId,
                'guest_token' => $guestToken,
                'order_number' => $orderNumber,
                'currency' => $validated['currency'],
                'subtotal' => $subtotal,
                'shipping_cost' => $shippingCost,
                'discount' => $discount,
                'coupon_id' => $couponId,
                'total_amount' => $totalAmount,
                'payment_status' => 'pending',
                'order_status' => 'pending',
                'notes' => $validated['notes'] ?? null,
                'address_id' => $validated['address_id'] ?? null,
                'guest_name' => $validated['guest_name'] ?? null,
                'guest_email' => $validated['guest_email'] ?? null,
                'guest_phone' => $validated['guest_phone'] ?? null,
                'guest_governorate' => $validated['guest_governorate'] ?? null,
                'guest_city' => $validated['guest_city'] ?? null,
                'guest_address_line' => $validated['guest_address_line'] ?? null,
                'guest_postal_code' => $validated['guest_postal_code'] ?? null,
            ];

            $order = Order::create($orderData);

            foreach ($orderItems as $item) {
                $order->items()->create($item);
            }

            if (($validated['payment_method_id'] ?? null) == 2) {
                $order->payments()->create([
                    'payment_method_id' => 2,
                    'amount' => $totalAmount,
                    'currency' => $validated['currency'],
                    'payment_status' => 'pending',
                ]);
                $order->update(['payment_status' => 'pending']);
            }

            if ($couponId) {
                Coupon::where('id', $couponId)->increment('used_count');
            }

            $cart->items()->delete();

            return $order;
        });

        $this->sendOrderToStox(
            $order->fresh(['items.product.inventory', 'items.variant', 'items.variant.images']),
            $validated,
            $userId
        );

        return response()->json($order->load('items.product', 'items.variant'), 201);
    }

    /**
     * Validate a coupon code against an order subtotal and return
     * [discount, couponId]. Throws a validation exception on failure.
     */
    protected function resolveCoupon(?string $code, float $subtotal): array
    {
        if (! $code) {
            return [0, null];
        }

        $coupon = Coupon::where('code', $code)->first();

        if (! $coupon) {
            abort(response()->json(['message' => 'Invalid coupon code.'], 422));
        }

        if ($coupon->expiry_date && now()->gt($coupon->expiry_date)) {
            abort(response()->json(['message' => 'Coupon has expired.'], 422));
        }

        if ($coupon->usage_limit && $coupon->used_count >= $coupon->usage_limit) {
            abort(response()->json(['message' => 'Coupon usage limit reached.'], 422));
        }

        if ($coupon->min_order_amount && $subtotal < $coupon->min_order_amount) {
            abort(response()->json(['message' => 'Minimum order amount not met.'], 422));
        }

        $discount = $coupon->discount_type === 'percentage'
            ? ($subtotal * $coupon->discount_value / 100)
            : (float) $coupon->discount_value;

        $discount = min($discount, $subtotal);

        return [round($discount, 2), $coupon->id];
    }

    private function sendOrderToStox(Order $order, array $validated, ?int $userId): void
    {
        /** @var StoxService $stox */
        $stox = app(StoxService::class);

        if (! $stox->isConfigured()) {
            return;
        }

        $physicalItems = $order->items->filter(function ($item) {
            if (! $item->product || $item->product->product_type !== 'physical') {
                return false;
            }
            if ($item->variant) {
                return ! empty($item->variant->stox_product_id);
            }

            return ! empty($item->product->stox_product_id);
        });

        if ($physicalItems->isEmpty()) {
            return;
        }

        $customerName = '';
        $customerPhone = '';
        $address = '';
        $areaId = null;
        $email = null;

        if ($userId) {
            $user = $order->user;
            $customerName = $user->name ?? '';
            $customerPhone = $user->phone ?? '';

            if ($order->address_id) {
                $addr = Address::find($order->address_id);
                if ($addr) {
                    $customerName = $customerName ?: $addr->full_name;
                    $customerPhone = $customerPhone ?: $addr->phone;
                    $address = trim(($addr->address_line ?? '').', '.($addr->city ?? '').', '.($addr->governorate ?? ''));
                    $areaId = $stox->resolveAreaId($addr->city, $addr->governorate);
                }
            } elseif (! $address) {
                $fallbackAddr = Address::where('user_id', $userId)->first();
                if ($fallbackAddr) {
                    $customerName = $customerName ?: $fallbackAddr->full_name;
                    $customerPhone = $customerPhone ?: $fallbackAddr->phone;
                    $address = trim(($fallbackAddr->address_line ?? '').', '.($fallbackAddr->city ?? '').', '.($fallbackAddr->governorate ?? ''));
                    $areaId = $stox->resolveAreaId($fallbackAddr->city, $fallbackAddr->governorate);
                }
            }

            $email = $user->email ?? null;
        }

        if (! $customerName) {
            $customerName = $validated['guest_name'] ?? $order->guest_name ?? '';
        }
        if (! $customerPhone) {
            $customerPhone = $validated['guest_phone'] ?? $order->guest_phone ?? '';
        }
        if (! $address) {
            $guestAddressLine = $validated['guest_address_line'] ?? $order->guest_address_line ?? '';
            $guestCity = $validated['guest_city'] ?? $order->guest_city ?? '';
            $guestGovernorate = $validated['guest_governorate'] ?? $order->guest_governorate ?? '';
            $address = trim($guestAddressLine.', '.$guestCity.', '.$guestGovernorate);
            $areaId = $areaId ?: $stox->resolveAreaId($guestCity ?: null, $guestGovernorate ?: null);
        }

        if (! $email && $userId) {
            $email = $order->user?->email;
        }

        if (! $customerName || ! $customerPhone || ! $address || ! $areaId) {
            Log::warning('Stox order skipped: missing required fields', [
                'order_id' => $order->id,
                'name' => $customerName,
                'phone' => $customerPhone,
                'address' => $address,
                'area_id' => $areaId,
            ]);

            return;
        }

        $paymentType = $stox->mapPaymentType($validated['payment_method_id'] ?? null);
        $codAmount = $paymentType === 'COD' ? (float) $order->total_amount : null;

        $products = $physicalItems->map(function ($item) {
            if ($item->variant && $item->variant->stox_product_id) {
                return [
                    'id' => (int) $item->variant->stox_product_id,
                    'qty' => (int) $item->quantity,
                    'sku' => $item->variant->sku ?? $item->product->slug,
                ];
            }
            $inventory = $item->product->inventory;

            return [
                'id' => (int) $item->product->stox_product_id,
                'qty' => (int) $item->quantity,
                'sku' => $inventory?->sku ?? $item->product->slug,
            ];
        })->toArray();

        $orderData = [
            'customer_name' => $customerName,
            'mobile_1' => $customerPhone,
            'email' => $email,
            'address' => $address,
            'area_id' => $areaId,
            'reference_number' => $order->order_number,
            'payment_type' => $paymentType,
            'cod_amount' => $codAmount,
            'note' => $order->notes,
            'products' => $products,
        ];

        $result = $stox->createOrder($orderData);

        if ($result) {
            $stoxId = $result['data'][0]['id'] ?? $result['data']['id'] ?? null;
            $order->update(['stox_order_id' => $stoxId]);
        }
    }

    public function destroy($id)
    {
        $order = Order::with('items', 'payments')->findOrFail($id);
        $order->items()->delete();
        $order->payments()->delete();
        $order->delete();

        return response()->json(['message' => 'Order deleted.']);
    }

    public function updateStatus(Request $request, $id)
    {
        $validated = $request->validate([
            'order_status' => 'sometimes|in:pending,under_review,confirmed,processing,shipped,delivered,cancelled',
            'payment_status' => 'sometimes|in:pending,paid,failed,refunded',
            'shipping_tracking_number' => 'nullable|string|max:255',
        ]);

        $order = Order::findOrFail($id);
        $order->update($validated);

        return response()->json($order->load('items.product', 'items.variant'));
    }

    public function downloadItem($orderId, $itemId, Request $request)
    {
        $order = Order::with('items.product.digitalFiles')->findOrFail($orderId);

        $userId = $this->resolveUser($request);
        $guestToken = $this->guestToken($request);

        $ownsOrder = false;
        if ($userId && $order->user_id === $userId) {
            $ownsOrder = true;
        } elseif ($guestToken && $order->guest_token === $guestToken) {
            $ownsOrder = true;
        }

        if (! $ownsOrder) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        if ($order->payment_status !== 'paid') {
            return response()->json(['message' => 'Payment required.'], 402);
        }

        $item = $order->items()->where('id', $itemId)->first();

        if (! $item) {
            return response()->json(['message' => 'Item not found in this order.'], 404);
        }

        $product = $item->product;
        $digitalFiles = $product->digitalFiles;

        if ($digitalFiles->count() > 1) {
            $downloadDir = storage_path("app/public/downloads");
            if (! File::isDirectory($downloadDir)) {
                File::makeDirectory($downloadDir, 0755, true);
            }

            $zipPath = "{$downloadDir}/order-{$orderId}-item-{$itemId}.zip";

            if (! File::exists($zipPath)) {
                $zip = new ZipArchive;
                if ($zip->open($zipPath, ZipArchive::CREATE | ZipArchive::OVERWRITE) === true) {
                    foreach ($digitalFiles as $df) {
                        $filePath = Storage::disk('public')->path($df->file_url);
                        if (File::exists($filePath)) {
                            $zip->addFile($filePath, basename($df->file_url));
                        }
                    }
                    $zip->close();
                }
            }

            return response()->download($zipPath, $product->name.'.zip')->deleteFileAfterSend(true);
        }

        $filePath = $product->design_file_path;

        if ($digitalFiles->count() === 1) {
            $filePath = $digitalFiles->first()->file_url;
        }

        if (! $filePath || ! Storage::disk('public')->exists($filePath)) {
            return response()->json(['message' => 'File not available.'], 404);
        }

        return Storage::disk('public')->download($filePath);
    }

    public function myOrders(Request $request)
    {
        $userId = $this->resolveUser($request);
        $guestToken = $this->guestToken($request);

        $orders = Order::with(['items.product.images', 'items.variant.images', 'items.product.digitalFiles', 'payments'])
            ->when($userId, fn ($q) => $q->where('user_id', $userId))
            ->when(! $userId && $guestToken, fn ($q) => $q->where('guest_token', $guestToken))
            ->when(! $userId && ! $guestToken, fn ($q) => $q->whereRaw('1 = 0'))
            ->latest()
            ->paginate($request->per_page ?? 20);

        return response()->json($orders);
    }
}
