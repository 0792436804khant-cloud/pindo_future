# Pindo Future — Massive Educational Platform
## Blueprint & Ground-Zero Foundation (Phase 0)

### 1. Architectural Blueprint Overview
- **Backend Service:** Laravel 11 (API-only architecture, no Blade/frontend views).
- **Mobile Client:** Flutter (Clean Architecture: Domain, Data, Presentation).
- **Primary Database:** PostgreSQL 16 (`pindo_future`).
- **High-Throughput Cache & Sessions:** Redis 7.
- **Dynamic Rooms & Concurrency:** Rooms are bound strictly to **`Session ID`** (not teacher user records), enabling horizontal scaling up to 30,000 concurrent active users without database contention.
- **Live Streaming Infrastructure:** Offloaded to an external WebRTC/SFU cluster (LiveKit / Agora / 100ms). Laravel acts solely as the secure token issuer, permissions engine, and room webhook orchestrator.
- **Teacher Platforms & Deep Links:** Teachers receive an immutable identifier (`teacher_id`, e.g., `TCH_123`) and deep links (`pindofuture.com/teacher/TCH_123`) that route prospective students into the app for payment and automatic course enrollment.

---

### 2. Directory Structure

```text
pindo_future/
├── docker-compose.yml              # Local orchestration (PostgreSQL 16, Redis 7, API)
├── .gitignore
├── README.md
├── backend/                        # Laravel 11 API-Only Service
│   ├── .env.example                # Configured with PostgreSQL defaults
│   ├── .env                        # Local development environment
│   ├── composer.json               # PHP 8.2 + Laravel 11 dependencies
│   ├── Dockerfile                  # Container definition with pdo_pgsql
│   ├── artisan
│   ├── app/
│   │   ├── Http/
│   │   │   └── Controllers/
│   │   │       ├── Controller.php
│   │   │       └── Api/
│   │   │           └── HealthController.php  # Health check & DB verification endpoint
│   │   ├── Models/
│   │   │   └── User.php            # Extended with role & teacher_id
│   │   └── Providers/
│   │       └── AppServiceProvider.php
│   ├── bootstrap/
│   │   ├── app.php                 # Laravel 11 lean routing (/api/v1 prefix)
│   │   └── providers.php
│   ├── config/
│   │   ├── app.php
│   │   ├── cors.php                # Cross-Origin resource sharing for Flutter
│   │   └── database.php            # Configured for PostgreSQL
│   ├── database/
│   │   ├── migrations/
│   │   │   └── 0001_01_01_000000_create_users_table.php
│   │   └── seeders/
│   │       └── DatabaseSeeder.php  # Seeds admin and demo teacher (TCH_123)
│   ├── public/
│   │   └── index.php
│   ├── routes/
│   │   ├── api.php                 # /api/v1/health & /api/v1/ping
│   │   └── console.php
│   └── tests/
│       ├── TestCase.php
│       └── Feature/
│           └── HealthCheckTest.php
│
└── mobile/                         # Flutter Mobile App (Clean Architecture)
    ├── pubspec.yaml
    ├── analysis_options.yaml
    ├── lib/
    │   ├── main.dart
    │   ├── core/
    │   │   ├── constants/
    │   │   │   └── api_constants.dart    # Auto-routes emulator (10.0.2.2) vs localhost
    │   │   ├── errors/
    │   │   │   ├── exceptions.dart
    │   │   │   └── failures.dart
    │   │   ├── network/
    │   │   │   └── api_client.dart       # HTTP client with timeouts & json parser
    │   │   └── theme/
    │   │       └── app_theme.dart        # Platform theme & branding
    │   └── features/
    │       └── health_check/             # Phase 0 Connectivity & Diagnostic Feature
    │           ├── domain/
    │           │   ├── entities/
    │           │   │   └── health_status.dart
    │           │   ├── repositories/
    │           │   │   └── health_repository.dart
    │           │   └── usecases/
    │           │       └── check_health_usecase.dart
    │           ├── data/
    │           │   ├── datasources/
    │           │   │   └── health_remote_datasource.dart
    │           │   ├── models/
    │           │   │   └── health_status_model.dart
    │           │   └── repositories/
    │           │       └── health_repository_impl.dart
    │           └── presentation/
    │               ├── controllers/
    │               │   └── health_controller.dart
    │               ├── screens/
    │               │   └── health_check_screen.dart
    │               └── widgets/
    │                   └── health_metric_tile.dart
    └── test/
        └── features/
            └── health_check/
                └── domain/
                    └── usecases/
                        └── check_health_usecase_test.dart
```

---

### 3. Step-by-Step Instructions: Running and Verifying Connection Locally

#### Step 1: Start PostgreSQL and Redis

**Option A (Using Docker — Recommended):**
From the root `pindo_future` folder:
```powershell
docker compose up -d postgres redis
```
This spins up PostgreSQL on port `5432` with user `postgres` and password `secret`, automatically creating database `pindo_future`.

**Option B (Local PostgreSQL):**
Ensure PostgreSQL is running locally and create the database:
```sql
CREATE DATABASE pindo_future;
```

---

#### Step 2: Initialize and Start the Laravel 11 Backend

1. Navigate to the backend directory:
```powershell
cd backend
```

2. Install Composer dependencies:
```powershell
composer install
```

3. Ensure application key exists:
```powershell
php artisan key:generate
```

4. Run migrations and database seeders:
```powershell
php artisan migrate:fresh --seed
```
*This creates the `users` table with role definitions (`admin`, `teacher`, `student`) and seeds teacher `TCH_123`.*

5. Start the development server:
```powershell
php -S 127.0.0.1:8080 -t public
# or: php artisan serve --port=8080
```

6. Quick sanity test in terminal or browser:
```powershell
curl http://127.0.0.1:8080/api/v1/health
```
Expected response:
```json
{
  "status": "success",
  "platform": "Pindo Future Educational Platform",
  "api_version": "v1.0.0-foundation",
  "services": {
    "api": "operational",
    "database": {
      "driver": "pgsql",
      "connected": true,
      "error": null
    }
  },
  "architecture": {
    "session_model": "dynamic_session_id",
    "target_capacity": "30,000 concurrent users",
    "sfu_infrastructure": "external_webrtc_delegated"
  }
}
```

---

#### Step 3: Launch the Flutter Application

1. Open a second terminal and navigate to the mobile directory:
```powershell
cd mobile
```

2. Install Flutter packages:
```powershell
flutter pub get
```

3. Run the app:
- **Chrome / Web:**
  ```powershell
  flutter run -d chrome
  ```
- **Android Emulator:**
  ```powershell
  flutter run -d emulator-5554
  ```
  *(Note: `ApiConstants` automatically handles `http://10.0.2.2:8000/api/v1` on Android emulator to connect to your host machine's Laravel server).*
- **Windows Desktop:**
  ```powershell
  flutter run -d windows
  ```

4. In the app UI:
   - Verify the endpoint (`http://127.0.0.1:8000/api/v1` or `http://10.0.2.2:8000/api/v1`).
   - Click **"Test Connection & PostgreSQL"**.
   - The screen will display green checkmarks verifying:
     - API Handshake Verified (`v1.0.0-foundation`)
     - Database Engine: `PGSQL • Connected`
     - Architecture Scaling Target: `30,000 concurrent users`
     - Room Model: `dynamic_session_id`

---

### 4. Phase 1: Authentication & Role-Based Access Control (RBAC)

#### A. 4 Strict User Roles & Seeded Accounts

| Role | Email | Password | Role Badge / Scope |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin@pindofuture.com` | `AdminPassword123!` | Full system administration |
| **Teacher** | `teacher.demo@pindofuture.com` | `TeacherPassword123!` | Teacher Studio, Deep Link (`TCH_123`) |
| **Student** | `student.demo@pindofuture.com` | `StudentPassword123!` | Join live rooms (`SES_xxx`), enroll in courses |
| **Parent** | `parent.demo@pindofuture.com` | `ParentPassword123!` | Monitor attendance, tuition, progress |

#### B. API Endpoints

- `POST /api/v1/auth/register`: Register user with strict role (`admin`, `teacher`, `student`, `parent`). Auto-generates `TCH_xxx` for teachers.
- `POST /api/v1/auth/login`: Authenticate and issue Laravel Sanctum Bearer token.
- `GET /api/v1/auth/me`: Protected via `auth:sanctum`. Returns authenticated user, roles, permissions, and `teacher_id`.
- `POST /api/v1/auth/logout`: Protected via `auth:sanctum`. Revokes current access token.

#### C. Flutter Role-Based Routing Matrix

Upon login or app launch with stored token in `flutter_secure_storage`:
- **Admin** ➔ `AdminDashboardScreen`
- **Teacher** ➔ `TeacherDashboardScreen` (displays unique Teacher ID + Platform Deep Link)
- **Student** ➔ `StudentDashboardScreen` (displays Quick Session ID Joiner)
- **Parent** ➔ `ParentDashboardScreen` (displays Guardian Oversight & Progress Tracking)

---

---

### 5. Phase 2: Teacher Platforms & Dynamic Classroom Sessions (SFU WebRTC)

#### A. Architecture & Session Decoupling
- **Session ID Decoupling:** Rooms are bound to `session_id` (`SES_xxxxxxxx`), completely decoupling room runtime from the teacher user record.
- **30,000 Capacity Constraint:** Default room capacity set to `30,000` concurrent users.
- **SFU Offloading (LiveKit WebRTC):** Laravel acts strictly as the token authority, generating cryptographically signed JWT tokens with granular video/audio grants.

#### B. LiveKit JWT Grant Matrix

| Participant Role | `canPublish` | `canSubscribe` | `canPublishData` (Chat) | `roomAdmin` |
| :--- | :--- | :--- | :--- | :--- |
| **Teacher / Host** | `true` | `true` | `true` | `true` |
| **Enrolled Student** | `false` | `true` | `true` (if room chat enabled) | `false` |
| **Parent / Guest** | `false` | `true` | `true` | `false` |

#### C. Phase 2 Endpoints

- `POST /api/v1/teacher/sessions`: Create dynamic room with auto-generated `session_id`.
- `GET /api/v1/teacher/sessions`: List teacher's classroom sessions.
- `POST /api/v1/teacher/sessions/{sessionId}/start`: Start session (`status: active`, `is_live: true`).
- `POST /api/v1/teacher/sessions/{sessionId}/end`: End session (`status: ended`).
- `GET /api/v1/teacher/platform`: Get teacher's platform details and deep link (`pindofuture.com/teacher/TCH_123`).
- `PUT /api/v1/teacher/platform`: Update teacher platform bio and headline.
- `GET /api/v1/sessions/{sessionId}`: Public attendee lookup by `session_id`.
- `POST /api/v1/sessions/{sessionId}/token`: Issue LiveKit SFU JWT access token (role-based grants).
- `POST /api/v1/sessions/{sessionId}/token/verify`: Cryptographically verify LiveKit JWT claims and signature.

---

---

### 6. Phase 3: Flutter Live Classroom & Video Integration (LiveKit SFU)

#### A. Architecture & Video Rendering
- **Clean Architecture Layers:**
  - `domain`: `RoomConnectionDetails` entity, `GetRoomTokenUseCase`
  - `data`: `ClassroomRemoteDataSource`, `ClassroomRepositoryImpl`
  - `services`: `LiveKitRoomService` managing `Room`, adaptive streams, and dynacast
  - `presentation`: `ClassroomController`, `LiveClassroomScreen`, `VideoTrackCard`, `ClassroomControlsBar`
- **Stage Layout:**
  - Instructor spotlight view (`isMainStage: true`) with speaking detection glow.
  - Multi-participant video filmstrip.
  - Avatar placeholder with initial and "Camera Off" badge when video track is muted.
- **Hardware Controls:**
  - Microphones and cameras dynamically toggled via LiveKit `localParticipant` APIs.
  - Permission requests handled via `permission_handler` on Android/iOS.
  - Student "Raise Hand" integration with real-time feedback.

#### B. Dashboard Integrations
- **Student Dashboard:** Directly connect to live sessions by inputting any valid `session_id` (`SES_...`).
- **Teacher Dashboard:** 1-tap "Launch Dynamic Session" creates a room with 30,000 capacity, starts it, and enters stage with publisher controls.

---

### 7. Roadmap to Next Phase
- **Phase 4:** Live Interactive Classroom Chat & Student Engagement (Real-time data messages, raise hand queue, mute management).

