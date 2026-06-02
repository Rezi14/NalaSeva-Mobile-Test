# 📋 Dokumentasi Logika Bisnis NalaSeva

> **Dua Project:** Laravel REST API (`nalaseva api`) dan Flutter Mobile App (`nalaseva 3`)  
> Sistem ini merupakan aplikasi manajemen antrean puskesmas digital dengan 4 role pengguna: **Admin**, **Dokter**, **Pasien**, dan **Apoteker (Pharmacist)**.

---

## 🗂️ Daftar Isi

1. [Autentikasi & Manajemen Akun](#1-autentikasi--manajemen-akun)
2. [Manajemen Antrean (Queue)](#2-manajemen-antrean-queue)
3. [Manajemen Dokter](#3-manajemen-dokter)
4. [Manajemen Jadwal Dokter](#4-manajemen-jadwal-dokter)
5. [Manajemen Cuti Dokter](#5-manajemen-cuti-dokter)
6. [Manajemen Hari Libur Klinik](#6-manajemen-hari-libur-klinik)
7. [Manajemen Poliklinik](#7-manajemen-poliklinik)
8. [Manajemen Pasien](#8-manajemen-pasien)
9. [Rekam Medis (Examination)](#9-rekam-medis-examination)
10. [Dashboard & Statistik](#10-dashboard--statistik)
11. [Profil Puskesmas](#11-profil-puskesmas)
12. [Notifikasi Firebase (FCM)](#12-notifikasi-firebase-fcm)
13. [Sistem Estimasi Waktu Antrean](#13-sistem-estimasi-waktu-antrean)
14. [Logika Prioritas Antrean](#14-logika-prioritas-antrean)
15. [Kontrol Akses Berbasis Role (RBAC)](#15-kontrol-akses-berbasis-role-rbac)
16. [Flutter: Manajemen State & Navigasi](#16-flutter-manajemen-state--navigasi)
17. [Flutter: API Client & Interceptor](#17-flutter-api-client--interceptor)
18. [Manajemen Pembayaran](#18-manajemen-pembayaran)
19. [Modul Apotek (Pharmacy)](#19-modul-apotek-pharmacy)
20. [Pengaturan Dinamis Puskesmas (System Settings)](#20-pengaturan-dinamis-puskesmas-system-settings)
21. [Standarisasi UI/UX & Penyempurnaan Alur Dialog (Flutter)](#21-standarisasi-uiux--penyempurnaan-alur-dialog-flutter)
22. [Flutter: Utilitas & Integrasi Sistem](#22-flutter-utilitas--integrasi-sistem)
23. [Struktur Model Data (Flutter)](#23-struktur-model-data-flutter)
24. [Daftar Dependensi & Library (pubspec.yaml)](#24-daftar-dependensi--library-pubspecyaml)
25. [Daftar Lengkap Halaman UI (UI Screens)](#25-daftar-lengkap-halaman-ui-ui-screens)

---

## 1. Autentikasi & Manajemen Akun

### 📍 API — `AuthService.php` + `AuthController.php`

#### 1.1 Login
- Memvalidasi email dan password.
- Jika email tidak ditemukan atau password salah → lempar Exception `401`.
- Membuat **Sanctum token** (`Bearer`) setelah login sukses.
- Memuat relasi `patient` dan `doctor` yang dimiliki user tersebut.

#### 1.2 Registrasi Pasien
- Validasi: `name`, `email` (unique), `password` (min 8), `national_id` (16 digit, unique), `phone_number`, `gender` (Laki-laki/Perempuan), `birth_date`, `address`.
- Menggunakan **DB Transaction**:
  - Buat user baru dengan `role = 'patient'`.
  - Buat record di tabel `patients` yang berelasi ke `user_id`.
- Langsung menghasilkan token autentikasi setelah registrasi berhasil.
- **Role baru hanya bisa 'patient'** — dokter hanya bisa ditambahkan oleh admin.

#### 1.3 Lupa Password (OTP Flow)
- **Step 1 — Request OTP:** Verifikasi bahwa email dan NIK (national_id) cocok di database. Jika cocok, generate OTP 6 digit (random), simpan ke tabel `password_reset_otps` dengan masa berlaku **15 menit**. OTP lama yang ada untuk email yang sama dihapus terlebih dahulu.
- **Step 2 — Reset Password:** Validasi OTP (harus benar + belum kedaluwarsa). Validasi ulang NIK dan email. Jika valid, hash password baru dan simpan. Semua token Sanctum lama dihapus (force logout semua sesi).
- **Mode Non-Production:** Kode OTP dikembalikan di dalam response JSON (untuk kemudahan testing).

#### 1.4 Logout
- Menghapus hanya token Sanctum **saat ini** (current token), bukan semua token.

#### 1.5 Update FCM Token
- Menyimpan/memperbarui token Firebase Cloud Messaging (FCM) ke kolom `fcm_token` di tabel `users`.
- Dipanggil setiap kali login berhasil.

#### 1.6 Lihat & Update Profil
- `getProfile`: Mengambil data user beserta relasi `patient` dan `doctor`.
- `updateProfile`: Menggunakan DB Transaction. Field yang bisa diubah: `name`, `email`, `phone`, `address`, `gender`, `birth_date`. **NIK hanya bisa diisi sekali** jika sebelumnya masih kosong (tidak bisa diubah setelah diisi).

---

### 📱 Flutter — [AuthProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/logic/auth_provider.dart) + [AuthRepository](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/data/auth_repository.dart)

#### 1.7 Login (Flutter)
1. Panggil API `POST auth/login` → dapatkan `access_token` + data user dasar.
2. Simpan `access_token` ke **FlutterSecureStorage** (`key: 'access_token'`).
3. Langsung panggil `GET auth/profile` untuk mendapatkan data profil lengkap (dengan relasi `patient`, `doctor`).
4. Simpan ke secure storage: `user_role`, dan kondisional `patient_id` (jika ada), `doctor_id` (jika ada).
5. Jika bukan platform web (`!kIsWeb`): Inisialisasi Firebase Messaging dan perbarui FCM Token ke server.
6. Error pada fetch profile saat login di-catch secara silent (`debugPrint`) agar login tetap berhasil.

#### 1.8 Register (Flutter)
- Mengirimkan data registrasi ke API `POST auth/register`.
- Mengirimkan 10 field: `name`, `email`, `password`, **`password_confirmation`** (diambil sama nilainya dengan `password`), `national_id` (NIK), `phone_number`, `gender`, `birth_date`, `address`, dan **`role`** (secara eksplisit diset `'patient'`).
- Setelah registrasi berhasil, pengguna tidak langsung login otomatis, melainkan diarahkan kembali ke halaman login.

#### 1.9 Logout (Flutter)
- Panggil `POST auth/logout` ke server (dalam blok `try`).
- Di blok `finally`: set `_user = null`, hapus **4 key** dari secure storage: `access_token`, `user_role`, `patient_id`, `doctor_id`.
- Trigger `notifyListeners()` agar UI refresh ke halaman login.

#### 1.10 Update Profil (Flutter)
- Kirim data yang diubah ke API menggunakan metode **`POST`** pada endpoint `auth/update-profile` (bukan menggunakan `PUT`, karena Laravel backend menangani multipart/form-data update profil lebih kompatibel lewat POST).
- Re-fetch profil lengkap dari server via `GET auth/profile`.
- Update ulang `patient_id` dan `doctor_id` di secure storage jika berubah.

#### 1.11 OTP (Flutter) — [ForgotPasswordScreen](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/ui/forgot_password_screen.dart)
- `requestPasswordResetOtp(email, nationalId)`: Kirim ke server, server mengembalikan kode OTP (dalam mode non-production) yang di-return dari provider.
- `forgotPassword(email, nationalId, otpCode, newPassword)`: Submit reset password.

#### 1.12 checkAuth — Session Restore (Flutter)
- Dipanggil di `initState()` `NalasevaApp` (StatefulWidget root) sebelum app merender route awal.
- Baca `access_token` dari secure storage.
- **Jika ada token** → coba `GET auth/profile`:
  - **Sukses:** Simpan ulang `user_role`, `patient_id`, `doctor_id` ke storage (sinkronisasi).
  - **Error 401/403/unauthorized/forbidden:** Hapus semua 4 key storage → `_user = null` (paksa login ulang).
  - **Error lain (jaringan/server down):** Baca `user_role`, `patient_id`, `doctor_id` dari storage, buat **UserModel sentinel "Offline"** (`id: 0, name: 'Offline User', email: ''`) — app tetap bisa menavigasi ke dashboard sesuai role.
- **Jika tidak ada token:** `_user = null`.
- Setelah selesai, `notifyListeners()` → `NalasevaApp` memutuskan `initialRoute` berdasarkan `user?.role`.

#### 1.13 Navigasi Awal Berdasarkan Role (Flutter)
| Role | Initial Route |
|------|---------------|
| `admin` | `/admin/home` |
| `doctor` | `/doctor/home` |
| `patient` | `/patient/home` |
| `pharmacist` | `/pharmacy/home` |
| `null` (belum login) | `/` (Login) |

---

## 2. Manajemen Antrean (Queue)

### 📍 API — `QueueService.php` + `QueueController.php`

#### 2.1 Booking Antrean (`storeQueue`)
Merupakan logika bisnis paling kompleks dalam sistem. Validasi dilakukan secara berlapis:

**Validasi Waktu Pendaftaran:**
- Pendaftaran hanya diperbolehkan maksimal **H-7** (7 hari ke depan) hingga hari ini. Tidak bisa mendaftar untuk tanggal yang sudah lewat.

**Validasi Kepemilikan (Anti-IDOR):**
- Jika user adalah `patient`, sistem memastikan `patient_id` yang dikirim adalah milik user yang sedang login. Pasien tidak bisa mendaftarkan orang lain.

**Validasi Ketersediaan (5 Layer):**
1. **Hari Libur Klinik** — Tidak bisa mendaftar jika tanggal tersebut adalah hari libur puskesmas.
2. **Cuti Dokter** — Tidak bisa mendaftar jika dokter yang dipilih sedang cuti pada tanggal tersebut.
3. **Konsistensi Jadwal** — `doctor_schedule_id` harus cocok dengan `doctor_id` dan `polyclinic_id` yang dikirim.
4. **Duplikat Antrean per Poliklinik** — Satu pasien hanya boleh memiliki 1 antrean aktif per poliklinik per hari.
5. **Konflik Waktu Antar Poliklinik** — Cek semua antrean aktif pasien di hari yang sama; tidak boleh ada jadwal yang jam layanannya tumpang tindih (overlap).

**Validasi Hari Praktik:**
- Tanggal yang dipilih harus sesuai dengan `day_of_week` jadwal dokter.
- Jika mendaftar untuk **hari ini**, pendaftaran hanya bisa dilakukan **sebelum jam mulai praktik**.

**Penghitungan Kapasitas Dinamis:**
- Kuota per jadwal dihitung otomatis: `durasi_menit / slot_duration_minutes` (default: 1 slot per 15 menit, dapat dikonfigurasikan via `System Settings`).
- Jika jumlah booking aktif sudah mencapai kuota → booking ditolak.

**Generate Nomor Antrean:**
- Format: `{KODE_POLI}-{NomorUrut}` (contoh: `UMM-001`).
- Nomor urut diambil dari nomor terakhir yang ada untuk poliklinik dan tanggal yang sama (menggunakan `withTrashed()` untuk mencegah duplikat setelah pembatalan).

**Penentuan Prioritas Otomatis:**
- Usia pasien dihitung berdasarkan `birth_date`. Jika usia **≥ 60 tahun**, antrean otomatis ditandai sebagai `is_priority = true`.

**Post-Booking:**
- Setelah antrean dibuat, langsung hitung estimasi waktu layanan.
- Recalculate semua estimasi antrean aktif di poliklinik dan tanggal yang sama.

#### 2.2 Update Status Antrean (`updateQueue`)
**Aturan Transisi Status (State Machine):**
```
booked   → [waiting, cancelled]
waiting  → [examining, cancelled]
examining → [completed]
completed → [] (final state)
cancelled → [] (final state)
```

**Representasi di Flutter (`QueueStatus` enum — `lib/shared/constants/app_constants.dart`):**
```dart
enum QueueStatus { booked, waiting, examining, completed, cancelled, unknown }
```
- `.value`: string API (`'booked'`, `'waiting'`, dll.)
- `.displayName`: label UI Bahasa Indonesia (`'Dipesan'`, `'Menunggu'`, dll.)
- `.isActive`: true jika `booked/waiting/examining`
- `.isTerminal`: true jika `completed/cancelled/unknown`

**Validasi Tambahan:**
- Pasien dilarang mengubah status antrean sama sekali.
- Dokter hanya bisa mengubah antrean miliknya sendiri.
- Dokter dilarang membatalkan (`cancelled`) antrean.
- Untuk transisi ke `examining`: tidak boleh ada pasien lain yang masih dalam status `examining` di dokter dan poliklinik yang sama. Juga, dokter harus dalam status online (`is_online = true`).
- Saat status menjadi `examining`, kolom `called_time` dicatat dan **notifikasi FCM dikirim ke pasien** dengan pesan "Giliran Anda!".

#### 2.3 Pembatalan Antrean (`destroyQueue`)
- Dokter tidak bisa membatalkan antrean sama sekali.
- Pasien hanya bisa membatalkan antrean miliknya sendiri.
- Antrean dengan status `examining` atau `completed` tidak bisa dibatalkan.
- **Aturan Cut-off Pembatalan untuk Pasien:**
  - Jika antrean dibuat **≤ 15 menit yang lalu** → bisa dibatalkan sampai waktu layanan mulai.
  - Jika antrean dibuat **> 15 menit yang lalu** → tidak bisa dibatalkan kurang dari **2 jam sebelum** waktu layanan mulai.

#### 2.4 Check-In Antrean
- Hanya **admin** yang bisa melakukan check-in.
- Check-in hanya bisa dilakukan **pada tanggal kunjungan yang sama**.
- Status antrean harus `booked` (belum check-in sebelumnya).
- Mencatat `check_in_time` dan mengubah status ke `waiting`.
- Bisa menyertakan `reason` (alasan kunjungan).
- Recalculate estimasi waktu layanan setelah check-in.

#### 2.5 Panggilan Ulang Antrean (Recall)
- Hanya **admin** yang bisa melakukan recall.
- Status antrean harus `examining`.
- Jika `recall_count < 3`: increment `recall_count`.
- Jika `recall_count >= 3`: antrean dikembalikan ke posisi **paling belakang** (`waiting`, `check_in_time = now()`, `recall_count = 0`). Validasi: waktu layanan dokter belum habis.

#### 2.6 Geser Antrean ke Belakang (Skip)
- Hanya admin yang bisa melakukan skip.
- Status antrean harus `waiting` dan sudah check-in.
- Reset `check_in_time = now()` dan `recall_count = 0` agar antrean berada di posisi paling belakang.

#### 2.7 Validasi Jendela Waktu Layanan (`validateServiceTimeWindow`)
- Perubahan status hanya boleh dilakukan **pada hari kunjungan**.
- Batas toleransi: perubahan diizinkan hingga **2 jam setelah estimasi waktu layanan**.
- Exception: Admin dibebaskan dari semua cek waktu. Dokter dibebaskan untuk transisi `examining` dan `completed`.

---

### 📱 Flutter — [PatientProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/logic/patient_provider.dart) + [DoctorProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/logic/doctor_provider.dart) + [AdminProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/logic/admin_provider.dart)

#### 2.8 Booking (Patient)
- `createBooking(data)`: Kirim data ke `POST /queues`, lalu refresh `_myQueues` via `getMyQueues()`. Jika refresh gagal, tetap log warning dan tidak melempar error (booking tetap sukses).
- `fetchHolidaysAndLeaves(doctorId)`: Fetch hari libur klinik dan cuti dokter secara **paralel** (`Future.wait([getClinicHolidays(), getDoctorLeaves(doctorId)])`) → disimpan ke `_clinicHolidays` (List\<String\>) dan `_doctorLeaves` (List\<String\>). Digunakan untuk **disable tanggal** di date picker booking.
- `cancelQueue(id)`: Kirim `DELETE /queues/{id}`, lalu refresh list antrean.
- `fetchMyData()`: Mengambil antrean, rekam medis, dan poliklinik secara **paralel** (`Future.wait`) untuk efisiensi load awal dashboard pasien.
- `getSchedulesDirectly(polyId)`: Mengambil jadwal secara langsung **tanpa menyimpan ke state** — untuk validasi real-time saat user memilih jadwal di form booking.

**State `PatientProvider`:**
```dart
List<QueueModel> _myQueues
List<ExaminationModel> _medicalRecords
List<PolyclinicModel> _polyclinics
List<ScheduleModel> _availableSchedules
List<DoctorModel> _doctors
List<String> _clinicHolidays
List<String> _doctorLeaves
```

#### 2.9 Proses Antrean (Dokter)
- `fetchMyQueues()`: Ambil daftar antrean milik dokter yang login dari `GET /queues`.
- `processQueue(id, status)`: Update status antrean via `PUT /queues/{id}`, lalu refresh list.
- `finishExamination(data)`: Submit rekam medis via `POST /examinations`, lalu refresh `_queues` **dan** `_medicalRecords` sekaligus.
- `toggleOnlineStatus()`: Toggle antara online/offline. Kirim `PATCH /doctors/me/status` dengan status baru. State `_isOnline` diupdate secara lokal setelah response sukses.
- `fetchHistoryForPatient(patientUserId)`: Ambil riwayat pemeriksaan pasien spesifik dari `GET /examinations?patient_user_id={id}` → disimpan ke `_patientHistory`.

**State `DoctorProvider`:**
```dart
List<QueueModel> _queues
List<ExaminationModel> _patientHistory
List<ExaminationModel> _medicalRecords
bool _isOnline // default: true
```

#### 2.10 Manajemen Antrean (Admin)
- `updateQueueStatus(id, status)`: Update status, refresh list.
- `checkInQueue(id, {reason})`: Check-in via `POST /queues/{id}/checkin`, refresh list.
- `recallQueue(id)`: Panggil ulang via `POST /queues/{id}/recall`. **Update item di list secara lokal** (`_queues[index] = updatedQueue`) tanpa refetch penuh — efisiensi UI.
- `moveQueueToBack(queue)`: Skip antrean via `POST /queues/{id}/skip`, refresh list.
- `bookQueueForPatient(data)`: Admin mendaftarkan antrean untuk pasien via `POST /queues`, refresh list.
- `deleteQueue(id)`: Hapus/batalkan antrean, refresh list.

**State `AdminProvider`:**
```dart
List<UserModel> _users
List<PatientModel> _patients
List<PolyclinicModel> _polyclinics
List<QueueModel> _queues
List<DoctorModel> _doctors
List<ScheduleModel> _schedules
List<ExaminationModel> _examinations
DashboardStatsModel? _dashboardStats
List<Map<String, dynamic>> _clinicHolidays
List<Map<String, dynamic>> _doctorLeaves
Map<String, dynamic> _systemSettings
```

---

## 3. Manajemen Dokter

### 📍 API — `DoctorService.php` + `DoctorController.php`

#### 3.1 Tambah Dokter (Admin Only)
- Menggunakan **DB Transaction**:
  - Buat user baru dengan `role = 'doctor'`, password di-hash.
  - Buat record `doctors` yang berelasi ke `user_id`, dengan data `polyclinic_id`, `specialization`, `license_number`.

#### 3.2 Update Data Dokter (Admin Only)
- Jika `polyclinic_id` berubah, cek apakah dokter masih punya antrean aktif (`booked`, `waiting`, `examining`) di poliklinik lama. Jika ada → tolak perubahan.
- Update dilakukan secara terpisah ke tabel `users` (data personal) dan `doctors` (data profesi).

#### 3.3 Hapus Dokter (Admin Only)
- Cek apakah dokter masih punya antrean aktif → jika ada, tolak penghapusan.
- Gunakan DB Transaction: soft-delete record `doctors` dan `users` secara bersamaan.

#### 3.4 Restore Dokter (Admin Only)
- Restore record `doctors` dan `users` (yang juga soft-deleted) secara bersamaan via Transaction.

#### 3.5 Update Status Online (Dokter Only)
- Dokter dapat mengubah status `is_online` (true/false).
- Jika dokter set status menjadi **offline**, sistem langsung mengirim **notifikasi FCM ke semua admin** yang memiliki FCM token, dengan pesan bahwa dokter sedang istirahat.

---

### 📱 Flutter — [AdminProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/logic/admin_provider.dart) (CRUD Dokter)
- `createDoctor(data)`: Buat dokter baru, refresh list dokter.
- `updateDoctor(id, data)`: Update dokter, refresh list.
- `deleteDoctor(id)`: Hapus dokter, refresh list.
- `fetchDoctors()`: Ambil semua dokter dari `GET /doctors`.

---

## 4. Manajemen Jadwal Dokter

### 📍 API — `DoctorService.php` + `DoctorScheduleController.php`

#### 4.1 Tambah Jadwal
- Validasi: jadwal baru tidak boleh tumpang tindih (overlap) dengan jadwal lain milik dokter yang sama pada hari yang sama. Cek menggunakan kondisi interval overlap: `start_baru < end_lama && start_lama < end_baru`.

#### 4.2 Update Jadwal
- Jika `day_of_week`, `start_time`, atau `end_time` berubah, cek apakah masih ada antrean aktif yang menggunakan jadwal ini → jika ada, tolak perubahan.
- Validasi overlap jadwal tetap dilakukan (kecuali jadwal itu sendiri).

#### 4.3 Hapus Jadwal
- Cek apakah ada antrean aktif yang menggunakan jadwal ini → jika ada, tolak penghapusan.

#### 4.4 Lihat Jadwal dengan Sisa Kuota
- Endpoint `GET /doctor-schedules` menghitung dan mengembalikan `remaining_daily_quota` untuk setiap jadwal pada tanggal tertentu (default: hari ini).
- Kuota = `durasi_menit / slot_duration_minutes` (dari System Settings), dikurangi jumlah booking aktif.

---

### 📱 Flutter — [AdminProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/logic/admin_provider.dart) (CRUD Jadwal)
- `createSchedule(data)`, `updateSchedule(id, data)`, `deleteSchedule(id)`, `fetchSchedules()`.
- UI: [doctor_schedule_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/doctor_schedule_management_screen.dart).

---

## 5. Manajemen Cuti Dokter

### 📍 API — `DoctorService.php` + `DoctorLeaveController.php`

#### 5.1 Tambah Cuti Dokter (Admin Only)
- Validasi: dokter tidak boleh punya cuti duplikat di tanggal yang sama.
- Menggunakan **DB Transaction**:
  - Buat record cuti.
  - Cari semua antrean aktif (`booked`, `waiting`) dokter tersebut pada tanggal cuti.
  - **Batalkan otomatis semua antrean tersebut** (`status = 'cancelled'`).
  - Kirim **notifikasi FCM** ke setiap pasien yang antreannya dibatalkan, dengan pesan bahwa antrean dibatalkan karena dokter cuti.
  - Recalculate estimasi waktu antrean yang tersisa.

#### 5.2 Lihat Cuti (Filter Role)
- Admin: melihat semua cuti termasuk yang sudah lewat.
- Non-admin: hanya melihat cuti dengan `leave_date >= hari ini`.
- Bisa difilter berdasarkan `doctor_id`.

---

### 📱 Flutter — [AdminProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/logic/admin_provider.dart) (CRUD Cuti)
- `fetchDoctorLeaves({doctorId})`: Ambil cuti, opsional filter per dokter.
- `addDoctorLeave(doctorId, date, reason)`: Tambah cuti, refresh list.
- UI: [admin_doctor_leaves_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/admin_doctor_leaves_screen.dart).

---

## 6. Manajemen Hari Libur Klinik

### 📍 API — `ClinicHolidayController.php`

#### 6.1 Tambah Hari Libur (Admin Only)
- Setelah hari libur ditambahkan, sistem langsung mencari semua antrean aktif (`booked`, `waiting`) pada tanggal tersebut dari **seluruh poliklinik**.
- **Batalkan otomatis semua antrean tersebut**.
- Kirim **notifikasi FCM** ke setiap pasien yang antreannya dibatalkan, dengan pesan bahwa puskesmas libur.
- Recalculate estimasi waktu per poliklinik.

#### 6.2 Lihat Hari Libur (Filter Role)
- Admin: melihat semua hari libur (termasuk yang sudah lewat).
- Non-admin (pasien, dokter): hanya melihat hari libur dengan `holiday_date >= hari ini`.

---

### 📱 Flutter — [AdminProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/logic/admin_provider.dart) (CRUD Libur)
- `fetchClinicHolidays()`: Ambil semua hari libur klinik.
- `addClinicHoliday(date, description)`: Tambah hari libur, refresh list.
- UI: [admin_clinic_holidays_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/admin_clinic_holidays_screen.dart).

---

## 7. Manajemen Poliklinik

### 📍 API — `PolyclinicController.php`

#### 7.1 Tambah & Update Poliklinik (Admin Only)
- Jika kode poliklinik (`code`) diubah, cek apakah ada antrean aktif hari ini → jika ada, tolak perubahan (kode digunakan sebagai prefix nomor antrean).

#### 7.2 Hapus Poliklinik (Admin Only)
- Cek apakah ada antrean aktif di poliklinik tersebut → jika ada, tolak penghapusan.
- Cek apakah ada jadwal dokter yang masih terdaftar → jika ada, tolak penghapusan.
- Jika semua aman, lakukan soft-delete.

---

### 📱 Flutter — [AdminProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/logic/admin_provider.dart) (CRUD Poliklinik)
- `fetchPolyclinics()`, `createPolyclinic(data)`, `updatePolyclinic(id, data)`, `deletePolyclinic(id)`.
- UI: [polyclinic_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/polyclinic_management_screen.dart).

---

## 8. Manajemen Pasien

### 📍 API — `PatientController.php`

#### 8.1 Lihat Daftar Pasien
- Admin: melihat semua pasien.
- Pasien: hanya melihat data diri sendiri.

#### 8.2 Tambah Pasien Manual (Admin Only)
- Admin bisa menambahkan pasien secara manual melalui DB Transaction (buat User + Patient sekaligus).

#### 8.3 Update Profil Pasien
- Pasien hanya bisa mengubah profil dirinya sendiri (**anti-IDOR check**).
- Dokter **dilarang** mengubah profil pasien.
- Admin bisa mengubah profil pasien manapun.
- Update dilakukan ke tabel `users` (bukan `patients` langsung).

#### 8.4 Hapus Pasien (Admin Only)
- Soft-delete data pasien.

---

### 📱 Flutter — [AdminProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/logic/admin_provider.dart) (CRUD Pasien & User)
- `fetchPatients()`, `createPatient(data)`.
- `fetchUsers()`, `createUser(data)`, `updateUser(id, data)`, `deleteUser(id)`.
- UI: [patient_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/patient_management_screen.dart) & [user_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/user_management_screen.dart).

---

## 9. Rekam Medis (Examination)

### 📍 API — `ExaminationController.php`

#### 9.1 Buat Rekam Medis (Dokter Only)
- Hanya dokter terdaftar yang bisa membuat rekam medis.
- Status antrean **harus `examining`** (pasien sudah dipanggil).
- Duplikasi dilarang: satu antrean hanya boleh punya satu rekam medis.
- Dokter hanya bisa membuat rekam medis untuk antrean yang memiliki `doctor_id` yang sama.
- Menggunakan DB Transaction:
  - Buat rekam medis.
  - Status antrean diubah otomatis menjadi **`completed`**.
  - `doctor_id` dipaksa menggunakan ID dokter yang sedang login (bukan dari request body).
  - Buat tagihan pembayaran otomatis (`Payment`).
  - Kirim **notifikasi FCM ke pasien**: "Tagihan Baru Diterbitkan" beserta nominal total.

#### 9.2 Lihat Rekam Medis
- Pasien: hanya bisa melihat rekam medis miliknya sendiri.
- Dokter: hanya bisa melihat rekam medis dari polikliniknya sendiri, bisa difilter berdasarkan `patient_user_id`.
- Admin: bisa melihat semua, bisa filter berdasarkan `patient_user_id`.

#### 9.3 Update Rekam Medis (Dokter & Admin)
- Pasien dilarang mengubah rekam medis.
- Dokter hanya bisa mengubah rekam medis yang dia buat sendiri (`doctor_id` harus cocok).

#### 9.4 Hapus Rekam Medis (Dokter & Admin)
- Pasien dilarang menghapus.
- Dokter hanya bisa menghapus rekam medis miliknya sendiri.
- Menggunakan soft-delete.

---

### 📱 Flutter — [DoctorProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/logic/doctor_provider.dart) + [ExaminationFormScreen](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/ui/examination_form_screen.dart)
- `finishExamination(data)`: Submit rekam medis + resep ke API, lalu refresh `_queues` dan `_medicalRecords`.
- `fetchHistoryForPatient(patientUserId)`: Lihat riwayat pemeriksaan pasien spesifik.
- UI: [examination_form_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/ui/examination_form_screen.dart) (input diagnosis, keluhan, resep obat).
- Admin: [examination_history_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/examination_history_screen.dart) (lihat riwayat pemeriksaan semua pasien).

---

## 10. Dashboard & Statistik

### 📍 API — `DashboardController.php`

#### 10.1 Statistik Dashboard (Admin & Dokter)
Mengambil data statistik real-time untuk hari ini:
- Total pasien dan dokter terdaftar.
- Jumlah antrean aktif hari ini (status: `booked`, `waiting`, `examining`).
- Jumlah antrean selesai hari ini.
- Jumlah antrean dibatalkan hari ini.
- **Statistik per poliklinik**: jumlah antrean aktif dan antrean menunggu per poliklinik (menggunakan 1 query agregat untuk mencegah N+1 query).

---

### 📱 Flutter — [AdminProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/logic/admin_provider.dart) + [AdminDashboard](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/admin_dashboard.dart)
- `fetchDashboardStats()`: Ambil statistik dari `GET /dashboard-stats` → disimpan ke `DashboardStatsModel? _dashboardStats`.
- UI: [admin_dashboard.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/admin_dashboard.dart) (kartu statistik, grafik mingguan antrean).
- UI: [queue_monitor_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/queue_monitor_screen.dart) (layar monitor antrean real-time / TV Monitor).

---

## 11. Profil Puskesmas

### 📍 API — `PuskesmasProfileService.php` + `PuskesmasProfileController.php`

#### 11.1 Lihat Profil Puskesmas (Telah Otentikasi)
- Data di-fetch setelah salah satu dari 4 role pengguna berhasil masuk (atau saat sesi dipulihkan).
- Menampilkan data profil puskesmas: nama, alamat, kontak, koordinat lokasi (latitude/longitude), dsb.

#### 11.2 Update Profil Puskesmas (Admin Only)
- Hanya admin yang bisa memperbarui informasi profil puskesmas.
- Mendukung update koordinat lokasi puskesmas via `MapPickerScreen` (OpenStreetMap — `flutter_map` library).

---

### 📱 Flutter — [PuskesmasProfileProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/providers/puskesmas_profile_provider.dart) + [AdminSettingsScreen](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/admin_settings_screen.dart)
- `PuskesmasProfileProvider` diakses secara asinkron setelah pengguna berhasil login atau saat restorasi sesi awal terdeteksi sukses.
- **Map Picker:** [admin_settings_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/admin_settings_screen.dart) mengintegrasikan [MapPickerScreen](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/widgets/map_picker_screen.dart) berbasis OpenStreetMap (`flutter_map` + `latlong2`) untuk memilih koordinat lokasi puskesmas. Default koordinat: Jember (`-8.165143, 113.716255`).

---

## 12. Notifikasi Firebase (FCM)

### 📍 API — `FirebaseNotificationService.php`

#### 12.1 Arsitektur Notifikasi
- Menggunakan library `kreait/firebase-php` untuk mengirim push notification.
- Credentials Firebase dimuat dari file JSON konfigurasi (path dari `.env`).
- Metode `sendToToken()` menerima: FCM token, judul, isi pesan, dan data payload tambahan.
- Semua error FCM di-**catch secara silent** (tidak gagalkan request utama).

#### 12.2 Trigger Notifikasi API
| Event | Penerima | Pesan |
|-------|----------|-------|
| Dokter set offline | Semua Admin | "Dokter sedang beristirahat" |
| Status antrean → `examining` | Pasien terkait | "Giliran Anda! Nomor: {queue_number}" |
| Cuti dokter ditambahkan | Pasien dengan antrean yang dibatalkan | "Antrean dibatalkan, dokter cuti" |
| Hari libur ditambahkan | Semua pasien dengan antrean yang dibatalkan | "Antrean dibatalkan, puskesmas libur" |
| Rekam medis selesai dibuat | Pasien terkait | "Tagihan Baru Diterbitkan" + nominal total |
| Admin verifikasi transfer → `paid` | Pasien terkait | "Pembayaran Terverifikasi Lunas!" |
| Admin cash-pay → `paid` | Pasien terkait | "Pembayaran Lunas (Tunai)!" |
| Apoteker serahkan obat | Pasien terkait | "Obat Selesai Diserahkan" |

---

### 📱 Flutter — [FirebaseMessagingService](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/services/firebase_messaging_service.dart)

#### 12.3 Inisialisasi & Setup
- Inisialisasi `flutter_local_notifications` untuk menampilkan notifikasi saat app di foreground.
- Register background message handler (`_firebaseMessagingBackgroundHandler`).
- Meminta izin notifikasi dari user (alert, badge, sound).
- Firebase diinisialisasi di `main.dart` via `Firebase.initializeApp()` dengan `DefaultFirebaseOptions.currentPlatform`. Error inisialisasi di-catch secara silent (log saja) untuk mencegah crash jika `google-services.json` tidak ada.

#### 12.4 Tampilkan Notifikasi Foreground
- Mendengarkan `FirebaseMessaging.onMessage.listen`.
- Jika ada notifikasi masuk saat app aktif, tampilkan sebagai **local notification** di notification tray.
- Channel ID: `nalaseva_channel`, nama: "Nalaseva Notifications".

#### 12.5 Get & Update FCM Token
- `getFCMToken()`: Ambil token dari Firebase.
- Token dikirim ke server via `POST /auth/fcm-token` setelah login berhasil.
- Di-wrap dalam `!kIsWeb` guard (FCM tidak tersedia di platform web).

---

### 📱 Flutter — [NotificationScreen](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/ui/notification_screen.dart)
- Layar riwayat notifikasi yang bisa diakses dari dashboard pasien.
- Menampilkan semua notifikasi yang pernah diterima.

---

## 13. Sistem Estimasi Waktu Antrean

### 📍 API — `Queue.php` (Model)

#### 13.1 Hitung Posisi Antrean (`getPositionWaitingAttribute`)
Accessor yang menghitung berapa banyak pasien yang masih berada di depan dalam antrian, dengan mempertimbangkan prioritas:

**Untuk pasien prioritas (lansia ≥60 tahun):**
- Hanya menunggu sesama pasien prioritas yang datang (check-in/booking) **lebih awal**.
- Tetap menunggu siapapun yang sedang dalam status `examining`.

**Untuk pasien reguler:**
- Menunggu semua pasien prioritas (tanpa melihat waktu kedatangan).
- Menunggu pasien reguler lain yang datang lebih awal.

#### 13.2 Hitung Rata-rata Waktu Pemeriksaan (`getAvgWaitingTimeAttribute`)
- **Adaptive Waiting Time**: mengambil **3 rekam medis terakhir** yang diselesaikan hari ini di poliklinik yang sama.
- Menghitung selisih waktu dari `called_time` (atau `check_in_time`, atau `created_at` sebagai fallback) hingga waktu rekam medis dibuat.
- Membatasi durasi antara **1 menit hingga 120 menit** per pemeriksaan.
- Jika tidak ada data historis → default nilai dari `Setting::getValue('slot_duration_minutes', 15)`.

#### 13.3 Hitung Estimasi Waktu Layanan (`calculateEstimatedServiceTime`)
- Berdasarkan `posisi_antrian × slot_duration_minutes` (dari System Settings, default 15 menit).
- `base_time`: waktu sekarang ATAU waktu mulai jadwal dokter (mana yang lebih lambat).
- Return format: `HH:mm`.

#### 13.4 Recalculate Semua Estimasi (`recalculateEstimatedTimes`)
- Dipanggil setiap kali ada perubahan status antrean (booking, check-in, skip, recall, dll).
- Mengambil semua antrean `booked` dan `waiting` di poliklinik dan tanggal yang sama, diurutkan: **prioritas duluan**, lalu berdasarkan waktu check-in/booking.
- Update kolom `estimated_service_time` untuk setiap antrean.

---

### 📱 Flutter — [ServiceTimeValidator](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/utils/service_time_validator.dart)
Validator sisi client yang digunakan oleh **Admin** saat check-in (termasuk via QR Scanner):
- **Cek Tanggal:** Antrean harus pada tanggal hari ini.
- **Cek Jendela Waktu:** Waktu sekarang harus berada dalam rentang **30 menit sebelum** hingga **2 jam setelah** `estimatedServiceTime`.
  - Terlalu awal: "Absensi hanya diizinkan maksimal 30 menit sebelum jam pelayanan."
  - Terlalu telat: "Sudah melewati batas 2 jam setelah jam pelayanan."

---

## 14. Logika Prioritas Antrean

### 📍 API

#### 14.1 Penentuan Status Prioritas
- Otomatis saat booking: usia dihitung dari `birth_date`. Jika **≥ 60 tahun** → `is_priority = true`.
- Tidak bisa diubah manual oleh pengguna.

#### 14.2 Urutan Prioritas dalam Antrean
1. Pasien prioritas (lansia) selalu berada di depan pasien reguler.
2. Di antara sesama prioritas: urutan berdasarkan waktu check-in (siapa yang lebih dulu datang).
3. Di antara sesama reguler: urutan berdasarkan waktu check-in.

---

## 15. Kontrol Akses Berbasis Role (RBAC)

### 📍 API — `routes/api.php` + Middleware

#### 15.1 Route Publik (Tanpa Autentikasi)
| Endpoint | Deskripsi |
|----------|-----------|
| `POST /auth/login` | Login |
| `POST /auth/register` | Registrasi pasien |
| `POST /auth/forgot-password/otp` | Request OTP reset password |
| `POST /auth/forgot-password` | Reset password dengan OTP |
| `GET /puskesmas-profile` | Lihat profil puskesmas |

#### 15.2 Route Semua Role (Authenticated)
| Endpoint | Deskripsi |
|----------|-----------|
| `POST /auth/logout` | Logout |
| `GET /auth/profile` | Lihat profil sendiri |
| `POST/PUT/PATCH /auth/update-profile` | Update profil sendiri |
| `POST /auth/fcm-token` | Update FCM token |
| `GET /polyclinics`, `GET /polyclinics/{id}` | Lihat poliklinik |
| `GET /doctors`, `GET /doctors/{id}` | Lihat dokter |
| `GET /doctor-schedules`, `GET /doctor-schedules/{id}` | Lihat jadwal |
| `GET /clinic-holidays`, `GET /clinic-holidays/{id}` | Lihat hari libur |
| `GET /doctor-leaves`, `GET /doctor-leaves/{id}` | Lihat cuti dokter |
| `GET /patients/{id}` | Lihat detail pasien (filter kepemilikan di controller) |
| `PUT/PATCH /patients/{id}` | Update pasien (filter kepemilikan di controller) |
| `GET/POST /queues` | Lihat & booking antrean (filter kepemilikan di service) |
| `DELETE /queues/{id}` | Batalkan antrean |
| `GET /examinations`, `GET /examinations/{id}` | Lihat rekam medis |

#### 15.3 Route Admin & Dokter (role:admin,doctor)
| Endpoint | Deskripsi |
|----------|-----------|
| `GET /dashboard-stats` | Statistik dashboard |
| `PUT/PATCH /queues/{id}` | Update status antrean |
| `POST /examinations` | Buat rekam medis |
| `PUT/PATCH /examinations/{id}` | Update rekam medis |
| `DELETE /examinations/{id}` | Hapus rekam medis |

#### 15.4 Route Dokter Only (role:doctor)
| Endpoint | Deskripsi |
|----------|-----------|
| `GET /doctors/profile` | Lihat profil dokter sendiri |
| `PATCH /doctors/me/status` | Update status online/offline |

#### 15.5 Route Admin Only (role:admin)
| Endpoint | Deskripsi |
|----------|-----------|
| `PUT /puskesmas-profile` | Update profil puskesmas |
| `POST /queues/{id}/checkin` | Check-in antrean |
| `POST /queues/{id}/skip` | Geser antrean ke belakang |
| `POST /queues/{id}/recall` | Panggil ulang antrean |
| `POST /queues/{id}/restore` | Restore antrean (soft-delete) |
| `POST /examinations/{id}/restore` | Restore rekam medis |
| CRUD `/users` | Manajemen user |
| CRUD `/polyclinics` | Manajemen poliklinik |
| CRUD `/doctors` | Manajemen dokter |
| CRUD `/doctor-schedules` | Manajemen jadwal dokter |
| CRUD `/patients` (kecuali `GET /patients/{id}`, `PUT/PATCH /patients/{id}`) | Manajemen pasien |
| CRUD `/clinic-holidays` | Manajemen hari libur |
| CRUD `/doctor-leaves` | Manajemen cuti dokter |
| `GET /settings`, `PUT /settings` | Pengaturan dinamis sistem |
| `POST /payments/{id}/verify` | Verifikasi bukti transfer |
| `POST /payments/{id}/cash-pay` | Pembayaran tunai |

#### 15.6 Route Admin & Apoteker (role:admin,pharmacist)
| Endpoint | Deskripsi |
|----------|-----------|
| `GET /pharmacy/queues` | Lihat antrean resep yang lunas & belum diserahkan |
| `POST /pharmacy/queues/{id}/dispense` | Serahkan obat ke pasien |
| `POST /medicines` | Tambah obat baru |
| `PUT/PATCH /medicines/{id}` | Update data obat |
| `DELETE /medicines/{id}` | Hapus obat (soft delete) |
| `POST /medicines/{id}/restore` | Restore obat |

#### 15.7 Route Read-Only Semua Role (Authenticated)
| Endpoint | Deskripsi |
|----------|-----------|
| `GET /medicines`, `GET /medicines/{id}` | Lihat daftar obat (semua role terautentikasi) |
| `GET /payments`, `GET /payments/{id}` | Lihat tagihan (filter IDOR di controller) |
| `POST /payments/{id}/upload-proof` | Upload bukti pembayaran (pasien, throttle 5/menit) |

#### 15.8 Throttling
- Route login, register, dan OTP menggunakan throttle: `throttle:auth` untuk mencegah brute-force.
- Route booking (`POST /queues`) dan upload bukti bayar (`POST /payments/{id}/upload-proof`) menggunakan throttle: `5 request per 1 menit`.

---

### 📱 Flutter — [AppRouter](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/router/app_router.dart) (Route-Level RBAC)

#### 15.9 Peta Route & Izin Role
```dart
static final Map<String, List<String>> _routePermissions = {
  // Route publik (list kosong = bebas akses)
  '/': [], '/register': [], '/forgot-password': [],
  // Admin
  '/admin/home': ['admin'], '/admin/users': ['admin'], ...
  '/tv-monitor': ['admin'],
  // Doctor
  '/doctor/home': ['doctor'], ...
  // Patient
  '/patient/home': ['patient'], ...
  '/payment/list': ['patient', 'admin'],
  // Pharmacy
  '/pharmacy/home': ['pharmacist', 'admin'],
  '/pharmacy/profile': ['pharmacist'], ...
};
```

#### 15.10 Guard di `onGenerateRoute`
- Jika route memiliki `allowedRoles` yang tidak kosong:
  - `user == null` → redirect ke `LoginScreen`.
  - `!allowedRoles.contains(user.role)` → redirect ke `LoginScreen`.
- Menggunakan `GlobalKey<NavigatorState> navigatorKey` untuk redirect global tanpa BuildContext (digunakan oleh `ApiClient` saat error 401).

---

## 16. Flutter: Manajemen State & Navigasi

### 📱 Flutter — Provider Architecture

**Berkas-berkas Provider:**
- [auth_provider.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/logic/auth_provider.dart)
- [admin_provider.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/logic/admin_provider.dart)
- [doctor_provider.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/logic/doctor_provider.dart)
- [patient_provider.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/logic/patient_provider.dart)
- [payment_provider.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/payment/logic/payment_provider.dart)
- [pharmacy_provider.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/logic/pharmacy_provider.dart)
- [puskesmas_profile_provider.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/providers/puskesmas_profile_provider.dart)

Semua provider mengelola state sinkronisasi dan memicu rendering ulang UI secara reaktif:

#### 16.1 Pola State Management (Provider + ChangeNotifier)
Hampir semua provider menggunakan pola abstraksi `_performAction()` untuk menyatukan manajemen status loading, penanganan error, dan panggilan `notifyListeners()`.

Metode asinkronus dijalankan sebagai callback dalam fungsi berikut:
```dart
Future<void> _performAction(Future<void> Function() action) async {
  _isLoading = true;
  _error = null;
  notifyListeners();
  try {
    await action();
  } catch (e) {
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

**Catatan Implementasi:**
- **`AdminProvider`**, **`PatientProvider`**, dan **`DoctorProvider`** menggunakan metode helper `_performAction()` sebagai abstraksi utama.
- **`PaymentProvider`** dan **`PharmacyProvider`** mengelola transisi loading dan error secara inline di masing-masing metode asinkronusnya.
- **`AuthProvider`** tidak menggunakan `_performAction()`. Setiap metodenya mengimplementasikan blok try/catch mandiri dengan melemparkan kembali (`rethrow`) exception tertentu agar UI dapat langsung memproses respons error pendaftaran atau login.

#### 16.2 Fitur Khusus Setiap Provider

**PatientProvider:**
- `fetchMyData()`: Mengambil data antrean (`_myQueues`), riwayat rekam medis (`_medicalRecords`), dan daftar poliklinik secara paralel (`Future.wait`) untuk mengurangi durasi load pada dashboard.
- `fetchHolidaysAndLeaves(doctorId)`: Membaca hari libur puskesmas dan jadwal cuti dokter secara paralel untuk menonaktifkan pemilihan tanggal tertentu pada kalender booking.
- `getSchedulesDirectly(polyId)`: Mengembalikan data jadwal dokter langsung ke widget form pemesanan secara sinkron tanpa menyimpannya ke state provider.
- `fetchSchedulesForPoly(polyId)`: Menyimpan jadwal yang ditemukan ke state `_availableSchedules` untuk ditampilkan pada UI pembuat antrean.

**DoctorProvider:**
- `toggleOnlineStatus()`: Mengubah status online dokter di server dan secara instan melakukan update lokal pada state `_isOnline`.
- `setOnlineStatus(bool value)`: Menginisialisasi state online dokter secara sinkronus berdasarkan profile payload dari server tanpa melakukan hit API tambahan.
- `finishExamination(data)`: Menyelesaikan proses pemeriksaan, mengirim data rekam medis, dan langsung menyegarkan data antrean `_queues` serta rekam medis dokter `_medicalRecords`.
- `fetchHistoryForPatient(patientUserId)`: Mengambil riwayat pemeriksaan pasien tertentu dan menyimpannya di state lokal `_patientHistory`.

**AdminProvider:**
- `recallQueue(id)`: Melakukan panggil ulang pasien dan langsung memodifikasi data antrean pada list lokal (`_queues[index] = updatedQueue`) tanpa melakukan hit API refetch penuh (optimasi rendering UI).
- `bookQueueForPatient(data)`: Memfasilitasi pendaftaran antrean secara manual oleh admin untuk pasien tertentu.
- `fetchSystemSettings()` & `updateSystemSettings()`: Membaca dan memperbarui parameter sistem dinamis puskesmas.

**PharmacyProvider:**
- `fetchPharmacyQueues()`: Mengambil seluruh antrean resep yang telah berstatus lunas (`paid`) dan siap diserahkan.
- `dispense(paymentId)`: Menyerahkan obat kepada pasien dan secara optimistik menghapus antrean resep tersebut dari list lokal `_queues` tanpa harus melakukan refetch data penuh ke server.
- `createMedicine(data)` / `editMedicine(id, data)` / `removeMedicine(id)` / `restoreMedicine(id)`: Melakukan CRUD data inventaris obat dan memanipulasi list lokal `_medicines` untuk sinkronisasi state instan.

**PaymentProvider:**
- `uploadProof(paymentId, filePath)`: Mengunggah file bukti transfer bank/QRIS dan memperbarui item pembayaran terkait di list lokal `_payments`.
- `verify(paymentId, status)` / `payWithCash(paymentId)`: Mengubah status pembayaran (approve/reject/tunai) dan menyelaraskan perubahan ke state lokal.

---

## 17. Flutter: API Client & Interceptor

### 📱 Flutter — [ApiClient](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/api/api_client.dart) (Dio)

#### 17.1 Konfigurasi Dasar
- **Base URL**: `https://nalaseva-api.up.railway.app/api/`
- **Timeout**: 30 detik (connect & receive).
- **Headers Default**: `Accept: application/json`, `Content-Type: application/json`.
- **validateStatus**: Hanya menerima response 2xx; semua non-2xx dilempar sebagai `DioException`.

#### 17.2 Request Interceptor (Inject Bearer Token)
- Setiap request, token dibaca dari `FlutterSecureStorage` (`key: 'access_token'`).
- **Exception**: path yang mengandung `'login'` tidak ditambahkan token (login tidak membutuhkan autentikasi).
- Token diinjeksi sebagai `Authorization: Bearer {token}`.

#### 17.3 Error Interceptor (Auto Logout saat 401)
- Jika server return **HTTP 401 (Unauthorized)**:
  - Hapus 4 key dari secure storage: `access_token`, `user_role`, `patient_id`, `doctor_id`.
  - Redirect ke halaman login menggunakan `AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil('/', ...)` (global navigasi tanpa BuildContext).

#### 17.4 Debug Logging
- Saat mode `kDebugMode = true`, request dan response body di-log secara otomatis via `LogInterceptor(requestBody: true, responseBody: true)`.

#### 17.5 Dependency Injection (DI Manual)
Di `main.dart`, satu instance `ApiClient` dibuat dan di-inject ke semua repository:
```dart
final apiClient = ApiClient();
final authRepository = AuthRepository(apiClient);
final adminRepository = AdminRepository(apiClient);
// ... dst
```

---

## 18. Manajemen Pembayaran

### 📍 API — `PaymentController.php` + `Payment.php` (Model)

#### 18.1 Pembuatan Tagihan Otomatis
- Dibuat secara otomatis di dalam database transaction ketika rekam medis (`Examination`) sukses disimpan oleh dokter.
- Formula Penghitungan: `total_amount = registration_fee (dari System Settings, default Rp10.000) + medicine_fee (jumlah quantity x harga obat saat diresepkan)`.
- Meng-generate nomor transaksi unik dengan format: `NS-PAY-YYYYMMDD-XXXXXX`.
- Status awal tagihan diset sebagai `pending`.

#### 18.2 Alur Transaksi Pasien (Upload Bukti)
- Pasien dapat melihat daftar tagihan aktif miliknya (dilengkapi IDOR protection agar pasien tidak bisa melihat pembayaran orang lain).
- Pasien mengunggah gambar bukti transfer bank/QRIS (`payment_proof`).
- Setelah bukti berhasil diunggah, status pembayaran berubah otomatis menjadi `waiting_verification` (menunggu verifikasi).
- Bukti transfer disimpan secara aman di storage direktori `payment_proofs/`.

#### 18.3 Verifikasi Admin (Cash / Transfer)
- **Verifikasi Bukti Transfer**: Admin memeriksa bukti transfer secara manual, lalu menyetujui (`status = 'paid'`, mencatat `paid_at = now()`) atau menolak (`status = 'failed'`).
- **Pembayaran Tunai (Cash Pay)**: Admin dapat langsung menyelesaikan pembayaran secara tunai di loket. Sistem mencatat pembayaran dengan metode `cash`, mengubah status menjadi `paid`, dan mengisi `paid_at = now()` secara instan.

---

### 📱 Flutter — [PaymentProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/payment/logic/payment_provider.dart) + Screens
- `fetchMyPayments()`: Ambil semua tagihan dari `GET /payments`.
- `uploadProof(paymentId, filePath)`: Upload bukti via multipart form-data, update item lokal setelah sukses.
- `verify(paymentId, status)`: Admin verifikasi (`approved`/`rejected`), update item lokal.
- `payWithCash(paymentId)`: Admin cash-pay, update item lokal.
- UI: [payment_list_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/payment/ui/payment_list_screen.dart) & [payment_detail_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/payment/ui/payment_detail_screen.dart).

---

## 19. Modul Apotek (Pharmacy)

### 📍 API — `PharmacyController.php` + `MedicineController.php`

#### 19.1 Antrean Apoteker (`Pharmacy Queues`)
- Hanya dapat diakses oleh **Admin** dan role baru **Apoteker (`pharmacist`)**.
- Endpoint `GET /pharmacy/queues` mengambil resep pemeriksaan yang status pembayarannya telah lunas (`status = 'paid'`) dan obatnya belum diserahkan (`dispensed_at IS NULL`).

#### 19.2 Validasi & Pengurangan Stok Obat Aman (`Dispense`)
- Saat apoteker menekan tombol serah obat (`POST /pharmacy/queues/{id}/dispense`), sistem menjalankan **DB Transaction** untuk keamanan inventaris:
  - Memvalidasi kecukupan stok obat untuk seluruh item yang diresepkan. Jika ada obat yang stoknya kurang dari kuantiti resep, transaksi digagalkan dan dilempar error `422 (Unprocessable Entity)`.
  - Mengurangi kolom `stock` di tabel `medicines` sesuai dengan `quantity` resep.
  - Mengisi kolom `dispensed_at = now()` pada tabel `payments` sebagai tanda obat telah sukses diserahkan ke pasien.
  - Kirim **notifikasi FCM ke pasien**: "Obat Selesai Diserahkan".

#### 19.3 CRUD Inventaris Obat & Harga (Admin & Apoteker Only)
- Admin dan Apoteker memegang hak akses penuh untuk melakukan CRUD pada data obat di `MedicineController`.
- Setiap obat memiliki kolom `price` (harga) yang dapat disesuaikan. Harga obat inilah yang dijadikan acuan perhitungan total tagihan resep pasien.
- **Soft Delete**: Penghapusan data obat menggunakan soft delete sehingga data riwayat resep terdahulu tidak mengalami kegagalan relasi foreign key, serta dapat dikembalikan sewaktu-waktu via endpoint `restore`.

---

### 📱 Flutter — [PharmacyProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/logic/pharmacy_provider.dart) + Screens
- State: `List<PaymentModel> _queues` (daftar resep siap serah), `List<MedicineModel> _medicines`.
- `dispense(paymentId)`: Serahkan obat, hapus dari `_queues` lokal tanpa refetch.
- `createMedicine(data)`: Tambah obat → append ke `_medicines` lokal.
- `editMedicine(id, data)`: Edit obat → update di `_medicines` lokal by index.
- `removeMedicine(id)`: Hapus obat → `_medicines.removeWhere(...)`.
- `restoreMedicine(id)`: Restore obat → append restored obat ke `_medicines`.
- UI: [pharmacy_dashboard_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/ui/pharmacy_dashboard_screen.dart), [medicine_inventory_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/ui/medicine_inventory_screen.dart), dan [prescription_detail_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/ui/prescription_detail_screen.dart).

---

## 20. Pengaturan Dinamis Puskesmas (System Settings)

### 📍 API — `SettingController.php` + `Setting.php` (Model)

#### 20.1 Tabel & Model Pengaturan
- Menyimpan parameter operasional puskesmas pada tabel `settings` dengan struktur pasangan kunci-nilai (`key` & `value`).
- Fungsi helper `Setting::getValue($key, $default)` dan `Setting::setValue($key, $value)` digunakan untuk mempermudah akses logika dinamis.

#### 20.2 Endpoint Pengaturan Admin (GET & PUT `/settings`)
- Rute `GET /settings` mengambil seluruh pengaturan terdaftar (dengan fallback biaya pendaftaran `10000` dan durasi slot `15` menit).
- Rute `PUT /settings` membolehkan admin memperbarui biaya layanan (`registration_fee`) dan durasi per slot antrean (`slot_duration_minutes`) secara instan.

#### 20.3 Integrasi Logika Dinamis
- **Nominal Tagihan Pembuatan Otomatis**: Logika pembuatan invoice pembayaran pada `ExaminationController` menggunakan `Setting::getValue('registration_fee', 10000)` untuk menentukan biaya layanan puskesmas yang fleksibel.
- **Kalkulasi Estimasi Waktu Antrean**: Logika perhitungan estimasi waktu layanan dan fallback waktu tunggu pada model `Queue.php` mengambil nilai dinamis dari `Setting::getValue('slot_duration_minutes', 15)`.

---

### 📱 Flutter — [AdminProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/logic/admin_provider.dart) + [AdminSettingsScreen](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/admin_settings_screen.dart)

#### 20.4 Integrasi REST API (Flutter)
- `AdminRepository` mengekspos `getSystemSettings()` dan `updateSystemSettings(Map<String, dynamic> data)`.
- `AdminProvider` menampung state `_systemSettings` dan mengekspos aksi `fetchSystemSettings()` & `updateSystemSettings()`.

#### 20.5 Antarmuka Pengaturan Dinamis
- **Sinkronisasi Otomatis**: [AdminSettingsScreen](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/admin_settings_screen.dart) memicu pemuatan konfigurasi pusat dari server saat layar diinisialisasi.
- **Biaya Pendaftaran**: Modal sheet untuk memperbarui biaya pendaftaran dari HP ke database.
- **Rata-rata Waktu Layanan**: Pilihan durasi slot disinkronkan ke server.
- **Profil Puskesmas**: Termasuk update nama, alamat, kontak, dan **koordinat lokasi** via `MapPickerScreen` (OpenStreetMap).

---

## 21. Standarisasi UI/UX & Penyempurnaan Alur Dialog (Flutter)

### 📱 Flutter — [AppDialogs](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/utils/app_dialogs.dart) + Custom Widgets

#### 21.1 Sistem Dialog Terstandarisasi (`AppDialogs`)
Kelas `AppDialogs` menyediakan 3 jenis dialog seragam yang responsif dan konsisten secara visual:

**`showNotificationDialog(context, title, message, {isError})`:**
- Digunakan untuk pesan informasi atau error.
- Icon & warna judul berubah sesuai `isError`: merah (`errorColor`) atau hijau (`successColor`).
- Tombol: satu tombol `ElevatedButton` "OK" lebar penuh.

**`showSuccessDialog(context, title, message, {onOkPressed})`:**
- Digunakan untuk konfirmasi sukses.
- `barrierDismissible: false` — user harus tekan OK.
- Mendukung callback `onOkPressed` untuk aksi setelah dialog ditutup.

**`showConfirmationDialog(context, title, message, {confirmText, cancelText, isDestructive})`:**
- Dialog konfirmasi dua tombol (Batal + Aksi).
- `isDestructive = true` → tombol konfirmasi berwarna merah (`errorColor`).
- `isDestructive = false` (default) → tombol konfirmasi berwarna `primaryColor`.
- Mapping teks tombol: `'YA, DAFTAR'` → `'Daftar'`, `'YA, HAPUS'` → `'Hapus'`, dll.
- Return `Future<bool?>` — `true` jika konfirmasi, `false` jika batal.

#### 21.2 Konfirmasi Pembatalan Bersyarat (Conditional Cancel Confirmation)
- Alur konfirmasi dua arah sebelum mengeksekusi fungsi pembatalan atau penghapusan.
- Sinkronisasi teks: "Batal" untuk menutup dialog, "Batalkan"/"Hapus" untuk tombol eksekusi destruktif.

#### 21.3 Standarisasi Navigasi & Pelindung State Form
- Dialog konfirmasi keluar (*discard changes prompt*) jika user mencoba kembali saat form telah terisi sebagian.
- Diterapkan di form: tambah dokter, cuti, jadwal praktik, rekam medis, inventaris obat.

---

## 22. Flutter: Utilitas & Integrasi Sistem

### 📱 Flutter — Fitur Khusus dan Modul Pembantu

#### 22.1 QR Scanner Check-In (Admin)
- **File**: [qr_scanner_page.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/widgets/qr_scanner_page.dart)
- **Library**: `mobile_scanner`
- Memindai QR Code tiket antrean milik pasien untuk memverifikasi kedatangan secara instan.
- **Format QR yang Didukung**:
  1. `NALASEVA_QUEUE_{id}` → dicocokkan berdasarkan `queue.id`.
  2. Nomor antrean (contoh: `UMM-001`) → dicocokkan berdasarkan `queue.queueNumber` terdaftar hari ini.
- **Validasi Jendela Waktu**: Terintegrasi dengan `ServiceTimeValidator.validateAdminAction()` (absensi diizinkan 30 menit sebelum hingga maksimal 2 jam setelah jam pelayanan tertera).
- **Akses**: Hanya dapat diakses oleh Admin pada rute `/admin/scan`.

#### 22.2 Connectivity Banner (Global)
- **File**: [connectivity_banner.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/widgets/connectivity_banner.dart)
- **Library**: `connectivity_plus`
- Banner merah yang melayang di bagian atas layar secara global ketika aplikasi mendeteksi tidak adanya koneksi internet aktif.
- Mendengarkan `Connectivity().onConnectivityChanged` secara asinkron di level root (`MaterialApp.builder`) untuk menjamin banner merender di atas halaman mana pun.

#### 22.3 Text-to-Speech (TTS) untuk Pemanggilan Antrean
- **File**: [tts_helper.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/utils/tts_helper.dart) + wrapper multiplatform: [tts_mobile.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/utils/tts_mobile.dart), [tts_web.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/utils/tts_web.dart), dan [tts_stub.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/utils/tts_stub.dart).
- Menggunakan conditional import berbasis arsitektur Dart:
  - `dart.library.html` → Memanggil API browser `SpeechSynthesis`.
  - `dart.library.io` → Memanggil package native `flutter_tts`.
- Mengekspos `TtsHelper.speak(text)` untuk membacakan nomor panggilan pasien secara lisan pada layar TV Monitor Puskesmas ([queue_monitor_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/queue_monitor_screen.dart)).

#### 22.4 Map Picker (Lokasi Puskesmas)
- **File**: [map_picker_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/widgets/map_picker_screen.dart)
- **Library**: `flutter_map` + `latlong2`
- Menampilkan peta OpenStreetMap dinamis. Admin dapat menandai dan menggeser marker koordinat lokasi puskesmas secara visual. Lokasi yang dipilih akan dikembalikan dalam format `LatLng` dan diunggah ke backend.

#### 22.5 App Logger (Structured Logging)
- **File**: [app_logger.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/utils/app_logger.dart)
- Menyediakan fungsi logging berjenjang (`AppLogger.debug(message)`, `AppLogger.error(message, error, stackTrace)`) untuk mempermudah pelacakan alur crash scanner, Dio, atau inisialisasi FCM.

#### 22.6 DateTimeParser (Sistem Parsing Aman)
- **File**: [date_time_parser.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/utils/date_time_parser.dart)
- Class utilitas statis untuk parsing tanggal dan waktu yang fleksibel untuk menghindari kegagalan parsing tipe data null atau string kosong dari backend Laravel:
  - `parseDateOnly(String? value)`: Mengubah string format tanggal menjadi objek `DateTime` dengan mereset komponen jam/menit/detik ke `00:00:00` (mengabaikan informasi timezone lokal).
  - `parseDateTime(String? value)`: Parsing representasi ISO 8601 string secara aman menjadi objek `DateTime?`.
  - `parseMinutesOfDay(String? value)`: Menerima format jam `HH:mm` (misal `"08:30"`) dan menghitung total menit dari tengah malam (`8 * 60 + 30 = 510` menit). Melakukan pengecekan validitas jam (0-23) dan menit (0-59).
  - `parseTimeOfDay(String? value)`: Parsing string `HH:mm` langsung menjadi objek `TimeOfDay?` bawaan Flutter.

#### 22.7 Validators (Validasi Form)
- **File**: [validators.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/utils/validators.dart)
- Berisi kumpulan fungsi validasi statis untuk input form:
  - `validateEmail(String? value)`: Validasi format email melalui regex `^[^\s@]+@[^\s@]+\.[^\s@]{2,}$`. Memastikan email tidak kosong dan tidak mengandung spasi di tengahnya.
  - `validateRequiredText(String? value, {String message})`: Validasi dasar teks wajib terisi (tidak null/kosong).
  - `validatePositiveInteger(String? value, {String message})`: Memastikan teks yang diinput merupakan bilangan bulat bernilai positif (> 0) (misalnya kuota antrean, harga obat).

#### 22.8 LocalStorage (Penyimpanan Key-Value Offline)
- **File**: [local_storage.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/utils/local_storage.dart)
- Menggunakan library `shared_preferences` untuk persistence data lokal:
  - `saveToken(token)` & `getToken()`: Menyimpan/membaca token otentikasi menggunakan key `'auth_token'`.
  - `saveRole(role)` & `getRole()`: Menyimpan/membaca hak akses pengguna menggunakan key `'user_role'`.
  - `clear()`: Menghapus seluruh data offline yang tersimpan di memori perangkat.
  - *Catatan Perbandingan*: Untuk penyimpanan runtime sensitif dalam otentikasi rekat, aplikasi mendominasi penggunaan `FlutterSecureStorage` di dalam [AuthProvider](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/logic/auth_provider.dart) untuk menyimpan key: `access_token`, `user_role`, `patient_id`, dan `doctor_id`.

#### 22.9 ErrorParser (Sistem Pengurai Pesan Error API)
- **File**: [error_parser.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/utils/error_parser.dart)
- Mengurai respons error `DioException` secara aman agar tidak memunculkan stack trace panjang backend ke dalam dialog pop-up pengguna:
  - `parse(DioException e, String defaultMsg)`:
    - Jika response dari Laravel bertipe `Map`, mengekstrak string dari key `'message'`.
    - Jika respons bertipe `String`, sistem mencoba melakukan decoding JSON untuk mengekstrak pesan.
    - **Proteksi Halaman Debug Laravel 500 (HTML Filter)**: Jika response diawali dengan tag `<!DOCTYPE` atau `<html` (yang mengindikasikan halaman error HTML internal Laravel), sistem secara cerdas akan langsung membuang teks tersebut dan mengembalikan pesan fallback `defaultMsg` agar UI tidak memuat teks HTML yang berantakan.
    - Memotong teks error non-HTML maksimal 100 karakter (`data.substring(0, 100)`) agar aman dirender pada pop-up dialog.

#### 22.10 Standardisasi UI Responsif (Responsive Breakpoints)
Sistem UI dikonsistensikan secara dinamis menggunakan utilitas responsif terpadu di dalam [responsive_helper.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/utils/responsive_helper.dart):
- **Breakpoints Standar**:
  - **Mobile**: Lebar layar di bawah `600.0` logical pixel.
  - **Tablet**: Lebar layar antara `600.0` (inklusif) hingga `1024.0` logical pixel. Admin direkomendasikan dan dioptimalkan menggunakan tablet untuk kenyamanan operasional.
  - **TV / Desktop**: Lebar layar di atas `1024.0` (inklusif). Dimanfaatkan penuh oleh layar monitor TV antrean Puskesmas.
- **ResponsiveHelper (Scalable Engine)**:
  - `isMobile(context)` / `isTablet(context)` / `isTv(context)`: Fungsi deteksi instan bertipe boolean.
  - `scale(context, baseMobile, {tablet, tv})`: Penskalaan otomatis ukuran widget/font. Jika ukuran tablet dan tv tidak didefinisikan secara eksplisit, sistem akan otomatis melakukan pengalian skala:
    - Faktor skala tablet: `1.2x` dari ukuran mobile.
    - Faktor skala TV/Desktop: `1.4x` dari ukuran mobile.
  - `fontSize(context, baseSize)` & `spacing(context, baseSpacing)`: Menerapkan penskalaan adaptif pada tipografi dan tata letak ruang (padding/margin) secara konsisten.
- **ResponsiveLayout (Layout Builder)**:
  - Widget yang merender struktur visual berbeda (`mobile`, `tablet`, atau `tv`) berdasarkan batasan lebar (`BoxConstraints`) layar saat runtime.
- **ResponsiveCenter (Centering Guard)**:
  - Membungkus konten agar tidak melebar berantakan di layar besar (seperti tablet/iPad). Membatasi lebar konten maksimal (`maxWidth` default `800`) dan memusatkan posisinya di layar sehingga tata letak UI tetap seimbang dan premium.

---

## 23. Struktur Model Data (Flutter)

Berikut adalah struktur representasi data objek (Model) di sisi aplikasi Flutter:

### 23.1 [PatientModel](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/patient_model.dart)
Merepresentasikan data lengkap pasien beserta info dasar akun.
- **Fields**:
  - `id` (`int`): ID Pasien di database.
  - `userId` (`int`): ID akun pengguna (`users` table).
  - `fullNameFromDb` (`String?`): Nama lengkap pasien dari JSON database (mendukung key `'fullname'`, `'full_name'`, atau `'name'`).
  - `medicalRecordNumber` (`String?`): Nomor Rekam Medis unik (MRN).
  - `nationalId` (`String?`): NIK (16 digit).
  - `gender` (`String?`): Jenis kelamin (otomatis dinormalkan dari `'l'`, `'male'`, `'p'`, atau `'female'` menjadi `'Laki-laki'` atau `'Perempuan'`).
  - `birthDate` (`DateTime?`): Tanggal lahir pasien (diproses via `DateTimeParser`).
  - `user` (`UserModel?`): Objek akun user terkait.
- **Convenience Getters**:
  - `name` / `fullName`: Mengembalikan nama lengkap pasien dari field DB, user profil, atau fallback `'Pasien'`.
  - `phone`: Mengambil nomor telepon dari relasi user (`user?.phone`).
  - `address`: Mengambil alamat tinggal dari relasi user (`user?.address`).
  - `age` (`int`): Menghitung umur pasien secara real-time berdasarkan selisih tahun, bulan, dan hari dari `birthDate` terhadap waktu saat ini.
  - `isElderly` (`bool`): Mengembalikan nilai `true` jika usia pasien saat ini sudah mencapai **60 tahun ke atas**, yang memicu pembuatan tiket antrean prioritas.

### 23.2 [DoctorModel](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/doctor_model.dart)
Merepresentasikan data dokter dan poliklinik tempatnya bertugas.
- **Fields**:
  - `id` (`int`): ID Dokter.
  - `userId` (`int`): ID user terasosiasi.
  - `licenseNumber` (`String?`): Nomor Surat Izin Praktik (SIP).
  - `polyclinicId` (`int?`): ID poliklinik tempat dokter ditugaskan.
  - `specialization` (`String?`): Spesialisasi dokter.
  - `user` (`UserModel?`): Detail akun user dokter.
  - `polyclinic` (`PolyclinicModel?`): Detail poliklinik terkait.
  - `isOnline` (`bool?`): Status online dokter (siap melayani antrean). Di-parse secara aman dari tipe boolean, string (`'true'`, `'1'`, `'online'`), atau number.
- **Convenience Getters**:
  - `name` / `fullName`: Mengambil nama dokter dari relasi user (`user?.name ?? 'Dokter'`).
  - `phone`: Mengambil nomor telepon (`user?.phone`).
  - `address`: Mengambil alamat tinggal (`user?.address`).

### 23.3 [ExaminationModel](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/examination_model.dart)
Merepresentasikan catatan medis hasil pemeriksaan dokter.
- **Fields**:
  - `id` (`int`): ID Pemeriksaan.
  - `queueId` (`int`): ID antrean terkait.
  - `doctorId` (`int`): ID dokter yang memeriksa.
  - `complaint` (`String`): Keluhan utama pasien.
  - `diagnosis` (`String`): Hasil diagnosis dokter.
  - `treatment` (`String`): Tindakan medis atau instruksi resep obat kasar.
  - `createdAt` (`DateTime?`): Tanggal pemeriksaan dilakukan.
  - `doctor` (`DoctorModel?`): Relasi dokter pemeriksa.
  - `queue` (`QueueModel?`): Relasi tiket antrean terikat.
  - `prescriptionItems` (`List<PrescriptionItemModel>`): Daftar obat terstruktur yang diresepkan.
- **Convenience Getters**:
  - `patientName` (`String`): Mengambil nama pasien langsung dari relasi antrean (`queue?.patient.name ?? 'Pasien'`).
  - `doctorName` (`String`): Mengambil nama dokter dari relasi dokter (`doctor?.name ?? 'Dokter'`).

### 23.4 [PolyclinicModel](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/models/polyclinic_model.dart)
Merepresentasikan unit poliklinik di puskesmas.
- **Fields**:
  - `id` (`int`): ID Poliklinik.
  - `name` (`String`): Nama poliklinik (misal: "Poli Umum", "Poli Gigi").
  - `code` (`String`): Kode unik poliklinik (misal: "UMM", "GIG"), digunakan sebagai prefix nomor antrean.
  - `description` (`String?`): Penjelasan deskripsi layanan poliklinik.

---

## 24. Daftar Dependensi & Library (pubspec.yaml)

Aplikasi dibangun menggunakan sekumpulan library pihak ketiga berikut:

- **`cupertino_icons`**: Set ikon default gaya iOS Cupertino.
- **`flutter_tts`**: Menjalankan konversi Text-to-Speech pada platform mobile untuk memanggil nomor antrean di TV Monitor.
- **`dio`**: HTTP Client berbasis Dart untuk melakukan request ke API Laravel dengan dukungan interceptor token dan error terpusat.
- **`provider`**: Solusi state management reaktif dan Dependency Injection sederhana.
- **`google_fonts`**: Memuat font modern (seperti *Plus Jakarta Sans* atau *Inter*) secara dinamis.
- **`shared_preferences`**: Menyimpan konfigurasi offline sederhana (seperti user_role offline).
- **`intl`**: Formatting tanggal, waktu, mata uang Rupiah, dan lokalisasi bahasa.
- **`flutter_svg`**: Merender grafis vektor SVG di dalam UI.
- **`cached_network_image`**: Mengunduh dan menaruh gambar internet ke cache lokal untuk menghemat kuota.
- **`font_awesome_flutter`**: Menyediakan ribuan ikon sosial dan medis FontAwesome.
- **`animate_do`**: Library animasi masuk mikro yang halus dan cepat (e.g., FadeIn, FadeInUp).
- **`flutter_staggered_animations`**: Memberikan animasi kemunculan bertahap (stagger) pada deretan item di ListView.
- **`glassmorphism`**: Merender kartu kaca buram transparan premium (efek glassmorphism).
- **`lottie`**: Merender animasi Lottie berbasis JSON berkualitas tinggi (seperti lottie sukses/loading).
- **`flutter_secure_storage`**: Menyimpan data sensitif (access_token, user_role, id) ke dalam keychain (iOS) / Keystore (Android) terenkripsi.
- **`mobile_scanner`**: Pembaca QR Code berkecepatan tinggi menggunakan kamera perangkat.
- **`qr_flutter`**: Membuat/merender gambar QR Code tiket antrean pasien secara instan.
- **`fl_chart`**: Menggambar grafik analitik data mingguan untuk dashboard.
- **`firebase_core` / `firebase_messaging`**: Integrasi dengan layanan Firebase Cloud Messaging (FCM) untuk pengiriman notifikasi push.
- **`flutter_local_notifications`**: Mengelola dan menampilkan notifikasi pop-up saat aplikasi berada di foreground.
- **`url_launcher`**: Membuka link URL web eksternal (OpenStreetMap, telepon, whatsapp).
- **`flutter_map` / `latlong2`**: Merender widget peta berbasis OpenStreetMap dan menangani kalkulasi koordinat geografis.
- **`image_picker`**: Membuka galeri atau kamera untuk memilih file foto bukti pembayaran pasien.
- **`connectivity_plus`**: Memantau perubahan status koneksi internet perangkat secara real-time.

---

## 25. Daftar Lengkap Halaman UI (UI Screens)

Berikut adalah pembagian seluruh berkas halaman antarmuka (UI Screens) yang diimplementasikan di dalam proyek Flutter:

### 🔑 Modul Autentikasi (`lib/features/auth/ui/`)
- **[login_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/ui/login_screen.dart)**: Halaman login pengguna (Email & Password).
- **[register_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/ui/register_screen.dart)**: Form pendaftaran pasien baru (NIK, nama, tanggal lahir, jenis kelamin, alamat, telepon).
- **[forgot_password_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/ui/forgot_password_screen.dart)**: Alur pemulihan kata sandi dengan OTP (Request OTP via Email & NIK → Reset Password).

### 👑 Modul Admin (`lib/features/admin/ui/`)
- **[admin_dashboard.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/admin_dashboard.dart)**: Pusat visualisasi data statistik harian, jalan pintas menu, dan grafik mingguan.
- **[queue_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/queue_management_screen.dart)**: Pengelolaan antrean hari ini (Check-in, Skip/Geser Belakang, Recall).
- **[admin_booking_detail_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/admin_booking_detail_screen.dart)**: Detail spesifik tiket antrean dari sisi admin dengan opsi tindakan operasional.
- **[doctor_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/doctor_management_screen.dart)**: CRUD data dokter puskesmas terintegrasi.
- **[doctor_schedule_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/doctor_schedule_management_screen.dart)**: Pengelolaan jam praktik dokter dan pendeteksian overlap jadwal.
- **[admin_doctor_leaves_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/admin_doctor_leaves_screen.dart)**: CRUD data cuti dokter dan pembatalan tiket terdampak otomatis.
- **[admin_clinic_holidays_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/admin_clinic_holidays_screen.dart)**: CRUD hari libur puskesmas dan pembatalan massal tiket antrean.
- **[polyclinic_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/polyclinic_management_screen.dart)**: CRUD poliklinik dan kode antrean.
- **[patient_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/patient_management_screen.dart)**: CRUD data pasien oleh admin.
- **[user_management_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/user_management_screen.dart)**: CRUD akun user dasar beserta penentuan role.
- **[examination_history_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/examination_history_screen.dart)**: Monitoring daftar riwayat pemeriksaan rekam medis seluruh pasien.
- **[queue_monitor_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/queue_monitor_screen.dart)**: Tampilan visual TV Monitor antrean publik (suara panggil TTS aktif).
- **[admin_settings_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/ui/admin_settings_screen.dart)**: Konfigurasi parameters global (`registration_fee`, `slot_duration_minutes`, profil puskesmas, dan map picker lokasi).

### 🩺 Modul Dokter (`lib/features/doctor/ui/`)
- **[doctor_dashboard.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/ui/doctor_dashboard.dart)**: Menampilkan antrean pasien aktif dokter terkait dan toggle status online/offline.
- **[examination_form_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/ui/examination_form_screen.dart)**: Form input hasil pemeriksaan pasien (Keluhan, Diagnosis, Tindakan, dan Resep obat).
- **[doctor_profile_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/ui/doctor_profile_screen.dart)**: Tampilan profil detail dokter terautentikasi.
- **[doctor_edit_profile_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/ui/doctor_edit_profile_screen.dart)**: Formulir perubahan data personal dokter.

### 👤 Modul Pasien (`lib/features/patient/ui/`)
- **[patient_dashboard.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/ui/patient_dashboard.dart)**: Dashboard pasien menampilkan status antrean hari ini, menu navigasi, dan profil ringkas puskesmas.
- **[booking_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/ui/booking_screen.dart)**: Alur pemesanan tiket antrean puskesmas secara mandiri.
- **[booking_detail_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/ui/booking_detail_screen.dart)**: Tiket antrean digital pasien yang dilengkapi dengan QR Code.
- **[patient_history_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/ui/patient_history_screen.dart)**: Layar riwayat rekam medis pasien terintegrasi dengan filter pencarian per rentang bulan.
- **[medical_history_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/ui/medical_history_screen.dart)**: Halaman ringkas daftar rekam medis pemeriksaan pasien.
- **[medical_record_detail_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/ui/medical_record_detail_screen.dart)**: Informasi detail hasil diagnosa dokter dan rincian obat yang wajib ditebus.
- **[notification_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/ui/notification_screen.dart)**: Pusat kotak masuk notifikasi aktivitas antrean dan status pembayaran pasien.
- **[profile_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/ui/profile_screen.dart)**: Rincian akun pasien terdaftar.
- **[edit_profile_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/ui/edit_profile_screen.dart)**: Halaman pengeditan data profil pasien.

### 💳 Modul Pembayaran (`lib/features/payment/ui/`)
- **[payment_list_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/payment/ui/payment_list_screen.dart)**: Halaman daftar tagihan medis yang berstatus *pending*, *waiting verification*, atau *paid*.
- **[payment_detail_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/payment/ui/payment_detail_screen.dart)**: Rincian total biaya tagihan (registrasi + obat-obatan), opsi upload bukti bayar bagi pasien, serta aksi verifikasi/bayar tunai bagi admin.

### 💊 Modul Apotek (`lib/features/pharmacy/ui/`)
- **[pharmacy_dashboard_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/ui/pharmacy_dashboard_screen.dart)**: Dashboard utama apoteker menampilkan antrean resep obat siap serah.
- **[prescription_detail_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/ui/prescription_detail_screen.dart)**: Rincian daftar obat resep pasien untuk divalidasi dan diserahkan (*Dispense*).
- **[medicine_inventory_screen.dart](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/ui/medicine_inventory_screen.dart)**: Layar pengelolaan stok obat (CRUD obat, stok, dan harga).

---

*Dokumen ini mencakup **seluruh** logika bisnis dari kedua project NalaSeva.*  
*Diperbarui: 3 Juni 2026 — Sinkronisasi penuh dengan kode aktual Flutter (`nalaseva 3`)*
