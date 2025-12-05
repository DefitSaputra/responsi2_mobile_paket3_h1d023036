
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

  // Factory constructor untuk membuat Book dari JSON (dari Supabase)
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int?,
      judul: json['judul'] as String? ?? '',
      harga: json['harga'] as int? ?? 0,
      jumlah: json['jumlah'] as int? ?? 0,
      tanggalMasuk: json['tanggal_masuk'] as String? ?? '',
      volume: json['volume'] as int? ?? 0,
      penulis: json['penulis'] as String? ?? '',
      penerbit: json['penerbit'] as String? ?? '',
    );
  }

  // Method untuk convert Book ke JSON (untuk dikirim ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'judul': judul,
      'harga': harga,
      'jumlah': jumlah,
      'tanggal_masuk': tanggalMasuk,
      'volume': volume,
      'penulis': penulis,
      'penerbit': penerbit,
    };
  }

  // Method untuk membuat copy dengan perubahan tertentu (untuk update)
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

  // Helper getter untuk total nilai (harga x jumlah)
  int get totalValue => harga * jumlah;

  @override
  String toString() {
    return 'Book(id: $id, judul: $judul, harga: $harga, jumlah: $jumlah, tanggalMasuk: $tanggalMasuk, volume: $volume, penulis: $penulis, penerbit: $penerbit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Book &&
      other.id == id &&
      other.judul == judul &&
      other.harga == harga &&
      other.jumlah == jumlah &&
      other.tanggalMasuk == tanggalMasuk &&
      other.volume == volume &&
      other.penulis == penulis &&
      other.penerbit == penerbit;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      judul.hashCode ^
      harga.hashCode ^
      jumlah.hashCode ^
      tanggalMasuk.hashCode ^
      volume.hashCode ^
      penulis.hashCode ^
      penerbit.hashCode;
  }
}