// (Salin dan ganti seluruh isi file lib/main.dart dengan ini)

import 'package:edujarkom/screens/splash/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// === IMPORT DARI PROYEKMU ===
import 'firebase_options.dart';
import 'package:edujarkom/screens/auth/auth_gate.dart';
import 'package:edujarkom/services/auth_service.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:edujarkom/services/storage_service.dart';

// --- 1. TAMBAHKAN IMPORT INI ---
import 'package:edujarkom/screens/splash/splash_screen.dart';

// ✅ Tambahkan import halaman admin
import 'package:edujarkom/screens/admin/tambah_akun_screen.dart';
import 'package:edujarkom/screens/admin/dashboard_admin.dart';

// ✅ Tambahkan import halaman auth (kalau digunakan)
import 'package:edujarkom/screens/auth/login_screen.dart';
import 'package:edujarkom/screens/auth/register_screen.dart';

// Palet warna sesuai desain
class AppColors {
  static const Color primaryBlue = Color(0xFF0D2A6F);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF333333);
  static const Color lightGrey = Color(0xFFF0F0F0);
  static const Color yellowAccent = Color(0xFFF9E852);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<StorageService>(create: (_) => StorageService()),

        // Stream untuk login state
        StreamProvider<User?>(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'EDUJARKOM',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: GoogleFonts.poppins().fontFamily,
          primaryColor: AppColors.primaryBlue,
          scaffoldBackgroundColor: AppColors.whiteColor,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.whiteColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.primaryBlue),
            titleTextStyle: GoogleFonts.poppins(
              color: AppColors.darkText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.whiteColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
            filled: true,
            fillColor: AppColors.whiteColor,
          ),
        ),

        // --- 2. UBAH BARIS INI ---
        // ✅ Entry point aplikasi
        home: const WelcomeScreen(), // <-- Ganti dari AuthGate()
        // -------------------------

        // ✅ Daftar routes
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboardAdmin': (context) => const DashboardAdmin(),
          '/tambahAkun': (context) =>
              const TambahAkunScreen(), // ✅ ini yang wajib
        },
      ),
    );
  }
}
