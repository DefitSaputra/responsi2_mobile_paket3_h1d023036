
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Get current user stream (untuk listen perubahan auth state)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // ==================== REGISTER ====================
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? '',
        },
      );

      if (response.user == null) {
        return {
          'success': false,
          'message': 'Registrasi gagal, silakan coba lagi',
        };
      }

      // Jika berhasil, profile akan otomatis dibuat lewat trigger di database
      return {
        'success': true,
        'message': 'Registrasi berhasil! Silakan login',
        'user': response.user,
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // ==================== LOGIN ====================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return {
          'success': false,
          'message': 'Login gagal, silakan coba lagi',
        };
      }

      return {
        'success': true,
        'message': 'Login berhasil!',
        'user': response.user,
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // ==================== LOGOUT ====================
  Future<Map<String, dynamic>> logout() async {
    try {
      await _supabase.auth.signOut();
      return {
        'success': true,
        'message': 'Logout berhasil',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal logout: ${e.toString()}',
      };
    }
  }

  // ==================== GET USER PROFILE ====================
  Future<UserModel?> getUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // ==================== UPDATE USER PROFILE ====================
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'User tidak ditemukan',
        };
      }

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _supabase.from('profiles').update(updates).eq('id', user.id);

      return {
        'success': true,
        'message': 'Profile berhasil diperbarui',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memperbarui profile: ${e.toString()}',
      };
    }
  }

  // ==================== RESET PASSWORD ====================
  Future<Map<String, dynamic>> resetPassword({
    required String email,
  }) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return {
        'success': true,
        'message': 'Email reset password telah dikirim',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // ==================== CHANGE PASSWORD ====================
  Future<Map<String, dynamic>> changePassword({
    required String newPassword,
  }) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return {
        'success': true,
        'message': 'Password berhasil diubah',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.message),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // ==================== HELPER: Error Message ====================
  String _getAuthErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email atau password salah';
    } else if (error.contains('User already registered')) {
      return 'Email sudah terdaftar';
    } else if (error.contains('Email not confirmed')) {
      return 'Email belum dikonfirmasi';
    } else if (error.contains('Password should be at least 6 characters')) {
      return 'Password minimal 6 karakter';
    } else if (error.contains('Unable to validate email address')) {
      return 'Format email tidak valid';
    } else if (error.contains('Email rate limit exceeded')) {
      return 'Terlalu banyak percobaan, silakan coba lagi nanti';
    }
    return error;
  }
}