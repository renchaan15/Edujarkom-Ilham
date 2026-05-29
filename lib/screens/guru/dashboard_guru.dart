import 'package:flutter/material.dart';
import 'package:edujarkom/services/auth_service.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:edujarkom/models/materi_model.dart';
import 'package:provider/provider.dart';
import 'package:edujarkom/models/user_model.dart';
import 'package:edujarkom/screens/guru/home_guru.dart';

class DashboardGuru extends StatefulWidget {
  const DashboardGuru({super.key});

  @override
  State<DashboardGuru> createState() => _DashboardGuruState();
}

class _DashboardGuruState extends State<DashboardGuru> {
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final String? currentUserId = authService.currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB), // Background abu-abu sangat muda bersih
      
      // [PERUBAHAN 1] AppBar dihapus total
      
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. BANNER STATIC (Gabungan Profil & Sapaan)
                _buildStaticBanner(context, firestoreService, currentUserId),
                const SizedBox(height: 24),

                // 2. STATISTIK REAL-TIME
                _buildSectionHeader("Statistik Cepat"),
                const SizedBox(height: 12),
                _buildQuickStatsSection(context, firestoreService),
                const SizedBox(height: 24),

                // 3. MATERI TERBARU
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Materi Terbaru",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final homeState = context.findAncestorStateOfType<HomeGuruScreenState>();
                        if (homeState != null) homeState.onItemTapped(1); 
                      },
                      child: const Text("Lihat Semua"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildMateriSection(context, firestoreService),
                const SizedBox(height: 24),

                // 4. AKSI CEPAT
                _buildSectionHeader("Aksi Cepat"),
                const SizedBox(height: 12),
                _buildQuickActionsSection(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // ==================================================
  // 1. Banner Static (Gabungan Sapaan & Profil)
  // ==================================================
  Widget _buildStaticBanner(BuildContext context, FirestoreService firestoreService, String? userId) {
    return StreamBuilder<UserModel?>(
      stream: firestoreService.getUserStream(userId ?? ''),
      builder: (context, snapshot) {
        String userName = "Guru";
        String? photoUrl;
        
        if (snapshot.hasData && snapshot.data != null) {
          userName = snapshot.data!.username;
          photoUrl = snapshot.data!.profileImageUrl;
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D2A6F).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D2A6F),
                Color(0xFF4A78D0),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Elemen Dekoratif Background
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -40,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              // Konten Utama Banner
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Bagian Teks (Kiri)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Halo, $userName! 👋",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Selamat datang kembali. Siap mengelola kelas hari ini?",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),

                    // [PERUBAHAN 2] Foto Profil di Kanan
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 32, 
                        backgroundColor: Colors.white,
                        backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null,
                        child: (photoUrl == null || photoUrl.isEmpty)
                            ? Icon(Icons.person, color: Colors.blue.shade700, size: 32)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  // ==================================================
  // 2. Statistik Cepat (Grid dengan Warna Soft)
  // ==================================================
  Widget _buildQuickStatsSection(BuildContext context, FirestoreService firestoreService) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4, 
      children: [
        StatCardWithStream<int>(
          title: 'Total Materi',
          subtitle: 'Modul aktif',
          icon: Icons.menu_book_rounded,
          color: Colors.blue, // Warna Ikon
          backgroundColor: Colors.blue.shade50, // [PERUBAHAN 3] Warna Latar Soft
          stream: firestoreService.getTotalMateri(),
          dataToString: (data) => data.toString(),
        ),
        StatCardWithStream<int>(
          title: 'Siswa Aktif',
          subtitle: 'Terdaftar',
          icon: Icons.people_alt_rounded,
          color: Colors.green,
          backgroundColor: Colors.green.shade50, // [PERUBAHAN 3] Warna Latar Soft
          stream: firestoreService.getJumlahSiswaAktif(),
          dataToString: (data) => data.toString(),
        ),
        StatCardWithStream<int>(
          title: 'Total Kuis',
          subtitle: 'Kuis dibuat',
          icon: Icons.quiz_rounded,
          color: Colors.orange,
          backgroundColor: Colors.orange.shade50, // [PERUBAHAN 3] Warna Latar Soft
          stream: firestoreService.getTotalQuiz(),
          dataToString: (data) => data.toString(),
        ),
        StatCardWithStream<double>(
          title: 'Rata-rata',
          subtitle: 'Nilai siswa',
          icon: Icons.analytics_rounded,
          color: Colors.purple,
          backgroundColor: Colors.purple.shade50, // [PERUBAHAN 3] Warna Latar Soft
          stream: firestoreService.getNilaiRataRataSiswa(),
          dataToString: (data) => data.toStringAsFixed(1),
        ),
      ],
    );
  }

  // ==================================================
  // 3. Materi Terbaru (Warna Soft)
  // ==================================================
  Widget _buildMateriSection(BuildContext context, FirestoreService firestoreService) {
    return StreamBuilder<List<MateriModel>>(
      stream: firestoreService.getMateriList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        List<MateriModel> materiList = snapshot.data ?? [];
        if (materiList.length > 4) materiList = materiList.sublist(0, 4);

        if (materiList.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text("Belum ada materi", style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: materiList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1, 
          ),
          itemBuilder: (context, index) {
            return _buildMateriCard(materiList[index]);
          },
        );
      },
    );
  }

  Widget _buildMateriCard(MateriModel materi) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // [PERUBAHAN 3] Background Soft Biru
        color: Colors.blue.shade50, 
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Colors.blue.shade700,
                    size: 28, 
                  ),
                ),
                const Spacer(),
                Text(
                  materi.judul,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Modul",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade800.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================================================
  // 4. Aksi Cepat (Warna Soft)
  // ==================================================
  Widget _buildQuickActionsSection(BuildContext context) {
    final actions = [
      {
        'title': 'Tambah Materi', 
        'icon': Icons.add_circle_outline_rounded, 
        'color': Colors.blue,
        'action': 'materi'
      },
      {
        'title': 'Buat Kuis', 
        'icon': Icons.quiz_outlined, 
        'color': Colors.teal,
        'action': 'kuis'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2, 
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return _buildQuickActionCard(context, actions[index]);
      },
    );
  }

  Widget _buildQuickActionCard(BuildContext context, Map<String, dynamic> action) {
    final Color baseColor = action['color'] as Color;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // [PERUBAHAN 3] Background Soft sesuai tema tombol
        color: baseColor.withOpacity(0.1), 
        border: Border.all(color: baseColor.withOpacity(0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final homeState = context.findAncestorStateOfType<HomeGuruScreenState>();
          if (homeState != null) {
            if (action['action'] == 'materi') {
              homeState.showModulForm(context, null);
            } else if (action['action'] == 'kuis') {
              homeState.showQuizForm(context, null);
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                action['icon'] as IconData,
                color: baseColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              action['title'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: baseColor.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================
// Helper Widget: Stat Card (Custom Color)
// ==================================================
class StatCardWithStream<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color backgroundColor; // Parameter baru untuk warna background
  final Stream<T> stream;
  final String Function(T) dataToString;

  const StatCardWithStream({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.stream,
    required this.dataToString,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        String displayValue = "0";
        if (snapshot.connectionState == ConnectionState.waiting) {
          displayValue = "...";
        } else if (snapshot.hasData) {
          displayValue = dataToString(snapshot.data as T);
        }

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor, // [PERUBAHAN 3] Menggunakan warna soft
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon, 
                        color: color, 
                        size: 24 
                      ),
                    ),
                    Text(
                      displayValue,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color.withOpacity(0.9), 
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}