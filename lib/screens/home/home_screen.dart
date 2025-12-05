
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../models/book_model.dart';
import '../../services/auth_service.dart';
import '../../services/book_service.dart';
import '../../widgets/book_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
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
  
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
  // Statistics
  int _totalBooks = 0;
  int _totalStock = 0;
  int _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _loadStatistics();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    
    final result = await _bookService.getAllBooks();
    
    if (result['success']) {
      setState(() {
        _books = result['data'];
        _filteredBooks = _books;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        result['message'],
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _loadStatistics() async {
    final totalBooks = await _bookService.getTotalBooks();
    final totalStock = await _bookService.getTotalStock();
    final totalValue = await _bookService.getTotalValue();
    
    setState(() {
      _totalBooks = totalBooks;
      _totalStock = totalStock;
      _totalValue = totalValue;
    });
  }

  void _searchBooks(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBooks = _books;
      } else {
        _filteredBooks = _books.where((book) {
          return book.judul.toLowerCase().contains(query.toLowerCase()) ||
                 book.penulis.toLowerCase().contains(query.toLowerCase()) ||
                 book.penerbit.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
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
      final result = await _bookService.deleteBook(book.id!);
      
      if (result['success']) {
        Get.snackbar(
          'Berhasil',
          result['message'],
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
        );
        _loadBooks();
        _loadStatistics();
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
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadBooks();
          await _loadStatistics();
        },
        child: _isLoading
            ? const LoadingIndicator(message: 'Memuat data buku...')
            : Column(
                children: [
                  // Statistics Card
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
                          value: '$_totalBooks',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.white.withOpacity(0.3),
                        ),
                        _buildStatItem(
                          icon: Icons.inventory_2,
                          label: 'Total Stok',
                          value: '$_totalStock',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.white.withOpacity(0.3),
                        ),
                        _buildStatItem(
                          icon: Icons.attach_money,
                          label: 'Total Nilai',
                          value: Helpers.formatCurrency(_totalValue),
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
                                onPressed: () => _searchBooks(''),
                              )
                            : null,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Book List
                  Expanded(
                    child: _filteredBooks.isEmpty
                        ? EmptyState(
                            icon: Icons.menu_book_outlined,
                            title: _searchQuery.isEmpty
                                ? 'Belum Ada Buku'
                                : 'Tidak Ditemukan',
                            message: _searchQuery.isEmpty
                                ? 'Tambahkan buku pertama Anda dengan menekan tombol + di bawah'
                                : 'Tidak ada buku yang sesuai dengan pencarian "$_searchQuery"',
                            onRefresh: _loadBooks,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _filteredBooks.length,
                            itemBuilder: (context, index) {
                              final book = _filteredBooks[index];
                              return BookCard(
                                book: book,
                                onTap: () async {
                                  await Get.to(() => DetailBookScreen(book: book));
                                  _loadBooks();
                                  _loadStatistics();
                                },
                                onEdit: () async {
                                  await Get.to(() => EditBookScreen(book: book));
                                  _loadBooks();
                                  _loadStatistics();
                                },
                                onDelete: () => _handleDelete(book),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.to(() => const AddBookScreen());
          _loadBooks();
          _loadStatistics();
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