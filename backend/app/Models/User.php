<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role_id',
        'phone',
        'is_active',
        'is_verified',
        'two_factor_enabled',
        'two_factor_secret',
        'reset_token',
        'reset_token_expiry',
        'currency_preference',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'two_factor_secret',
        'reset_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_active' => 'boolean',
            'is_verified' => 'boolean',
            'two_factor_enabled' => 'boolean',
            'reset_token_expiry' => 'datetime',
        ];
    }

    public function role()
    {
        return $this->belongsTo(Role::class);
    }

    public function hasRole(string $roleName): bool
    {
        return $this->role && $this->role->name === $roleName;
    }

    public function hasAnyRole(array $roleNames): bool
    {
        return $this->role && in_array($this->role->name, $roleNames);
    }

    public function addresses()
    {
        return $this->hasMany(Address::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    public function cart()
    {
        return $this->hasOne(Cart::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function wishlist()
    {
        return $this->hasMany(Wishlist::class);
    }

    public function affiliate()
    {
        return $this->hasOne(Affiliate::class);
    }

    public function activityLogs()
    {
        return $this->hasMany(ActivityLog::class);
    }

    public function customerAnalytics()
    {
        return $this->hasOne(CustomerAnalytics::class);
    }

    public function sessions()
    {
        return $this->hasMany(VisitorSession::class);
    }

    public function subscriptions()
    {
        return $this->hasMany(UserSubscription::class);
    }

    public function activeSubscription()
    {
        return $this->hasOne(UserSubscription::class)
            ->where('status', 'active')
            ->where(function ($q) {
                $q->whereNull('end_date')->orWhere('end_date', '>', now());
            })
            ->latestOfMany('id');
    }

    public function ticketsAsIndustor()
    {
        return $this->hasMany(Ticket::class, 'industor_id');
    }

    public function ticketsAsTester()
    {
        return $this->hasMany(Ticket::class, 'tester_id');
    }

    public function ticketsAsDesigner()
    {
        return $this->hasMany(Ticket::class, 'designer_id');
    }

    public function designerProducts()
    {
        return $this->hasMany(Product::class, 'designer_id');
    }

    public function modificationRequests()
    {
        return $this->hasMany(TicketModificationRequest::class, 'designer_id');
    }

    public function designerPool()
    {
        return $this->belongsToMany(User::class, 'industor_designers', 'industor_id', 'designer_id')
            ->withPivot('is_active', 'created_at')
            ->wherePivot('is_active', true);
    }

    public function industorClients()
    {
        return $this->belongsToMany(User::class, 'industor_designers', 'designer_id', 'industor_id')
            ->withPivot('is_active');
    }

    public function appNotifications()
    {
        return $this->hasMany(Notification::class);
    }

    public function roles()
    {
        return $this->hasMany(UserRoleAssignment::class);
    }

    public function cartAnalytics()
    {
        return $this->hasMany(CartAnalytics::class);
    }

    public function savedCards()
    {
        return $this->hasMany(SavedCard::class);
    }

    public function defaultSavedCard()
    {
        return $this->hasOne(SavedCard::class)->where('is_default', true)->latestOfMany();
    }
}
