<?php

use App\Http\Controllers\FacebookFeedController;
use App\Http\Controllers\SeoController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/products/{slug}', [SeoController::class, 'productShow']);

Route::get('/main-categories/{slug}', [SeoController::class, 'mainCategoryShow']);

Route::get('/facebook/products.xml', [FacebookFeedController::class, 'products']);
