// (File: lib/screens/siswa/hasil_quiz_screen.dart)
// Sudah diperbaiki sesuai permintaan user

import 'package:edujarkom/main.dart';
import 'package:edujarkom/models/hasil_quiz_model.dart';
import 'package:edujarkom/models/soal_model.dart';
import 'package:edujarkom/screens/siswa/quiz_screen.dart';
import 'package:edujarkom/screens/siswa/siswa_main_screen.dart';
import 'package:flutter/material.dart';

class HasilQuizScreen extends StatelessWidget {
  final HasilQuizModel hasil;
  final List<SoalModel> soalList;
  final Map<int, String> jawabanUser;

  const HasilQuizScreen({
    super.key,
    required this.hasil,
    required this.soalList,
    required this.jawabanUser,
  });

  @override
  Widget build(BuildContext context) {
    final int jumlahSalah = hasil.jumlahSoal - hasil.jumlahBenar;

    // 🔥 LOGIKA BARU: Selamat / Coba Lagi
    final bool lulus = hasil.nilai >= 70;
    final String statusText = lulus ? "Selamat!" : "Coba Lagi!";
    final Color statusColor = lulus ? AppColors.primaryBlue : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hasil Kuis"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // 🔥 DESKRIPSI DULU
              Text(
                "Kamu telah menyelesaikan ${hasil.quizJudul}.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),

              const SizedBox(height: 8),

              // 🔥 STATUS (Selamat / Coba Lagi) DIPINDAHKAN KE SINI
              Text(
                statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),

              const SizedBox(height: 40),

              // --- Kotak Skor ---
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: [
                    const Text(
                      "SKOR KAMU",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${hasil.nilai}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- Rincian Jawaban ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildScoreDetail(
                    context: context,
                    value: "${hasil.jumlahSoal}",
                    label: "Total Soal",
                    color: Colors.grey,
                    icon: Icons.list_alt,
                  ),
                  _buildScoreDetail(
                    context: context,
                    value: "${hasil.jumlahBenar}",
                    label: "Jawaban Benar",
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                  _buildScoreDetail(
                    context: context,
                    value: "$jumlahSalah",
                    label: "Jawaban Salah",
                    color: Colors.red,
                    icon: Icons.cancel,
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Tombol "Lihat Pembahasan"
              ElevatedButton.icon(
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text("Lihat Pembahasan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen.reviewMode(
                        quiz: hasil,
                        soalListReview: soalList,
                        jawabanUserReview: jawabanUser,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Tombol kembali ke dashboard
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SiswaMainScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Kembali ke Dashboard"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreDetail({
    required BuildContext context,
    required String value,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }
}
