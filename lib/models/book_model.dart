import 'package:intl/intl.dart';

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
 
  factory Book.fromJson(Map<String, dynamic> json) {
    String rawDate = json['tanggal_masuk'] as String? ?? '';
    String formattedDate = rawDate;
   
    if (rawDate.isNotEmpty) {
      try {       
        final DateTime parsedDate = DateTime.parse(rawDate);       
        formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
      } catch (e) {       
        formattedDate = rawDate;
      }
    }

    return Book(
      id: json['id'] as int?,
      judul: json['judul'] as String? ?? '',
      harga: json['harga'] as int? ?? 0,
      jumlah: json['jumlah'] as int? ?? 0,
      tanggalMasuk: formattedDate,
      volume: json['volume'] as int? ?? 0,
      penulis: json['penulis'] as String? ?? '',
      penerbit: json['penerbit'] as String? ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    String dbDate = tanggalMasuk;
    
    if (tanggalMasuk.isNotEmpty) {
      try {        
        final DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(tanggalMasuk);      
        dbDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        // Supabase akan melempar error jika format salah, yang akan ditangkap di Service
      }
    }

    return {
      if (id != null) 'id': id,
      'judul': judul,
      'harga': harga,
      'jumlah': jumlah,
      'tanggal_masuk': dbDate, 
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