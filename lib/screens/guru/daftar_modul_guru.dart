import 'package:edujarkom/models/materi_model.dart';
import 'package:edujarkom/screens/guru/home_guru.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:edujarkom/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DaftarModulGuru extends StatelessWidget {
  const DaftarModulGuru({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final storageService =
        Provider.of<StorageService>(context, listen: false);

    return StreamBuilder<List<MateriModel>>(
      stream: firestoreService.getMateriList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Anda belum membuat modul.\nTekan tombol (+) untuk memulai.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        final listModul = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: listModul.length,
          itemBuilder: (context, index) {
            final materi = listModul[index];
            return _buildMateriTile(
                context, materi, firestoreService, storageService);
          },
        );
      },
    );
  }

  Widget _buildMateriTile(
      BuildContext context,
      MateriModel materi,
      FirestoreService firestoreService,
      StorageService storageService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon/Image Container
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 2,
                  ),
                ),
                child: materi.imageUrl != null && materi.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          materi.imageUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, 
                                  size: 30, color: Colors.blue.shade600),
                        ),
                      )
                    : Icon(Icons.article_rounded, 
                        size: 35, color: Colors.blue.shade700),
              ),
              
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      materi.judul,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      materi.isi,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Action Buttons
              Column(
                children: [
                  // Edit Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      onPressed: () {
                        context
                            .findAncestorStateOfType<HomeGuruScreenState>()
                            ?.showModulForm(context, materi);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Delete Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                      onPressed: () {
                        _hapusModul(context, materi, firestoreService, storageService);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _hapusModul(
      BuildContext context,
      MateriModel materi,
      FirestoreService firestoreService,
      StorageService storageService) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Hapus Modul",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus modul '${materi.judul}'?",
          style: const TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Batal",
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await firestoreService.deleteMateri(materi.id);
                
                if (materi.imageUrl != null && materi.imageUrl!.isNotEmpty) {
                  print("LOG: Hapus file dari Storage belum diimplementasikan.");
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Modul berhasil dihapus."),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Gagal menghapus: $e"),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Hapus",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}