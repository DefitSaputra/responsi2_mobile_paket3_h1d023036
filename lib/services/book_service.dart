// lib/services/book_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book_model.dart';
import '../config/supabase_config.dart';

class BookService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== CREATE - Tambah Buku Baru ====================
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
    } on PostgrestException catch (e) {
      return {
        'success': false,
        'message': 'Gagal menambahkan buku: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // ==================== READ - Get Semua Buku ====================
  Future<Map<String, dynamic>> getAllBooks() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.booksTable)
          .select()
          .order('id', ascending: false);

      final books = (response as List)
          .map((json) => Book.fromJson(json))
          .toList();

      return {
        'success': true,
        'data': books,
      };
    } on PostgrestException catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil data buku: ${e.message}',
        'data': <Book>[],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'data': <Book>[],
      };
    }
  }

  // ==================== READ - Get Buku by ID ====================
  Future<Map<String, dynamic>> getBookById(int id) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.booksTable)
          .select()
          .eq('id', id)
          .single();

      return {
        'success': true,
        'data': Book.fromJson(response),
      };
    } on PostgrestException catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil data buku: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // ==================== UPDATE - Update Buku ====================
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
        'data': Book.fromJson(response),
      };
    } on PostgrestException catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui buku: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // ==================== DELETE - Hapus Buku ====================
  Future<Map<String, dynamic>> deleteBook(int id) async {
    try {
      await _supabase
          .from(SupabaseConfig.booksTable)
          .delete()
          .eq('id', id);

      return {
        'success': true,
        'message': 'Buku berhasil dihapus',
      };
    } on PostgrestException catch (e) {
      return {
        'success': false,
        'message': 'Gagal menghapus buku: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // ==================== SEARCH - Cari Buku ====================
  Future<Map<String, dynamic>> searchBooks(String query) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.booksTable)
          .select()
          .or('judul.ilike.%$query%,penulis.ilike.%$query%,penerbit.ilike.%$query%')
          .order('id', ascending: false);

      final books = (response as List)
          .map((json) => Book.fromJson(json))
          .toList();

      return {
        'success': true,
        'data': books,
      };
    } on PostgrestException catch (e) {
      return {
        'success': false,
        'message': 'Gagal mencari buku: ${e.message}',
        'data': <Book>[],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'data': <Book>[],
      };
    }
  }

  // ==================== FILTER - Filter by Penulis ====================
  Future<Map<String, dynamic>> getBooksByPenulis(String penulis) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.booksTable)
          .select()
          .eq('penulis', penulis)
          .order('id', ascending: false);

      final books = (response as List)
          .map((json) => Book.fromJson(json))
          .toList();

      return {
        'success': true,
        'data': books,
      };
    } on PostgrestException catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil data buku: ${e.message}',
        'data': <Book>[],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'data': <Book>[],
      };
    }
  }

  // ==================== FILTER - Filter by Penerbit ====================
  Future<Map<String, dynamic>> getBooksByPenerbit(String penerbit) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.booksTable)
          .select()
          .eq('penerbit', penerbit)
          .order('id', ascending: false);

      final books = (response as List)
          .map((json) => Book.fromJson(json))
          .toList();

      return {
        'success': true,
        'data': books,
      };
    } on PostgrestException catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil data buku: ${e.message}',
        'data': <Book>[],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'data': <Book>[],
      };
    }
  }

  // ==================== STATISTICS - Get Total Books ====================
  Future<int> getTotalBooks() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.booksTable)
          .select();
      
      // Count dari length list yang dikembalikan
      return response.length;
    } catch (e) {
      print('Error getting total books: $e');
      return 0;
    }
  }

  // ==================== STATISTICS - Get Total Stock ====================
  Future<int> getTotalStock() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.booksTable)
          .select('jumlah');

      int total = 0;
      for (var item in response) {
        total += (item['jumlah'] as int?) ?? 0;
      }
      return total;
    } catch (e) {
      print('Error getting total stock: $e');
      return 0;
    }
  }

  // ==================== STATISTICS - Get Total Value ====================
  Future<int> getTotalValue() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.booksTable)
          .select('harga, jumlah');

      int total = 0;
      for (var item in response) {
        final harga = (item['harga'] as int?) ?? 0;
        final jumlah = (item['jumlah'] as int?) ?? 0;
        total += (harga * jumlah);
      }
      return total;
    } catch (e) {
      print('Error getting total value: $e');
      return 0;
    }
  }

  // ==================== REALTIME - Listen to changes ====================
  RealtimeChannel subscribeToBooks(Function(List<Book>) onData) {
    final channel = _supabase
        .channel('public:books')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseConfig.booksTable,
          callback: (payload) async {
            // Fetch updated data
            final result = await getAllBooks();
            if (result['success']) {
              onData(result['data'] as List<Book>);
            }
          },
        )
        .subscribe();

    return channel;
  }
}