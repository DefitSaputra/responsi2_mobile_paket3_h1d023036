import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../models/book_model.dart';
import '../../services/auth_service.dart';
import '../../services/book_service.dart';
import '../../widgets/book_card.dart';
import '../../widgets/loading_indicator.dart' hide EmptyState;
import '../../widgets/empty_state.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import '../book/add_book_screen.dart';
import '../book/edit_book_screen.dart';
import '../book/detail_book_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final BookService _bookService = BookService();
  
  // Stream untuk mendengarkan perubahan data secara langsung
  late Stream<List<Book>> _booksStream;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    // Inisialisasi stream satu kali saat halaman dibuka
    // Pastikan getBooksStream sudah ada di BookService
    _booksStream = _bookService.getBooksStream();
  }

  void _searchBooks(String query) {
    setState(() {
      _searchQuery = query;
      // Tidak perlu panggil fungsi filter manual, 
      // setState akan memicu build ulang dan StreamBuilder akan memfilter ulang datanya
    });
  }

  Future<void> _handleDelete(Book book) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus buku "${book.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Tidak perlu loading indicator full screen karena stream akan update UI otomatis
      // Feedback cukup dengan snackbar
      final result = await _bookService.deleteBook(book.id!);
      
      if (result['success']) {
        Get.snackbar(
          'Berhasil',
          result['message'],
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );
        // TIDAK PERLU _refreshData(), Stream otomatis update
      } else {
        Get.snackbar(
          'Error',
          result['message'],
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaris Buku - Deef Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      // ✅ Menggunakan StreamBuilder untuk Realtime Updates
      body: StreamBuilder<List<Book>>(
        stream: _booksStream,
        builder: (context, snapshot) {
          // 1. Handle Loading Awal
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator(message: 'Menghubungkan data...'));
          }

          // 2. Handle Error
          if (snapshot.hasError) {
            return Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Terjadi Kesalahan',
                message: 'Gagal memuat data: ${snapshot.error}',
              ),
            );
          }

          // 3. Ambil Data
          final allBooks = snapshot.data ?? [];
          
          // Filter data berdasarkan search query
          final filteredBooks = _searchQuery.isEmpty 
              ? allBooks 
              : allBooks.where((book) {
                  final query = _searchQuery.toLowerCase();
                  return book.judul.toLowerCase().contains(query) ||
                         book.penulis.toLowerCase().contains(query) ||
                         book.penerbit.toLowerCase().contains(query);
                }).toList();

          // 4. Hitung Statistik secara Realtime (Client Side Calculation)
          // Ini lebih efisien daripada request terpisah ke DB
          final totalBooks = allBooks.length;
          final totalStock = allBooks.fold<int>(0, (sum, item) => sum + item.jumlah);
          final totalValue = allBooks.fold<int>(0, (sum, item) => sum + (item.harga * item.jumlah));

          return Column(
            children: [
              // Statistics Card (UI Tetap Sama)
              if (allBooks.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.library_books,
                      label: 'Total Buku',
                      value: '$totalBooks',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.white.withOpacity(0.3),
                    ),
                    _buildStatItem(
                      icon: Icons.inventory_2,
                      label: 'Total Stok',
                      value: '$totalStock',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.white.withOpacity(0.3),
                    ),
                    _buildStatItem(
                      icon: Icons.attach_money,
                      label: 'Total Nilai',
                      value: Helpers.formatCurrency(totalValue),
                      isSmall: true,
                    ),
                  ],
                ),
              ),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: _searchBooks,
                  decoration: InputDecoration(
                    hintText: 'Cari buku, penulis, atau penerbit...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchBooks('');
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Book List
              Expanded(
                child: filteredBooks.isEmpty
                    ? EmptyState(
                        icon: Icons.menu_book_outlined,
                        title: _searchQuery.isEmpty
                            ? 'Belum Ada Buku'
                            : 'Tidak Ditemukan',
                        message: _searchQuery.isEmpty
                            ? 'Tambahkan buku pertama Anda dengan menekan tombol + di bawah'
                            : 'Tidak ada buku yang sesuai dengan pencarian "$_searchQuery"',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = filteredBooks[index];
                          return BookCard(
                            book: book,
                            onTap: () {
                              // Navigasi ke Detail
                              // Tidak perlu await result, karena data realtime
                              Get.to(() => DetailBookScreen(book: book));
                            },
                            onEdit: () {
                              // Navigasi ke Edit
                              Get.to(() => EditBookScreen(book: book));
                            },
                            onDelete: () => _handleDelete(book),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigasi ke Add Book
          Get.to(() => const AddBookScreen());
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Buku'),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    bool isSmall = false,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.white,
            fontSize: isSmall ? 12 : 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}