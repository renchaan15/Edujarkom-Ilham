import 'package:edujarkom/main.dart'; // Untuk AppColors
import 'package:edujarkom/models/materi_model.dart';
import 'package:flutter/material.dart';

class MateriCard extends StatelessWidget {
  final MateriModel materi;
  final VoidCallback onTap;

  const MateriCard({
    super.key,
    required this.materi,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Gunakan InkWell untuk efek 'splash' saat disentuh
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            // Icon (sesuai mockup)
            const Icon(
              Icons.menu_book, // Icon buku/materi
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 16),
            // Judul
            Expanded(
              child: Text(
                materi.judul,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right, // Icon panah ke kanan
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
