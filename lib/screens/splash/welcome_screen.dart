import 'package:flutter/material.dart';
import 'package:edujarkom/main.dart'; // Impor untuk mengakses AppColors
import 'package:google_fonts/google_fonts.dart';

// TAMBAHKAN IMPORT INI:
import 'package:edujarkom/screens/auth/auth_gate.dart';

// Pastikan nama class-nya adalah WelcomeScreen
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 62, 109, 220), // Background biru tua
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // Logo
              Image.asset(
                'assets/images/logo.png', // Pastikan path ini benar
                height: size.width * 0.35, // Ukuran logo responsif
              ),
              const SizedBox(height: 16),
              Text(
                'EDUJARKOM',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.whiteColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const Spacer(flex: 1),

              // Teks Selamat Datang (Sesuai Mockup)
              Text(
                'Selamat Datang di Edujarkom',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.whiteColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Platform pembelajaran interaktif untuk guru dan siswa dalam memahami dunia jaringan komputer',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.whiteColor.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              
              const Spacer(flex: 3),

              // Tombol Mulai
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.whiteColor, // Tombol putih
                  foregroundColor: AppColors.primaryBlue, // Teks biru
                ),
                onPressed: () {
                  // === PERUBAHAN DI SINI ===
                  // Arahkan ke AuthGate, bukan print() lagi
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthGate()),
                  );
                },
                child: const Text('Mulai'),
              ),
              
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
