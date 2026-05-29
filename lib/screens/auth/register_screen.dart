// (Ganti seluruh isi file lib/screens/auth/register_screen.dart dengan ini)

import 'package:edujarkom/main.dart'; // Untuk AppColors
import 'package:edujarkom/services/auth_service.dart';
import 'package:edujarkom/services/firestore_service.dart'; // <-- 1. TAMBAHKAN IMPORT
import 'package:edujarkom/widgets/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- 2. TAMBAHKAN IMPORT
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // --- 3. FUNGSI INI DIPERBARUI ---
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak sama")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);

      // 1. Buat akun di Auth (panggil method baru)
      final cred = await authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2. Jika sukses, simpan data ke Firestore (karena service tidak lagi melakukannya)
      if (cred?.user != null) {
        await firestoreService.simpanUserData(
          uid: cred!.user!.uid,
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          role: 'Siswa', // Tetap 'Siswa'
        );
      }

      // 3. Kembali ke halaman login jika sukses
      if (mounted) {
        Navigator.pop(context);
      }

    } on FirebaseAuthException catch (e) {
      // Tangani error jika gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Gagal mendaftar")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  // ------------------------------------

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topSpacing = MediaQuery.of(context).size.height * 0.05;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: topSpacing),
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 16),
                Text(
                  'Daftar Akun Baru',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 40),

                // Username
                CustomTextField(
                  controller: _usernameController,
                  hintText: 'Nama Pengguna',
                  prefixIcon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Username wajib diisi";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Email wajib diisi";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Kata Sandi',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Kata Sandi Wajib diisi";
                    if (v.length < 6) return "Kata Sandi minimal 6 karakter";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Konfirmasi Kata Sandi',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Konfirmasi Kata Sandi Wajib diisi";
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Tombol Register
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Daftar',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                const SizedBox(height: 24),

                // Link ke Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Masuk Sekarang',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}