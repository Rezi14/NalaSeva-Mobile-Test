# 📋 Dokumentasi Logika Bisnis NalaSeva

> **Dua Project:** Laravel REST API (`nalaseva api`) dan Flutter Mobile App (`nalaseva 3`)  
> Sistem ini merupakan aplikasi manajemen antrean puskesmas digital dengan 3 role pengguna: **Admin**, **Dokter**, dan **Pasien**.

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
  - Buat record di tabel `users` dengan `role = 'patient'`.
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

### 📱 Flutter — `AuthProvider` + `AuthRepository`

#### 1.7 Login (Flutter)
1. Panggil API `POST auth/login`.
2. Simpan `access_token` ke **FlutterSecureStorage**.
3. Langsung panggil `GET auth/profile` untuk mendapatkan data profil lengkap (dengan relasi).
4. Simpan `user_role`, `patient_id`, `doctor_id` ke secure storage.
5. Inisialisasi Firebase Messaging dan perbarui FCM Token ke server.

#### 1.8 Logout (Flutter)
- Panggil `POST auth/logout` ke server.
- Bersihkan semua key dari secure storage: `access_token`, `user_role`, `patient_id`, `doctor_id`.
- Trigger `notifyListeners()` agar UI refresh ke halaman login.

#### 1.9 checkAuth (Session Restore)
- Dipanggil saat aplikasi dibuka.
- Jika ada `access_token` di storage, coba fetch profil dari server.
- Jika server return `401/403` (token tidak valid) → hapus semua data dan paksa login ulang.
- Jika error jaringan/server down → buat **UserModel sentinel "Offline"** berdasarkan role yang tersimpan, sehingga aplikasi tetap bisa menampilkan UI sesuai role tanpa koneksi.

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
- Kuota per jadwal dihitung otomatis: `durasi_menit / 15` (1 slot per 15 menit).
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

### 📱 Flutter — `PatientProvider` + `DoctorProvider` + `AdminProvider`

#### 2.8 Booking (Patient)
- `createBooking()`: Kirim data ke API, refresh daftar antrean setelahnya.
- `fetchHolidaysAndLeaves()`: Fetch hari libur klinik dan cuti dokter secara **paralel** (`Future.wait`) untuk validasi di UI (disable tanggal yang tidak tersedia di date picker).
- `cancelQueue()`: Kirim `DELETE /queues/{id}`, refresh daftar antrean.

#### 2.9 Proses Antrean (Dokter)
- `processQueue()`: Update status antrean (`PUT /queues/{id}`), refresh daftar antrean.
- `finishExamination()`: Submit rekam medis (`POST /examinations`), refresh antrean dan rekam medis.
- `toggleOnlineStatus()`: Toggle status online/offline dokter, kirim ke `PATCH /doctors/me/status`.

#### 2.10 Manajemen Antrean (Admin)
- `updateQueueStatus()`: Update status antrean.
- `checkInQueue()`: Check-in pasien via `POST /queues/{id}/checkin`.
- `recallQueue()`: Panggil ulang pasien via `POST /queues/{id}/recall`, update item di list secara lokal tanpa refetch penuh.
- `moveQueueToBack()`: Skip antrean ke belakang via `POST /queues/{id}/skip`.
- `bookQueueForPatient()`: Admin bisa mendaftarkan antrean untuk pasien.

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
- Kuota = `durasi_menit / 15`, dikurangi jumlah booking aktif.

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

## 7. Manajemen Poliklinik

### 📍 API — `PolyclinicController.php`

#### 7.1 Tambah & Update Poliklinik (Admin Only)
- Jika kode poliklinik (`code`) diubah, cek apakah ada antrean aktif hari ini → jika ada, tolak perubahan (kode digunakan sebagai prefix nomor antrean).

#### 7.2 Hapus Poliklinik (Admin Only)
- Cek apakah ada antrean aktif di poliklinik tersebut → jika ada, tolak penghapusan.
- Cek apakah ada jadwal dokter yang masih terdaftar → jika ada, tolak penghapusan.
- Jika semua aman, lakukan soft-delete.

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

## 11. Profil Puskesmas

### 📍 API — `PuskesmasProfileService.php` + `PuskesmasProfileController.php`

#### 11.1 Lihat Profil Puskesmas (Publik)
- Endpoint publik (tidak membutuhkan autentikasi).
- Menampilkan data profil puskesmas: nama, alamat, kontak, dsb.

#### 11.2 Update Profil Puskesmas (Admin Only)
- Hanya admin yang bisa memperbarui informasi profil puskesmas.

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

---

### 📱 Flutter — `FirebaseMessagingService`

#### 12.3 Inisialisasi & Setup
- Inisialisasi `flutter_local_notifications` untuk menampilkan notifikasi saat app di foreground.
- Register background message handler (`_firebaseMessagingBackgroundHandler`).
- Meminta izin notifikasi dari user (alert, badge, sound).

#### 12.4 Tampilkan Notifikasi Foreground
- Mendengarkan `FirebaseMessaging.onMessage.listen`.
- Jika ada notifikasi masuk saat app aktif, tampilkan sebagai **lokal notification** di notification tray.
- Channel ID: `nalaseva_channel`, nama: "Nalaseva Notifications".

#### 12.5 Get & Update FCM Token
- `getFCMToken()`: Ambil token dari Firebase.
- Token dikirim ke server via `POST /auth/fcm-token` setelah login berhasil.

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
- Jika tidak ada data historis → default **15 menit**.

#### 13.3 Hitung Estimasi Waktu Layanan (`calculateEstimatedServiceTime`)
- Berdasarkan `posisi_antrian × 15 menit` (fixed per slot).
- `base_time`: waktu sekarang ATAU waktu mulai jadwal dokter (mana yang lebih lambat).
- Return format: `HH:mm`.

#### 13.4 Recalculate Semua Estimasi (`recalculateEstimatedTimes`)
- Dipanggil setiap kali ada perubahan status antrean (booking, check-in, skip, recall, dll).
- Mengambil semua antrean `booked` dan `waiting` di poliklinik dan tanggal yang sama, diurutkan: **prioritas duluan**, lalu berdasarkan waktu check-in/booking.
- Update kolom `estimated_service_time` untuk setiap antrean.

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

#### 15.6 Throttling
- Route login, register, dan OTP menggunakan throttle: `throttle:auth` untuk mencegah brute-force.

---

## 16. Flutter: Manajemen State & Navigasi

### 📱 Flutter — `AuthProvider`, `PatientProvider`, `DoctorProvider`, `AdminProvider`

#### 16.1 Pola State Management (Provider + ChangeNotifier)
Semua provider menggunakan pola yang sama:
```dart
_isLoading = true;
_error = null;
notifyListeners();
try {
  // logika bisnis
} catch (e) {
  _error = e.toString();
} finally {
  _isLoading = false;
  notifyListeners();
}
```

#### 16.2 Fitur Khusus Setiap Provider

**PatientProvider:**
- `fetchMyData()`: Mengambil antrean, rekam medis, dan poliklinik secara **paralel** (`Future.wait`) untuk efisiensi.
- `fetchHolidaysAndLeaves(doctorId)`: Mengambil hari libur klinik dan cuti dokter spesifik secara paralel, digunakan untuk disable tanggal di date picker booking.
- `getSchedulesDirectly()`: Mengambil jadwal langsung tanpa menyimpan ke state (untuk validasi real-time saat booking).

**DoctorProvider:**
- `toggleOnlineStatus()`: Toggle antara online/offline, simpan state lokal, kirim ke server.
- `finishExamination()`: Submit rekam medis dan refresh antrean + rekam medis sekaligus.
- `fetchHistoryForPatient(patientUserId)`: Lihat riwayat pemeriksaan pasien spesifik (filter by patient ID).

**AdminProvider:**
- `recallQueue()`: Setelah recall, update item di list lokal secara langsung (bukan refetch semua) untuk optimasi UI.
- `bookQueueForPatient()`: Admin bisa mendaftarkan antrean untuk pasien.
- `fetchDashboardStats()`: Ambil statistik dashboard dari `GET /dashboard-stats`.

---

## 17. Flutter: API Client & Interceptor

### 📱 Flutter — `ApiClient` (Dio)

#### 17.1 Konfigurasi Dasar
- **Base URL**: `https://nalaseva-api.up.railway.app/api/`
- **Timeout**: 30 detik (connect & receive).
- **Accept Header**: `application/json`.
- **validateStatus**: Hanya menerima response 2xx; semua non-2xx dilempar sebagai `DioException`.

#### 17.2 Request Interceptor (Inject Bearer Token)
- Setiap request, token dibaca dari `FlutterSecureStorage`.
- Exception: path yang mengandung `'login'` tidak ditambahkan token (login tidak membutuhkan autentikasi).
- Token diinjeksi sebagai `Authorization: Bearer {token}`.

#### 17.3 Error Interceptor (Auto Logout saat 401)
- Jika server return **HTTP 401 (Unauthorized)**:
  - Hapus semua data dari secure storage: `access_token`, `user_role`, `patient_id`, `doctor_id`.
  - Redirect ke halaman login menggunakan `AppRouter.navigatorKey` (global navigasi tanpa BuildContext).

#### 17.4 Debug Logging
- Saat mode `kDebugMode = true`, request dan response body di-log secara otomatis via `LogInterceptor`.

---

## 18. Manajemen Pembayaran

### 📍 API — `PaymentController.php` + `Payment.php` (Model)

#### 18.1 Pembuatan Tagihan Otomatis
- Dibuat secara otomatis di dalam database transaction ketika rekam medis (`Examination`) sukses disimpan oleh dokter.
- Formula Penghitungan: `total_amount = registration_fee (default Rp10.000) + medicine_fee (jumlah quantity x harga obat saat diresepkan)`.
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

#### 19.3 CRUD Inventaris Obat & Harga (Admin & Apoteker Only)
- Admin dan Apoteker memegang hak akses penuh untuk melakukan CRUD pada data obat di `MedicineController`.
- Setiap obat memiliki kolom `price` (harga) yang dapat disesuaikan. Harga obat inilah yang dijadikan acuan perhitungan total tagihan resep pasien.
- **Soft Delete**: Penghapusan data obat menggunakan soft delete sehingga data riwayat resep terdahulu tidak mengalami kegagalan relasi foreign key, serta dapat dikembalikan sewaktu-waktu via endpoint `restore`.

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

### 📱 Flutter — `AdminProvider` + `AdminSettingsScreen`

#### 20.4 Integrasi REST API (Flutter)
- `AdminRepository` memperluas pemanggilan endpoint lewat `getSystemSettings()` dan `updateSystemSettings(Map<String, dynamic> data)`.
- `AdminProvider` menampung state `_systemSettings` dan mengekspos aksi `fetchSystemSettings()` & `updateSystemSettings()`.

#### 20.5 Antarmuka Pengaturan Dinamis
- **Sinkronisasi Otomatis**: `AdminSettingsScreen` memicu pemuatan konfigurasi pusat dari server saat layar diinisialisasi.
- **Biaya Pendaftaran**: Menambahkan item visual **"Biaya Pendaftaran"** dengan modal sheet elegan untuk membolehkan admin memperbarui biaya pendaftaran langsung dari HP ke database.
- **Rata-rata Waktu Layanan**: Pilihan rata-rata waktu layanan disinkronkan langsung untuk memperbarui durasi slot pemeriksaan di server.

---

## 21. Standarisasi UI/UX & Penyempurnaan Alur Dialog (Flutter)

### 📱 Flutter — `AppDialogs` + Custom Widgets

#### 21.1 Dialog Konfirmasi Terstandarisasi
- Mengubah elemen tombol bawaan (`TextButton`) pada dialog informasi, sukses, dan konfirmasi menjadi tombol bergaya premium (`ElevatedButton` & `OutlinedButton`) dengan lebar penuh (*full-width*) atau tata letak baris yang responsif.
- Memberikan pewarnaan khusus berbasis aksi: `isDestructive` akan menggunakan warna error/merah (`AppTheme.errorColor`) untuk tombol tindakan destruktif (seperti pembatalan antrean atau penghapusan data), sementara tindakan standar menggunakan `AppTheme.primaryColor`.

#### 21.2 Konfirmasi Pembatalan Bersyarat (Conditional Cancel Confirmation)
- Menerapkan alur konfirmasi dua arah yang aman sebelum mengeksekusi fungsi pembatalan atau penghapusan guna mencegah salah klik oleh pengguna.
- Sinkronisasi teks konfirmasi yang disederhanakan dan konsisten di seluruh aplikasi (misal: "Batal" untuk pembatalan dialog dan "Batalkan"/"Hapus" untuk tombol aksi eksekusi).

#### 21.3 Standarisasi Navigasi & Pelindung State Form
- Menyempurnakan perilaku tombol kembali (*back navigation buttons & handlers*) di berbagai form penting (seperti formulir tambah dokter, cuti, jadwal praktik, rekam medis, dan inventaris obat).
- Mengintegrasikan dialog konfirmasi keluar (*discard changes prompt*) jika pengguna mencoba kembali saat form telah terisi sebagian guna menghindari hilangnya input data secara tidak sengaja.

---


## 📊 Ringkasan Logika Bisnis per Entitas

| Entitas | Logika Bisnis Kunci |
|---------|---------------------|
| **Autentikasi** | OTP reset password, session restore offline, FCM token update |
| **Antrean** | 5 lapis validasi booking, state machine status, priority queue, estimasi waktu adaptif, auto-cancel |
| **Dokter** | Guard antrean aktif saat edit/hapus, notifikasi admin saat offline |
| **Jadwal** | Overlap prevention, guard antrean aktif, sisa kuota real-time |
| **Cuti Dokter** | Auto-cancel antrean pasien + FCM notification |
| **Hari Libur** | Auto-cancel semua antrean puskesmas + FCM notification |
| **Poliklinik** | Guard antrean dan jadwal aktif saat hapus/ubah kode |
| **Rekam Medis** | Linked ke queue `examining`, auto-complete queue, duplikasi dicegah |
| **Pasien** | IDOR protection di semua level |
| **Notifikasi** | 4 trigger FCM: giliran, cancel-cuti, cancel-libur, dokter offline |
| **Dashboard** | Statistik real-time per poliklinik, N+1 safe |
| **Pembayaran** | Otomatisasi generate tagihan, upload bukti transfer, verifikasi admin, pencatatan tunai, soft delete |
| **Apotek** | Peran apoteker, antrean resep terkonfirmasi lunas, penyerahan obat, auto-reduction stok obat, CRUD inventaris obat & harga |
| **Pengaturan Dinamis** | Pasangan key-value database, konfigurasi REST API admin, penentu dinamis biaya pendaftaran & durasi slot estimasi waktu antrean di Flutter |
| **Standarisasi UI/UX** | Penggunaan tombol premium full-width, alur konfirmasi pembatalan bersyarat, serta pelindung state form saat navigasi kembali |

---

*Dokumen ini mencakup **seluruh** logika bisnis dari kedua project NalaSeva.*  
*Diharsipkan & Diperbarui: 1 Juni 2026*
