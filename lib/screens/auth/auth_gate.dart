import 'package:edujarkom/screens/auth/login_screen.dart';
import 'package:edujarkom/screens/auth/role_redirector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita "tonton" status login dari StreamProvider
    final User? user = context.watch<User?>();

    // Cek apakah data user sudah ada (logged in) atau belum (null)
    if (user == null) {
      // User belum login
      return const LoginScreen();
    } else {
      // User sudah login, biarkan RoleRedirector yang bekerja
      return const RoleRedirector();
    }
  }
}
