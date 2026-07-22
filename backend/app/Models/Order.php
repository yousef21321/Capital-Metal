<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = [
        'user_id', 'guest_token', 'order_number', 'affiliate_id', 'currency', 'subtotal',
        'shipping_cost', 'discount', 'coupon_id', 'total_amount',
        'payment_status', 'order_status', 'shipping_tracking_number', 'stox_order_id', 'notes',
        'guest_name', 'guest_phone', 'guest_governorate', 'guest_city',
        'guest_address_line', 'guest_postal_code',
    ];

    protected function casts(): array
    {
        return [
            'subtotal' => 'decimal:2',
            'shipping_cost' => 'decimal:2',
            'discount' => 'decimal:2',
            'total_amount' => 'decimal:2',
        ];
    }

    public function coupon()
    {
        return $this->belongsTo(Coupon::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function affiliate()
    {
        return $this->belongsTo(Affiliate::class);
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function payments()
    {
        return $this->hasMany(Payment::class);
    }

    public function refunds()
    {
        return $this->hasMany(Refund::class);
    }

    public function affiliateEarnings()
    {
        return $this->hasMany(AffiliateEarning::class);
    }

    public function financialAnalytics()
    {
        return $this->hasOne(FinancialAnalytics::class);
    }
}
