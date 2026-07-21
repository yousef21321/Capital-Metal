<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $fillable = [
        'name', 'slug', 'description', 'product_type', 'price_egp', 'price_usd',
        'platform_commission_egp', 'platform_commission_usd',
        'designer_price_egp', 'designer_price_usd',
        'tester_suggested_price_egp', 'tester_suggested_price_usd',
        'tester_comment', 'tested_by', 'tested_at',
        'cost', 'status', 'publish_date', 'country_availability', 'designer_id',
        'material', 'manufacturing_method', 'tags', 'design_file_path', 'type_sample',
        'ticket_id',
    ];

    protected function casts(): array
    {
        return [
            'price_egp' => 'decimal:2',
            'price_usd' => 'decimal:2',
            'platform_commission_egp' => 'decimal:2',
            'platform_commission_usd' => 'decimal:2',
            'designer_price_egp' => 'decimal:2',
            'designer_price_usd' => 'decimal:2',
            'cost' => 'decimal:2',
            'publish_date' => 'datetime',
            'tags' => 'array',
        ];
    }

    public function designer()
    {
        return $this->belongsTo(User::class, 'designer_id');
    }

    public function ticket()
    {
        return $this->belongsTo(Ticket::class);
    }

    public function images()
    {
        return $this->hasMany(ProductImage::class)->orderBy('sort_order');
    }

    public function inventory()
    {
        return $this->hasOne(Inventory::class);
    }

    public function digitalFiles()
    {
        return $this->hasMany(DigitalFile::class);
    }

    public function licenseAgreements()
    {
        return $this->hasMany(LicenseAgreement::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function cartItems()
    {
        return $this->hasMany(CartItem::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function wishlist()
    {
        return $this->hasMany(Wishlist::class);
    }

    public function analytics()
    {
        return $this->hasOne(ProductAnalytics::class);
    }

    public function variants()
    {
        return $this->hasMany(ProductVariant::class)->orderBy('sort_order');
    }
}
