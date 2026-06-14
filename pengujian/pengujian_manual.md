# 🧪 Dokumen Pengujian Manual Lengkap (Manual Testing Specifications)
## Aplikasi Puskesmas Digital NalaSeva (Flutter Mobile + Laravel API)

Dokumen ini berisi daftar skenario pengujian manual secara lengkap, sangat detail, dan akurat untuk memvalidasi fungsi aplikasi **NalaSeva** (Flutter Mobile Client `nalaseva 3` dan Laravel REST API `nalaseva api`). Pengujian mencakup 4 aktor utama: **Pasien (Patient)**, **Dokter (Doctor)**, **Apoteker (Pharmacist)**, dan **Admin (Administrator)**.

---

## 🗂️ Daftar Isi
1. [ℹ️ Informasi Lingkungan Pengujian](#-informasi-lingkungan-pengujian)
2. [👤 Skenario Aktor 1: Pasien (Patient)](#-skenario-aktor-1-pasien-patient)
3. [🩺 Skenario Aktor 2: Dokter (Doctor)](#-skenario-aktor-2-dokter-doctor)
4. [💊 Skenario Aktor 3: Apoteker (Pharmacist)](#-skenario-aktor-3-apoteker-pharmacist)
5. [👑 Skenario Aktor 4: Admin (Administrator)](#-skenario-aktor-4-admin-administrator)
6. [🛡️ Pengujian Keamanan & RBAC (Role-Based Access Control)](#%EF%B8%8F-pengujian-keamanan--rbac-role-based-access-control)
7. [📡 Pengujian Jaringan & Offline Mode](#-pengujian-jaringan--offline-mode)

---

## ℹ️ Informasi Lingkungan Pengujian
- **Base URL API**: `https://nalaseva-api.up.railway.app/api/`
- **Sistem Autentikasi**: Laravel Sanctum Bearer Token (Disimpan di `FlutterSecureStorage` dengan `key: 'access_token'`).
- **Penyimpanan Lokal**:
  - `access_token` (Bearer token)
  - `user_role` (`patient`, `doctor`, `pharmacist`, `admin`)
  - `patient_id` (Khusus pasien)
  - `doctor_id` (Khusus dokter)
- **Firebase Messaging (FCM)**: Push Notification dengan silent-synchronization payload.

---

## 👤 Skenario Aktor 1: Pasien (Patient)

Pasien dapat mendaftar mandiri, login, memesan antrean, melakukan pembayaran nontunai, melihat rekam medis, dan menerima notifikasi real-time.

### Tabel Kasus Uji Pasien

| ID Kasus Uji | Skenario Pengujian | Langkah-Langkah (Steps) | Data Uji (Test Data) | Hasil yang Diharapkan (Expected Results) | Kriteria Sukses (Validasi & DB) |
|---|---|---|---|---|---|
| **TC-PAS-001** | Registrasi Mandiri (Sukses) | 1. Buka Halaman Registrasi.<br>2. Isi seluruh field dengan data valid.<br>3. Tekan tombol daftar. | - NIK: 16 Digit unik (contoh: `3201020304050607`) <br>- Email: belum terdaftar (contoh: `pasien@test.com`) <br>- Nama Lengkap: `Budi Santoso` <br>- Password: `password123` | - Form tervalidasi sukses.<br>- Response `POST auth/register` sukses.<br>- Diarahkan ke halaman login. | - DB Transaction menyimpan user (`role = 'patient'`) dan data `patients` terkait.<br>- `password_confirmation` diinjeksi otomatis oleh Flutter. |
| **TC-PAS-002** | Registrasi Mandiri (Gagal — Duplikat NIK & Email) | 1. Isi form registrasi dengan NIK atau Email yang sudah ada di sistem.<br>2. Tekan tombol daftar. | - NIK atau Email yang sudah terdaftar di database. | - Validasi API gagal.<br>- Error message "NIK/Email sudah terdaftar" muncul di UI. | - Server mengembalikan error validation (status `422`).<br>- Database di-rollback (tidak ada user baru). |
| **TC-PAS-003** | Login Pasien & Sinkronisasi FCM | 1. Masukkan email & password.<br>2. Tekan Login. | - Email: `pasien@test.com` <br>- Password: `password123` | - Login sukses.<br>- `access_token`, `user_role`, `patient_id` tersimpan di secure storage.<br>- Pendaftaran FCM Token dipanggil via `POST auth/fcm-token`.<br>- Navigasi ke `/patient/home`. | - Request token Sanctum berhasil.<br>- FCM token terdaftar di tabel `users`. |
| **TC-PAS-004** | Pemulihan Sandi (OTP Request & Reset) | 1. Tekan "Lupa Password".<br>2. Masukkan NIK & Email cocok.<br>3. Masukkan OTP (mode non-production: OTP ada di JSON response) & password baru.<br>4. Reset. | - Email: `pasien@test.com`<br>- NIK: `3201020304050607` | - OTP 6-digit dikirim.<br>- Reset sukses, force logout seluruh sesi aktif.<br>- Diarahkan ke Login. | - Record OTP di `password_reset_otps` kedaluwarsa dalam 15 menit.<br>- Seluruh token Sanctum user dihapus dari database. |
| **TC-PAS-005** | Auto-Logout Akibat Inaktivitas | 1. Login sebagai Pasien.<br>2. Diamkan aplikasi tanpa interaksi layar selama 15 menit. | - Status: Inaktif 15 menit. | - Sesi otomatis berakhir.<br>- Diredirect paksa ke halaman Login.<br>- SnackBar kuning floating muncul: *"Sesi Telah Berakhir — Sesi Anda telah berakhir karena tidak ada aktivitas."* | - Token dihapus dari secure storage.<br>- `authProvider.logout()` terpanggil di background. |
| **TC-PAS-005b** | Auto-Logout Saat Keluar/Menutup Aplikasi | 1. Login sebagai Pasien.<br>2. Tutup/keluar aplikasi tanpa menekan tombol logout.<br>3. Buka kembali aplikasi. | - Status: Keluar/Tutup Aplikasi (terminasi proses). | - Aplikasi terbuka dari awal.<br>- Tidak memulihkan sesi, melainkan langsung diarahkan ke halaman Login.<br>- Token server dicabut secara silent. | - Token dan kredensial lokal dihapus dari secure storage saat startup (`checkAuth()`) jika role terdeteksi 'patient'. |
| **TC-PAS-006** | Edit Profil Pasien | 1. Buka Edit Profil.<br>2. Ubah data personal.<br>3. Tekan Simpan. | - Data baru kecuali NIK (NIK read-only). | - Update berhasil via `POST auth/update-profile`.<br>- Profil terupdate di UI. | - NIK diproteksi read-only untuk menghindari manipulasi identitas. |
| **TC-PAS-007** | Booking Antrean (Validasi Tagihan Tertunggak) | 1. Buat booking antrean baru.<br>Prasyarat: Pasien memiliki tagihan pending berusia > 24 jam. | - Poliklinik: Umum<br>- Tanggal: Besok | - Proses pendaftaran dihentikan seketika di client.<br>- Pesan error muncul: *"Harap lunasi tagihan Anda sebelumnya untuk dapat membuat antrean baru."* | - Client memvalidasi status tagihan pembayaran secara offline/lokal sebelum hit API booking. |
| **TC-PAS-008** | Booking Antrean (Cuti & Hari Libur Terblokir) | 1. Buka kalender date picker untuk booking.<br>2. Coba pilih tanggal di mana dokter bersangkutan cuti atau puskesmas libur. | - Tanggal cuti dokter / libur klinik. | - Tanggal tersebut ter-disable (berwarna abu-abu) pada kalender.<br>- Pengguna tidak dapat memilih tanggal tersebut. | - Panggilan paralel `Future.wait([getClinicHolidays(), getDoctorLeaves(doctorId)])` sukses mem-blacklist tanggal. |
| **TC-PAS-009** | Booking Antrean (Sukses & Prioritas Lansia Otomatis) | 1. Isi form booking (Poli, Dokter, Tanggal valid, Jadwal).<br>2. Konfirmasi pendaftaran. | - Usia Pasien >= 60 tahun (dihitung dari `birth_date`). | - Booking sukses.<br>- Tiket antrean diterbitkan dengan flag `is_priority = true`. | - Backend otomatis menetapkan prioritas berdasarkan usia (usia >= 60 tahun).<br>- Format nomor antrean `{KODE_POLI}-{NomorUrut}` terbuat (contoh: `UMM-001`). |
| **TC-PAS-010** | Pembatalan Antrean Mandiri (Aturan Cut-off) | 1. Coba batalkan antrean yang dibuat > 15 menit lalu dan jam layanan kurang dari 2 jam lagi. | - Antrean aktif (status `booked`/`waiting`). | - Pembatalan ditolak oleh server.<br>- Muncul pesan error pembatalan tidak diizinkan. | - Backend memvalidasi aturan cut-off: Boleh jika dibuat <= 15 menit lalu, ATAU jika > 15 menit lalu tapi waktu sekarang masih > 2 jam sebelum `estimated_service_time`. |
| **TC-PAS-011** | Pembayaran & Validasi Bukti Unggah | 1. Buka tagihan pending.<br>2. Unggah bukti transfer (format salah / ukuran > 2MB). | - Format: `.gif` atau ukuran: `3MB`. | - Klien menolak file.<br>- Tampil pesan error format (.jpg/.jpeg/.png) dan batas ukuran maksimal 2MB. | - Client-side validation memblokir file sebelum dikirim ke API `POST payments/{id}/upload-proof`. |
| **TC-PAS-012** | Pembayaran Kadaluwarsa (Limit 2 Jam) | 1. Biarkan tagihan berstatus `pending` selama >= 2 jam sejak diterbitkan. | - Status tagihan pending >= 2 jam. | - Status tagihan dinamis berubah menjadi **Resep Kadaluwarsa/Tidak Ditebus**.<br>- Warna indikator merah.<br>- Tombol pembayaran tidak aktif. | - Client mendeteksi `created_at` tagihan secara berkala. |

---

## 🩺 Skenario Aktor 2: Dokter (Doctor)

Dokter mengelola status kehadiran, memantau antrean polikliniknya, melakukan pemeriksaan, menuliskan resep obat, dan mengakses riwayat medis pasien.

### Tabel Kasus Uji Dokter

| ID Kasus Uji | Skenario Pengujian | Langkah-Langkah (Steps) | Data Uji (Test Data) | Hasil yang Diharapkan (Expected Results) | Kriteria Sukses (Validasi & DB) |
|---|---|---|---|---|---|
| **TC-DOC-001** | Login Dokter & Inisialisasi Status | 1. Login menggunakan kredensial dokter.<br>2. Masuk ke dashboard. | - Email/Password dokter terdaftar. | - Login sukses.<br>- State `is_online` terinisialisasi langsung dari field profil `is_online`. | - Token Sanctum dan `doctor_id` tersimpan di secure storage. |
| **TC-DOC-002** | Toggle Kehadiran Offline | 1. Ubah switch online menjadi offline di dashboard dokter. | - Aksi: Menggeser toggle offline. | - Status berganti offline di database.<br>- Notifikasi FCM terkirim secara otomatis ke semua admin terdaftar. | - API `PATCH doctors/me/status` mengirim `is_online = false`. |
| **TC-DOC-003** | Mulai Pemeriksaan (waiting -> examining) | 1. Pilih pasien berstatus `waiting` pada antrean.<br>2. Tekan tombol panggil/periksa. | - Status awal antrean: `waiting`. | - Status berubah menjadi `examining`.<br>- Jam panggilan tercatat (`called_time = now()`).<br>- Pasien menerima Notifikasi FCM: *"Giliran Anda! Silakan masuk ruang periksa."* | - Validasi backend: Dokter wajib online (`is_online = true`) dan tidak boleh ada pasien lain berstatus `examining` di poliklinik dan dokter yang sama. |
| **TC-DOC-004** | Patient History Lookup | 1. Saat memeriksa pasien, buka riwayat rekam medis pasien tersebut. | - ID Pasien yang sedang diperiksa. | - Menampilkan riwayat rekam medis masa lalu pasien tersebut.<br>- Terbatas pada poliklinik tempat dokter bertugas. | - Request API `GET examinations?patient_user_id={id}` berhasil difilter di backend. |
| **TC-DOC-005** | Formulir Pemeriksaan & Form Guard | 1. Isi formulir pemeriksaan setengah jalan.<br>2. Coba tekan tombol kembali (back) tanpa menyimpan. | - Input: Diagnosa/Keluhan terisi sebagian. | - Pop-up dialog peringatan konfirmasi muncul: *"Apakah Anda yakin ingin membatalkan? Data yang belum disimpan akan hilang."* | - Dialog guard mencegah kehilangan data pemeriksaan tidak sengaja. |
| **TC-DOC-006** | Menyelesaikan Pemeriksaan & Auto Invoice | 1. Isi rekam medis lengkap (Keluhan, Diagnosa, Tindakan, Resep Obat).<br>2. Simpan pemeriksaan. | - Resep: Obat A (qty 2) & B (qty 1). | - Rekam medis tersimpan.<br>- Status antrean berganti `completed`.<br>- Invoice tagihan otomatis dibuat.<br>- Pasien menerima notifikasi tagihan baru. | - Backend menjalankan **DB Transaction**: simpan rekam medis, **kunci harga obat saat ini** di resep, ubah status antrean, terbitkan payment record (nominal = `registration_fee` + biaya obat terkunci), kirim FCM. |

---

## 💊 Skenario Aktor 3: Apoteker (Pharmacist)

Apoteker memantau antrean resep yang telah lunas, mendengarkan TTS antrean apotek, memproses penyerahan obat fisik, dan mengelola stok obat di inventaris.

### Tabel Kasus Uji Apoteker

| ID Kasus Uji | Skenario Pengujian | Langkah-Langkah (Steps) | Data Uji (Test Data) | Hasil yang Diharapkan (Expected Results) | Kriteria Sukses (Validasi & DB) |
|---|---|---|---|---|---|
| **TC-PHA-001** | Daftar Antrean Resep | 1. Buka dashboard apoteker. | - Status: Login sebagai Apoteker. | - Menampilkan daftar resep yang berstatus Pembayaran `paid` (Lunas) dan obatnya belum diserahkan (`dispensed_at IS NULL`). | - API `GET pharmacy/queues` mengambil data yang tepat. |
| **TC-PHA-002** | Fitur Panggilan Loket Apotek (TTS & FCM) | 1. Buka detail resep.<br>2. Tekan tombol ikon volume panggilan loket. | - Tombol volume panggilan di resep. | - Suara pembacaan TTS lisan terdengar secara lokal: *"Panggilan resep atas nama {nama_pasien}..."*<br>- Pasien menerima Notifikasi FCM: *"Panggilan Apotek - Panggilan kepada pasien..., silakan mengambil obat Anda di loket Apotek."* | - Library `TtsHelper.speak` terpanggil dalam Bahasa Indonesia.<br>- API `POST pharmacy/queues/{id}/call` berhasil memicu notifikasi FCM payload `type: 'prescription_called'`. |
| **TC-PHA-003** | Penyerahan Obat (Dispense — Sukses) | 1. Tekan tombol **"Serahkan Obat"**.<br>Prasyarat: Stok obat di inventaris mencukupi. | - Resep: Paracetamol (qty: 3).<br>- Stok di DB: Paracetamol (stok: 100). | - Obat sukses diserahkan.<br>- Pasien menerima notifikasi FCM penyerahan selesai.<br>- Item langsung hilang dari list lokal secara optimistik. | - DB Transaction berhasil.<br>- Stok Paracetamol berkurang menjadi 97.<br>- Kolom `dispensed_at` terisi `now()`. |
| **TC-PHA-004** | Penyerahan Obat (Gagal — Stok Kritis / Habis) | 1. Tekan tombol **"Serahkan Obat"**.<br>Prasyarat: Salah satu obat di resep kekurangan stok. | - Resep: Amoxicillin (qty: 10).<br>- Stok di DB: Amoxicillin (stok: 2). | - Transaksi dibatalkan secara penuh.<br>- UI menampilkan warning dialog: *"Stok obat Amoxicillin tidak mencukupi."* | - Backend mengembalikan error `422 Unprocessable Entity`.<br>- **DB Transaction Rollback**: Tidak ada pemotongan stok obat apa pun di resep tersebut. |
| **TC-PHA-005** | CRUD Inventaris Obat | 1. Tambah/Edit/Hapus (Soft-Delete) obat di inventaris. | - Data obat: nama, deskripsi, harga, stok. | - Tambah & Edit sukses memperbarui list lokal.<br>- Hapus memindahkan obat ke status non-aktif (soft delete). | - Soft delete (`deleted_at` terisi) menjaga integritas riwayat transaksi resep lama yang merujuk obat ini. |

---

## 👑 Skenario Aktor 4: Admin (Administrator)

Admin memiliki kontrol penuh untuk memproses check-in, recall, walk-in, pembayaran loket, master data, jadwal dokter, hari libur, dan memantau TV Monitor antrean.

### Tabel Kasus Uji Admin

| ID Kasus Uji | Skenario Pengujian | Langkah-Langkah (Steps) | Data Uji (Test Data) | Hasil yang Diharapkan (Expected Results) | Kriteria Sukses (Validasi & DB) |
|---|---|---|---|---|---|
| **TC-ADM-001** | Booking Walk-In Patient | 1. Daftarkan antrean untuk pasien yang datang langsung ke klinik tanpa aplikasi. | - Cari Pasien, pilih Poli, Dokter, Jadwal. | - Booking walk-in berhasil dibuat.<br>- Tiket antrean dicetak/diterbitkan. | - Menggunakan validasi backend 5-layer yang sama dengan pendaftaran pasien mandiri. |
| **TC-ADM-002** | Check-in Manual (Validasi Jendela Waktu) | 1. Cari antrean pasien.<br>2. Coba lakukan check-in diluar jendela waktu layanan. | - Waktu sekarang: 1 jam sebelum estimasi layanan.<br>- Jendela: maksimal -30 menit. | - Tombol check-in ter-disable atau sistem menampilkan warning: *"Absensi hanya diizinkan maksimal 30 menit sebelum jam pelayanan."* | - Klien memvalidasi waktu check-in menggunakan `ServiceTimeValidator` sebelum mengirim API `POST queues/{id}/checkin`. |
| **TC-ADM-003** | Check-in Manual (Bypass Jendela Waktu - Override) | 1. Lakukan check-in diluar jendela waktu menggunakan akun Admin. | - Antrean milik pasien terpilih hari ini. | - Check-in sukses dilakukan bypass oleh sistem. | - Hak akses Admin bebas dari validasi jendela waktu pelayanan di server. |
| **TC-ADM-004** | Check-in via QR Scanner | 1. Buka fitur Scanner kamera.<br>2. Pindai QR Code tiket pasien. | - QR Payload: `NALASEVA_QUEUE_{id}`. | - Scanner mendeteksi data QR dengan cepat.<br>- Status antrean berubah menjadi `waiting` (jika berada dalam jendela waktu). | - Library `mobile_scanner` membaca payload dengan benar dan memicu API check-in. |
| **TC-ADM-005** | Recall & Mekanisme Geser ke Belakang | 1. Tekan tombol panggil ulang (recall) pasien pada loket pendaftaran.<br>2. Ulangi hingga panggilan ke-4. | - Pasien terdaftar status `examining` tetapi tidak hadir secara fisik. | - Panggilan 1 s.d 3 menaikkan count recall.<br>- Panggilan ke-4 otomatis memindahkan antrean pasien ke posisi paling belakang. | - Panggilan ke-4 memicu backend mengubah status kembali ke `waiting`, menyetel `recall_count = 0`, dan mengupdate `check_in_time = now()`. |
| **TC-ADM-006** | TV Monitor Antrean Publik | 1. Buka rute `/tv-monitor`.<br>2. Lakukan perubahan status antrean pasien di loket menjadi `examining`. | - Transaksi status antrean. | - Layar TV Monitor merespons perubahan status secara real-time.<br>- Suara TTS lisan berbunyi otomatis membacakan nomor antrean dalam Bahasa Indonesia. | - Halaman `queue_monitor_screen.dart` responsif di browser TV/desktop.<br>- TTS menggunakan Web SpeechSynthesis API di browser. |
| **TC-ADM-007** | Verifikasi Bukti Pembayaran Digital | 1. Buka daftar pembayaran.<br>2. Pilih tagihan status `waiting_verification`.<br>3. Tinjau gambar bukti transfer, pilih Setuju atau Tolak. | - Aksi: Approve atau Reject. | - Jika Setuju: Status menjadi `paid` dan kirim FCM Lunas.<br>- Jika Tolak: Status kembali menjadi `failed` dan kirim FCM Gagal untuk unggah ulang. | - Request `POST payments/{id}/verify` dengan parameter status disetujui/ditolak berhasil dieksekusi. |
| **TC-ADM-008** | Pembayaran Tunai (Cash Pay) Loket | 1. Pasien menyerahkan uang tunai di loket kasir.<br>2. Admin menekan tombol "Bayar Tunai". | - Invoice tagihan pending milik pasien. | - Status langsung berubah menjadi `paid` (Lunas).<br>- Metode pembayaran terekam sebagai `cash`.<br>- Pasien menerima notifikasi FCM lunas tunai. | - API `POST payments/{id}/cash-pay` berhasil dieksekusi instan. |
| **TC-ADM-009** | Manajemen Dokter (Mutasi Poliklinik Terproteksi) | 1. Edit data dokter.<br>2. Coba ubah `polyclinic_id` dokter tersebut.<br>Prasyarat: Dokter masih punya antrean aktif di poliklinik lama. | - Mutasi poli dokter. | - Sistem menolak perubahan poliklinik.<br>- Menampilkan pesan error kegagalan mutasi. | - Backend memvalidasi ketiadaan antrean aktif dokter di poliklinik lama sebelum mengizinkan mutasi. |
| **TC-ADM-010** | Manajemen Jadwal (Proteksi Overlap & Antrean) | 1. Coba tambah jadwal dokter yang jamnya bertabrakan dengan jadwal lainnya di hari yang sama.<br>2. Coba hapus jadwal yang masih memiliki antrean aktif terkait. | - Tabrakan jam praktik / antrean aktif. | - Sistem menolak tambah jadwal (overlap) dan menolak hapus jadwal (memiliki antrean aktif). | - Backend memvalidasi interval overlap dan relasi antrean aktif di tabel `queues`. |
| **TC-ADM-011** | Tambah Cuti Dokter (Auto-Cancel Antrean) | 1. Admin menambahkan cuti dokter pada tanggal tertentu. | - Dokter A, Tanggal Cuti: Besok. | - Record cuti tersimpan.<br>- Seluruh antrean pasien dokter A besok otomatis dibatalkan (`cancelled`).<br>- Seluruh pasien terdampak menerima notifikasi FCM pembatalan beserta alasannya. | - **DB Transaction** backend membatalkan antrean massal secara atomik dan menghitung ulang estimasi sisa antrean. |
| **TC-ADM-012** | Tambah Hari Libur Puskesmas (Mass Cancel) | 1. Admin menambahkan hari libur klinik. | - Tanggal Libur Puskesmas. | - Hari libur tersimpan di sistem.<br>- Seluruh antrean aktif semua poliklinik pada tanggal tersebut otomatis dibatalkan.<br>- Semua pasien menerima notifikasi FCM pembatalan libur klinik. | - **DB Transaction** backend memproses pembatalan massal lintas poliklinik secara instan. |
| **TC-ADM-013** | Pengaturan Parameter Sistem (Settings) | 1. Masuk Pengaturan.<br>2. Ubah `registration_fee` atau `slot_duration_minutes`. | - Ubah nominal biaya registrasi. | - Perubahan parameter tersimpan.<br>- Nominal tagihan resep pasien baru otomatis menggunakan biaya registrasi ter-update. | - Perubahan langsung memengaruhi logika runtime kalkulasi invoice pembayaran tanpa restart server. |
| **TC-ADM-014** | Map Picker Puskesmas (OpenStreetMap) | 1. Klik pilih koordinat lokasi puskesmas.<br>2. Geser penanda marker peta pada layar peta.<br>3. Konfirmasi koordinat baru. | - Peta Interaktif OSM (MapPickerScreen). | - Marker dapat digerakkan dengan lancar.<br>- Koordinat ter-update dan dikirim ke server. | - Koordinat terkirim sebagai objek `LatLng` dan disimpan ke dalam database Puskesmas Profile. |

---

## 🛡️ Pengujian Keamanan & RBAC (Role-Based Access Control)

Memastikan pengguna tidak dapat mengakses fitur di luar peran masing-masing atau memanipulasi data pengguna lain.

### Tabel Kasus Uji Keamanan

| ID Kasus Uji | Skenario Pengujian | Langkah-Langkah (Steps) | Hasil yang Diharapkan (Expected Results) | Kriteria Sukses (Validasi & DB) |
|---|---|---|---|---|
| **TC-SEC-001** | Proteksi Izin Rute Flutter (RBAC Guard) | 1. Login sebagai Pasien.<br>2. Coba navigasi manual menggunakan kode/deep link ke rute admin `/admin/home` atau `/tv-monitor`. | - Sistem menolak akses.<br>- Klien otomatis melakukan redirect kembali ke halaman utama Login. | - `AppRouter` membatasi navigasi berdasarkan `user.role` yang cocok dengan `_routePermissions`. |
| **TC-SEC-002** | Proteksi IDOR — Rekam Medis & Tagihan | 1. Login sebagai Pasien A.<br>2. Coba panggil API `GET examinations/{id_resep_pasien_B}` secara langsung. | - Server mengembalikan error HTTP 403 Forbidden atau 404 Not Found. | - Backend memvalidasi kepemilikan data user terautentikasi terhadap record `patient_id` target. |
| **TC-SEC-003** | Auto-Logout Interceptor (HTTP 401) | 1. Saat aplikasi terbuka, lakukan manipulasi/hapus token di database atau masa token berakhir.<br>2. Lakukan navigasi/request data ke server. | - Request mengembalikan HTTP 401 Unauthorized.<br>- Flutter client menangkap error secara global.<br>- Seluruh key dihapus dan pengguna diredirect seketika ke halaman Login. | - Dio `ApiClient` Interceptor berhasil menangani status code 401 secara global menggunakan `GlobalKey<NavigatorState>`. |
| **TC-SEC-004** | Proteksi API Apotek & Inventaris | 1. Login sebagai Pasien atau Dokter.<br>2. Kirim request ke `POST pharmacy/queues/{id}/dispense` atau `POST medicines` (Tambah Obat). | - Request ditolak oleh server dengan response HTTP 403 Forbidden. | - Middleware role-based access control pada Laravel Laravel membatasi hak akses penyerahan & inventaris obat khusus untuk `'pharmacist'`. |

---

## 📡 Pengujian Jaringan & Offline Mode

Menguji ketahanan aplikasi client saat mengalami gangguan koneksi internet atau server puskesmas padam.

### Tabel Kasus Uji Jaringan & Offline

| ID Kasus Uji | Skenario Pengujian | Langkah-Langkah (Steps) | Hasil yang Diharapkan (Expected Results) | Kriteria Sukses (Validasi & DB) |
|---|---|---|---|---|
| **TC-NET-001** | Banner Koneksi Internet (Connectivity Banner) | 1. Jalankan aplikasi dalam kondisi online.<br>2. Putuskan koneksi internet perangkat (aktifkan Airplane Mode atau matikan Wi-Fi/Data). | - Banner peringatan merah bertuliskan "Koneksi Terputus" melayang di bagian atas layar secara global. | - Listener `Connectivity().onConnectivityChanged` mendeteksi hilangnya koneksi secara real-time pada level root widget. |
| **TC-NET-002** | Restorasi Sesi Mode Offline (Sentinel User) | 1. Matikan internet perangkat.<br>2. Buka aplikasi yang sebelumnya sudah login.<br>3. Amati perilaku dashboard. | - Aplikasi tidak mengalami crash.<br>- Menampilkan nama profil sentinel **"Offline User"**.<br>- Pengguna tetap dapat melihat rekam medis dan antrean ter-cache lokal. | - Blok `catch` pada fungsi `checkAuth()` memuat sentinel `UserModel` dengan data offline dari secure storage. |
| **TC-NET-003** | Silent-Sync FCM pada Mode Foreground | 1. Pasien sedang membuka dashboard aplikasi.<br>2. Admin melakukan verifikasi pembayaran di loket kasir.<br>3. Amati perubahan status tagihan pasien. | - Status tagihan pembayaran pasien langsung berubah di layar secara otomatis tanpa pasien perlu menarik layar (pull-to-refresh). | - Service listener `FirebaseMessagingService` menangkap payload `'type': 'payment_updated'` dan memicu refresh provider data secara silent. |
