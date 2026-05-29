import 'package:edujarkom/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edujarkom/services/auth_service.dart';

// 1. IMPORT SEMUA HALAMAN ADMIN KITA
import 'package:edujarkom/screens/admin/dashboard_admin.dart';
import 'package:edujarkom/screens/admin/kelola_akun_screen.dart';
import 'package:edujarkom/screens/admin/monitoring_aktivitas_screen.dart';
import 'package:edujarkom/screens/admin/profile_admin.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  int _selectedIndex = 0;

  // 2. PERBARUI JUDUL (4 JUDUL)
  static const List<String> _appBarTitles = [
    'Dashboard Admin',
    'Kelola Akun Pengguna',
    'Monitoring Aktivitas',
    'Profil Admin',
  ];

  // 3. PERBARUI HALAMAN (4 HALAMAN)
  static const List<Widget> _pages = [
    DashboardAdmin(),
    KelolaAkunScreen(),
    MonitoringAktivitasScreen(),
    ProfileAdminScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Konfirmasi Keluar",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Batal",
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthService>().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Keluar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        // --- TOMBOL KELUAR DI ATAS KANAN ---
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context),
            tooltip: 'Keluar',
            color: Colors.white,
          ),
        ],
        // -------------------------
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // 4. PERBARUI BOTTOMNAV (4 ITEM)
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Kelola Akun',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Monitoring',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}