import 'package:edujarkom/models/user_model.dart';
import 'package:edujarkom/screens/admin/home_admin.dart';
import 'package:edujarkom/screens/auth/login_screen.dart'; // Untuk fallback logout
import 'package:edujarkom/screens/siswa/siswa_main_screen.dart';
import 'package:edujarkom/services/auth_service.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORT BARU UNTUK GURU ---
import 'package:edujarkom/screens/guru/home_guru.dart'; 
// -------------------------------

class RoleRedirector extends StatelessWidget {
  const RoleRedirector({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final String currentUserId = authService.currentUserId!;

    return FutureBuilder<UserModel?>(
      // Kita panggil getUser(currentUserId)
      future: firestoreService.getUser(currentUserId),
      builder: (context, snapshot) {
        // --- Tampilkan loading ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // --- Tampilkan error (jika ada) ---
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }

        // --- Cek data user (ini bagian yang kita perbaiki) ---
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;

          // Arahkan berdasarkan role
          switch (user.role) {
            case 'Siswa':
              return const SiswaMainScreen(); // Arahkan ke Dashboard Siswa

            // ========================================================
            // === PERUBAHAN DI SINI ===
            // ========================================================
            case 'Guru':
              return const HomeGuruScreen(); // <-- Arahkan ke Dashboard Guru
            // ========================================================

            case 'Admin':
            return const HomeAdminScreen();

            default:
              return const Scaffold(
                body: Center(child: Text("Role tidak dikenal!")),
              );
          }
        }

        // --- Jika data user null (tidak ditemukan di Firestore) ---
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Data user tidak ditemukan."),
                const Text("Silakan login kembali."),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Logout paksa, lalu arahkan ke LoginScreen
                    context.read<AuthService>().signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text("Ke Halaman Login"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

