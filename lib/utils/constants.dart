class AppConstants {
  // App Info
  static const String appName = 'Responsi 2 Mobile Paket 3 H1D023036';
  static const String appStoreName = 'Deef Books'; // Nama toko buku Anda
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxTitleLength = 100;
  static const int maxNameLength = 50;
  
  // Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Messages
  static const String successSave = 'Data berhasil disimpan';
  static const String successUpdate = 'Data berhasil diperbarui';
  static const String successDelete = 'Data berhasil dihapus';
  static const String errorGeneral = 'Terjadi kesalahan, silakan coba lagi';
  static const String errorNetwork = 'Tidak ada koneksi internet';
  static const String errorEmptyField = 'Field tidak boleh kosong';
  static const String errorInvalidEmail = 'Email tidak valid';
  static const String errorPasswordTooShort = 'Password minimal 6 karakter';
  static const String confirmDelete = 'Apakah Anda yakin ingin menghapus data ini?';
  
  // Validation Messages
  static String fieldRequired(String fieldName) => '$fieldName tidak boleh kosong';
  static String fieldTooShort(String fieldName, int minLength) => 
      '$fieldName minimal $minLength karakter';
  static String fieldInvalid(String fieldName) => '$fieldName tidak valid';
}