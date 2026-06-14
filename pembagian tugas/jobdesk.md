# Pembagian Tugas Kelompok (Jobdesk) - Projek NalaSeva

Pembagian ini menggunakan **Model Vertikal (Vertical Slicing)** — setiap anggota mengerjakan Backend (Laravel) dan Frontend (Flutter) untuk modulnya masing-masing.

> [!NOTE]
> **Pembaruan Pasca-Implementasi:** Seluruh file Flutter diorganisasi ulang menggunakan **arsitektur feature-first** — setiap fitur memiliki sub-folder `ui/`, `data/`, `logic/`, dan `widgets/` sendiri (contoh: `lib/features/admin/queue/ui/`, `lib/features/patient/booking/ui/`). Path di bawah mencerminkan struktur akhir yang aktual. Modul `payment` (F) dibubarkan dari feature tersendiri; `PaymentProvider` & `PaymentRepository` dipindah ke `lib/shared/`, sedangkan layar UI-nya dibagi ke sisi `patient/payment/ui/` dan `admin/payment/ui/`.

---

## ⚖️ Analisis Keseimbangan Beban Kerja

Sebelum pembagian, semua file diinventarisasi dan dibobot berdasarkan **jumlah + ukuran/kompleksitas** file:

| Anggota | Controllers | Services | Models | Form Requests | Migrations | Seeders | Flutter UI |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **A** | 3 | 3 | 3 | 3 | 4 | 5 | 7 |
| **B** | 5 | 1 | 5 | 10 | 5 | 3 | 7 |
| **C** | 2 | 1 | 2 | 4 | 2 | 0 | 10 |
| **D** | 5 | 0 | 4 | 2 | 4 | 1 | 14 |

> [!NOTE]
> Migrations dan FormRequests (Request Validation) turut dibagi secara merata karena keduanya adalah bagian nyata dari pekerjaan backend Laravel.

---

## 🚦 Sprint 0 — Setup Fondasi Bersama (Sebelum Mulai Coding Fitur)

> [!IMPORTANT]
> Kerjakan tabel di bawah ini **terlebih dahulu secara bersama-sama** sebelum masing-masing anggota mulai mengerjakan fitur modul. Ini memastikan tidak ada yang *stuck* menunggu.

| Tugas | PIC | File |
| :--- | :--- | :--- |
| Setup HTTP client Flutter (base URL, auth header, error handling) | **A** | [api_client.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/api/api_client.dart) |
| Setup router & navigasi Flutter (semua named routes didaftarkan di sini) | **C** | [app_router.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/router/app_router.dart) |
| Jalankan semua migration & seeder, pastikan DB lokal tim berjalan | **B** | [DatabaseSeeder.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/database/seeders/DatabaseSeeder.php) |
| Bagikan file Postman Collection dari API.md ke seluruh anggota | **A** | [API.md](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/dokumentasi/API.md) |

---

## 📊 Ringkasan File per Anggota

| Anggota | Modul | Controllers | Services | Models | Request Forms | Migrations | Seeders | Flutter UI | Flutter Models |
| :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **A** | Auth, Notifikasi & Pengaturan | 3 | 3 | 3 | 4 | 4 | 5 | 7 | 3 |
| **B** | Master Data (Poli, Dokter, Jadwal, Cuti, Libur) | 5 | 1 | 5 | 10 | 5 | 3 | 7 | 3 |
| **C** | Antrean, QR Scanner & Pasien | 2 | 1 | 2 | 4 | 2 | 0 | 10 | 2 |
| **D** | Pemeriksaan, Pembayaran, Farmasi & Dashboard | 5 | 0 | 4 | 2 | 4 | 1 | 14 | 5 |

---

## 📄 Rincian File Kode per Anggota

---

### 🛡️ Anggota A — Auth, User Management & Push Notification
**Peran Tambahan: 🔑 Git Coordinator** (Me-*merge* branch semua anggota ke `main` & menjaga `routes/api.php` bebas konflik)

Mengerjakan fondasi keamanan: login, registrasi, reset password via OTP, manajemen profil user, data puskesmas, konfigurasi setting, dan push notification.

#### Backend (Laravel)
*   **Controllers:**
    *   [AuthController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/AuthController.php) — Login, register pasien mandiri, logout, profil aktif, update profil, verifikasi OTP, update FCM token.
    *   [UserController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/UserController.php) — Manajemen akun user (blokir, aktifkan, ubah role).
    *   [PuskesmasProfileController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/PuskesmasProfileController.php) — Ambil & perbarui data klinik (alamat, logo, koordinat GPS).
*   **Services:**
    *   [AuthService.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Services/AuthService.php) — Logic token Sanctum, OTP, registrasi.
    *   [FirebaseNotificationService.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Services/FirebaseNotificationService.php) — Kirim push notification server → perangkat via FCM.
    *   [PuskesmasProfileService.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Services/PuskesmasProfileService.php) — Logic update profil klinik.
*   **Models:**
    *   [User.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Models/User.php)
    *   [PuskesmasProfile.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Models/PuskesmasProfile.php)
    *   [Setting.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Models/Setting.php)
*   **Form Requests (Validasi):**
    *   [StoreUserRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/StoreUserRequest.php)
    *   [UpdateUserRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/UpdateUserRequest.php)
    *   [UpdatePuskesmasProfileRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/UpdatePuskesmasProfileRequest.php)
*   **Migrations:**
    *   `create_users_table.php`
    *   `create_personal_access_tokens_table.php`
    *   `create_password_reset_otps_table.php`
    *   `create_settings_table.php`
*   **Seeders:**
    *   [DatabaseSeeder.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/database/seeders/DatabaseSeeder.php)
    *   [AdminSeeder.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/database/seeders/AdminSeeder.php)
    *   [PharmacistSeeder.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/database/seeders/PharmacistSeeder.php)
    *   [PuskesmasProfileSeeder.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/database/seeders/PuskesmasProfileSeeder.php)
    *   [SettingSeeder.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/database/seeders/SettingSeeder.php)
*   **Routes (dikelola A sebagai Git Coordinator):**
    *   [api.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/routes/api.php)

#### Frontend (Flutter)
*   **Core (Sprint 0):**
    *   [api_client.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/api/api_client.dart) — Dio HTTP client dengan Bearer token interceptor & global error handler (auto-logout jika 401).
    *   [firebase_messaging_service.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/services/firebase_messaging_service.dart) — Inisialisasi Firebase Messaging & sinkronisasi FCM token ke backend.
    *   [firebase_options.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/firebase_options.dart)
    *   [main.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/main.dart) — Entry point app: Provider setup, FCM listener, & `SessionTimeoutListener` global.
    *   [session_timeout_listener.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/widgets/session_timeout_listener.dart) — Widget global yang memicu auto logout pasien setelah **15 menit** tidak ada interaksi layar.
*   **Auth UI (`lib/features/auth/ui/`):**
    *   [login_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/ui/login_screen.dart)
    *   [register_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/ui/register_screen.dart) — Form 8 kolom: NIK 16-digit, Nama Lengkap, Email, Jenis Kelamin, Tgl Lahir, No. WhatsApp, Alamat, Password.
    *   [forgot_password_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/ui/forgot_password_screen.dart) — Alur OTP 2 langkah: Request OTP (berlaku 15 menit) → Reset Password (force logout semua sesi).
*   **Profil Pasien (`lib/features/patient/profile/ui/`):**
    *   [profile_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/profile/ui/profile_screen.dart) — Tampilan data akun pasien terdaftar.
    *   [edit_profile_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/profile/ui/edit_profile_screen.dart) — Edit profil pasien; NIK bersifat **read-only** (tidak dapat diubah mandiri).
*   **User Management & Settings — Admin (`lib/features/admin/`):**
    *   [user_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/user/ui/user_management_screen.dart) — CRUD akun user & penentuan role (`admin`, `doctor`, `patient`, `pharmacist`).
    *   [admin_settings_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/settings/ui/admin_settings_screen.dart) — Konfigurasi `registration_fee`, `slot_duration_minutes`, profil puskesmas, dan **Map Picker** koordinat GPS (OpenStreetMap).
*   **Flutter Shared (terkait modul A):**
    *   [user_model.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/user_model.dart)
    *   [puskesmas_profile_model.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/puskesmas_profile_model.dart)
    *   [puskesmas_profile_provider.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/providers/puskesmas_profile_provider.dart)
    *   [puskesmas_profile_repository.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/repositories/puskesmas_profile_repository.dart)
    *   [auth_provider.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/logic/auth_provider.dart)
    *   [auth_repository.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/data/auth_repository.dart)

---

### 🏥 Anggota B — Master Data (Poliklinik, Dokter, Jadwal, Cuti & Libur)
**Peran Tambahan: 🗄️ Database Owner** (Pastikan semua migration & seeder tim berjalan dan DB lokal sinkron)

Mengerjakan seluruh data operasional dasar puskesmas yang dikelola Administrator.

#### Backend (Laravel)
*   **Controllers:**
    *   [PolyclinicController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/PolyclinicController.php) — CRUD poliklinik + soft delete & restore.
    *   [DoctorController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/DoctorController.php) — CRUD dokter (registrasi user+doctor secara transaksional).
    *   [DoctorScheduleController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/DoctorScheduleController.php) — CRUD jadwal praktik (validasi anti-bentrok jam).
    *   [ClinicHolidayController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/ClinicHolidayController.php) — CRUD hari libur puskesmas.
    *   [DoctorLeaveController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/DoctorLeaveController.php) — CRUD cuti/absen dokter.
*   **Services:**
    *   [DoctorService.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Services/DoctorService.php) — Logic relasi dokter-poliklinik, validasi jadwal bentrok, restore akun.
*   **Models:**
    *   [Polyclinic.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Models/Polyclinic.php)
    *   [Doctor.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Models/Doctor.php)
    *   [DoctorSchedule.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Models/DoctorSchedule.php)
    *   [ClinicHoliday.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Models/ClinicHoliday.php)
    *   [DoctorLeave.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Models/DoctorLeave.php)
*   **Form Requests:**
    *   [StorePolyclinicRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/StorePolyclinicRequest.php)
    *   [UpdatePolyclinicRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/UpdatePolyclinicRequest.php)
    *   [StoreDoctorRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/StoreDoctorRequest.php)
    *   [UpdateDoctorRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/UpdateDoctorRequest.php)
    *   [StoreDoctorScheduleRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/StoreDoctorScheduleRequest.php)
    *   [UpdateDoctorScheduleRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/UpdateDoctorScheduleRequest.php)
    *   [StoreClinicHolidayRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/StoreClinicHolidayRequest.php)
    *   [UpdateClinicHolidayRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/UpdateClinicHolidayRequest.php)
    *   [StoreDoctorLeaveRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/StoreDoctorLeaveRequest.php)
    *   [UpdateDoctorLeaveRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/UpdateDoctorLeaveRequest.php)
*   **Migrations:**
    *   `create_polyclinics_table.php`
    *   `create_doctors_table.php`
    *   `create_doctor_schedules_table.php`
    *   `create_doctor_leaves_table.php`
    *   `create_clinic_holidays_table.php`
*   **Seeders:**
    *   [PolyclinicSeeder.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/database/seeders/PolyclinicSeeder.php)
    *   [DoctorSeeder.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/database/seeders/DoctorSeeder.php)
    *   [DoctorScheduleSeeder.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/database/seeders/DoctorScheduleSeeder.php)

#### Frontend (Flutter)
*   **Admin — Manajemen Poliklinik (`lib/features/admin/polyclinic/ui/`):**
    *   [polyclinic_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/polyclinic/ui/polyclinic_management_screen.dart) — CRUD poliklinik + kode awalan nomor antrean (contoh: `UMM`, `GIG`).
*   **Admin — Manajemen Dokter (`lib/features/admin/doctor/ui/`):**
    *   [doctor_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/doctor/ui/doctor_management_screen.dart) — CRUD dokter (buat user + profil dokter secara transaksional).
    *   [doctor_schedule_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/doctor/ui/doctor_schedule_management_screen.dart) — CRUD jadwal praktik dengan validasi anti-bentrok jam (`overlap detection`).
    *   [admin_doctor_leaves_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/doctor/ui/admin_doctor_leaves_screen.dart) — CRUD cuti dokter + auto-cancel antrean terdampak & notifikasi FCM ke pasien.
*   **Admin — Manajemen Hari Libur (`lib/features/admin/clinic_holiday/ui/`):**
    *   [admin_clinic_holidays_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/clinic_holiday/ui/admin_clinic_holidays_screen.dart) — CRUD hari libur puskesmas + mass-cancel semua antrean terdampak.
*   **Profil Dokter (`lib/features/doctor/profile/ui/`):**
    *   [doctor_profile_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/profile/ui/doctor_profile_screen.dart) — Tampilan profil detail dokter (nama, spesialisasi, SIP, poliklinik).
    *   [doctor_edit_profile_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/profile/ui/doctor_edit_profile_screen.dart) — Edit data profil personal dokter.
*   **Flutter Shared (terkait modul B):**
    *   [doctor_model.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/doctor_model.dart)
    *   [polyclinic_model.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/polyclinic_model.dart)
    *   [schedule_model.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/schedule_model.dart)
    *   [admin_repository.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart) — Berisi metode terkait modul B: `fetchDoctors()`, `fetchSchedules()`, `fetchPolyclinics()`, `fetchDoctorLeaves()`, `fetchClinicHolidays()`.
    *   [admin_provider.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/logic/admin_provider.dart) — State management CRUD untuk semua master data admin (dipakai bersama A & B).

---

### 🎫 Anggota C — Antrean & Pasien
**Peran Tambahan: ⚙️ Core Logic Lead** (QueueService adalah file paling kompleks di seluruh sistem — perlu dikoordinasikan dengan B dan D)

> [!WARNING]
> **Dependency dua arah:** Modul C membutuhkan data dokter/jadwal dari **B**. Output antrean selesai dari C menjadi trigger untuk proses pembayaran di **D**. Koordinasikan timeline dengan keduanya.

Mengerjakan inti pelayanan: booking, QR check-in, manajemen antrean loket, dan data rekam profil pasien.

#### Backend (Laravel)
*   **Controllers:**
    *   [QueueController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/QueueController.php) — Booking antrean, QR check-in, panggil/skip/recall, validasi kuota & hari libur.
    *   [PatientController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/PatientController.php) — CRUD data pasien & nomor rekam medis.
*   **Services:**
    *   [QueueService.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Services/QueueService.php) — Logika kalkulasi nomor urut, estimasi waktu, validasi status antrean, dan trigger notifikasi FCM saat pasien dipanggil.
*   **Models:**
    *   [Queue.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Models/Queue.php)
    *   [Patient.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Models/Patient.php)
*   **Form Requests:**
    *   [StoreQueueRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/StoreQueueRequest.php)
    *   [UpdateQueueRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/UpdateQueueRequest.php)
    *   [StorePatientRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/StorePatientRequest.php)
    *   [UpdatePatientRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/UpdatePatientRequest.php)
*   **Migrations:**
    *   `create_patients_table.php`
    *   `create_queues_table.php`

#### Frontend (Flutter)
*   **Core (Sprint 0):**
    *   [app_router.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/router/app_router.dart) — Semua named routes & RBAC guard (role check sebelum render, navigasi global via `GlobalKey<NavigatorState>`).
*   **Dashboard Pasien (`lib/features/patient/dashboard/ui/`):**
    *   [patient_dashboard.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/dashboard/ui/patient_dashboard.dart) — Status antrean hari ini, jalan pintas menu, info ringkas puskesmas.
*   **Booking Antrean (`lib/features/patient/booking/ui/`):**
    *   [booking_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/booking/ui/booking_screen.dart) — Alur pemesanan mandiri (maks. H-7): pilih poli → dokter → tanggal → jadwal → konfirmasi. Validasi 5-layer client+server.
    *   [booking_detail_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/booking/ui/booking_detail_screen.dart) — Tiket antrean digital dengan **QR Code unik** (`NALASEVA_QUEUE_{id}`) + estimasi waktu tunggu adaptif.
*   **Riwayat (`lib/features/patient/history/ui/`):**
    *   [patient_history_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/history/ui/patient_history_screen.dart) — Riwayat rekam medis pasien dengan **filter pencarian per rentang bulan**.
*   **Notifikasi (`lib/features/patient/notification/ui/`):**
    *   [notification_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/notification/ui/notification_screen.dart) — Kotak masuk push notification aktivitas antrean & pembayaran.
*   **Admin — Loket Antrean (`lib/features/admin/queue/ui/`):**
    *   [queue_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/queue/ui/queue_management_screen.dart) — Panel loket: Check-in manual, Panggil, Skip/Geser Belakang, Recall antrean.
    *   [admin_booking_detail_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/queue/ui/admin_booking_detail_screen.dart) — Detail tiket antrean admin dengan tombol TTS panggil suara & tindakan status operasional.
    *   [qr_scanner_page.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/queue/ui/qr_scanner_page.dart) — Scanner QR Code tiket pasien via `mobile_scanner`; mendukung format `NALASEVA_QUEUE_{id}` & nomor antrean teks.
*   **Admin — Widget Antrean (`lib/features/admin/queue/widgets/`):**
    *   [admin_voice_call_dialog.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/queue/widgets/admin_voice_call_dialog.dart) — Dialog visual panggilan suara loket: validasi `ServiceTimeValidator` → TTS → ubah status ke `examining`.
*   **Admin — Manajemen Pasien (`lib/features/admin/patient/ui/`):**
    *   [patient_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/patient/ui/patient_management_screen.dart) — CRUD data pasien oleh admin & daftar pencarian rekam pasien di loket.
*   **Flutter Shared (terkait modul C):**
    *   [queue_model.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/queue_model.dart)
    *   [patient_model.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/patient_model.dart)
    *   [patient_provider.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/logic/patient_provider.dart)
    *   [patient_repository.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart)

---

### 💊 Anggota D — Pemeriksaan Medis, Pembayaran, Farmasi & Dashboard
**Peran Tambahan: 📊 Visual & Finance Lead** (Bertanggung jawab atas semua output akhir dan laporan)

Mengerjakan rekam medis dokter, sistem kasir, manajemen stok obat, farmasi/apoteker, dan dashboard statistik visual.

#### Backend (Laravel)
*   **Controllers:**
    *   [ExaminationController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/ExaminationController.php) — Simpan rekam medis, diagnosis, tindakan, dan proses resep obat (potong stok otomatis).
    *   [PaymentController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/PaymentController.php) — Generate tagihan, upload bukti bayar, verifikasi nontunai & tunai.
    *   [PharmacyController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/PharmacyController.php) — Antrean resep siap racik (sudah lunas).
    *   [MedicineController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/MedicineController.php) — CRUD inventaris obat.
    *   [DashboardController.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Controllers/Api/DashboardController.php) — Agregat statistik harian (total pasien, antrean, grafik per poli).
*   **Models:**
    *   [Examination.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Models/Examination.php)
    *   [Payment.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Models/Payment.php)
    *   [Medicine.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Models/Medicine.php)
    *   [PrescriptionItem.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Models/PrescriptionItem.php)
*   **Form Requests:**
    *   [StoreExaminationRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/StoreExaminationRequest.php)
    *   [UpdateExaminationRequest.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/app/Http/Requests/UpdateExaminationRequest.php)
*   **Migrations:**
    *   `create_examinations_table.php`
    *   `create_medicines_table.php`
    *   `create_prescription_items_table.php`
    *   `create_payments_table.php`
*   **Seeders:**
    *   [MedicineSeeder.php](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/database/seeders/MedicineSeeder.php)

#### Frontend (Flutter)
*   **Dokter — Dashboard (`lib/features/doctor/dashboard/ui/`):**
    *   [doctor_dashboard.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/dashboard/ui/doctor_dashboard.dart) — Daftar tunggu antrean pasien aktif di poli dokter + toggle status **online/offline**.
*   **Dokter — Pemeriksaan (`lib/features/doctor/examination/ui/`):**
    *   [examination_form_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/examination/ui/examination_form_screen.dart) — Form rekam medis: keluhan, diagnosis, tindakan, dan resep obat terstruktur (harga obat **dikunci saat transaksi**).
*   **Rekam Medis Pasien (`lib/features/patient/history/ui/`):**
    *   [medical_history_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/history/ui/medical_history_screen.dart) — Daftar ringkas riwayat rekam medis pasien.
    *   [medical_record_detail_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/history/ui/medical_record_detail_screen.dart) — Detail diagnosa, tindakan, dan rincian resep obat.
*   **Admin — Monitoring Rekam Medis (`lib/features/admin/patient/ui/`):**
    *   [examination_history_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/patient/ui/examination_history_screen.dart) — Monitoring riwayat pemeriksaan seluruh pasien oleh admin (filter per `patient_user_id`).
*   **Pembayaran — Sisi Pasien (`lib/features/patient/payment/ui/`):**
    *   [patient_payment_list_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/payment/ui/patient_payment_list_screen.dart) — Daftar tagihan milik pasien (status: `pending`/`waiting_verification`/`paid`/`cancelled`); indikator **kadaluwarsa otomatis** jika pending ≥ 2 jam.
    *   [patient_payment_detail_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/payment/ui/patient_payment_detail_screen.dart) — Rincian biaya (registrasi + obat) & upload bukti transfer/QRIS (validasi ekstensi + maks. 2MB).
*   **Pembayaran — Sisi Admin (`lib/features/admin/payment/ui/`):**
    *   [admin_payment_list_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/payment/ui/admin_payment_list_screen.dart) — Semua tagihan seluruh pasien untuk diproses kasir loket.
    *   [admin_payment_detail_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/payment/ui/admin_payment_detail_screen.dart) — Verifikasi bukti transfer (approve/reject) & pembayaran tunai langsung (cash-pay).
*   **Farmasi — Dashboard (`lib/features/pharmacy/dashboard/ui/`):**
    *   [pharmacy_dashboard_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/dashboard/ui/pharmacy_dashboard_screen.dart) — Antrean resep siap serah (status `paid`, `dispensed_at IS NULL`).
*   **Farmasi — Resep (`lib/features/pharmacy/prescription/ui/`):**
    *   [prescription_detail_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/prescription/ui/prescription_detail_screen.dart) — Validasi stok & penyerahan obat (`Dispense`) disertai **TTS panggilan suara apotek**.
*   **Farmasi — Inventaris (`lib/features/pharmacy/inventory/ui/`):**
    *   [medicine_inventory_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/inventory/ui/medicine_inventory_screen.dart) — CRUD inventaris obat (nama, satuan, stok, harga dikunci saat resep dibuat).
*   **Admin — Dashboard & TV Monitor (`lib/features/admin/`):**
    *   [admin_dashboard.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/dashboard/ui/admin_dashboard.dart) — Kartu statistik harian + grafik mingguan antrean per poliklinik (`fl_chart`).
    *   [queue_monitor_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/queue/ui/queue_monitor_screen.dart) — Display publik TV Monitor ruang tunggu; **TTS auto** saat status berubah ke `examining`; responsif (Mobile/Tablet/TV).
*   **Flutter Shared (terkait modul D):**
    *   [examination_model.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/examination_model.dart)
    *   [payment_model.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/payment_model.dart)
    *   [medicine_model.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/medicine_model.dart)
    *   [prescription_item_model.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/prescription_item_model.dart)
    *   [dashboard_stats_model.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/dashboard_stats_model.dart)
    *   [payment_provider.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/providers/payment_provider.dart) — ⚠️ Di `lib/shared/` (bukan `features/`): dipakai bersama pasien & admin.
    *   [payment_repository.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/repositories/payment_repository.dart) — ⚠️ Di `lib/shared/repositories/` (bukan `features/`).
    *   [pharmacy_provider.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/logic/pharmacy_provider.dart) — Logic list resep, dispense resep, CRUD obat, dan panggil pasien (`callPatient`).
    *   [pharmacy_repository.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/data/pharmacy_repository.dart) — Memanggil API `pharmacy/queues`, `dispense`, `medicines`, dan `call` (`callPrescriptionPatient`).
    *   [doctor_provider.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/logic/doctor_provider.dart)
    *   [doctor_repository.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/data/doctor_repository.dart)

---

## 📢 Protokol Kerja Sama Tim

| # | Aturan |
|---|---|
| 1 | **Git:** Branch per fitur (`feature/A-auth`, `feature/B-master`, `feature/C-queue`, `feature/D-payment`). Tidak boleh push langsung ke `main`. |
| 2 | **Merge:** Hanya **A** (Git Coordinator) yang merge ke `main` setelah code review singkat. |
| 3 | **API Contract:** Selalu rujuk [API.md](file:///d:/Materi%20Semester%204/PAA%20TM/Tugas/nalaseva%20api/dokumentasi/API.md) sebelum slicing UI Flutter. |
| 4 | **Seeder Update:** Jika ada seeder baru, informasikan ke tim untuk jalankan `php artisan db:seed --class=NamaSeeder`. |
| 5 | **Review Mingguan:** Sinkronisasi progress tiap minggu, terutama di titik handoff C → D (resep → pembayaran). |

---

## 🏁 Hasil Akhir Beban Kerja per Anggota

| Anggota | Controllers | Services | Models | Form Requests | Migrations | Seeders | Flutter UI | Keterangan |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **A** | 3 | 3 | 3 | 3 | 4 | 5 | 7 | Fondasi sistem — auth (OTP), session timeout 15 mnt, konfigurasi sistem, profil pasien |
| **B** | 5 | 1 | 5 | 10 | 5 | 3 | 7 | Master data terbanyak; tiap screen adalah CRUD yang relatif simpel |
| **C** | 2 | 1 | 2 | 4 | 2 | 0 | 10 | Sedikit file, tapi `QueueService` **paling kompleks**; tambah QR Scanner & TTS dialog |
| **D** | 5 | 0 | 4 | 2 | 4 | 1 | 14 | Terbanyak UI — payment terpecah 4 screen (2 pasien + 2 admin); modul payment di `lib/shared/` |

> [!TIP]
> Meski jumlah file C terlihat sedikit, kompleksitas logika bisnis di `QueueService.php` (kalkulasi nomor urut, estimasi waktu tunggu, validasi kuota, dan trigger notifikasi FCM) setara dengan pengerjaan 3–4 controller CRUD biasa. Anggota C memiliki **beban kompleksitas tertinggi** meski jumlah file lebih sedikit.
