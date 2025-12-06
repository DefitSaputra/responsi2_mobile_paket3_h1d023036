import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../widgets/custom_button.dart';
import '../../utils/helpers.dart';
import 'edit_book_screen.dart';

class DetailBookScreen extends StatefulWidget {
  final Book book;
  
  const DetailBookScreen({super.key, required this.book});

  @override
  State<DetailBookScreen> createState() => _DetailBookScreenState();
}

class _DetailBookScreenState extends State<DetailBookScreen> {
  final BookService _bookService = BookService();
    
  late Stream<Book?> _bookStream;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();    
    _bookStream = _bookService.getBookByIdStream(widget.book.id!);
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus buku ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      
      final result = await _bookService.deleteBook(id);
      
      if (mounted) {
        setState(() => _isDeleting = false);
      }
      
      if (result['success']) {
        Get.snackbar(
          'Berhasil',
          result['message'],
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );        
        Get.back(); 
      } else {
        Get.snackbar(
          'Error',
          result['message'],
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Book?>(
      stream: _bookStream,
      initialData: widget.book, 
      builder: (context, snapshot) {       
        if (snapshot.hasData && snapshot.data == null) {
           return Scaffold(
             backgroundColor: AppColors.background,
             appBar: AppBar(
               title: const Text('Detail Buku'),
               // ✅ Tetap kasih tombol back biar user tidak terjebak
               leading: IconButton(
                 icon: const Icon(Icons.arrow_back),
                 onPressed: () => Get.back(),
               ),
             ),
             body: const Center(
               child: Text(
                 "Buku tidak ditemukan", 
                 style: TextStyle(color: AppColors.textSecondary),
               )
             ),
           );
        }
      
        final book = snapshot.data ?? widget.book;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Buku - Deef Books'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // ✅ Navigasi ke Edit
                  Get.to(() => EditBookScreen(book: book));
                },
                tooltip: 'Edit',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _isDeleting ? null : () => _handleDelete(book.id!),
                tooltip: 'Hapus',
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [               
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration( 
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        book.judul,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Volume ${book.volume}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Buku',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildDetailItem(
                        icon: Icons.person,
                        label: 'Penulis',
                        value: book.penulis,
                        color: AppColors.primary,
                      ),
                      
                      _buildDetailItem(
                        icon: Icons.business,
                        label: 'Penerbit',
                        value: book.penerbit,
                        color: AppColors.secondary,
                      ),
                      
                      _buildDetailItem(
                        icon: Icons.attach_money,
                        label: 'Harga Satuan',
                        value: Helpers.formatCurrency(book.harga),
                        color: AppColors.success,
                      ),
                      
                      _buildDetailItem(
                        icon: Icons.inventory_2,
                        label: 'Jumlah Stok',
                        value: '${book.jumlah} buah',
                        color: AppColors.info,
                      ),
                      
                      _buildDetailItem(
                        icon: Icons.calendar_today,
                        label: 'Tanggal Masuk',                       
                        value: Helpers.formatDate(book.tanggalMasuk),
                        color: AppColors.warning,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Total Nilai Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent.withOpacity(0.8),
                              AppColors.secondary.withOpacity(0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Total Nilai Inventaris',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              Helpers.formatCurrency(book.totalValue),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${Helpers.formatCurrency(book.harga)} × ${book.jumlah} buah',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Action Buttons
                      CustomButton(
                        text: 'Edit Buku',
                        onPressed: () {
                          Get.to(() => EditBookScreen(book: book));
                        },
                        icon: Icons.edit,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      CustomButton(
                        text: 'Hapus Buku',
                        onPressed: () {
                          if (!_isDeleting) _handleDelete(book.id!);
                        },
                        isLoading: _isDeleting,
                        backgroundColor: AppColors.error,
                        icon: Icons.delete,
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}