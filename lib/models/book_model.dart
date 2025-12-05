class Book {
  final int? id;
  final String judul;
  final int harga;
  final int jumlah;
  final String tanggalMasuk;
  final int volume;
  final String penulis;
  final String penerbit;

  Book({
    this.id,
    required this.judul,
    required this.harga,
    required this.jumlah,
    required this.tanggalMasuk,
    required this.volume,
    required this.penulis,
    required this.penerbit,
  });

  // Factory constructor: Mengubah Data DB (yyyy-MM-dd) -> Data App (dd/MM/yyyy)
  factory Book.fromJson(Map<String, dynamic> json) {
    String rawDate = json['tanggal_masuk'] as String? ?? '';
    
    // ✅ AUTO FIX: Jika format dari DB adalah yyyy-MM-dd, ubah ke dd/MM/yyyy
    if (rawDate.contains('-')) {
      try {
        final parts = rawDate.split('-'); // [2023, 12, 25]
        if (parts.length == 3) {
          rawDate = '${parts[2]}/${parts[1]}/${parts[0]}'; // 25/12/2023
        }
      } catch (e) {
        // Biarkan rawDate apa adanya jika gagal parse
      }
    }

    return Book(
      id: json['id'] as int?,
      judul: json['judul'] as String? ?? '',
      harga: json['harga'] as int? ?? 0,
      jumlah: json['jumlah'] as int? ?? 0,
      tanggalMasuk: rawDate, // Sudah format dd/MM/yyyy
      volume: json['volume'] as int? ?? 0,
      penulis: json['penulis'] as String? ?? '',
      penerbit: json['penerbit'] as String? ?? '',
    );
  }

  // Method toJson: Mengubah Data App (dd/MM/yyyy) -> Data DB (yyyy-MM-dd)
  Map<String, dynamic> toJson() {
    String dbDate = tanggalMasuk;

    // ✅ AUTO FIX: Jika format dari App adalah dd/MM/yyyy, ubah ke yyyy-MM-dd
    if (tanggalMasuk.contains('/')) {
      try {
        final parts = tanggalMasuk.split('/'); // [25, 12, 2023]
        if (parts.length == 3) {
          dbDate = '${parts[2]}-${parts[1]}-${parts[0]}'; // 2023-12-25
        }
      } catch (e) {
        // Kirim apa adanya jika gagal parse
      }
    }

    return {
      if (id != null) 'id': id,
      'judul': judul,
      'harga': harga,
      'jumlah': jumlah,
      'tanggal_masuk': dbDate, // Dikirim dengan format yang dimengerti Supabase
      'volume': volume,
      'penulis': penulis,
      'penerbit': penerbit,
    };
  }

  Book copyWith({
    int? id,
    String? judul,
    int? harga,
    int? jumlah,
    String? tanggalMasuk,
    int? volume,
    String? penulis,
    String? penerbit,
  }) {
    return Book(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      harga: harga ?? this.harga,
      jumlah: jumlah ?? this.jumlah,
      tanggalMasuk: tanggalMasuk ?? this.tanggalMasuk,
      volume: volume ?? this.volume,
      penulis: penulis ?? this.penulis,
      penerbit: penerbit ?? this.penerbit,
    );
  }

  int get totalValue => harga * jumlah;

  @override
  String toString() {
    return 'Book(id: $id, judul: $judul, harga: $harga, jumlah: $jumlah, tanggalMasuk: $tanggalMasuk, volume: $volume, penulis: $penulis, penerbit: $penerbit)';
  }
}