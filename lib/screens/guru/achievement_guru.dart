import 'package:flutter/material.dart';

class AchievementGuru extends StatelessWidget {
  const AchievementGuru({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Achievement")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul "GRADES"
            Text(
              "GRADES",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Kartu Header Guru (sesuai mockup)
            _buildGradesHeader(),

            const SizedBox(height: 24),

            // Judul "SISWA"
            Text(
              "SISWA",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Daftar Siswa (Placeholder)
            _buildSiswaList(),
          ],
        ),
      ),
    );
  }

  // Widget untuk kartu header di atas
  Widget _buildGradesHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Placeholder Avatar
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 16),
            // Placeholder Info Guru
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ilham Ibnu Qalbi. Yk", // Placeholder dari mockup
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "GURU", // Placeholder dari mockup
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk daftar siswa (placeholder)
  Widget _buildSiswaList() {
    // Kita buat list statis untuk meniru data
    final List<String> siswaList = [
      "Aprilia Amelisa",
      "Siswa B",
      "Siswa C",
      "Siswa D",
      "Siswa E",
    ];

    return ListView.builder(
      itemCount: siswaList.length,
      shrinkWrap: true, // Wajib di dalam SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // Wajib
      itemBuilder: (context, index) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueGrey[100],
              child: const Icon(Icons.person_outline, color: Colors.blueGrey),
            ),
            title: Text(
              siswaList[index],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text("Lihat Progress"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Arahkan ke halaman detail progress siswa
            },
          ),
        );
      },
    );
  }
}
