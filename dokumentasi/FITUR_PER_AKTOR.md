# 👥 Daftar Fitur NalaSeva Berdasarkan Aktor (Role-Based Feature Specification)

> Dokumen ini memetakan **seluruh fitur** aplikasi **NalaSeva** (Laravel REST API + Flutter Mobile App) secara sangat rinci berdasarkan 4 role pengguna.  
> Sistem = Manajemen Antrean & Rekam Medis Puskesmas Digital dengan RBAC ketat.

---

## 🗂️ Daftar Isi

1. [👤 Pasien (Patient)](#-aktor-1-pasien-patient)
2. [🩺 Dokter (Doctor)](#-aktor-2-dokter-doctor)
3. [💊 Apoteker (Pharmacist)](#-aktor-3-apoteker-pharmacist)
4. [👑 Admin (Administrator)](#-aktor-4-admin-administrator)

---

## 👤 Aktor 1: Pasien (Patient)

Pasien adalah pengguna akhir yang mendaftar sendiri, melakukan booking antrean secara mandiri (maks. H-7), memantau status kunjungan secara real-time, melihat rekam medis pribadi, dan melakukan pembayaran digital. Semua akses pasien terlindungi oleh proteksi IDOR (pasien hanya bisa melihat dan mengubah data miliknya sendiri).

---

### 🔐 F1 — Autentikasi & Manajemen Akun

#### F1.1 Registrasi Mandiri
- Pasien mengisi form pendaftaran dengan **10 kolom**: `Nama Lengkap`, `Email`, `Password`, `Konfirmasi Password`, `NIK` (National Identity Number — 16 digit), `Nomor Telepon`, `Jenis Kelamin` (Laki-laki / Perempuan), `Tanggal Lahir`, `Alamat`.
- Sisi Flutter: kelas `Validators` memvalidasi format email dan memastikan seluruh field terisi sebelum request dikirim ke server.
- Payload yang dikirim ke `POST auth/register` secara otomatis menyertakan `password_confirmation` (bernilai sama dengan `password`) dan `role: 'patient'` yang diinjeksi oleh kode Flutter, bukan dari input pengguna.
- Backend (Laravel): NIK dan Email divalidasi unik di database. Jika lolos, backend menjalankan **DB Transaction** untuk membuat baris baru di tabel `users` (`role = 'patient'`) dan baris baru di tabel `patients` yang berelasi ke `user_id`.
- Setelah registrasi berhasil, pengguna **tidak** langsung masuk ke dashboard — diarahkan ke halaman Login.

#### F1.2 Login & Sinkronisasi Token FCM
- Memasukkan Email dan Password pada `login_screen.dart`.
- Request ke `POST auth/login`. Jika kredensial salah → error `401` ditangkap `ErrorParser` dan ditampilkan di UI.
- Jika login sukses, backend mengembalikan `access_token` (Laravel Sanctum Bearer Token) yang disimpan terenkripsi ke `FlutterSecureStorage` (`key: 'access_token'`).
- Langsung setelah itu, aplikasi memanggil `GET auth/profile` untuk mengambil data profil lengkap beserta relasi `patient` dan `doctor`.
- ID yang relevan (`patient_id`) dan `user_role` disimpan ke `FlutterSecureStorage` untuk kebutuhan offline.
- Inisialisasi Firebase Messaging (dikunci di belakang kondisi `!kIsWeb` agar tidak crash di browser) dan mendaftarkan FCM Token perangkat ke server via `POST auth/fcm-token`.
- Navigasi otomatis menuju `/patient/home`.

#### F1.3 Pemulihan Sesi (Session Restore / Offline Mode)
- Setiap kali aplikasi dibuka, `checkAuth()` di `AuthProvider` dipanggil sebelum widget pertama dirender.
- Membaca `access_token` dari `FlutterSecureStorage`.
- **Jika token ada → coba `GET auth/profile`:**
  - ✅ Sukses: sinkronisasi ulang `user_role`, `patient_id`, `doctor_id` ke storage → navigasi ke dashboard.
  - ❌ Error 401/403 (token kedaluwarsa/tidak valid): hapus **4 key** (`access_token`, `user_role`, `patient_id`, `doctor_id`) → paksa ke layar Login.
  - 📡 Error jaringan/server down (offline): tangkap error secara *silent*, baca `user_role` dan `patient_id` yang sudah tersimpan di storage, buat **Sentinel UserModel Offline** (`id: 0`, `name: 'Offline User'`, `email: ''`) → app tetap navigasi ke dashboard offline agar pasien tetap bisa melihat data yang di-cache.
- **Jika tidak ada token:** `_user = null` → tampilkan layar Login.

#### F1.4 Lupa Password (OTP 6-Digit Flow)
- **Langkah 1 — Request OTP:** Mengisi Email dan NIK terdaftar di `forgot_password_screen.dart`. Request ke `POST auth/forgot-password/otp`. Backend memverifikasi kecocokan Email + NIK. Jika cocok, generate OTP 6-digit acak, hapus OTP lama untuk email ini, simpan ke tabel `password_reset_otps` dengan masa kedaluwarsa **15 menit**. *(Pada mode non-production, kode OTP dikembalikan langsung di JSON response untuk kemudahan pengujian.)*
- **Langkah 2 — Reset Password:** Mengisi OTP, password baru. Request ke `POST auth/forgot-password`. Backend memvalidasi OTP (benar dan belum expired), memvalidasi ulang NIK + email. Jika valid, hash password baru disimpan. Backend menghapus **seluruh** token Sanctum aktif user tersebut (*force logout semua perangkat/sesi*).

#### F1.5 Logout
- Request ke `POST auth/logout`.
- Blok `finally` di Flutter: hapus 4 key dari storage (`access_token`, `user_role`, `patient_id`, `doctor_id`), set `_user = null`, panggil `notifyListeners()` → UI otomatis kembali ke layar Login.
- ⚠️ Catatan: logout API hanya menghapus token **saat ini**, bukan semua token aktif.

#### F1.6 Lihat Profil & Edit Profil
- Melihat data profil diri sendiri: nama, email, telepon, alamat, jenis kelamin, tanggal lahir, NIK.
- Memperbarui profil via `POST auth/update-profile` (menggunakan POST bukan PUT karena Flutter mengirim multipart form-data yang lebih kompatibel).
- Field yang bisa diubah: `name`, `email`, `phone`, `address`, `gender`, `birth_date`.
- **Aturan NIK:** NIK hanya bisa diisi/diubah **jika sebelumnya masih kosong**. Setelah NIK tersimpan, tidak dapat diubah lagi untuk mencegah pemalsuan identitas.
- Setelah update: Flutter otomatis refetch `GET auth/profile` dan sinkronisasi ulang `patient_id` di storage.

#### F1.7 Auto Logout (Session Timeout — Pasien Only)
- Widget `SessionTimeoutListener` membungkus seluruh `MaterialApp` secara global, namun pengecekan inaktivitas hanya aktif untuk pengguna dengan **role pasien**.
- Jika pengguna dengan role pasien tidak berinteraksi dengan layar selama **15 menit** (tidak ada `onPointerDown` maupun `onPointerSignal`), sistem secara otomatis:
  1. Memanggil `authProvider.logout()` → hapus token dari `FlutterSecureStorage`, panggil API logout.
  2. Redirect paksa ke halaman Login via `AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil('/')` (global navigasi tanpa `BuildContext`).
  3. Menampilkan `SnackBar` floating berwarna kuning/warning: **"Sesi Telah Berakhir — Sesi Anda telah berakhir karena tidak ada aktivitas."**
- Timer reset otomatis setiap kali pengguna menyentuh layar.
- Berbeda dengan Auto-Logout pada **F1.2** (error interceptor 401) — fitur ini berbasis **inaktivitas waktu**, bukan respons server.

---

### 🗓️ F2 — Booking & Manajemen Antrean

#### F2.1 Melihat Daftar Antrean Aktif
- Dashboard pasien (`patient_dashboard.dart`) menampilkan antrean aktif milik pasien hari ini.
- Data antrean, rekam medis, dan poliklinik di-load secara **paralel** (`Future.wait`) saat pertama membuka dashboard untuk meminimalisir waktu loading.

#### F2.2 Booking Antrean Online (Mandiri)
- **Alur Step-by-Step:**
  1. Pilih **Poliklinik** → sistem memuat daftar poliklinik via `GET polyclinics` dan daftar dokter via `GET doctors`.
  2. Pilih **Dokter** → sistem memicu **2 request paralel** (`Future.wait`):
     - `GET clinic-holidays`: mengambil daftar tanggal hari libur puskesmas.
     - `GET doctor-leaves?doctor_id={id}`: mengambil daftar tanggal cuti dokter tersebut.
  3. Tanggal-tanggal libur dan cuti otomatis di-*disable* pada kalender date picker — pasien tidak dapat memilihnya.
  4. Pilih **Tanggal Kunjungan** (dibatasi maksimal H-7 dari sekarang hingga hari ini; tidak bisa memilih tanggal lampau).
  5. Pilih **Jadwal Dokter** (`doctor_schedule_id`) sesuai hari yang dipilih. Jadwal di-fetch via `GET doctor-schedules?polyclinic_id={id}` — langsung divalidasi real-time tanpa disimpan ke state provider.
  6. Dialog konfirmasi visual ditampilkan (`AppDialogs.showConfirmationDialog`).
  7. Jika dikonfirmasi, data dikirim ke `POST queues` (dilindungi **throttle: maks. 5 request per menit** per user untuk mencegah spam booking).

- **5-Layer Validasi Backend (berurutan):**
  1. **Hari Libur Klinik:** Tanggal pelayanan tidak boleh bertepatan dengan hari libur puskesmas.
  2. **Cuti Dokter:** Dokter yang dipilih tidak boleh sedang cuti pada tanggal tersebut.
  3. **Konsistensi Jadwal:** `doctor_schedule_id` yang dikirim harus benar-benar milik `doctor_id` dan `polyclinic_id` yang dipilih, dan hari praktik harus sesuai.
  4. **Duplikat Antrean:** Pasien hanya boleh memiliki **1 antrean aktif per poliklinik per hari** yang sama.
  5. **Konflik Waktu Antar Poliklinik:** Cek semua antrean aktif pasien di hari yang sama — tidak boleh ada jadwal yang jam layanannya tumpang tindih (*overlap*) dengan jadwal yang sudah ada.
  - *Tambahan:* Kuota harian dihitung otomatis: `durasi_praktik_menit / slot_duration_minutes`. Jika penuh → ditolak. Jika mendaftar untuk hari ini, hanya bisa mendaftar **sebelum jam mulai praktik**.

- **Anti-IDOR Check:** Backend memastikan `patient_id` yang dikirim adalah milik user yang sedang login — pasien tidak bisa mendaftarkan orang lain.

#### F2.3 Nomor Antrean & Klasifikasi Prioritas Otomatis
- Backend menentukan nomor urut terakhir di poliklinik + tanggal yang sama menggunakan `withTrashed()` (agar nomor tidak bentrok setelah ada pembatalan sebelumnya), lalu membentuk format `{KODE_POLI}-{NomorUrut}` (contoh: `UMM-001`, `GIG-002`).
- **Prioritas Lansia Otomatis:** Backend menghitung usia pasien dari `birth_date`. Jika usia **≥ 60 tahun** → antrean ditandai `is_priority = true` secara otomatis. Tidak bisa dimanipulasi manual.
- Setelah antrean terbuat, backend menghitung estimasi waktu layanan dan memicu **re-kalkulasi ulang** estimasi seluruh antrean aktif (`booked` + `waiting`) di poliklinik dan tanggal yang sama.

#### F2.4 Tiket Antrean Digital & QR Code
- Melihat detail tiket di `booking_detail_screen.dart`:
  - Nomor antrean, nama poliklinik, nama dokter, tanggal kunjungan.
  - Estimasi jam pelayanan (`HH:mm`).
  - Status antrean saat ini (`booked`, `waiting`, `examining`).
  - **QR Code unik** yang di-generate oleh library `qr_flutter` dengan payload `NALASEVA_QUEUE_{id}` — digunakan admin untuk scan check-in.
  - Posisi antrean di depan (jumlah orang yang masih menunggu di depan).

#### F2.5 Estimasi Waktu Tunggu Real-Time
- Estimasi waktu dihitung oleh backend (model `Queue.php`):
  - **Posisi Antrean:** Untuk pasien prioritas: hanya menunggu sesama prioritas yang check-in lebih awal + pasien yang sedang diperiksa. Untuk pasien reguler: menunggu semua prioritas + reguler yang check-in lebih awal.
  - **Waktu Rata-rata per Pasien (Adaptive):** Diambil dari **3 rekam medis terakhir** yang selesai hari ini di poliklinik yang sama. Dihitung selisih `called_time` → `created_at` rekam medis. Dibatasi antara 1-120 menit/pasien. Jika belum ada data historis hari ini → default dari `slot_duration_minutes` (System Settings).
  - **Estimasi Layanan:** `base_time` (waktu sekarang atau jam mulai praktik, mana yang lebih lambat) + `posisi × slot_duration_minutes`.

#### F2.6 Pembatalan Antrean Mandiri
- Request `DELETE queues/{id}`.
- **Aturan yang divalidasi backend sebelum mengizinkan pembatalan:**
  - Antrean milik pasien sendiri (anti-IDOR).
  - Status harus `booked` atau `waiting` (tidak bisa batalkan yang sudah `examining` atau `completed`).
  - **Aturan Cut-Off Pembatalan:**
    - Jika antrean **dibuat ≤ 15 menit yang lalu** → bebas dibatalkan kapan saja selama waktu layanan belum mulai.
    - Jika antrean **dibuat > 15 menit yang lalu** → hanya bisa dibatalkan jika waktu sekarang masih **> 2 jam sebelum** `estimated_service_time`. Lewat dari itu → ditolak.

---

### 🏥 F3 — Riwayat Rekam Medis

#### F3.1 Daftar Riwayat Pemeriksaan
- Melihat semua rekam medis pemeriksaan milik pasien sendiri (IDOR-protected: pasien tidak bisa melihat rekam medis orang lain).
- **Filter Pencarian per Bulan:** Mencari rekam medis berdasarkan rentang bulan tertentu di `patient_history_screen.dart`.

#### F3.2 Detail Rekam Medis
- Melihat rincian hasil pemeriksaan di `medical_record_detail_screen.dart`:
  - Tanggal pemeriksaan.
  - Nama Dokter pemeriksa.
  - Keluhan utama yang dicatat dokter.
  - Hasil Diagnosa klinis.
  - Tindakan medis yang dilakukan.
  - **Daftar Resep Obat Terstruktur:** nama obat, kuantiti yang diresepkan, dan instruksi pemakaian.

---

### 💳 F4 — Tagihan & Pembayaran

#### F4.1 Melihat Daftar Tagihan
- Melihat semua tagihan pembayaran miliknya di `payment_list_screen.dart` (IDOR-protected: tidak bisa melihat tagihan pasien lain).
- Status tagihan yang bisa dilihat: `pending`, `waiting_verification`, `paid`, `failed`.

#### F4.2 Detail Tagihan & Rincian Biaya
- Melihat rincian di `payment_detail_screen.dart`:
  - Nomor invoice unik (format: `NS-PAY-YYYYMMDD-XXXXXX`).
  - **Biaya Registrasi:** nilai `registration_fee` dari System Settings (default Rp 10.000 — dapat diubah admin).
  - **Biaya Obat:** total `quantity × harga obat yang dikunci saat resep dibuat`.
  - Total tagihan (biaya registrasi + biaya obat).

#### F4.3 Upload Bukti Transfer / QRIS
- Mengambil foto bukti transfer dari galeri atau kamera menggunakan library `image_picker`.
- Mengirim gambar ke `POST payments/{id}/upload-proof` (dilindungi **throttle: maks. 5 request per menit** untuk mencegah spam upload).
- Setelah upload berhasil, status tagihan otomatis berubah menjadi `waiting_verification`.
- Bukti tersimpan di direktori server `payment_proofs/`.

---

### 🔔 F5 — Notifikasi & Profil Puskesmas

#### F5.1 Kotak Masuk Notifikasi FCM
- Melihat riwayat notifikasi push yang diterima di `notification_screen.dart`.
- Jenis notifikasi yang diterima pasien dari sistem:
  | Trigger | Pesan yang Diterima |
  |---|---|
  | Status antrean → `examining` | "Giliran Anda! Nomor: {queue_number} — Silakan masuk ruang periksa." |
  | Rekam medis selesai dibuat | "Tagihan Baru Diterbitkan. Harap lakukan pembayaran sebesar Rp{total}." |
  | Admin setujui bukti transfer | "Pembayaran Terverifikasi Lunas! Silakan mengambil obat di apotek." |
  | Admin tolak bukti transfer | "Verifikasi Pembayaran Gagal. Bukti transfer tidak valid, harap unggah ulang." |
  | Admin cash-pay | "Pembayaran Lunas (Tunai)! Silakan menuju apotek." |
  | Apoteker serahkan obat | "Obat Selesai Diserahkan. Terima kasih atas kunjungan Anda!" |
  | Dokter cuti → antrean dibatalkan | "Antrean {queue_number} dibatalkan karena dokter cuti: {alasan}." |
  | Klinik libur → antrean dibatalkan | "Antrean {queue_number} dibatalkan karena puskesmas libur: {deskripsi}." |

- Notifikasi muncul di tray HP bahkan saat aplikasi di background/foreground (menggunakan `flutter_local_notifications` untuk foreground).

#### F5.2 Melihat Profil Puskesmas
- Melihat informasi puskesmas (nama, alamat, nomor kontak, koordinat lokasi) yang ditampilkan di dashboard pasien.
- Data di-fetch dari `GET puskesmas-profile` setelah login berhasil atau saat sesi dipulihkan.

#### F5.3 Indikator Koneksi Internet (Connectivity Banner)
- Banner merah melayang muncul di bagian atas layar secara global jika aplikasi mendeteksi tidak ada koneksi internet aktif.
- Mendengarkan `Connectivity().onConnectivityChanged` secara real-time — aktif di level root `MaterialApp.builder`.

---

## 🩺 Aktor 2: Dokter (Doctor)

Dokter berinteraksi dengan aplikasi untuk mengelola antrean di ruang periksa, mengontrol status kehadiran online/offline, dan melakukan pencatatan rekam medis beserta resep obat pasien.

---

### 🔐 F1 — Autentikasi & Status Kehadiran

#### F1.1 Login Dokter
- Masuk menggunakan email dan password khusus dokter yang sebelumnya didaftarkan oleh admin (dokter tidak bisa mendaftar sendiri).
- `access_token` dan `doctor_id` disimpan ke `FlutterSecureStorage`.
- Navigasi otomatis menuju `/doctor/home`.

#### F1.2 Sinkronisasi Status Online dari Profil
- Saat `checkAuth()` dipanggil dan profil berhasil diambil, `DoctorProvider.setOnlineStatus(bool)` langsung menginisialisasi state `_isOnline` dari field `is_online` di response profil **tanpa** hit API tambahan.

#### F1.3 Toggle Status Online / Offline
- Mengubah status kehadiran melalui switch di `doctor_dashboard.dart`.
- Request `PATCH doctors/me/status` dengan field `is_online = true/false`.
- **Efek saat set Offline:** Backend otomatis mengirim **notifikasi FCM ke semua akun Admin** yang memiliki FCM token terdaftar dengan pesan bahwa dokter sedang beristirahat/tidak tersedia.
- State `_isOnline` di `DoctorProvider` diperbarui secara lokal setelah response sukses (tidak perlu refetch).

#### F1.4 Lihat & Edit Profil Dokter
- Melihat data profil diri: nama, email, telepon, spesialisasi, nomor SIP (Surat Izin Praktik), poliklinik.
- Mengedit data profil personal melalui `doctor_edit_profile_screen.dart` (menggunakan endpoint yang sama `POST auth/update-profile`).

#### F1.5 Logout
- Request ke `POST auth/logout`. Blok `finally` membersihkan storage dan menavigasi ke Login.

---

### 📋 F2 — Pemantauan & Pemrosesan Antrean

#### F2.1 Daftar Antrean Harian
- Melihat semua antrean pasien yang ditugaskan untuk dirinya pada hari ini di `doctor_dashboard.dart`.
- Data di-fetch via `GET queues` (backend memfilter berdasarkan `doctor_id` dari token).
- Menampilkan status setiap antrean: `booked`, `waiting`, `examining`, `completed`.

#### F2.2 Transisi Status Antrean
- Dokter mengubah status antrean melalui `PUT queues/{id}` sesuai aturan *state machine*:
  ```
  waiting → examining  (memulai pemeriksaan)
  examining → completed (selesai — tapi biasanya via finishExamination)
  ```
- **Validasi Ketat saat Mengubah ke `examining`:**
  - Dokter harus berstatus online (`is_online = true`). Jika offline → request ditolak.
  - Tidak boleh ada pasien lain yang masih berstatus `examining` di dokter dan poliklinik yang sama pada saat itu.
  - Saat berhasil: backend mencatat `called_time = now()` dan mengirimkan **FCM "Giliran Anda!"** ke HP pasien.
- **Batasan dokter:** Dokter **dilarang** mengubah status ke `cancelled` — hanya admin yang bisa.

#### F2.3 Skip Antrean (Geser ke Belakang)
- Dokter dapat memindahkan antrean pasien ke posisi belakang antrean dari sisi dokter.
- Request `POST queues/{id}/skip`. Backend: reset `check_in_time = now()`, `recall_count = 0`.

#### F2.4 Riwayat Pemeriksaan Pasien (Patient History Lookup)
- Melihat riwayat pemeriksaan pasien tertentu sebelum memulai pemeriksaan baru — berguna untuk konteks medis.
- `fetchHistoryForPatient(patientUserId)` → `GET examinations?patient_user_id={id}` → disimpan ke state `_patientHistory`.
- Terbatas pada rekam medis dari poliklinik dokter yang bersangkutan.

---

### 📝 F3 — Rekam Medis & Resep

#### F3.1 Formulir Pemeriksaan (Examination Form)
- Mengisi form di `examination_form_screen.dart` dengan:
  - **Keluhan Utama** pasien (text bebas).
  - **Hasil Diagnosa** klinis (text bebas).
  - **Tindakan Medis / Treatment** (text bebas).
  - **Resep Obat Terstruktur:** memilih obat dari inventaris aktif puskesmas via `GET medicines`, mengisi jumlah (*quantity*), dan instruksi pemakaian (contoh: *"3x1 tablet setelah makan"*).

#### F3.2 Pelindung Form (Form Guard)
- Jika dokter menekan tombol *back* saat form sudah terisi sebagian, sistem memunculkan **dialog konfirmasi peringatan** (`showConfirmationDialog`) agar data tidak hilang tanpa sengaja.

#### F3.3 Simpan Rekam Medis & Pembuatan Tagihan Otomatis
- Request ke `POST examinations`.
- Backend menjalankan **DB Transaction** yang atomik:
  1. Simpan rekam medis ke tabel `examinations`. `doctor_id` dikunci dari token login, bukan dari input request (anti-spoofing).
  2. Simpan tiap item resep ke tabel `prescription_items`. **Harga obat dikunci pada saat ini** dari tabel `medicines` → harga tidak akan berubah di tagihan pasien walau admin mengubah harga obat di masa depan.
  3. Status antrean diubah otomatis menjadi `completed`.
  4. Invoice tagihan baru dibuat di tabel `payments` (status: `pending`), dengan nomor unik format `NS-PAY-YYYYMMDD-XXXXXX`. Formula: `registration_fee + Σ(quantity × harga_terkunci)`.
  5. Kirim **FCM ke Pasien:** *"Tagihan Baru Diterbitkan. Silakan lakukan pembayaran sebesar Rp{total}."*
- Setelah sukses: `DoctorProvider.finishExamination()` menyegarkan state `_queues` dan `_medicalRecords` sekaligus.

#### F3.4 Statistik Dashboard Dokter
- Melihat statistik harian di dashboard: jumlah antrean aktif, antrean selesai.
- Data statistik di-fetch dari `GET dashboard-stats` (endpoint yang sama dengan Admin, namun data difilter di backend berdasarkan poliklinik dokter).

---

## 💊 Aktor 3: Apoteker (Pharmacist)

Apoteker memproses penyerahan obat resep yang telah dibayar lunas, mengelola inventaris stok dan harga obat puskesmas, serta memastikan ketersediaan obat terjaga.

---

### 🔐 F1 — Autentikasi

#### F1.1 Login Apoteker
- Login menggunakan kredensial yang dibuat oleh admin dengan `role = 'pharmacist'`.
- Navigasi otomatis menuju `/pharmacy/home`.
- `access_token` dan `user_role` tersimpan di `FlutterSecureStorage`.

---

### 💊 F2 — Antrean Resep & Penyerahan Obat

#### F2.1 Memantau Antrean Resep Siap Layani
- Membuka `pharmacy_dashboard_screen.dart` yang menampilkan daftar antrean resep yang:
  - Status pembayaran = `paid` (sudah lunas).
  - `dispensed_at IS NULL` (obat belum diserahkan).
- Data di-fetch dari `GET pharmacy/queues`.

#### F2.2 Detail Resep Pasien
- Membuka `prescription_detail_screen.dart` untuk melihat rincian tiap resep:
  - Nama pasien.
  - Nomor invoice dan total tagihan.
  - Daftar obat: nama obat, jumlah yang diresepkan, instruksi pemakaian, harga per satuan (saat resep dibuat).

#### F2.3 Serahkan Obat ke Pasien (Dispense) — DB Transaction
- Apoteker menyiapkan obat fisik, lalu menekan tombol **"Serahkan Obat"**.
- Request ke `POST pharmacy/queues/{id}/dispense`.
- Backend menjalankan **DB Transaction** dengan keamanan berlapis:
  1. **Loop seluruh item resep** untuk divalidasi satu per satu.
  2. **Validasi Stok Kritis:** Cek stok aktual tiap obat di tabel `medicines`. Jika **satu saja** obat stoknya kurang dari kuantiti resep → **Rollback seluruh transaksi** → return error `422 Unprocessable Entity` → Apoteker menerima dialog warning dengan nama obat yang stoknya tidak cukup.
  3. Jika semua stok aman → kurangi kolom `stock` di tabel `medicines` sesuai kuantiti masing-masing resep.
  4. Isi `dispensed_at = now()` di tabel `payments`.
  5. Kirim **FCM ke Pasien:** *"Obat Selesai Diserahkan. Terima kasih atas kunjungan Anda!"*
- Sisi Flutter: setelah sukses, `PharmacyProvider.dispense()` langsung menghapus item dari state list lokal `_queues` tanpa refetch penuh (*optimistic update*).

---

### 🗄️ F3 — Manajemen Inventaris Obat

#### F3.1 Daftar Inventaris Obat
- Melihat semua obat aktif di `medicine_inventory_screen.dart`, termasuk stok terkini dan harga satuan.
- Data dari `GET medicines` (endpoint ini bisa diakses semua role yang sudah login, termasuk dokter untuk memilih obat saat menulis resep).

#### F3.2 Tambah Obat Baru
- Request `POST medicines` dengan data: nama obat, deskripsi, satuan (tablet/botol/ampul/dll), harga satuan, dan stok awal.
- Sisi Flutter: setelah sukses, item baru langsung di-*append* ke state list lokal `_medicines` tanpa refetch.
- ⚠️ Harga obat yang disimpan inilah yang akan digunakan untuk **mengunci biaya resep** pasien pada saat dokter membuat rekam medis.

#### F3.3 Edit Data Obat
- Request `PUT medicines/{id}`: update nama, deskripsi, harga, satuan.
- Sisi Flutter: update data di state list lokal by index.
- Perubahan harga hanya berlaku untuk resep **yang dibuat setelah** perubahan ini; resep lama tidak terpengaruh karena harga sudah dikunci saat transaksi.

#### F3.4 Hapus Obat (Soft Delete)
- Request `DELETE medicines/{id}` → soft delete (data tidak benar-benar terhapus dari database).
- Tujuan soft delete: riwayat resep lama yang merujuk obat ini tetap valid dan tidak rusak relasinya.
- Sisi Flutter: item dihapus dari state list lokal `_medicines` via `removeWhere`.

#### F3.5 Restore Obat (dari Arsip)
- Memulihkan obat yang sebelumnya dihapus (soft delete) kembali ke inventaris aktif.
- Request `POST medicines/{id}/restore`.
- Sisi Flutter: item yang di-restore di-*append* kembali ke state list `_medicines`.

---

## 👑 Aktor 4: Admin (Administrator)

Admin memiliki hak akses tertinggi dan terlengkap. Admin mengelola keseluruhan data master, memproses pelayanan loket (check-in, recall, skip, pembayaran), memverifikasi bukti pembayaran digital, mengonfigurasi sistem puskesmas, dan memantau TV Monitor antrean real-time.

---

### 🔐 F1 — Autentikasi Admin

#### F1.1 Login Admin
- Login menggunakan kredensial admin (`role = 'admin'`).
- Navigasi ke `/admin/home`.

#### F1.2 Error Interceptor (401 Auto-Logout)
- `ApiClient` (Dio) memiliki error interceptor: jika server mengembalikan **HTTP 401 Unauthorized**, sistem otomatis menghapus semua key storage dan meredirect ke layar Login menggunakan `AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil('/')` (navigasi global tanpa `BuildContext`).

---

### 📋 F2 — Manajemen Antrean di Loket

#### F2.1 Booking Antrean Manual (Walk-In Patient)
- Mendaftarkan antrean untuk pasien yang datang langsung ke puskesmas tanpa aplikasi.
- Memilih data pasien, poliklinik, dokter, jadwal, dan tanggal.
- Request ke `POST queues` (validasi backend yang sama dengan booking mandiri pasien, termasuk 5-layer validation dan kuota).

#### F2.2 Check-In Manual (Loket)
- Admin mencari antrean pasien di list `queue_management_screen.dart`.
- Mengisi alasan kunjungan (`reason`) opsional.
- **Validasi Waktu Check-In (ServiceTimeValidator — sisi Flutter sebelum hit API):**
  - Antrean harus pada tanggal hari ini.
  - Waktu saat ini harus dalam rentang: **30 menit sebelum** hingga **2 jam setelah** `estimated_service_time`.
  - Jika terlalu awal → dialog: *"Absensi hanya diizinkan maksimal 30 menit sebelum jam pelayanan."*
  - Jika terlalu telat → dialog: *"Sudah melewati batas 2 jam setelah jam pelayanan."*
- Request `POST queues/{id}/checkin`. Backend mengubah status → `waiting`, mencatat `check_in_time = now()`.
- Setelah check-in: backend memicu recalculate estimasi seluruh antrean di poliklinik + tanggal yang sama.

#### F2.3 Check-In via QR Code Scanner
- Admin membuka `qr_scanner_page.dart` (library `mobile_scanner`), mengarahkan kamera ke QR Code tiket pasien.
- **Format QR yang Didukung:**
  1. `NALASEVA_QUEUE_{id}` → cocokkan dengan `queue.id`.
  2. Nomor antrean (contoh: `UMM-001`) → cocokkan dengan `queue.queueNumber` yang aktif hari ini.
- Setelah QR terbaca, validasi jendela waktu (`ServiceTimeValidator`) tetap dijalankan sebelum hit API.
- Jika valid → langsung trigger check-in instan.

#### F2.4 Recall / Panggil Ulang Antrean
- Memanggil ulang pasien via `POST queues/{id}/recall`.
- **Aturan Recall:**
  - Jika `recall_count < 3` → backend increment `recall_count + 1`.
  - Jika `recall_count >= 3` → backend **menggeser antrean ke posisi paling belakang**: status kembali ke `waiting`, `check_in_time = now()`, `recall_count = 0`. Validasi: waktu layanan dokter belum habis.
- Sisi Flutter: `AdminProvider.recallQueue()` mengupdate item antrean **di list lokal secara langsung** (`_queues[index] = updatedQueue`) tanpa refetch penuh — optimasi rendering UI.
- Bersamaan dengan recall, layar TV Monitor merespons dengan output suara TTS (Text-to-Speech).

#### F2.5 Skip Antrean (Geser ke Paling Belakang)
- Admin memindahkan antrean pasien secara paksa ke posisi belakang antrean.
- Validasi: status harus `waiting` dan sudah check-in.
- Request `POST queues/{id}/skip`. Backend: reset `check_in_time = now()`, `recall_count = 0`.
- Sisi Flutter: refresh list antrean setelah sukses.

#### F2.6 Batalkan / Hapus Antrean
- Admin dapat membatalkan atau menghapus antrean pasien mana pun tanpa batasan waktu operasional.
- Request `DELETE queues/{id}`.

#### F2.7 Update Status Antrean (Manual Override)
- Admin dapat mengubah status antrean (`booked` → `waiting`, `waiting` → `examining`, dll.) langsung dari panel antrean.
- Request `PUT queues/{id}` dengan field `status`.
- Admin dibebaskan dari validasi jendela waktu layanan (hak akses override).

---

### 💰 F3 — Verifikasi Pembayaran & Kasir Loket

#### F3.1 Melihat Semua Tagihan Pasien
- Admin bisa melihat semua tagihan dari semua pasien (tidak terbatas) via `GET payments`.
- Daftar di `payment_list_screen.dart` menampilkan status: `pending`, `waiting_verification`, `paid`, `failed`.

#### F3.2 Verifikasi Bukti Transfer (Manual Review)
- Admin membuka detail tagihan di `payment_detail_screen.dart`, melihat foto bukti transfer yang diunggah pasien.
- **Jika SETUJU:** Request `POST payments/{id}/verify` dengan `status = 'approved'`. Backend: status → `paid`, catat `paid_at = now()`. Kirim **FCM ke Pasien:** *"Pembayaran Terverifikasi Lunas!"*
- **Jika TOLAK:** Request `POST payments/{id}/verify` dengan `status = 'rejected'`. Backend: status → `failed`. Pasien diminta upload ulang bukti.

#### F3.3 Pembayaran Tunai di Loket (Cash Pay)
- Menerima uang tunai dari pasien di loket kasir fisik.
- Request `POST payments/{id}/cash-pay`. Backend: status → `paid`, metode = `cash`, catat `paid_at = now()` secara instan.
- Kirim **FCM ke Pasien:** *"Pembayaran Lunas (Tunai)! Silakan menuju apotek."*

---

### 👨‍⚕️ F4 — Manajemen Data Master Dokter

#### F4.1 Tambah Dokter
- Request `POST doctors` dengan data: nama, email, password, nomor telepon, spesialisasi, nomor SIP, poliklinik.
- Backend menjalankan **DB Transaction**: buat akun `users` (`role = 'doctor'`) + buat record profil di tabel `doctors`.

#### F4.2 Edit Data Dokter
- Request `PUT doctors/{id}`.
- **Proteksi Mutasi Poliklinik:** Jika `polyclinic_id` diubah, backend mengecek apakah dokter masih punya antrean aktif (`booked`, `waiting`, `examining`) di poliklinik lama. Jika ada → **ditolak**.
- Update dilakukan secara terpisah ke tabel `users` (data personal) dan tabel `doctors` (data profesi).

#### F4.3 Hapus Dokter (Soft Delete)
- Backend mengecek antrean aktif dokter. Jika ada → ditolak.
- Jika aman → DB Transaction: soft-delete tabel `doctors` dan `users` sekaligus.

---

### 📅 F5 — Manajemen Jadwal Praktik Dokter

#### F5.1 Tambah Jadwal Praktik
- Request `POST doctor-schedules` dengan: `doctor_id`, `polyclinic_id`, `day_of_week` (hari), `start_time`, `end_time`.
- **Deteksi Overlap:** Backend menolak jika ada jadwal lain dokter yang sama pada hari yang sama dengan jam yang bertabrakan. Kondisi overlap: `start_baru < end_lama && start_lama < end_baru`.

#### F5.2 Edit Jadwal Praktik
- Request `PUT doctor-schedules/{id}`.
- **Proteksi Perubahan:** Jika `day_of_week`, `start_time`, atau `end_time` berubah → backend cek antrean aktif yang menggunakan jadwal ini. Jika ada → **ditolak**.
- Validasi overlap tetap dilakukan (kecuali dengan jadwal itu sendiri).

#### F5.3 Hapus Jadwal
- Backend cek antrean aktif yang menggunakan jadwal ini. Jika ada → ditolak.
- Jika aman → hapus jadwal.

#### F5.4 Lihat Jadwal dengan Sisa Kuota
- `GET doctor-schedules` (admin) atau `GET doctor-schedules?polyclinic_id={id}` (pasien saat booking) mengembalikan `remaining_daily_quota` untuk setiap jadwal.
- Kuota = `durasi_menit / slot_duration_minutes` dikurangi jumlah booking aktif pada tanggal tersebut.

---

### 🏥 F6 — Manajemen Cuti Dokter

#### F6.1 Tambah Cuti Dokter — Auto-Cancel Antrean
- Request `POST doctor-leaves` dengan: `doctor_id`, `leave_date`, `reason`.
- Backend menjalankan **DB Transaction:**
  1. Simpan data cuti ke tabel `doctor_leaves`.
  2. Cari semua antrean aktif (`booked`, `waiting`) dokter tersebut pada `leave_date`.
  3. Batalkan semua antrean yang ditemukan (`status = 'cancelled'`).
  4. Kirim **FCM ke setiap pasien** yang antreannya dibatalkan: *"Antrean {queue_number} dibatalkan karena dokter cuti: {reason}."*
  5. Recalculate estimasi antrean yang tersisa di poliklinik + tanggal tersebut.

#### F6.2 Lihat & Hapus Cuti
- Admin melihat semua data cuti (termasuk yang sudah lewat) via `GET doctor-leaves`.
- Bisa filter per `doctor_id` via `GET doctor-leaves?doctor_id={id}`.
- Menghapus data cuti yang sudah tidak relevan via `DELETE doctor-leaves/{id}`.

---

### 📅 F7 — Manajemen Hari Libur Puskesmas

#### F7.1 Tambah Hari Libur — Mass Cancel Otomatis
- Request `POST clinic-holidays` dengan: `holiday_date`, `description`.
- Backend menjalankan **DB Transaction:**
  1. Simpan hari libur ke tabel `clinic_holidays`.
  2. Cari **semua** antrean aktif (`booked`, `waiting`) dari **seluruh poliklinik** pada `holiday_date`.
  3. Batalkan semua antrean yang ditemukan secara massal.
  4. Kirim **FCM ke semua pasien terdampak:** *"Antrean {queue_number} dibatalkan karena puskesmas libur: {description}."*
  5. Recalculate estimasi per poliklinik.

#### F7.2 Lihat & Hapus Hari Libur
- Admin melihat semua hari libur (termasuk yang sudah lewat) via `GET clinic-holidays`.
- Non-admin (pasien, dokter) hanya melihat hari libur yang belum lewat (`holiday_date >= hari ini`).
- Hapus hari libur via `DELETE clinic-holidays/{id}`.

---

### 🏛️ F8 — Manajemen Poliklinik

#### F8.1 Tambah Poliklinik
- Request `POST polyclinics` dengan: nama poliklinik, `code` unik (awalan nomor antrean, misal: `UMM`), deskripsi layanan.

#### F8.2 Edit Poliklinik
- Request `PUT polyclinics/{id}`.
- **Proteksi Kode:** Jika `code` diubah → backend cek antrean aktif hari ini. Jika ada → ditolak (karena kode sudah menjadi prefix di nomor antrean yang beredar).

#### F8.3 Hapus Poliklinik
- Backend cek: ada antrean aktif? Ada jadwal dokter terdaftar? Jika ada salah satu → ditolak.
- Jika aman → soft-delete poliklinik via `DELETE polyclinics/{id}`.

---

### 👥 F9 — Manajemen User & Pasien

#### F9.1 CRUD User
- Membuat, melihat, mengedit, dan menonaktifkan akun pengguna dengan role apa pun (`admin`, `doctor`, `patient`, `pharmacist`).
- Request ke `GET users`, `POST users`, `PUT users/{id}`, `DELETE users/{id}`.

#### F9.2 CRUD Pasien
- Tambah pasien secara manual (untuk pasien tanpa smartphone): DB Transaction buat `users` + `patients` via `POST patients`.
- Edit data demografis pasien (nama, alamat, dll) via `PUT users/{id}`. Update dilakukan ke tabel `users`.
- Hapus (soft delete) pasien via `DELETE users/{id}`.
- Melihat seluruh daftar pasien via `GET patients`.

---

### 📋 F10 — Riwayat Rekam Medis (Monitoring)

#### F10.1 Lihat Semua Riwayat Pemeriksaan
- Admin melihat rekam medis seluruh pasien dari semua poliklinik di `examination_history_screen.dart`.
- `GET examinations` (admin mendapatkan seluruh data tanpa filter poliklinik).
- Bisa filter berdasarkan `patient_user_id` untuk mencari riwayat pasien spesifik.

---

### 📊 F11 — Dashboard Statistik & TV Monitor

#### F11.1 Dashboard Statistik Harian
- `GET dashboard-stats` mengembalikan statistik real-time hari ini:
  - Total pasien dan dokter terdaftar.
  - Jumlah antrean aktif (status: `booked`, `waiting`, `examining`).
  - Jumlah antrean selesai (`completed`) hari ini.
  - Jumlah antrean dibatalkan (`cancelled`) hari ini.
  - **Statistik per poliklinik:** jumlah antrean aktif dan menunggu — dihitung dengan **1 query agregat** untuk mencegah N+1 query problem.
- Divisualisasikan di `admin_dashboard.dart` sebagai kartu statistik + grafik analitik mingguan (`fl_chart`).

#### F11.2 TV Monitor Antrean Publik (Ruang Tunggu)
- Rute `/tv-monitor` → `queue_monitor_screen.dart`, dirancang untuk ditampilkan di layar TV/tablet di ruang tunggu puskesmas.
- **Responsif:** Menggunakan `ResponsiveHelper` — layout berbeda untuk Mobile, Tablet, dan TV/Desktop (threshold: Mobile < 600px, Tablet 600-1024px, TV > 1024px).
- **Text-to-Speech (TTS) Panggilan Suara:** Ketika status antrean berubah menjadi `examining`, TV Monitor menggunakan `TtsHelper.speak(text)` untuk membacakan nomor antrean secara lisan dalam Bahasa Indonesia.
  - Platform **mobile/native** (Android/iOS) → library `flutter_tts`.
  - Platform **web browser** → browser API `SpeechSynthesis`.
  - Platform lain → stub/fallback kosong.
  - Conditional import berbasis `dart.library.html` vs `dart.library.io` untuk *zero compile error* di semua platform.

---

### ⚙️ F12 — Pengaturan Dinamis Puskesmas (System Settings)

#### F12.1 Konfigurasi Parameter Operasional
- Melihat dan mengubah pengaturan puskesmas di `admin_settings_screen.dart` via `GET settings` dan `PUT settings`.
- **Biaya Pendaftaran (`registration_fee`):** Nilai default Rp 10.000. Nilai ini digunakan backend saat membuat invoice tagihan pasien otomatis (`ExaminationController`).
- **Durasi Slot Pelayanan (`slot_duration_minutes`):** Nilai default 15 menit. Digunakan oleh: (1) kalkulasi kuota harian booking; (2) kalkulasi estimasi waktu tunggu antrean; (3) fallback waktu tunggu jika belum ada historis pemeriksaan hari ini.
- Perubahan langsung berlaku untuk semua kalkulasi selanjutnya tanpa perlu restart server.

#### F12.2 Update Profil Puskesmas & Koordinat Lokasi
- Memperbarui nama, alamat, nomor kontak puskesmas via `PUT puskesmas-profile`.
- **Map Picker (OpenStreetMap):** Menekan tombol pilih lokasi membuka `MapPickerScreen` yang menampilkan peta interaktif berbasis `flutter_map` + `latlong2`. Admin dapat menggeser marker untuk menentukan koordinat persis lokasi puskesmas. Koordinat dikembalikan sebagai objek `LatLng` dan diunggah ke backend. Default koordinat (jika belum pernah diset): Jember (`-8.165143, 113.716255`).

---

### 🔒 F13 — Kontrol Akses Route-Level (RBAC Guard)

#### F13.1 Peta Izin Route Flutter
- `AppRouter._routePermissions` memetakan setiap route ke daftar role yang diizinkan.
- Di `onGenerateRoute`: jika route memerlukan autentikasi dan `user == null` atau `user.role` tidak ada dalam daftar → **redirect ke halaman Login**.
- Navigasi menggunakan `GlobalKey<NavigatorState>` yang bisa dipanggil dari mana saja (termasuk dari error interceptor Dio tanpa `BuildContext`).

---

### 🎛️ F14 — Hak Akses Apotek (Shared Role: Admin = Apoteker)

- Admin memiliki **semua akses yang sama** dengan Apoteker:
  - Melihat antrean resep obat siap serah (`GET pharmacy/queues`).
  - Serahkan obat ke pasien (`POST pharmacy/queues/{id}/dispense`).
  - CRUD inventaris obat (`POST`, `PUT`, `DELETE medicines`).
  - Restore obat yang di-soft-delete (`POST medicines/{id}/restore`).

---

## 📎 Referensi Cepat: Endpoint API per Aktor

> **Catatan Base URL:** Base URL = `https://nalaseva-api.up.railway.app/api/`  
> Semua path di bawah adalah **relatif** terhadap base URL tersebut — **tanpa** prefix `/api/` tambahan.  
> Contoh: `auth/login` → URL lengkap = `https://nalaseva-api.up.railway.app/api/auth/login`

### 🔐 Autentikasi (Semua Aktor)

| Fitur | Method | Endpoint | Aktor |
|---|---|---|---|
| Registrasi | `POST` | `auth/register` | Pasien |
| Login | `POST` | `auth/login` | Semua |
| Lupa Password — Request OTP | `POST` | `auth/forgot-password/otp` | Semua |
| Lupa Password — Reset | `POST` | `auth/forgot-password` | Semua |
| Lihat Profil | `GET` | `auth/profile` | Semua |
| Update Profil | `POST` | `auth/update-profile` | Semua |
| Update FCM Token | `POST` | `auth/fcm-token` | Semua |
| Logout | `POST` | `auth/logout` | Semua |

### 🗓️ Antrean

| Fitur | Method | Endpoint | Aktor |
|---|---|---|---|
| Lihat Antrean | `GET` | `queues` | Pasien, Dokter, Admin |
| Booking Antrean | `POST` | `queues` *(throttle 5/menit)* | Pasien, Admin |
| Batalkan / Hapus Antrean | `DELETE` | `queues/{id}` | Pasien, Admin |
| Update Status Antrean | `PUT` | `queues/{id}` | Dokter, Admin |
| Check-In Loket | `POST` | `queues/{id}/checkin` | Admin |
| Recall Antrean | `POST` | `queues/{id}/recall` | Admin |
| Skip Antrean | `POST` | `queues/{id}/skip` | Dokter, Admin |

### 📝 Rekam Medis

| Fitur | Method | Endpoint | Aktor |
|---|---|---|---|
| Lihat Rekam Medis | `GET` | `examinations` | Pasien, Dokter, Admin |
| Lihat Rekam Medis per Pasien | `GET` | `examinations?patient_user_id={id}` | Dokter, Admin |
| Buat Rekam Medis | `POST` | `examinations` | Dokter |

### 💳 Pembayaran

| Fitur | Method | Endpoint | Aktor |
|---|---|---|---|
| Lihat Tagihan | `GET` | `payments` | Pasien, Admin |
| Upload Bukti Transfer | `POST` | `payments/{id}/upload-proof` *(throttle 5/menit)* | Pasien |
| Verifikasi Transfer | `POST` | `payments/{id}/verify` | Admin |
| Pembayaran Tunai | `POST` | `payments/{id}/cash-pay` | Admin |

### 💊 Apotek & Inventaris Obat

| Fitur | Method | Endpoint | Aktor |
|---|---|---|---|
| Lihat Antrean Resep Apotek | `GET` | `pharmacy/queues` | Admin, Apoteker |
| Serahkan Obat (Dispense) | `POST` | `pharmacy/queues/{id}/dispense` | Admin, Apoteker |
| Lihat Inventaris Obat | `GET` | `medicines` | Dokter, Admin, Apoteker |
| Tambah Obat | `POST` | `medicines` | Admin, Apoteker |
| Edit Obat | `PUT` | `medicines/{id}` | Admin, Apoteker |
| Hapus Obat | `DELETE` | `medicines/{id}` | Admin, Apoteker |
| Restore Obat | `POST` | `medicines/{id}/restore` | Admin, Apoteker |

### 🩺 Dokter & Jadwal

| Fitur | Method | Endpoint | Aktor |
|---|---|---|---|
| Toggle Status Online Dokter | `PATCH` | `doctors/me/status` | Dokter |
| Lihat Daftar Dokter | `GET` | `doctors` | Pasien, Admin |
| Tambah Dokter | `POST` | `doctors` | Admin |
| Edit Dokter | `PUT` | `doctors/{id}` | Admin |
| Hapus Dokter | `DELETE` | `doctors/{id}` | Admin |
| Lihat Jadwal Dokter | `GET` | `doctor-schedules` | Admin |
| Lihat Jadwal per Poliklinik | `GET` | `doctor-schedules?polyclinic_id={id}` | Pasien |
| Tambah Jadwal | `POST` | `doctor-schedules` | Admin |
| Edit Jadwal | `PUT` | `doctor-schedules/{id}` | Admin |
| Hapus Jadwal | `DELETE` | `doctor-schedules/{id}` | Admin |

### 🏥 Cuti, Libur & Poliklinik

| Fitur | Method | Endpoint | Aktor |
|---|---|---|---|
| Lihat Cuti Dokter | `GET` | `doctor-leaves` / `doctor-leaves?doctor_id={id}` | Pasien, Admin |
| Tambah Cuti Dokter | `POST` | `doctor-leaves` | Admin |
| Hapus Cuti Dokter | `DELETE` | `doctor-leaves/{id}` | Admin |
| Lihat Hari Libur | `GET` | `clinic-holidays` | Pasien, Admin |
| Tambah Hari Libur | `POST` | `clinic-holidays` | Admin |
| Hapus Hari Libur | `DELETE` | `clinic-holidays/{id}` | Admin |
| Lihat Poliklinik | `GET` | `polyclinics` | Pasien, Admin |
| Tambah Poliklinik | `POST` | `polyclinics` | Admin |
| Edit Poliklinik | `PUT` | `polyclinics/{id}` | Admin |
| Hapus Poliklinik | `DELETE` | `polyclinics/{id}` | Admin |

### 👥 User & Pasien

| Fitur | Method | Endpoint | Aktor |
|---|---|---|---|
| Lihat Semua User | `GET` | `users` | Admin |
| Tambah User | `POST` | `users` | Admin |
| Edit User | `PUT` | `users/{id}` | Admin |
| Hapus User | `DELETE` | `users/{id}` | Admin |
| Lihat Semua Pasien | `GET` | `patients` | Admin |
| Tambah Pasien Manual | `POST` | `patients` | Admin |

### 📊 Statistik & Pengaturan

| Fitur | Method | Endpoint | Aktor |
|---|---|---|---|
| Dashboard Statistik | `GET` | `dashboard-stats` | Admin, Dokter |
| Pengaturan Sistem | `GET` | `settings` | Admin |
| Update Pengaturan | `PUT` | `settings` | Admin |
| Lihat Profil Puskesmas | `GET` | `puskesmas-profile` | Semua |
| Update Profil Puskesmas | `PUT` | `puskesmas-profile` | Admin |

---

*Dokumen ini merupakan spesifikasi fitur resmi per role sistem NalaSeva.*  
*Diperbarui: 8 Juni 2026 — Sinkronisasi penuh dengan kode aktual Flutter (`ApiClient` base URL dikonfirmasi = `.../api/`). Perbaikan konsistensi: semua path endpoint seragam tanpa prefix `/api/` (karena base URL sudah mengandungnya). Endpoint tambahan dari kode aktual ditambahkan: `GET doctors` & `GET polyclinics` (digunakan pasien saat booking), `GET doctor-schedules?polyclinic_id` (pasien), `GET clinic-holidays` & `GET doctor-leaves?doctor_id` (pasien saat booking), `POST queues/{id}/skip` oleh Dokter, `GET medicines` oleh Dokter. Tabel referensi cepat dipecah per kategori. Skip antrean oleh Dokter ditambahkan sebagai F2.3 baru.*
