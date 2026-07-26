<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'resend' => [
        'key' => env('RESEND_KEY'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'paymob' => [
        'api_key' => env('PAYMOB_API_KEY'),
        'public_key' => env('PAYMOB_PUBLIC_KEY'),
        'merchant_id' => env('PAYMOB_MERCHANT_ID'),
        'integration_id' => env('PAYMOB_INTEGRATION_ID'),
        'iframe_id' => env('PAYMOB_IFRAME_ID'),
        'hmac' => env('PAYMOB_HMAC'),
    ],

    'stox' => [
        'token' => env('STOX_TOKEN'),
        'cod_payment_method_id' => env('STOX_COD_PAYMENT_METHOD_ID', 2),
        'area_mapping' => [
            'default' => null,
            'cairo' => null,
            'giza' => null,
            'alexandria' => null,
            'qalyubia' => null,
            'sharqia' => null,
            'gharbia' => null,
            'menofia' => null,
            'kafr el sheikh' => null,
            'beheira' => null,
            'dakahlia' => null,
            'damietta' => null,
            'ismailia' => null,
            'port said' => null,
            'suez' => null,
            'beni suef' => null,
            'fayoum' => null,
            'minya' => null,
            'assiut' => null,
            'sohag' => null,
            'qena' => null,
            'luxor' => null,
            'aswan' => null,
            'red sea' => null,
            'new valley' => null,
            'matrouh' => null,
            'north sinai' => null,
            'south sinai' => null,
        ],
    ],

    'google' => [
        'client_id' => env('GOOGLE_CLIENT_ID'),
        'client_secret' => env('GOOGLE_CLIENT_SECRET'),
        'redirect' => env('GOOGLE_REDIRECT', '/auth/google/callback'),
    ],

];
