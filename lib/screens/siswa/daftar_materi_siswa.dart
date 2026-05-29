import 'package:edujarkom/main.dart';
import 'package:edujarkom/models/materi_model.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:edujarkom/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// [PENTING] Import AuthGate
import 'package:edujarkom/screens/auth/auth_gate.dart';
import 'package:edujarkom/screens/siswa/detail_materi_siswa.dart';

class DaftarMateriSiswa extends StatefulWidget {
  const DaftarMateriSiswa({super.key});

  @override
  State<DaftarMateriSiswa> createState() => _DaftarMateriSiswaState();
}

class _DaftarMateriSiswaState extends State<DaftarMateriSiswa> {
  bool _isGridView = false;
  String searchQuery = "";

  // --- FUNGSI LOGOUT DIPERBARUI ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text("Konfirmasi Keluar Akun"),
            ],
          ),
          content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog

                // 1. Proses Logout
                await context.read<AuthService>().signOut();

                if (mounted) {
                  // 2. [FIX] Arahkan kembali ke AuthGate
                  // Ini akan mereset aplikasi ke status awal (pengecekan login)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                    (route) => false,
                  );
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
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Daftar Materi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          // Tombol List/Grid
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.list,
                    color: !_isGridView ? AppColors.primaryBlue : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() => _isGridView = false);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.grid_view,
                    color: _isGridView ? AppColors.primaryBlue : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() => _isGridView = true);
                  },
                ),
              ],
            ),
          ),

          // Tombol Logout
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              onPressed: () => _showLogoutDialog(context),
              tooltip: "Keluar",
            ),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 20),

            // STREAM FIRESTORE
            Expanded(
              child: StreamBuilder<List<MateriModel>>(
                stream: firestoreService.getMateriList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final materiList = snapshot.data!;

                  // FILTER SEARCH
                  final filteredList = materiList.where((m) {
                    final query = searchQuery.toLowerCase();
                    return m.judul.toLowerCase().contains(query) ||
                        m.isi.toLowerCase().contains(query);
                  }).toList();

                  return _isGridView
                      ? _buildGridView(filteredList)
                      : _buildListView(filteredList);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Widget Helper di bawah ini tetap sama) ...
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Materi Pembelajaran",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text("Pilih dan pelajari materi yang tersedia",
            style: TextStyle(color: Colors.grey)),

        const SizedBox(height: 16),

        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              hintText: "Cari materi...",
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );

  Widget _buildErrorState(String error) {
    return Center(
      child: Text("Terjadi kesalahan: $error",
          style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("Belum ada materi tersedia.",
          style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildListView(List<MateriModel> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => _buildListItem(list[index]),
    );
  }

  Widget _buildListItem(MateriModel materi) {
    return InkWell(
      onTap: () => _openDetail(materi),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
            )
          ],
        ),
        child: Row(
          children: [
            _buildImage(materi, size: 70),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(materi.judul,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(
                    materi.isi.length > 80
                        ? "${materi.isi.substring(0, 80)}..."
                        : materi.isi,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<MateriModel> list) {
    return GridView.builder(
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, i) => _buildGridItem(list[i]),
    );
  }

  Widget _buildGridItem(MateriModel materi) {
    return InkWell(
      onTap: () => _openDetail(materi),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
            )
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: _buildImage(materi),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      materi.judul,
                      maxLines: 2,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      materi.isi.length > 50
                          ? "${materi.isi.substring(0, 50)}..."
                          : materi.isi,
                      maxLines: 2,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImage(MateriModel materi, {double size = double.infinity}) {
    final hasImage =
        materi.imageUrl != null && materi.imageUrl!.trim().isNotEmpty;

    return Container(
      width: size == double.infinity ? null : size,
      height: size == double.infinity ? null : size,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(materi.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: !hasImage
          ? const Icon(Icons.article,
              size: 35, color: AppColors.primaryBlue)
          : null,
    );
  }

  void _openDetail(MateriModel materi) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailMateriSiswa(materi: materi),
      ),
    );
  }
}