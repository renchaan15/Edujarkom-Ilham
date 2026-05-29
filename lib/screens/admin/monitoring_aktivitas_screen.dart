import 'package:edujarkom/models/hasil_quiz_model.dart';
import 'package:edujarkom/models/user_model.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonitoringAktivitasScreen extends StatefulWidget {
  const MonitoringAktivitasScreen({super.key});

  @override
  State<MonitoringAktivitasScreen> createState() => _MonitoringAktivitasScreenState();
}

class _MonitoringAktivitasScreenState extends State<MonitoringAktivitasScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Column(
        children: [
          // --- 1. Header Search ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Cari nama siswa atau judul kuis...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),

          // --- 2. Konten List ---
          Expanded(
            // StreamBuilder 1: Ambil Data User (untuk pencarian nama)
            child: StreamBuilder<List<UserModel>>(
              stream: firestoreService.getAllUsersStream(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Buat Map: UserID -> Username
                final Map<String, String> userMap = {};
                if (userSnapshot.hasData) {
                  for (var user in userSnapshot.data!) {
                    userMap[user.uid] = user.username;
                  }
                }

                // StreamBuilder 2: Ambil Data Hasil Quiz
                return StreamBuilder<List<HasilQuizModel>>(
                  stream: firestoreService.getAllHasilQuizStream(),
                  builder: (context, hasilSnapshot) {
                    if (hasilSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (hasilSnapshot.hasError) {
                      return _buildErrorState(hasilSnapshot.error.toString());
                    }
                    if (!hasilSnapshot.hasData || hasilSnapshot.data!.isEmpty) {
                      return _buildEmptyState("Belum ada aktivitas.");
                    }

                    // Filter data berdasarkan search query
                    final allData = hasilSnapshot.data!;
                    final filteredData = allData.where((hasil) {
                      final quizTitle = hasil.quizJudul.toLowerCase();
                      final studentName = (userMap[hasil.userId] ?? "").toLowerCase();
                      
                      return quizTitle.contains(_searchQuery) || 
                             studentName.contains(_searchQuery);
                    }).toList();

                    // Sort berdasarkan waktu terbaru
                    filteredData.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                    if (filteredData.isEmpty) {
                      return _buildEmptyState("Tidak ditemukan hasil untuk '$_searchQuery'");
                    }

                    return Column(
                      children: [
                        // Statistik Ringkas (Hanya muncul jika tidak sedang mencari / search kosong)
                        if (_searchQuery.isEmpty) 
                          _buildHeaderStats(filteredData),
                        
                        const SizedBox(height: 8),
                        
                        // List Item
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredData.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final hasil = filteredData[index];
                              final namaSiswa = userMap[hasil.userId] ?? "User tidak dikenal";
                              return _buildActivityItem(context, hasil, namaSiswa);
                            },
                          ),
                        ),
                      ],
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

  Widget _buildHeaderStats(List<HasilQuizModel> listHasil) {
    final totalAktivitas = listHasil.length;
    final rataRataNilai = listHasil.isEmpty ? 0 : 
        listHasil.map((e) => e.nilai).reduce((a, b) => a + b) / listHasil.length;
    
    // Hitung aktivitas hari ini
    final now = DateTime.now();
    final aktivitasHariIni = listHasil.where((hasil) {
      final hasilDate = hasil.timestamp;
      return now.year == hasilDate.year && 
             now.month == hasilDate.month && 
             now.day == hasilDate.day;
    }).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A579A), Color(0xFF3A6BCA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.assignment_turned_in,
            value: totalAktivitas.toString(),
            label: 'Total',
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem(
            icon: Icons.today,
            value: aktivitasHariIni.toString(),
            label: 'Hari Ini',
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem(
            icon: Icons.assessment,
            value: rataRataNilai.toStringAsFixed(1),
            label: 'Rata-rata',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, HasilQuizModel hasil, String namaSiswa) {
    final Color nilaiColor = _getNilaiColor(hasil.nilai);
    final Color backgroundColor = _getNilaiBackgroundColor(hasil.nilai);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nilai Circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                hasil.nilai.toString(),
                style: TextStyle(
                  color: nilaiColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Name
                Text(
                  namaSiswa,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Quiz Title
                Text(
                  hasil.quizJudul,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                
                // Meta info (Benar/Salah & Waktu)
                Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 14, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    Text(
                      "${hasil.jumlahBenar} Benar",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('d MMM, HH:mm').format(hasil.timestamp),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper functions
  Color _getNilaiColor(int nilai) {
    if (nilai >= 80) return Colors.green.shade700;
    if (nilai >= 60) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  Color _getNilaiBackgroundColor(int nilai) {
    if (nilai >= 80) return Colors.green.shade50;
    if (nilai >= 60) return Colors.orange.shade50;
    return Colors.red.shade50;
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade300, size: 60),
          const SizedBox(height: 16),
          Text(
            "Terjadi Kesalahan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, color: Colors.grey.shade300, size: 70),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}