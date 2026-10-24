<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Video & Audio Streaming SFU Provider
    |--------------------------------------------------------------------------
    |
    | Pindo Future delegates WebRTC media routing to external SFU clusters.
    | Laravel manages cryptographic access tokens and session permissions.
    |
    */

    'provider' => env('SFU_PROVIDER', 'livekit'),

    'livekit' => [
        'url' => env('LIVEKIT_URL', 'wss://livekit.pindofuture.com'),
        'api_key' => env('LIVEKIT_API_KEY', 'devkey_pindo_future'),
        'api_secret' => env('LIVEKIT_API_SECRET', 'secret_pindo_future_webrtc_cluster_key_123'),
        'token_ttl' => (int) env('LIVEKIT_TOKEN_TTL', 21600), // 6 hours in seconds
    ],

];
