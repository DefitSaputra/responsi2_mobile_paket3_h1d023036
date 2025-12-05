import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // PENTING: GANTI DENGAN DATA DARI SUPABASE SETTINGS > API KAMU
  await Supabase.initialize(
    url: 'https://agzqenfgfdrdqozeqfqb.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFnenFlbmZnZmRyZHFvemVxZnFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ5NTcxMjAsImV4cCI6MjA4MDUzMzEyMH0.KXs4Qoc4eKkSlk6HwsOhGY3w1xK_lWzx7k9Pfv10Jeg', 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deef Books',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Konfigurasi Warna: Coklat (Deef Books Theme)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D4037), // Dark Coffee
          primary: const Color(0xFF5D4037),
          secondary: const Color(0xFF8D6E63),
          surface: const Color(0xFFF5F5F5), // Cream Background
          onPrimary: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5D4037),
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5D4037), width: 2)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5D4037),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}