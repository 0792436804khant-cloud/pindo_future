<?php

namespace Tests\Feature;

use Tests\TestCase;

class HealthCheckTest extends TestCase
{
    /**
     * Test health check endpoint returns 200 and expected blueprint parameters.
     */
    public function test_health_check_endpoint_returns_successful_payload(): void
    {
        $response = $this->getJson('/api/v1/health');

        $response->assertStatus(200)
            ->assertJsonPath('status', 'success')
            ->assertJsonPath('platform', 'Pindo Future Educational Platform')
            ->assertJsonPath('architecture.target_capacity', '30,000 concurrent users')
            ->assertJsonPath('architecture.session_model', 'dynamic_session_id');
    }

    /**
     * Test ping endpoint.
     */
    public function test_ping_endpoint(): void
    {
        $response = $this->getJson('/api/v1/ping');

        $response->assertStatus(200)
            ->assertJson(['message' => 'pong']);
    }
}
