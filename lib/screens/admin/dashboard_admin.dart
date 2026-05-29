import 'package:edujarkom/models/hasil_quiz_model.dart';
import 'package:edujarkom/models/materi_model.dart';
import 'package:edujarkom/models/user_model.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:edujarkom/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header yang Diperbarui ---
            _buildHeader(context),
            const SizedBox(height: 24),

            // --- Bagian Kartu Statistik ---
            _buildStatsSection(firestoreService),
            const SizedBox(height: 32),

            // --- Bagian Grafik (PERBAIKAN OVERFLOW DI SINI) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Tambahkan Expanded agar teks fleksibel
                  child: Text(
                    'Aktivitas Quiz (7 Hari Terakhir)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2, // Izinkan maks 2 baris jika sempit
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8), // Jarak aman
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timeline, size: 14, color: AppColors.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'Statistik',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            StreamBuilder<List<HasilQuizModel>>(
              stream: firestoreService.getAllHasilQuizStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingChartPlaceholder();
                }
                if (snapshot.hasError) {
                  return _buildErrorChartPlaceholder(
                    "Error memuat data grafik",
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyChartPlaceholder(
                    "Belum ada data aktivitas quiz",
                  );
                }

                final spots = _generateChartData(snapshot.data!);
                final labels = _getBottomLabels();
                return _buildChart(spots, labels);
              },
            ),

            const SizedBox(height: 32),

            // --- Aktivitas Terbaru (PERBAIKAN PREVENTIF OVERFLOW DI SINI) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Tambahkan Expanded
                  child: Text(
                    'Aktivitas Quiz Terbaru',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                  ),
                  child: StreamBuilder<List<HasilQuizModel>>(
                    stream: firestoreService.getAllHasilQuizStream(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Text(
                        '$count total',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildRecentActivity(firestoreService),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER YANG DIPERBARUI ====================

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withOpacity(0.8),
            AppColors.primaryColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, Admin! 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Selamat datang kembali di dashboard',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PLACEHOLDER CHART ====================

  Widget _buildLoadingChartPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor),
          const SizedBox(height: 12),
          Text(
            "Memuat data grafik...",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorChartPlaceholder(String message) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 40),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChartPlaceholder(String message) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, color: Colors.grey.shade400, size: 40),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== STATISTIK ====================

  Widget _buildStatsSection(FirestoreService firestoreService) {
    return Column(
      children: [
        Row(
          children: [
            // Kartu Total Siswa
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: firestoreService.getAllUsersStream(),
                builder: (context, snapshot) {
                  final count = (snapshot.data?.where((user) => user.role == 'Siswa').length ?? 0);
                  return _buildStatCard(
                    'Total Siswa',
                    count.toString(),
                    Icons.people_outline,
                    AppColors.primaryColor,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),

            // Kartu Total Materi
            Expanded(
              child: StreamBuilder<List<MateriModel>>(
                stream: firestoreService.getMateriList(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return _buildStatCard(
                    'Total Materi',
                    count.toString(),
                    Icons.library_books_outlined,
                    Colors.orange.shade600,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            // Kartu Quiz Dikerjakan
            Expanded(
              child: StreamBuilder<List<HasilQuizModel>>(
                stream: firestoreService.getAllHasilQuizStream(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return _buildStatCard(
                    'Quiz Dikerjakan',
                    count.toString(),
                    Icons.quiz_outlined,
                    Colors.green.shade600,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),

            // Kartu Rata-rata Nilai
            Expanded(
              child: StreamBuilder<List<HasilQuizModel>>(
                stream: firestoreService.getAllHasilQuizStream(),
                builder: (context, snapshot) {
                  final results = snapshot.data ?? [];
                  final rataRata = results.isEmpty ? 0 : 
                      results.map((e) => e.nilai).reduce((a, b) => a + b) / results.length;
                  return _buildStatCard(
                    'Rata-rata Nilai',
                    results.isEmpty ? '0' : rataRata.toStringAsFixed(1),
                    Icons.assessment_outlined,
                    Colors.purple.shade600,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              count,
              style: TextStyle(
                fontSize: 28,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CHART ====================

  List<FlSpot> _generateChartData(List<HasilQuizModel> results) {
    final Map<int, int> dailyCounts = {for (var i = 0; i < 7; i++) i: 0};
    final now = DateTime.now();
    final startDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));

    for (var hasil in results) {
      final timestampDate = hasil.timestamp.toLocal();
      final int dayIndex = timestampDate.difference(startDate).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        dailyCounts[dayIndex] = dailyCounts[dayIndex]! + 1;
      }
    }

    return dailyCounts.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
        .toList();
  }

  Map<int, String> _getBottomLabels() {
    final Map<int, String> labels = {};
    final now = DateTime.now();
    final formatter = DateFormat('EEE');

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      labels[i] = formatter.format(date);
    }
    return labels;
  }

  Widget _buildChart(List<FlSpot> spots, Map<int, String> bottomLabels) {
    double maxY = spots.isEmpty
        ? 1
        : spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1.0;
    if (maxY < 5) maxY = 5;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: AppColors.primaryColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Statistik Aktivitas',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '7 Hari',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 5 ? (maxY / 4).ceilToDouble() : 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: maxY > 5 ? (maxY / 4).ceilToDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10, 
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 25,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final text = bottomLabels[value.toInt()] ?? '';
                          return Text(
                            text,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: spots,
                      color: AppColors.primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeColor: AppColors.primaryColor,
                              strokeWidth: 2,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== AKTIVITAS TERBARU ====================

  Widget _buildRecentActivity(FirestoreService firestoreService) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: StreamBuilder<List<HasilQuizModel>>(
        stream: firestoreService.getAllHasilQuizStream().map((list) {
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list.length > 5 ? list.sublist(0, 5) : list;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.assignment_outlined, color: Colors.grey.shade400, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    "Belum ada aktivitas quiz",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final activities = snapshot.data!;
          return Column(
            children: [
              ...activities.map((activity) => _buildActivityItem(activity, firestoreService)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActivityItem(HasilQuizModel activity, FirestoreService firestoreService) {
    final Color nilaiColor = activity.nilai >= 70 ? Colors.green.shade600 : 
                           activity.nilai >= 50 ? Colors.orange.shade600 : Colors.red.shade600;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.assignment_turned_in,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.quizJudul,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _SiswaNama(
                  userId: activity.userId,
                  firestoreService: firestoreService,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(activity.timestamp.toLocal()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: nilaiColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: nilaiColor.withOpacity(0.3)),
            ),
            child: Text(
              '${activity.nilai}',
              style: TextStyle(
                color: nilaiColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HELPER: Nama Siswa ====================

class _SiswaNama extends StatelessWidget {
  final String userId;
  final FirestoreService firestoreService;

  const _SiswaNama({required this.userId, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: firestoreService.getUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "Memuat...",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Text(
            "User tidak ditemukan",
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade600,
            ),
          );
        }

        final user = snapshot.data!;
        return Row(
          children: [
            Icon(Icons.person_outline, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              user.username,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}