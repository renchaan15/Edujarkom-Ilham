import 'package:edujarkom/models/materi_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import package baru

class DetailMateriSiswa extends StatelessWidget {
  final MateriModel materi;

  const DetailMateriSiswa({super.key, required this.materi});

  // Fungsi untuk membuka link PDF
  Future<void> _bukaLink(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada file PDF untuk materi ini.")),
      );
      return;
    }

    final Uri uri = Uri.parse(url);
    try {
      // Coba buka di aplikasi eksternal (browser/Google Drive)
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak dapat membuka link: $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuka link: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(materi.judul),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Gambar Cover
            _buildHeaderImage(context),

            // 2. Konten (Judul, Deskripsi, dan Tombol)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    materi.judul,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    materi.isi,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5, // Jarak antar baris
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 3. Tombol Buka PDF
                  // Tombol ini hanya muncul jika fileUrl-nya ada
                  if (materi.fileUrl != null && materi.fileUrl!.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text("Buka Materi (PDF)"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          _bukaLink(context, materi.fileUrl);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk menampilkan gambar header
  Widget _buildHeaderImage(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        image: (materi.imageUrl != null && materi.imageUrl!.isNotEmpty)
            ? DecorationImage(
                image: NetworkImage(materi.imageUrl!),
                fit: BoxFit.cover,
                // Beri efek gelap agar AppBar terlihat kontras
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      // Tampilkan ikon jika tidak ada gambar
      child: (materi.imageUrl == null || materi.imageUrl!.isEmpty)
          ? Icon(Icons.article, color: Colors.grey[400], size: 100)
          : null,
    );
  }
}

