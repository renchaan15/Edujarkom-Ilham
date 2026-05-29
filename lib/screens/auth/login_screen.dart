import 'package:edujarkom/main.dart'; // Untuk AppColors
import 'package:edujarkom/screens/auth/register_screen.dart';
import 'package:edujarkom/services/auth_service.dart';
import 'package:edujarkom/widgets/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// [PENTING] Tambahkan import AuthGate
import 'package:edujarkom/screens/auth/auth_gate.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- FUNGSI LOGIN DIPERBARUI ---
  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      // 1. Proses Login ke Firebase
      await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2. [PERBAIKAN UTAMA]
      // Jika sukses, JANGAN diam saja. Paksa pindah ke AuthGate.
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
      
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "Gagal Masuk"),
            backgroundColor: Colors.red,
          )
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  // ------------------------------------

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fitur lupa password belum tersedia.")),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Image.asset('assets/images/logo.png', height: 100),
                const SizedBox(height: 16),
                Text(
                  'Masuk ke Akun Anda',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 40),
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
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Kata Sandi',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Kata Sandi Wajib diisi";
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _handleForgotPassword,
                    child: Text(
                      '',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _handleLogin,
                        child: Text(
                          'Masuk',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Tidak punya akun? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Daftar Sekarang',
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