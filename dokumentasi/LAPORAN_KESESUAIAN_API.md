# Laporan Kesesuaian Endpoint API dengan Aplikasi Flutter NalaSeva

Laporan ini menganalisis kesesuaian antara endpoint yang dideklarasikan pada dokumen [API.md](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/dokumentasi/API.md) dengan pemanggilan API nyata di dalam kode sumber aplikasi Flutter **NalaSeva**.

---

## 📊 Ringkasan Eksekutif

Berdasarkan analisis statis kode sumber Flutter (pada direktori `lib/`), berikut adalah ringkasan kesesuaian endpoint API:

- **Total Endpoint Dokumentasi**: **85**
- **Endpoint yang Digunakan (Aktif)**: **71**
- **Endpoint yang Tidak Digunakan**: **14**
- **Endpoint Tidak Terdokumentasi**: **0** (Semua pemanggilan API dalam kode Flutter memiliki padanannya di dokumen API)

Seluruh pemanggilan API dalam aplikasi Flutter terpusat pada file [ApiClient](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/core/api/api_client.dart) dan disalurkan melalui 7 kelas repositori. Enam di antaranya berada di folder `lib/features/{feature}/data/` (auth, admin, doctor, patient, pharmacy), sedangkan `PaymentRepository` dan `PuskesmasProfileRepository` dipindahkan ke `lib/shared/repositories/` setelah refaktor arsitektur feature-first.

---

## 📌 Daftar Endpoint yang Tidak Digunakan di Aplikasi Flutter

Berikut adalah daftar **13 endpoint** yang dideklarasikan di backend/dokumentasi API, namun **tidak dipanggil atau tidak digunakan** di dalam aplikasi Flutter:

| No | Nama Endpoint | URL | Method | Keterangan / Alasan |
| :--- | :--- | :--- | :--- | :--- |
| **17** | Pulihkan Poliklinik Terhapus | `/api/polyclinics/{id}/restore` | `POST` | Fitur pemulihan data poliklinik yang di-*soft delete* belum diimplementasikan di antarmuka Admin. |
| **23** | Pulihkan Akun Dokter Terhapus | `/api/doctors/{id}/restore` | `POST` | Fitur pemulihan dokter belum dipasang pada repositori Flutter. |
| **31** | Pulihkan Jadwal Terhapus | `/api/doctor-schedules/{id}/restore` | `POST` | Pemulihan jadwal praktik dokter yang di-*soft delete* belum dipanggil dari aplikasi. |
| **35** | Perbarui Hari Libur Klinik | `/api/clinic-holidays/{id}` | `PUT`/`PATCH` | Aplikasi Admin hanya mengizinkan penambahan dan penghapusan hari libur, tidak ada fitur ubah/edit. |
| **40** | Perbarui Pengajuan Cuti Dokter | `/api/doctor-leaves/{id}` | `PUT`/`PATCH` | Aplikasi Admin hanya mengizinkan pengajuan baru dan pembatalan cuti dokter, tidak ada fitur ubah/edit. |
| **45** | Perbarui Profil Pasien | `/api/patients/{id}` | `PUT`/`PATCH` | Pembaruan profil pasien mandiri menggunakan `/api/auth/update-profile` (No. 7) dan via Admin menggunakan `/api/users/{id}` (No. 81). |
| **46** | Hapus Pasien | `/api/patients/{id}` | `DELETE` | Penghapusan pasien dilakukan melalui penghapusan user login di `/api/users/{id}` (No. 82). |
| **47** | Pulihkan Pasien Terhapus | `/api/patients/{id}/restore` | `POST` | Fitur pemulihan pasien belum diimplementasikan di antarmuka Admin. |
| **53** | Pulihkan Antrean Terhapus | `/api/queues/{id}/restore` | `POST` | Pemulihan tiket antrean belum didukung di antarmuka aplikasi. |
| **60** | Perbarui Hasil Pemeriksaan | `/api/examinations/{id}` | `PUT`/`PATCH` | Riwayat rekam medis/pemeriksaan yang sudah disimpan bersifat permanen (read-only) di aplikasi Dokter. |
| **61** | Hapus Rekam Medis | `/api/examinations/{id}` | `DELETE` | Tidak ada fitur penghapusan rekam medis dari sisi aplikasi Dokter maupun Admin. |
| **62** | Pulihkan Rekam Medis Terhapus | `/api/examinations/{id}/restore` | `POST` | Tidak ada fitur pemulihan rekam medis di aplikasi. |
| **83** | Pulihkan Pengguna Terhapus | `/api/users/{id}/restore` | `POST` | Fitur pemulihan user umum belum didukung di antarmuka Admin. |

---

## 🔍 Detail Pemetaan dan Kesesuaian Endpoint

Berikut adalah daftar lengkap 83 endpoint beserta status kesesuaian dan penempatan kodenya di dalam aplikasi Flutter:

### 1. 🔑 Autentikasi & Akun (`Auth`)
*Semua endpoint autentikasi aktif digunakan dan sesuai.*

| No | Nama API | URL | Method | Status | Penempatan Kode / Metode Repositori |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Login Pengguna | `/api/auth/login` | `POST` | **Sesuai** | [AuthRepository.login](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/data/auth_repository.dart#L11) |
| 2 | Registrasi Pasien Baru | `/api/auth/register` | `POST` | **Sesuai** | [AuthRepository.register](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/data/auth_repository.dart#L34) |
| 3 | Minta OTP Reset Password | `/api/auth/forgot-password/otp` | `POST` | **Sesuai** | [AuthRepository.requestPasswordResetOtp](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/data/auth_repository.dart#L132) |
| 4 | Lupa Password (Reset via OTP) | `/api/auth/forgot-password` | `POST` | **Sesuai** | [AuthRepository.forgotPassword](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/data/auth_repository.dart#L152) |
| 5 | Keluar / Logout | `/api/auth/logout` | `POST` | **Sesuai** | [AuthRepository.logout](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/data/auth_repository.dart#L68) |
| 6 | Ambil Profil Aktif | `/api/auth/profile` | `GET` | **Sesuai** | [AuthRepository.getProfile](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/data/auth_repository.dart#L121) |
| 7 | Perbarui Profil Aktif | `/api/auth/update-profile` | `POST` / `PUT` | **Sesuai** | [AuthRepository.updateProfile](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/data/auth_repository.dart#L86) |
| 8 | Perbarui Token FCM | `/api/auth/fcm-token` | `POST` | **Sesuai** | [AuthRepository.updateFcmToken](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/auth/data/auth_repository.dart#L76) |

---

### 2. 📊 Dashboard & Profil Puskesmas (`Dashboard & Profile`)
*Semua endpoint dashboard & profil aktif digunakan dan sesuai.*

| No | Nama API | URL | Method | Status | Penempatan Kode / Metode Repositori |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 9 | Ambil Statistik Dashboard | `/api/dashboard-stats` | `GET` | **Sesuai** | [AdminRepository.getDashboardStats](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L252) |
| 10 | Ambil Profil Puskesmas | `/api/puskesmas-profile` | `GET` | **Sesuai** | [PuskesmasProfileRepository.fetchProfile](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/repositories/puskesmas_profile_repository.dart#L11) |
| 11 | Perbarui Profil Puskesmas | `/api/puskesmas-profile` | `PUT` | **Sesuai** | [PuskesmasProfileRepository.updateProfile](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/repositories/puskesmas_profile_repository.dart#L21) |

---

### 3. 🏥 Manajemen Poliklinik (`Polyclinics`)
*5 digunakan, 1 tidak digunakan (restore).*

| No | Nama API | URL | Method | Status | Penempatan Kode / Metode Repositori |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 12 | Ambil Semua Poliklinik | `/api/polyclinics` | `GET` | **Sesuai** | [PatientRepository.getPolyclinics](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L75)<br>[AdminRepository.getPolyclinics](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L108) |
| 13 | Ambil Detail Poliklinik | `/api/polyclinics/{id}` | `GET` | **Sesuai** | [PatientRepository.getPolyclinic](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L174)<br>[AdminRepository.getPolyclinic](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L377) |
| 14 | Buat Poliklinik Baru | `/api/polyclinics` | `POST` | **Sesuai** | [AdminRepository.createPolyclinic](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L118) |
| 15 | Perbarui Poliklinik | `/api/polyclinics/{id}` | `PUT` / `PATCH` | **Sesuai** | [AdminRepository.updatePolyclinic](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L126) |
| 16 | Hapus Poliklinik | `/api/polyclinics/{id}` | `DELETE` | **Sesuai** | [AdminRepository.deletePolyclinic](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L134) |
| 17 | Pulihkan Poliklinik Terhapus | `/api/polyclinics/{id}/restore` | `POST` | **Tidak Digunakan** | - |

---

### 4. 🩺 Manajemen Dokter & Jadwal (`Doctors & Schedules`)
*11 digunakan, 3 tidak digunakan (restore, profile, schedule-restore).*

| No | Nama API | URL | Method | Status | Penempatan Kode / Metode Repositori |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 18 | Ambil Semua Dokter | `/api/doctors` | `GET` | **Sesuai** | [PatientRepository.getDoctors](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L97)<br>[AdminRepository.getDoctors](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L73) |
| 19 | Ambil Detail Dokter | `/api/doctors/{id}` | `GET` | **Sesuai** | [PatientRepository.getDoctor](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L184)<br>[AdminRepository.getDoctor](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L368) |
| 20 | Tambahkan Dokter Baru | `/api/doctors` | `POST` | **Sesuai** | [AdminRepository.createDoctor](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L83) |
| 21 | Perbarui Akun Dokter | `/api/doctors/{id}` | `PUT` / `PATCH` | **Sesuai** | [AdminRepository.updateDoctor](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L91) |
| 22 | Hapus Akun Dokter | `/api/doctors/{id}` | `DELETE` | **Sesuai** | [AdminRepository.deleteDoctor](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L99) |
| 23 | Pulihkan Akun Dokter Terhapus | `/api/doctors/{id}/restore` | `POST` | **Tidak Digunakan** | - |
| 24 | Ambil Profil Dokter Aktif | `/api/doctors/profile` | `GET` | **Dihapus** | Telah dihapus dari backend API karena redundan dengan `/api/auth/profile`. |
| 25 | Perbarui Status Online Dokter | `/api/doctors/me/status` | `PATCH` | **Sesuai** | [DoctorRepository.updateOnlineStatus](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/data/doctor_repository.dart#L66) |
| 26 | Ambil Semua Jadwal Dokter | `/api/doctor-schedules` | `GET` | **Sesuai** | [PatientRepository.getDoctorSchedules](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L86)<br>[AdminRepository.getSchedules](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L206) |
| 27 | Ambil Detail Jadwal | `/api/doctor-schedules/{id}` | `GET` | **Sesuai** | [PatientRepository.getDoctorScheduleDetail](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L194)<br>[AdminRepository.getSchedule](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L395) |
| 28 | Tambah Jadwal Praktik Baru | `/api/doctor-schedules` | `POST` | **Sesuai** | [AdminRepository.createSchedule](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L216) |
| 29 | Perbarui Jadwal Praktik | `/api/doctor-schedules/{id}` | `PUT` / `PATCH` | **Sesuai** | [AdminRepository.updateSchedule](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L224) |
| 30 | Hapus Jadwal Praktik | `/api/doctor-schedules/{id}` | `DELETE` | **Sesuai** | [AdminRepository.deleteSchedule](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L232) |
| 31 | Pulihkan Jadwal Terhapus | `/api/doctor-schedules/{id}/restore` | `POST` | **Tidak Digunakan** | - |

---

### 5. 📅 Hari Libur & Cuti (`Holidays & Leaves`)
*8 digunakan, 2 tidak digunakan (holiday-update, leave-update).*

| No | Nama API | URL | Method | Status | Penempatan Kode / Metode Repositori |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 32 | Ambil Daftar Libur Klinik | `/api/clinic-holidays` | `GET` | **Sesuai** | [PatientRepository.getClinicHolidays](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L117)<br>[AdminRepository.getClinicHolidays](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L262) |
| 33 | Ambil Detail Hari Libur | `/api/clinic-holidays/{id}` | `GET` | **Sesuai** | [PatientRepository.getClinicHoliday](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L204)<br>[AdminRepository.getClinicHoliday](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L413) |
| 34 | Tetapkan Tanggal Libur Klinik | `/api/clinic-holidays` | `POST` | **Sesuai** | [AdminRepository.addClinicHoliday](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L272) |
| 35 | Perbarui Hari Libur Klinik | `/api/clinic-holidays/{id}` | `PUT` / `PATCH` | **Tidak Digunakan** | - |
| 36 | Hapus Hari Libur Klinik | `/api/clinic-holidays/{id}` | `DELETE` | **Sesuai** | [AdminRepository.deleteClinicHoliday](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L283) |
| 37 | Ambil Daftar Cuti Dokter | `/api/doctor-leaves` | `GET` | **Sesuai** | [PatientRepository.getDoctorLeaves](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L135)<br>[AdminRepository.getDoctorLeaves](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L292) |
| 38 | Ambil Detail Cuti Dokter | `/api/doctor-leaves/{id}` | `GET` | **Sesuai** | [PatientRepository.getDoctorLeave](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L214)<br>[AdminRepository.getDoctorLeave](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L422) |
| 39 | Ajukan Cuti Dokter | `/api/doctor-leaves` | `POST` | **Sesuai** | [AdminRepository.addDoctorLeave](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L303) |
| 40 | Perbarui Pengajuan Cuti Dokter | `/api/doctor-leaves/{id}` | `PUT` / `PATCH` | **Tidak Digunakan** | - |
| 41 | Hapus/Batalkan Cuti Dokter | `/api/doctor-leaves/{id}` | `DELETE` | **Sesuai** | [AdminRepository.deleteDoctorLeave](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L315) |

---

### 6. 👥 Manajemen Pasien (`Patients`)
*3 digunakan, 3 tidak digunakan (patient-update, patient-delete, patient-restore).*

| No | Nama API | URL | Method | Status | Penempatan Kode / Metode Repositori |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 42 | Ambil Daftar Pasien | `/api/patients` | `GET` | **Sesuai** | [AdminRepository.getPatients](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L62) |
| 43 | Ambil Detail Pasien | `/api/patients/{id}` | `GET` | **Sesuai** | [PatientRepository.getPatient](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L184)<br>[AdminRepository.getPatient](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L359) |
| 44 | Daftarkan Pasien Baru (Oleh Admin) | `/api/patients` | `POST` | **Sesuai** | [AdminRepository.createPatient](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L37) |
| 45 | Perbarui Profil Pasien | `/api/patients/{id}` | `PUT` / `PATCH` | **Tidak Digunakan** | - |
| 46 | Hapus Pasien | `/api/patients/{id}` | `DELETE` | **Tidak Digunakan** | - |
| 47 | Pulihkan Pasien Terhapus | `/api/patients/{id}/restore` | `POST` | **Tidak Digunakan** | - |

---

### 7. 🎫 Sistem Antrean & Check-In (`Queues`)
*8 digunakan, 1 tidak digunakan (restore).*

| No | Nama API | URL | Method | Status | Penempatan Kode / Metode Repositori |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 48 | Ambil Semua Antrean | `/api/queues` | `GET` | **Sesuai** | [PatientRepository.getMyQueues](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L43)<br>[DoctorRepository.getMyQueues](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/data/doctor_repository.dart#L12)<br>[AdminRepository.getQueues](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L143) |
| 49 | Ambil Detail Antrean | `/api/queues/{id}` | `GET` | **Sesuai** | [PatientRepository.getQueue](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L154)<br>[DoctorRepository.getQueue](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/data/doctor_repository.dart#L75)<br>[AdminRepository.getQueue](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L386) |
| 50 | Daftar Antrean Online (Booking) | `/api/queues` | `POST` | **Sesuai** | [PatientRepository.bookQueue](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L65)<br>[AdminRepository.bookQueue](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L323) |
| 51 | Perbarui Status Antrean / Panggil Pasien | `/api/queues/{id}` | `PUT` / `PATCH` | **Sesuai** | [DoctorRepository.updateQueueStatus](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/data/doctor_repository.dart#L50)<br>[AdminRepository.updateQueueStatus](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L153)<br>[AdminRepository.updateQueue](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L161) |
| 52 | Batalkan Antrean Pasien | `/api/queues/{id}` | `DELETE` | **Sesuai** | [PatientRepository.cancelQueue](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L108)<br>[AdminRepository.deleteQueue](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L197) |
| 53 | Pulihkan Antrean Terhapus | `/api/queues/{id}/restore` | `POST` | **Tidak Digunakan** | - |
| 54 | Verifikasi Check-In Antrean | `/api/queues/{id}/checkin` | `POST` | **Sesuai** | [AdminRepository.checkInQueue](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L169) |
| 55 | Geser Antrean Pasien (Skip) | `/api/queues/{id}/skip` | `POST` | **Sesuai** | [DoctorRepository.skipQueue](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/data/doctor_repository.dart#L58)<br>[AdminRepository.skipQueue](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L189) |
| 56 | Panggil Ulang Antrean Pasien (Recall) | `/api/queues/{id}/recall` | `POST` | **Sesuai** | [AdminRepository.recallQueue](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L180) |

---

### 8. 📝 Rekam Medis & Pemeriksaan (`Examinations`)
*3 digunakan, 3 tidak digunakan (exam-update, exam-delete, exam-restore).*

| No | Nama API | URL | Method | Status | Penempatan Kode / Metode Repositori |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 57 | Ambil Rekam Medis / Pemeriksaan | `/api/examinations` | `GET` | **Sesuai** | [PatientRepository.getMyExaminations](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L54)<br>[DoctorRepository.getMyExaminations](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/data/doctor_repository.dart#L32)<br>[DoctorRepository.getPatientHistory](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/data/doctor_repository.dart#L22)<br>[AdminRepository.getExaminations](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L241) |
| 58 | Ambil Detail Rekam Medis | `/api/examinations/{id}` | `GET` | **Sesuai** | [PatientRepository.getExamination](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/patient/data/patient_repository.dart#L164)<br>[DoctorRepository.getExamination](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/data/doctor_repository.dart#L84)<br>[AdminRepository.getExamination](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L404) |
| 59 | Simpan Hasil Pemeriksaan (Rekam Medis) | `/api/examinations` | `POST` | **Sesuai** | [DoctorRepository.submitExamination](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/doctor/data/doctor_repository.dart#L42) |
| 60 | Perbarui Hasil Pemeriksaan | `/api/examinations/{id}` | `PUT` / `PATCH` | **Tidak Digunakan** | - |
| 61 | Hapus Rekam Medis | `/api/examinations/{id}` | `DELETE` | **Tidak Digunakan** | - |
| 62 | Pulihkan Rekam Medis Terhapus | `/api/examinations/{id}/restore` | `POST` | **Tidak Digunakan** | - |

---

### 9. 💳 Manajemen Transaksi & Pembayaran (`Payments`)
*Semua endpoint pembayaran aktif digunakan dan sesuai.*

| No | Nama API | URL | Method | Status | Penempatan Kode / Metode Repositori |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 63 | Ambil Semua Transaksi Pembayaran | `/api/payments` | `GET` | **Sesuai** | [PaymentRepository.getMyPayments](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/repositories/payment_repository.dart#L34) |
| 64 | Ambil Detail Pembayaran | `/api/payments/{id}` | `GET` | **Sesuai** | [PaymentRepository.getPayment](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/repositories/payment_repository.dart#L89) |
| 65 | Upload Bukti Pembayaran | `/api/payments/{id}/upload-proof` | `POST` | **Sesuai** | [PaymentRepository.uploadPaymentProof](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/repositories/payment_repository.dart#L45) |
| 66 | Verifikasi Pembayaran Online | `/api/payments/{id}/verify` | `POST` | **Sesuai** | [PaymentRepository.verifyPayment](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/repositories/payment_repository.dart#L65) |
| 67 | Verifikasi Pembayaran Tunai | `/api/payments/{id}/cash-pay` | `POST` | **Sesuai** | [PaymentRepository.cashPay](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/shared/repositories/payment_repository.dart#L78) |
| 67b | Load Gambar Bukti Transfer | `/api/payments/{id}/proof-image` | `GET` | **Sesuai** | Digunakan langsung sebagai URL gambar di `prescription_detail_screen.dart` dan `admin_payment_detail_screen.dart` |

---

### 10. 💊 Inventaris Obat & Farmasi (`Pharmacy & Medicines`)
*Semua endpoint farmasi dan obat aktif digunakan.*

| No | Nama API | URL | Method | Status | Penempatan Kode / Metode Repositori |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 68 | Daftar Antrean Obat Apotek | `/api/pharmacy/queues` | `GET` | **Sesuai** | [PharmacyRepository.getPharmacyQueues](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/data/pharmacy_repository.dart#L35) |
| 69 | Penyerahan Obat Pasien | `/api/pharmacy/queues/{id}/dispense` | `POST` | **Sesuai** | [PharmacyRepository.dispensePrescription](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/data/pharmacy_repository.dart#L46) |
| 69b | Panggilan Suara Loket Apotek | `/api/pharmacy/queues/{id}/call` | `POST` | **Sesuai** | [PharmacyRepository.callPrescriptionPatient](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/data/pharmacy_repository.dart#L117) |
| 70 | Ambil Semua Daftar Obat | `/api/medicines` | `GET` | **Sesuai** | [PharmacyRepository.getMedicines](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/data/pharmacy_repository.dart#L56) |
| 71 | Ambil Detail Obat | `/api/medicines/{id}` | `GET` | **Sesuai** | [PharmacyRepository.getMedicine](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/data/pharmacy_repository.dart#L107) |
| 72 | Tambah Obat Baru | `/api/medicines` | `POST` | **Sesuai** | [PharmacyRepository.addMedicine](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/data/pharmacy_repository.dart#L67) |
| 73 | Perbarui Data/Stok Obat | `/api/medicines/{id}` | `PUT` / `PATCH` | **Sesuai** | [PharmacyRepository.updateMedicine](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/data/pharmacy_repository.dart#L77) |
| 74 | Hapus Obat | `/api/medicines/{id}` | `DELETE` | **Sesuai** | [PharmacyRepository.deleteMedicine](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/data/pharmacy_repository.dart#L87) |
| 75 | Pulihkan Obat Terhapus | `/api/medicines/{id}/restore` | `POST` | **Sesuai** | [PharmacyRepository.restoreMedicine](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/pharmacy/data/pharmacy_repository.dart#L96) |

---

### 11. ⚙️ Konfigurasi & Pengguna Umum (`Settings & Users`)
*7 digunakan, 1 tidak digunakan (restore).*

| No | Nama API | URL | Method | Status | Penempatan Kode / Metode Repositori |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 76 | Ambil Pengaturan Puskesmas | `/api/settings` | `GET` | **Sesuai** | [AdminRepository.getSystemSettings](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L331) |
| 77 | Perbarui Pengaturan Puskesmas | `/api/settings` | `PUT` | **Sesuai** | [AdminRepository.updateSystemSettings](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L340) |
| 78 | Ambil Semua Pengguna (Admin) | `/api/users` | `GET` | **Sesuai** | [AdminRepository.getUsers](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L19) |
| 79 | Buat Pengguna Baru (Admin) | `/api/users` | `POST` | **Sesuai** | [AdminRepository.createUser](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L29) |
| 80 | Ambil Detail Pengguna (Admin) | `/api/users/{id}` | `GET` | **Sesuai** | [AdminRepository.getUser](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L350) |
| 81 | Perbarui Pengguna (Admin) | `/api/users/{id}` | `PUT` | **Sesuai** | [AdminRepository.updateUser](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L45) |
| 82 | Hapus Pengguna (Admin — Soft Delete) | `/api/users/{id}` | `DELETE` | **Sesuai** | [AdminRepository.deleteUser](file:///d:/Materi%20Semester%204/PBM/nalaseva%203/lib/features/admin/data/admin_repository.dart#L53) |
| 83 | Pulihkan Pengguna Terhapus | `/api/users/{id}/restore` | `POST` | **Tidak Digunakan** | - |
