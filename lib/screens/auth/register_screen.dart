import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final result = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );
      
      setState(() => _isLoading = false);
      
      if (result['success']) {
        // ✅ SUCCESS: Tampilkan Pop-up (Dialog) Berhasil
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Sukses
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle, 
                    color: AppColors.success, 
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Judul
                const Text(
                  'Registrasi Berhasil! 🎉',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Pesan
                Text(
                  result['message'] ?? 'Akun Anda berhasil dibuat. Silakan login untuk melanjutkan.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Tombol ke Login
                CustomButton(
                  text: 'Login Sekarang',
                  onPressed: () {
                    Get.back(); // Tutup Dialog
                    Get.back(); // Kembali ke halaman Login (Pop screen register)
                  },
                  height: 45,
                ),
              ],
            ),
          ),
          barrierDismissible: false, // User tidak bisa menutup dialog dengan tap di luar
        );
      } else {
        // ❌ ERROR: Show error snackbar
        Get.snackbar(
          'Registrasi Gagal ❌',
          result['message'] ?? 'Terjadi kesalahan saat mendaftar',
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          duration: const Duration(seconds: 4),
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      // ❌ CATCH ERROR
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registrasi - Deef Books'),
        elevation: 0,
        // ✅ Disable back button saat loading
        leading: _isLoading 
          ? null 
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Isi form di bawah untuk membuat akun',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Full Name Field
                CustomTextField(
                  controller: _fullNameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap Anda',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  enabled: !_isLoading, // ✅ Disable saat loading
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.fieldRequired('Nama lengkap');
                    }
                    if (value.length < 3) {
                      return 'Nama lengkap minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Masukkan email Anda',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading, // ✅ Disable saat loading
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.fieldRequired('Email');
                    }
                    if (!Helpers.isValidEmail(value)) {
                      return AppConstants.errorInvalidEmail;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Masukkan password (min. 6 karakter)',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  enabled: !_isLoading, // ✅ Disable saat loading
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.fieldRequired('Password');
                    }
                    if (value.length < AppConstants.minPasswordLength) {
                      return AppConstants.errorPasswordTooShort;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Password',
                  hint: 'Masukkan ulang password Anda',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  enabled: !_isLoading, // ✅ Disable saat loading
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppConstants.fieldRequired('Konfirmasi password');
                    }
                    if (value != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Register Button
                CustomButton(
                  text: 'Daftar Sekarang',
                  // PERBAIKAN DI SINI: Menggunakan closure () { ... }
                  onPressed: _isLoading 
                      ? () {} 
                      : () {
                          _handleRegister();
                        }, 
                  isLoading: _isLoading,
                  icon: Icons.person_add_outlined,
                ),
                
                const SizedBox(height: 24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        Get.back();
                      },
                      child: Text(
                        'Login di sini',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          // ✅ Dim saat loading
                          color: _isLoading 
                            ? AppColors.textSecondary.withOpacity(0.5)
                            : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Terms & Privacy
                Center(
                  child: Text(
                    'Dengan mendaftar, Anda menyetujui\nSyarat & Ketentuan kami',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}