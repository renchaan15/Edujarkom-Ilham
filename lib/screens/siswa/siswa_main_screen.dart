import 'package:edujarkom/main.dart';
import 'package:edujarkom/screens/siswa/dashboard_siswa.dart' as dashboard;
import 'package:edujarkom/screens/siswa/daftar_materi_siswa.dart' as materi;
import 'package:edujarkom/screens/siswa/daftar_quiz_siswa.dart' as quiz;
import 'package:edujarkom/screens/siswa/profile_siswa.dart' as profile;
import 'package:flutter/material.dart';
import 'package:edujarkom/screens/siswa/profile_siswa.dart';


class SiswaMainScreen extends StatefulWidget {
  const SiswaMainScreen({super.key});

  @override
  State<SiswaMainScreen> createState() => _SiswaMainScreenState();
}

class _SiswaMainScreenState extends State<SiswaMainScreen> {
  int _selectedIndex = 0;

  // PERBAIKAN: Pastikan menggunakan class yang benar dari profile_siswa.dart
  static final List<Widget> _widgetOptions = <Widget>[
    const dashboard.DashboardSiswa(), // Indeks 0 (Home)
    const materi.DaftarMateriSiswa(), // Indeks 1 (Materi)
    const quiz.DaftarQuizSiswa(),     // Indeks 2 (Quiz)
    const profile.ProfileSiswaPage(), // PERBAIKAN: Pastikan nama class sesuai
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              // PERBAIKAN: Ganti withOpacity dengan withAlpha untuk menghindari deprecation
              color: Colors.grey.withAlpha(25), // 0.1 opacity equivalent
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books_outlined),
                activeIcon: Icon(Icons.library_books_rounded),
                label: 'Materi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_outlined),
                activeIcon: Icon(Icons.quiz_rounded),
                label: 'Kuis',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            showUnselectedLabels: true,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}