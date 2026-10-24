<?php

namespace App\Services\Streaming;

use App\Models\ClassroomSession;
use App\Models\User;
use InvalidArgumentException;

class LiveKitTokenService
{
    protected string $apiKey;
    protected string $apiSecret;
    protected string $serverUrl;
    protected int $tokenTtl;

    public function __construct(
        ?string $apiKey = null,
        ?string $apiSecret = null,
        ?string $serverUrl = null,
        ?int $tokenTtl = null
    ) {
        $this->apiKey = $apiKey ?? config('streaming.livekit.api_key', 'devkey_pindo_future');
        $this->apiSecret = $apiSecret ?? config('streaming.livekit.api_secret', 'secret_pindo_future_webrtc_cluster_key_123');
        $this->serverUrl = $serverUrl ?? config('streaming.livekit.url', 'wss://livekit.pindofuture.com');
        $this->tokenTtl = $tokenTtl ?? config('streaming.livekit.token_ttl', 21600);
    }

    public function getServerUrl(): string
    {
        return $this->serverUrl;
    }

    /**
     * Create token for a Teacher / Host (Publisher + Room Admin grants).
     */
    public function createTeacherToken(ClassroomSession $session, User $teacher): array
    {
        $grants = [
            'room' => $session->session_id,
            'roomJoin' => true,
            'canPublish' => true,
            'canSubscribe' => true,
            'canPublishData' => true,
            'roomAdmin' => true,
            'roomRecord' => (bool) ($session->settings['recording_enabled'] ?? false),
        ];

        $metadata = [
            'user_id' => $teacher->id,
            'role' => 'teacher',
            'teacher_id' => $teacher->teacher_id,
            'session_id' => $session->session_id,
        ];

        $token = $this->generateJwt(
            identity: "teacher_{$teacher->id}",
            name: $teacher->name,
            grants: $grants,
            metadata: $metadata
        );

        return [
            'token' => $token,
            'server_url' => $this->serverUrl,
            'room' => $session->session_id,
            'identity' => "teacher_{$teacher->id}",
            'role' => 'teacher',
            'can_publish' => true,
            'can_subscribe' => true,
            'expires_in' => $this->tokenTtl,
        ];
    }

    /**
     * Create token for an enrolled Student (Subscriber + Chat Data grant).
     */
    public function createStudentToken(ClassroomSession $session, User $student): array
    {
        $canChat = (bool) ($session->settings['allow_chat'] ?? true);

        $grants = [
            'room' => $session->session_id,
            'roomJoin' => true,
            'canPublish' => false, // Listen-only subscriber
            'canSubscribe' => true,
            'canPublishData' => $canChat,
            'roomAdmin' => false,
            'roomRecord' => false,
        ];

        $watermark = $student->guardian_link_code
            ? "{$student->name} • {$student->guardian_link_code}"
            : "{$student->name} • {$student->email}";

        $metadata = [
            'user_id' => $student->id,
            'role' => 'student',
            'session_id' => $session->session_id,
            'watermark' => $watermark,
        ];

        $token = $this->generateJwt(
            identity: "student_{$student->id}",
            name: $student->name,
            grants: $grants,
            metadata: $metadata
        );

        return [
            'token' => $token,
            'server_url' => $this->serverUrl,
            'room' => $session->session_id,
            'identity' => "student_{$student->id}",
            'role' => 'student',
            'watermark_text' => $watermark,
            'can_publish' => false,
            'can_subscribe' => true,
            'expires_in' => $this->tokenTtl,
        ];
    }

    /**
     * Create token for a Parent or Guest attendee.
     */
    public function createAttendeeToken(
        ClassroomSession $session,
        string $identity,
        string $name,
        string $role = 'attendee'
    ): array {
        $canChat = (bool) ($session->settings['allow_chat'] ?? true);

        $grants = [
            'room' => $session->session_id,
            'roomJoin' => true,
            'canPublish' => false,
            'canSubscribe' => true,
            'canPublishData' => $canChat,
            'roomAdmin' => false,
            'roomRecord' => false,
        ];

        $metadata = [
            'role' => $role,
            'session_id' => $session->session_id,
        ];

        $token = $this->generateJwt(
            identity: $identity,
            name: $name,
            grants: $grants,
            metadata: $metadata
        );

        return [
            'token' => $token,
            'server_url' => $this->serverUrl,
            'room' => $session->session_id,
            'identity' => $identity,
            'role' => $role,
            'can_publish' => false,
            'can_subscribe' => true,
            'expires_in' => $this->tokenTtl,
        ];
    }

    /**
     * Generate an RFC 7519 compliant HMAC-SHA256 JWT specifically formatted for LiveKit SFU.
     */
    public function generateJwt(
        string $identity,
        string $name,
        array $grants,
        array $metadata = []
    ): string {
        $issuedAt = time();
        $notBefore = $issuedAt - 10; // 10s clock drift allowance
        $expiresAt = $issuedAt + $this->tokenTtl;

        $header = [
            'alg' => 'HS256',
            'typ' => 'JWT',
        ];

        $payload = [
            'iss' => $this->apiKey,
            'sub' => $identity,
            'iat' => $issuedAt,
            'nbf' => $notBefore,
            'exp' => $expiresAt,
            'name' => $name,
            'metadata' => json_encode($metadata),
            'video' => $grants,
        ];

        $encodedHeader = $this->base64UrlEncode(json_encode($header));
        $encodedPayload = $this->base64UrlEncode(json_encode($payload));

        $signature = hash_hmac(
            'sha256',
            "{$encodedHeader}.{$encodedPayload}",
            $this->apiSecret,
            true
        );

        $encodedSignature = $this->base64UrlEncode($signature);

        return "{$encodedHeader}.{$encodedPayload}.{$encodedSignature}";
    }

    /**
     * Validate and decode a LiveKit JWT token.
     */
    public function validateToken(string $token): array
    {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            throw new InvalidArgumentException('Malformed JWT token structure.');
        }

        [$encodedHeader, $encodedPayload, $encodedSignature] = $parts;

        // Verify Signature
        $expectedSignature = hash_hmac(
            'sha256',
            "{$encodedHeader}.{$encodedPayload}",
            $this->apiSecret,
            true
        );

        if (! hash_equals($this->base64UrlDecode($encodedSignature), $expectedSignature)) {
            throw new InvalidArgumentException('Invalid JWT signature.');
        }

        $payload = json_decode($this->base64UrlDecode($encodedPayload), true);
        if (! is_array($payload)) {
            throw new InvalidArgumentException('Invalid JWT payload.');
        }

        // Verify Expiration
        if (isset($payload['exp']) && time() >= $payload['exp']) {
            throw new InvalidArgumentException('JWT token has expired.');
        }

        // Verify Not Before
        if (isset($payload['nbf']) && time() < $payload['nbf']) {
            throw new InvalidArgumentException('JWT token is not valid yet.');
        }

        return $payload;
    }

    protected function base64UrlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    protected function base64UrlDecode(string $data): string
    {
        $remainder = strlen($data) % 4;
        if ($remainder) {
            $data .= str_repeat('=', 4 - $remainder);
        }

        return base64_decode(strtr($data, '-_', '+/'));
    }
}
