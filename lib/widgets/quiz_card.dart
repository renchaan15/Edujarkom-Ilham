import 'package:edujarkom/main.dart'; // Untuk AppColors
import 'package:edujarkom/models/quiz_model.dart';
import 'package:flutter/material.dart';

class QuizCard extends StatelessWidget {
  final QuizModel quiz;
  final VoidCallback onTap;

  const QuizCard({
    super.key,
    required this.quiz,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.lightbulb_outline, // Icon Quiz
                  color: AppColors.primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.judul,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quiz.deskripsi,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right, // Icon panah ke kanan
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
