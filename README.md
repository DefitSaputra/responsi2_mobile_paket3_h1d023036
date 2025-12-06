
# 📚 Deef Books - Aplikasi Inventaris Buku Modern

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![GetX](https://img.shields.io/badge/GetX-purple?style=for-the-badge&logo=flutter&logoColor=white)

**Deef Books** adalah aplikasi mobile manajemen inventaris perpustakaan yang dibangun menggunakan framework **Flutter** dengan backend **Supabase**. Aplikasi ini dirancang untuk mempermudah proses pendataan buku dengan fitur unggulan **Realtime Updates**, di mana data pada aplikasi akan diperbarui secara instan tanpa perlu refresh manual saat terjadi perubahan di database.

---

## 👨‍🎓 Identitas Mahasiswa

| Informasi | Detail |
| :--- | :--- |
| **Nama Lengkap** | **Defit Bagus Saputra** |
| **NIM** | **H1D023036** |
| **Shift Baru** | **F** |
| **Shift Asal** | **C** |

---

## 📱 Demo Aplikasi

Berikut adalah demonstrasi fitur utama aplikasi (Login, Tambah Buku, Edit, Hapus, dan Realtime Update):

<div align="center">
  <img src="assets/demo.gif" width="320" alt="Demo Aplikasi Deef Books" style="border-radius: 15px; box-shadow: 0px 4px 10px rgba(0,0,0,0.2);" />
  <p><i>Preview Tampilan Aplikasi pada Android</i></p>
</div>

---

## 📂 Struktur Proyek

Aplikasi ini menerapkan arsitektur yang bersih (*Clean Code*) dengan pemisahan tugas (*Separation of Concerns*) yang jelas antara tampilan (UI), logika bisnis, dan model data.

```

lib/
├── config/
│   ├── supabase\_config.dart  \# Konfigurasi Environment & Klien Supabase
│   └── theme.dart            \# Manajemen Tema (Warna, Font, Gaya Global)
├── models/
│   ├── book\_model.dart       \# Data Model Buku (JSON Parsing & Format Tanggal)
│   └── user\_model.dart       \# Data Model Pengguna
├── screens/
│   ├── auth/
│   │   ├── login\_screen.dart    \# UI Login
│   │   └── register\_screen.dart \# UI Registrasi Akun
│   ├── book/
│   │   ├── add\_book\_screen.dart    \# Form Tambah Buku
│   │   ├── detail\_book\_screen.dart \# Tampilan Detail & Aksi CRUD
│   │   └── edit\_book\_screen.dart   \# Form Edit Buku
│   ├── home/
│   │   └── home\_screen.dart        \# Dashboard Utama (List Stream & Statistik)
│   └── splash\_screen.dart          \# Layar Pembuka & Pengecekan Sesi
├── services/
│   ├── auth\_service.dart     \# Service Autentikasi (Sign In/Up/Out)
│   └── book\_service.dart     \# Service Database Buku (CRUD & Realtime Stream)
├── utils/
│   ├── constants.dart        \# Konstanta Teks & Pesan Validasi
│   └── helpers.dart          \# Fungsi Bantuan (Format Rupiah, Tanggal, dll)
├── widgets/
│   ├── book\_card.dart        \# Widget Kartu Item Buku
│   ├── custom\_button.dart    \# Widget Tombol Kustom
│   ├── custom\_text\_field.dart\# Widget Input Field Kustom
│   ├── empty\_state.dart      \# Widget Tampilan Kosong
│   └── loading\_indicator.dart\# Widget Loading
└── main.dart                 \# Titik Masuk Aplikasi & Inisialisasi

````

---

## 🔌 Spesifikasi API & Database (Supabase)

Backend aplikasi ini menggunakan **Supabase** (PostgreSQL) dengan konfigurasi tabel sebagai berikut:

### Tabel Utama: `books`

Tabel ini digunakan untuk menyimpan seluruh data inventaris perpustakaan.

| Nama Kolom | Tipe Data | Keterangan |
| :--- | :--- | :--- |
| `id` | `int8` | *Primary Key*, Auto Increment. Identitas unik buku. |
| `judul` | `string` | Judul lengkap buku. |
| `penulis` | `string` | Nama penulis buku. |
| `penerbit` | `string` | Nama penerbit buku. |
| `harga` | `int8` | Harga buku dalam mata uang Rupiah. |
| `jumlah` | `int8` | Stok buku yang tersedia di perpustakaan. |
| `volume` | `int8` | Informasi volume/jilid buku. |
| `tanggal_masuk` | `date` | Tanggal buku didata (Format standar DB: `yyyy-MM-dd`). |

### Fitur Backend

* **Realtime Subscription:** Menggunakan protokol WebSocket (`supabase_flutter` stream) untuk mendengarkan event `INSERT`, `UPDATE`, dan `DELETE` pada tabel `books`. Ini memungkinkan UI sinkron otomatis.
* **Authentication:** Menggunakan Email & Password provider dari Supabase Auth.
* **Filtering:** Pencarian data dilakukan secara responsif di sisi klien.

---

## 📝 Penjelasan Kode & Fungsi Utama

Berikut adalah breakdown logika kode untuk modul-modul penting dalam aplikasi:

### 1. Manajemen Data Buku (`BookService`)
Lokasi: `lib/services/book_service.dart`

Kelas ini adalah jembatan antara aplikasi Flutter dan database Supabase.
* **`getBooksStream()`**:
    * **Fungsi:** Mengambil data list buku secara *realtime*.
    * **Logika:** Menggunakan `.stream()` yang akan terus "mendengarkan" perubahan di tabel `books`. Data diurutkan berdasarkan `id` terbaru.
* **`getBookByIdStream(int id)`**:
    * **Fungsi:** Mendengarkan perubahan pada satu buku spesifik. Digunakan di halaman Detail agar saat buku diedit, tampilan detail langsung berubah.
* **`createBook`, `updateBook`, `deleteBook`**:
    * **Fungsi:** Operasi standar CRUD.
    * **Logika:** Mengirim perintah `.insert()`, `.update()`, atau `.delete()` ke Supabase.

### 2. Model Data & Konversi Tanggal (`BookModel`)
Lokasi: `lib/models/book_model.dart`

Menangani masalah perbedaan format tanggal antara standar database dan format umum di Indonesia.
* **`fromJson` (Database ➡ Aplikasi)**:
    * Menerima string tanggal format ISO (`yyyy-MM-dd`) dari database.
    * Mengonversinya menjadi objek `DateTime` lalu diformat menjadi string `dd/MM/yyyy` (Contoh: 25/12/2023) agar mudah dibaca pengguna.
* **`toJson` (Aplikasi ➡ Database)**:
    * Menerima input tanggal format Indonesia (`dd/MM/yyyy`).
    * Mengonversinya kembali ke format standar database (`yyyy-MM-dd`) sebelum data dikirim ke server untuk menghindari error validasi.

### 3. Dashboard Realtime (`HomeScreen`)
Lokasi: `lib/screens/home/home_screen.dart`

* **UI Responsif:** Menggunakan `StreamBuilder` yang terhubung ke `BookService`. Saat ada data baru masuk (misal dari pengguna lain), list buku di layar akan bertambah sendiri tanpa loading ulang.
* **Statistik Aset:** Menghitung total buku, total stok, dan total nilai aset (Harga x Jumlah) secara *on-the-fly* menggunakan fungsi `.fold()` pada list data yang diterima.

### 4. Helper & Formatting (`Helpers`)
Lokasi: `lib/utils/helpers.dart`

* **`formatCurrency(int amount)`**: Mengubah angka integer (misal: `50000`) menjadi format mata uang Rupiah yang rapi (`Rp 50.000`) menggunakan library `intl`.
* **`formatDate`**: Fungsi utilitas pintar yang memastikan tanggal ditampilkan dengan benar, menangani baik input berupa string maupun objek DateTime.

---

## 🛠️ Cara Instalasi & Menjalankan

Ikuti langkah berikut untuk menjalankan project ini di komputer Anda:

1.  **Clone Repository**
    ```bash
    git clone [https://github.com/defitsaputra/responsi_2_mobile_paket_3_h1d023036.git](https://github.com/defitsaputra/responsi_2_mobile_paket_3_h1d023036.git)
    cd responsi_2_mobile_paket_3_h1d023036
    ```

2.  **Konfigurasi Environment**
    Buat file bernama `.env` di folder root proyek, lalu isi dengan kredensial Supabase Anda:
    ```env
    SUPABASE_URL=[https://project-id-anda.supabase.co](https://project-id-anda.supabase.co)
    SUPABASE_ANON_KEY=anon-key-anda-disini
    ```

3.  **Install Dependencies**
    Jalankan perintah ini di terminal untuk mengunduh library yang dibutuhkan:
    ```bash
    flutter pub get
    ```

4.  **Jalankan Aplikasi**
    Pastikan emulator atau device fisik sudah terhubung, lalu jalankan:
    ```bash
    flutter run
    ```

---

<center>
  <small>Copyright<b>Defit Bagus Saputra</b> untuk Responsi 2 Praktikum Pemrograman Mobile</small>
</center>
````