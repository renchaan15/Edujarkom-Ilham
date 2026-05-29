import 'package:edujarkom/models/hasil_quiz_model.dart';
import 'package:edujarkom/models/user_model.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:edujarkom/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LihatHasilSiswa extends StatefulWidget {
  const LihatHasilSiswa({super.key});

  @override
  State<LihatHasilSiswa> createState() => _LihatHasilSiswaState();
}

class _LihatHasilSiswaState extends State<LihatHasilSiswa> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      // Background
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 1. Header Pencarian
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: Colors.white,
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Cari nama siswa...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),

          // 2. Konten
          Expanded(
            // Menggunakan StreamBuilder bersarang untuk mendapatkan User dan Hasil
            child: StreamBuilder<List<UserModel>>(
              stream: firestoreService.getAllUsersStream(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Buat Map User ID -> User Name untuk akses cepat
                final Map<String, String> userMap = {};
                if (userSnapshot.hasData) {
                  for (var user in userSnapshot.data!) {
                    userMap[user.uid] = user.username;
                  }
                }

                return StreamBuilder<List<HasilQuizModel>>(
                  stream: firestoreService.getAllHasilQuizStream(),
                  builder: (context, hasilSnapshot) {
                    if (hasilSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!hasilSnapshot.hasData || hasilSnapshot.data!.isEmpty) {
                      return const Center(child: Text("Belum ada hasil kuis."));
                    }

                    final listHasil = hasilSnapshot.data!;
                    
                    // LOGIKA PENGELOMPOKAN (GROUPING)
                    // Group hasil berdasarkan Judul Kuis (Kategori)
                    final Map<String, List<HasilQuizModel>> groupedHasil = {};
                    
                    for (var hasil in listHasil) {
                      if (!groupedHasil.containsKey(hasil.quizJudul)) {
                        groupedHasil[hasil.quizJudul] = [];
                      }
                      
                      // FILTER SEARCH (Nama Siswa)
                      // Jika search kosong, masukkan semua.
                      // Jika search ada, cek apakah nama user mengandung query
                      final namaSiswa = userMap[hasil.userId] ?? "Unknown";
                      if (_searchQuery.isEmpty || namaSiswa.toLowerCase().contains(_searchQuery)) {
                        groupedHasil[hasil.quizJudul]!.add(hasil);
                      }
                    }

                    // Hapus grup yang kosong (karena filter search)
                    groupedHasil.removeWhere((key, value) => value.isEmpty);

                    if (groupedHasil.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 60, color: Colors.grey),
                            const SizedBox(height: 10),
                            Text("Tidak ditemukan siswa dengan nama '$_searchQuery'", style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    // Tampilkan List Group
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: groupedHasil.keys.length,
                      itemBuilder: (context, index) {
                        String quizTitle = groupedHasil.keys.elementAt(index);
                        List<HasilQuizModel> hasilItems = groupedHasil[quizTitle]!;
                        
                        // Urutkan berdasarkan nilai tertinggi di dalam grup
                        hasilItems.sort((a, b) => b.nilai.compareTo(a.nilai));

                        return _buildQuizGroupCard(quizTitle, hasilItems, userMap);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Group Card (Kategori Kuis)
  Widget _buildQuizGroupCard(String quizTitle, List<HasilQuizModel> items, Map<String, String> userMap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true, // Default terbuka agar guru langsung lihat
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.quiz, color: AppColors.primaryColor),
          ),
          title: Text(
            quizTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            "${items.length} Siswa Mengerjakan",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          children: [
            // Header Tabel Kecil
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[50],
              child: const Row(
                children: [
                  Expanded(flex: 2, child: Text("Nama Siswa", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                  Expanded(child: Text("Tanggal", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                  SizedBox(width: 50, child: Text("Nilai", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center)),
                ],
              ),
            ),
            const Divider(height: 1),
            // List Siswa di dalam Group
            ...items.map((hasil) => _buildStudentResultItem(hasil, userMap)).toList(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Widget Item Hasil Siswa (Baris)
  Widget _buildStudentResultItem(HasilQuizModel hasil, Map<String, String> userMap) {
    final namaSiswa = userMap[hasil.userId] ?? "Siswa tidak ditemukan";
    final colorNilai = _getNilaiColor(hasil.nilai);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          // Nama
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(namaSiswa, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  "Benar: ${hasil.jumlahBenar}/${hasil.jumlahSoal}",
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Tanggal
          Expanded(
            child: Text(
              DateFormat('d MMM, HH:mm').format(hasil.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          // Nilai Badge
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: colorNilai.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorNilai.withOpacity(0.3)),
            ),
            child: Text(
              "${hasil.nilai}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorNilai,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNilaiColor(int nilai) {
    if (nilai >= 80) return Colors.green.shade700;
    if (nilai >= 60) return Colors.orange.shade700;
    return Colors.red.shade700;
  }
}