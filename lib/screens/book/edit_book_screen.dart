import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;
  
  const EditBookScreen({super.key, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookService _bookService = BookService();
  
  late TextEditingController _judulController;
  late TextEditingController _hargaController;
  late TextEditingController _jumlahController;
  late TextEditingController _tanggalMasukController;
  late TextEditingController _volumeController;
  late TextEditingController _penulisController;
  late TextEditingController _penerbitController;
  
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    
    _judulController = TextEditingController(text: widget.book.judul);
    _hargaController = TextEditingController(
      text: NumberFormat('#,###', 'id_ID')
          .format(widget.book.harga)
          .replaceAll(',', '.'),
    );
    _jumlahController = TextEditingController(text: widget.book.jumlah.toString());
    _tanggalMasukController = TextEditingController(text: widget.book.tanggalMasuk);
    _volumeController = TextEditingController(text: widget.book.volume.toString());
    _penulisController = TextEditingController(text: widget.book.penulis);
    _penerbitController = TextEditingController(text: widget.book.penerbit);
    
    // Parse tanggal
    _selectedDate = Helpers.parseDate(widget.book.tanggalMasuk);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _hargaController.dispose();
    _jumlahController.dispose();
    _tanggalMasukController.dispose();
    _volumeController.dispose();
    _penulisController.dispose();
    _penerbitController.dispose();
    super.dispose();
  }

  void _selectDate() {
    if (_isLoading) return; 
    _showDatePicker();
  }
  
  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalMasukController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final updatedBook = Book(
        id: widget.book.id,
        judul: _judulController.text.trim(),
        harga: int.parse(_hargaController.text.replaceAll('.', '')),
        jumlah: int.parse(_jumlahController.text),
        tanggalMasuk: _tanggalMasukController.text,
        volume: int.parse(_volumeController.text),
        penulis: _penulisController.text.trim(),
        penerbit: _penerbitController.text.trim(),
      );
      
      final result = await _bookService.updateBook(widget.book.id!, updatedBook);
      
      setState(() => _isLoading = false);
      
      if (result['success']) {
        Get.snackbar(
          'Buku Berhasil Diperbarui! ✅',
          'Buku "${_judulController.text.trim()}" telah diperbarui',
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
        
        await Future.delayed(const Duration(milliseconds: 1000));
        
        if (mounted) {          
          Get.back(); 
        }
      } else {
        Get.snackbar(
          'Gagal Memperbarui Buku ❌',
          result['message'] ?? 'Terjadi kesalahan saat memperbarui buku',
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error ❌',
        'Terjadi kesalahan: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Buku - Deef Books'),
        leading: _isLoading
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning.withOpacity(0.1),
                      AppColors.warning.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mode Edit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mengedit: "${widget.book.judul}"',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              CustomTextField(
                controller: _judulController,
                label: 'Judul Buku',
                hint: 'Masukkan judul buku',
                prefixIcon: Icons.book,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.fieldRequired('Judul buku');
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _penulisController,
                label: 'Penulis',
                hint: 'Masukkan nama penulis',
                prefixIcon: Icons.person,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.fieldRequired('Penulis');
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _penerbitController,
                label: 'Penerbit',
                hint: 'Masukkan nama penerbit',
                prefixIcon: Icons.business,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.fieldRequired('Penerbit');
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _volumeController,
                label: 'Volume',
                hint: 'Masukkan volume (angka)',
                prefixIcon: Icons.format_list_numbered,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.fieldRequired('Volume');
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _hargaController,
                label: 'Harga Satuan (Rp)',
                hint: 'Masukkan harga',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.isEmpty) {
                      return newValue;
                    }
                    final number = int.parse(newValue.text);
                    final formatted = NumberFormat('#,###', 'id_ID').format(number);
                    return TextEditingValue(
                      text: formatted.replaceAll(',', '.'),
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.fieldRequired('Harga');
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _jumlahController,
                label: 'Jumlah Stok',
                hint: 'Masukkan jumlah stok',
                prefixIcon: Icons.inventory_2,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.fieldRequired('Jumlah stok');
                  }
                  if (int.parse(value) < 1) {
                    return 'Jumlah minimal 1';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: _tanggalMasukController,
                label: 'Tanggal Masuk',
                hint: 'Pilih tanggal',
                prefixIcon: Icons.calendar_today,
                readOnly: true,
                onTap: _selectDate,
                suffixIcon: Icons.arrow_drop_down,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppConstants.fieldRequired('Tanggal masuk');
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Update Button
              CustomButton(
                text: 'Update Buku',
                // ✅ Fix: Gunakan anonymous function
                onPressed: () {
                  if (!_isLoading) _handleSubmit();
                }, 
                isLoading: _isLoading,
                icon: Icons.save,
              ),
              
              const SizedBox(height: 16),
              
              // Cancel Button
              CustomButton(
                text: 'Batal',               
                onPressed: _isLoading ? () {} : () => Get.back(),
                isOutlined: true,
                icon: Icons.close,
              ),
            ],
          ),
        ),
      ),
    );
  }
}