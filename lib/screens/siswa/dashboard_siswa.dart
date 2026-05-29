import 'package:edujarkom/main.dart';
import 'package:flutter/material.dart';
import 'package:edujarkom/services/auth_service.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:edujarkom/models/hasil_quiz_model.dart';
import 'package:edujarkom/models/materi_model.dart';
import 'package:edujarkom/models/user_model.dart';
import 'package:edujarkom/screens/siswa/detail_materi_siswa.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// [PENTING] Tambahkan import AuthGate
import 'package:edujarkom/screens/auth/auth_gate.dart';

class DashboardSiswa extends StatelessWidget {
  const DashboardSiswa({super.key});

  // --- FUNGSI LOGOUT DIPERBARUI ---
  void _showLogoutDialog(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text("Konfirmasi Keluar"),
            ],
          ),
          content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                try {
                  await authService.signOut();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Berhasil Keluar"),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // [PERBAIKAN UTAMA]
                    // Arahkan ke AuthGate, BUKAN '/login'
                    // Ini mereset state aplikasi agar siap login ulang
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthGate()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Gagal Keluar: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text("Keluar"),
            ),
          ],
        );
      },
    );
  }
  // --------------------------------

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        elevation: 1,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 22,
                ),
              ),
              onPressed: () => _showLogoutDialog(context),
              tooltip: "Keluar Akun",
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(context, firestoreService),
              const SizedBox(height: 24),
              _buildQuickStatsSection(context, firestoreService),
              const SizedBox(height: 24),
              _buildMateriSection(context, firestoreService),
              const SizedBox(height: 24),
              _buildAchievementSection(context, firestoreService),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Bagian Widget Helper di bawah ini TIDAK BERUBAH, copy-paste dari kode sebelumnya) ...
  Widget _buildWelcomeSection(
      BuildContext context, FirestoreService firestoreService) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final String? currentUserId = authService.currentUserId;

    return StreamBuilder<UserModel?>(
      stream: currentUserId != null
          ? firestoreService.getUserStream(currentUserId)
          : null,
      builder: (context, snapshot) {
        final username = snapshot.data?.username ?? "Siswa";
        final currentHour = DateTime.now().hour;
        String greeting;

        if (currentHour < 12) {
          greeting = "Selamat Pagi";
        } else if (currentHour < 15) {
          greeting = "Selamat Siang";
        } else if (currentHour < 19) {
          greeting = "Selamat Sore";
        } else {
          greeting = "Selamat Malam";
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                Color(0xFF5D8BF4),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Mari terus belajar dan raih prestasi terbaik!",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStatsSection(
      BuildContext context, FirestoreService firestoreService) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final String? currentUserId = authService.currentUserId;

    return StreamBuilder<List<HasilQuizModel>>(
      stream: currentUserId != null
          ? firestoreService.getHasilQuizForSiswa(currentUserId)
          : Stream.value([]),
      builder: (context, snapshot) {
        final quizCount = snapshot.data?.length ?? 0;
        final avgScore = snapshot.data?.isNotEmpty == true
            ? snapshot.data!.map((e) => e.nilai).reduce((a, b) => a + b) /
                snapshot.data!.length
            : 0.0;

        final highScore = snapshot.data?.isNotEmpty == true
            ? snapshot.data!.map((e) => e.nilai).reduce((a, b) => a > b ? a : b)
            : 0.0;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                "Quiz Diselesaikan",
                quizCount.toString(),
                Icons.quiz_outlined,
                Colors.blue,
                Colors.blue.withOpacity(0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                "Rata-rata Nilai",
                avgScore.toStringAsFixed(1),
                Icons.assessment_outlined,
                Colors.purple,
                Colors.purple.withOpacity(0.1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                "Nilai Tertinggi",
                highScore.toStringAsFixed(1),
                Icons.emoji_events_outlined,
                Colors.orange,
                Colors.orange.withOpacity(0.1),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMateriSection(
    BuildContext context,
    FirestoreService firestoreService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Materi Pembelajaran",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: StreamBuilder<List<MateriModel>>(
                stream: firestoreService.getMateriList(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$count",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Materi",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "Pelajari materi terbaru dan tingkatkan pemahamanmu",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        _buildMateriContent(context, firestoreService),
      ],
    );
  }

  Widget _buildMateriContent(
    BuildContext context,
    FirestoreService firestoreService,
  ) {
    return StreamBuilder<List<MateriModel>>(
      stream: firestoreService.getMateriList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildMateriLoading();
        }
        if (snapshot.hasError) {
          return _buildErrorCard("Error memuat materi: ${snapshot.error}");
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCard("Belum ada materi tersedia");
        }

        final allMateri = snapshot.data!;
        final materiTerbaru = allMateri.first;
        final listRekomendasi = allMateri.skip(1).take(3).toList();

        return Column(
          children: [
            _buildFeaturedMateri(context, materiTerbaru),
            if (listRekomendasi.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildRekomendasiList(context, listRekomendasi),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMateriLoading() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Memuat materi...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedMateri(BuildContext context, MateriModel materi) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailMateriSiswa(materi: materi),
          ),
        );
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  materi.imageUrl?.isNotEmpty == true
                      ? materi.imageUrl!
                      : 'https://placehold.co/600x400/0D2A6F/FFFFFF?text=Materi',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primaryBlue.withOpacity(0.8),
                    child: const Center(
                      child: Icon(Icons.menu_book_rounded,
                          color: Colors.white, size: 50),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "MATERI TERBARU",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        materi.judul,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.primaryBlue,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Pelajari",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRekomendasiList(
    BuildContext context,
    List<MateriModel> listRekomendasi,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Rekomendasi Lainnya",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: listRekomendasi.length,
            itemBuilder: (context, index) {
              final materi = listRekomendasi[index];
              return _buildRekomendasiCard(context, materi);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRekomendasiCard(BuildContext context, MateriModel materi) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailMateriSiswa(materi: materi),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          materi.imageUrl?.isNotEmpty == true
                              ? materi.imageUrl!
                              : 'https://placehold.co/600x400/0D2A6F/FFFFFF?text=Materi',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: AppColors.primaryBlue.withOpacity(0.6),
                            child: const Center(
                              child: Icon(Icons.menu_book_rounded,
                                  color: Colors.white, size: 40),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 12,
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.primaryBlue,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              materi.judul,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementSection(
    BuildContext context,
    FirestoreService firestoreService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pencapaian Terbaru",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Riwayat kuis yang telah diselesaikan",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        _buildAchievementContent(context, firestoreService),
      ],
    );
  }

  Widget _buildAchievementContent(
    BuildContext context,
    FirestoreService firestoreService,
  ) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final String? currentUserId = authService.currentUserId;

    if (currentUserId == null) {
      return _buildEmptyCard("Siswa tidak terautentikasi");
    }

    return StreamBuilder<List<HasilQuizModel>>(
      stream: firestoreService.getHasilQuizForSiswa(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }
        if (snapshot.hasError) {
          return _buildErrorCard("Error memuat pencapaian");
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCard(
              "Belum ada hasil quiz. Ayo mulai belajar dan kerjakan quiz!");
        }

        final listHasil = snapshot.data!;
        listHasil.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return Column(
          children: listHasil.take(3).map((hasil) {
            return _buildAchievementCard(hasil);
          }).toList(),
        );
      },
    );
  }

  Widget _buildAchievementCard(HasilQuizModel hasil) {
    final Color cardColor;
    final Color iconColor;
    final IconData iconData;
    final String status;

    if (hasil.nilai >= 80) {
      cardColor = Colors.green.shade50;
      iconColor = Colors.green;
      iconData = Icons.emoji_events_rounded;
      status = "Bagus Sekali!";
    } else if (hasil.nilai >= 60) {
      cardColor = Colors.orange.shade50;
      iconColor = Colors.orange;
      iconData = Icons.thumb_up_rounded;
      status = "Bagus";
    } else {
      cardColor = Colors.red.shade50;
      iconColor = Colors.red;
      iconData = Icons.autorenew_rounded;
      status = "Perlu Peningkatan";
    }

    final String formattedDate =
        DateFormat('d MMM yyyy, HH:mm').format(hasil.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hasil.quizJudul,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildScoreBadge("Nilai", "${hasil.nilai}", iconColor),
                    const SizedBox(width: 8),
                    _buildScoreBadge("Benar",
                        "${hasil.jumlahBenar}/${hasil.jumlahSoal}", Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Memuat pencapaian...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade400,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              color: Colors.grey.shade400,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}