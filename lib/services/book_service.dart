import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book_model.dart';
import '../config/supabase_config.dart';

class BookService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== REALTIME STREAMS ====================
  
  // 1. Stream Semua Buku (Untuk Home)
  Stream<List<Book>> getBooksStream() {
    return _supabase
        .from(SupabaseConfig.booksTable)
        .stream(primaryKey: ['id']) // Primary key tabel Anda
        .order('id', ascending: false)
        .map((data) => data.map((json) => Book.fromJson(json)).toList());
  }

  // 2. Stream Satu Buku (Untuk Detail) - ✅ INI YANG SEBELUMNYA HILANG
  Stream<Book?> getBookByIdStream(int id) {
    return _supabase
        .from(SupabaseConfig.booksTable)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) {
          if (data.isNotEmpty) {
            return Book.fromJson(data.first);
          }
          return null; // Jika data kosong (misal dihapus)
        });
  }

  // ==================== CRUD OPERATIONS ====================
  
  // CREATE
  Future<Map<String, dynamic>> createBook(Book book) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.booksTable)
          .insert(book.toJson())
          .select()
          .single();

      return {
        'success': true,
        'message': 'Buku berhasil ditambahkan',
        'data': Book.fromJson(response),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // READ (Tetap ada untuk kebutuhan non-stream jika perlu)
  Future<Map<String, dynamic>> getAllBooks() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.booksTable)
          .select()
          .order('id', ascending: false);
      
      final books = (response as List).map((json) => Book.fromJson(json)).toList();
      return {'success': true, 'data': books};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // READ BY ID
  Future<Map<String, dynamic>> getBookById(int id) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.booksTable)
          .select()
          .eq('id', id)
          .single();
      return {'success': true, 'data': Book.fromJson(response)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // UPDATE
  Future<Map<String, dynamic>> updateBook(int id, Book book) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.booksTable)
          .update(book.toJson())
          .eq('id', id)
          .select()
          .single();
      return {
        'success': true,
        'message': 'Buku berhasil diperbarui',
        'data': Book.fromJson(response), // Mengembalikan object terbaru
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // DELETE
  Future<Map<String, dynamic>> deleteBook(int id) async {
    try {
      await _supabase.from(SupabaseConfig.booksTable).delete().eq('id', id);
      return {'success': true, 'message': 'Buku berhasil dihapus'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // STATISTICS
  Future<int> getTotalBooks() async {
    try {
      final response = await _supabase.from(SupabaseConfig.booksTable).count();
      return response;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getTotalStock() async {
    try {
      // Menggunakan RPC (Stored Procedure) lebih efisien, tapi manual loop oke untuk skala kecil
      final response = await _supabase.from(SupabaseConfig.booksTable).select('jumlah');
      int total = 0;
      for (var item in response) total += (item['jumlah'] as int?) ?? 0;
      return total;
    } catch (e) { return 0; }
  }

  Future<int> getTotalValue() async {
    try {
      final response = await _supabase.from(SupabaseConfig.booksTable).select('harga, jumlah');
      int total = 0;
      for (var item in response) {
        total += ((item['harga'] as int? ?? 0) * (item['jumlah'] as int? ?? 0));
      }
      return total;
    } catch (e) { return 0; }
  }
}