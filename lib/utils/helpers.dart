import 'package:intl/intl.dart';

class Helpers {
  static String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Format angka dengan separator
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(number);
  }

  // Format tanggal dari string atau DateTime
  static String formatDate(dynamic date, {String format = 'dd/MM/yyyy'}) {
    try {
      if (date == null || date == '') return '-';
      
      if (date is String && date.contains('/')) {
        return date;
      }

      DateTime dateTime;
      if (date is String) {       
        try {
          dateTime = DateTime.parse(date);
        } catch (e) {         
          return date; 
        }
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return '-';
      }        
      final formatter = DateFormat(format); 
      return formatter.format(dateTime);
    } catch (e) {
      return '-';
    }
  }

  static String getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(now);
  }

  static DateTime? parseDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalizeFirst(word)).join(' ');
  }

  static double calculatePercentage(int part, int total) {
    if (total == 0) return 0;
    return (part / total) * 100;
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static void debounce(
    Function() action, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    Future.delayed(delay, action);
  }
}