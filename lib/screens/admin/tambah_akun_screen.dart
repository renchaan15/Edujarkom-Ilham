import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edujarkom/services/auth_service.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:edujarkom/widgets/custom_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TambahAkunScreen extends StatefulWidget {
  const TambahAkunScreen({super.key});

  @override
  State<TambahAkunScreen> createState() => _TambahAkunScreenState();
}

class _TambahAkunScreenState extends State<TambahAkunScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  
  String _selectedRole = 'Siswa';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _tambahAkun() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();
    final role = _selectedRole;

    try {
      // 1. Buat akun di Auth
      final cred = await authService.createUserByAdmin(
        email,
        password,
      );

      // 2. Jika sukses, simpan data ke Firestore
      if (cred?.user != null) {
        await firestoreService.simpanUserData(
          uid: cred!.user!.uid,
          email: email,
          username: username,
          role: role,
        );
      }

      // 3. Tampilkan pesan sukses dan kembali
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Akun berhasil dibuat'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "Gagal membuat akun"),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Akun Baru',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(0, 242, 34, 34),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Buat Akun Pengguna',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Isi form berikut untuk menambahkan akun baru',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // === Username ===
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Masukkan username',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Masukkan username' : null,
                      ),
                    ),

                    // === Email ===
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'contoh@email.com',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            value == null || !value.contains('@') ? 'Email tidak valid' : null,
                      ),
                    ),

                    // === Password ===
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Minimal 6 karakter',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey.shade500,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.length < 6 ? 'Minimal 6 karakter' : null,
                      ),
                    ),

                    // === Pilih Role ===
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Peran Pengguna',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.people_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Siswa',
                            child: Text('Siswa'),
                          ),
                          DropdownMenuItem(
                            value: 'Guru',
                            child: Text('Guru'),
                          ),
                          DropdownMenuItem(
                            value: 'Admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // === Tombol Simpan ===
              Container(
                width: double.infinity,
                height: 56,
                margin: const EdgeInsets.only(top: 16),
                child: _isLoading
                    ? ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Membuat Akun...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _tambahAkun,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                        child: const Text(
                          'Buat Akun',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}