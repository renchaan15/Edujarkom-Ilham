import 'package:edujarkom/models/user_model.dart';
import 'package:edujarkom/services/auth_service.dart';
import 'package:edujarkom/services/firestore_service.dart';
import 'package:edujarkom/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KelolaAkunScreen extends StatefulWidget {
  const KelolaAkunScreen({super.key});

  @override
  State<KelolaAkunScreen> createState() => _KelolaAkunScreenState();
}

class _KelolaAkunScreenState extends State<KelolaAkunScreen> {
  String _filterRole = 'Semua';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _filterOptions = [
    {'value': 'Semua', 'label': 'Semua', 'color': AppColors.primaryColor, 'icon': Icons.all_inclusive},
    {'value': 'Siswa', 'label': 'Siswa', 'color': Colors.green, 'icon': Icons.person},
    {'value': 'Guru', 'label': 'Guru', 'color': const Color(0xFF2196F3), 'icon': Icons.school},
    {'value': 'Admin', 'label': 'Admin', 'color': Colors.red, 'icon': Icons.admin_panel_settings},
  ];

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final String? currentAdminId = authService.currentUserId;

    return Scaffold(
      
      body: Column(
        children: [
          // Filter Chips Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Berdasarkan Role',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _filterRole == filter['value'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            filter['label'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          avatar: Icon(
                            filter['icon'],
                            size: 18,
                            color: isSelected ? Colors.white : filter['color'] as Color,
                          ),
                          selected: isSelected,
                          backgroundColor: Colors.grey.shade50,
                          selectedColor: filter['color'] as Color,
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected 
                                  ? filter['color'] as Color 
                                  : Colors.grey.shade300,
                              width: isSelected ? 0 : 1,
                            ),
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              _filterRole = selected ? filter['value'] : 'Semua';
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: firestoreService.getAllUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Terjadi kesalahan saat memuat data",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Tidak ada pengguna terdaftar",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final listPengguna = snapshot.data!;
                
                // Filter pengguna berdasarkan role yang dipilih
                final filteredUsers = _filterRole == 'Semua' 
                    ? listPengguna 
                    : listPengguna.where((user) => user.role.toLowerCase() == _filterRole.toLowerCase()).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Tidak ada pengguna dengan role $_filterRole",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Kelompokkan pengguna berdasarkan role
                final Map<String, List<UserModel>> groupedUsers = {};
                for (var user in filteredUsers) {
                  final role = user.role;
                  if (!groupedUsers.containsKey(role)) {
                    groupedUsers[role] = [];
                  }
                  groupedUsers[role]!.add(user);
                }

                // Urutkan role: Admin -> Guru -> Siswa -> lainnya
                final sortedRoles = groupedUsers.keys.toList()
                  ..sort((a, b) {
                    final order = {'Admin': 0, 'Guru': 1, 'Siswa': 2};
                    return (order[a] ?? 3).compareTo(order[b] ?? 3);
                  });

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: sortedRoles.length,
                  itemBuilder: (context, groupIndex) {
                    final role = sortedRoles[groupIndex];
                    final usersInRole = groupedUsers[role]!;
                    
                    return _buildRoleGroup(
                      context, 
                      role, 
                      usersInRole, 
                      currentAdminId!
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Tombol FloatingActionButton untuk menambah akun baru
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 255, 221, 0),
        icon: const Icon(Icons.person_add),
        label: const Text("Tambah Akun"),
        onPressed: () async {
          if (_isLoading) return;
          
          setState(() => _isLoading = true);
          try {
            await Navigator.pushNamed(context, '/tambahAkun');
          } catch (e) {
            _showSnackBar('Halaman tambah akun belum terdaftar di route.', isError: true);
          } finally {
            setState(() => _isLoading = false);
          }
        },
      ),
    );
  }

  Widget _buildRoleGroup(BuildContext context, String role, List<UserModel> users, String currentAdminId) {
    // Tentukan warna dan icon berdasarkan role
    Color headerColor;
    IconData roleIcon;
    int userCount = users.length;

    switch (role.toLowerCase()) {
      case 'admin':
        headerColor = Colors.red.shade700;
        roleIcon = Icons.admin_panel_settings;
        break;
      case 'guru':
        headerColor = Colors.blue.shade700;
        roleIcon = Icons.school;
        break;
      case 'siswa':
        headerColor = Colors.green.shade700;
        roleIcon = Icons.person;
        break;
      default:
        headerColor = Colors.grey.shade700;
        roleIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header Group
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(roleIcon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  '$role ($userCount)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // List pengguna dalam group
          ...users.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            final bool isSelf = (user.uid == currentAdminId);
            final bool isLast = index == users.length - 1;
            
            return _buildUserTile(context, user, isSelf, headerColor, isLast);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel user, bool isSelf, Color roleColor, bool isLast) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast 
              ? BorderSide.none 
              : BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: roleColor.withOpacity(0.1),
          backgroundImage: (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: (user.profileImageUrl == null || user.profileImageUrl!.isEmpty)
              ? Icon(
                  _getRoleIcon(user.role), 
                  color: roleColor,
                  size: 20,
                )
              : null,
        ),
        title: Text(
          user.username,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            if (user.role.toLowerCase() == 'siswa') ...[
              const SizedBox(height: 4),
              Text(
                "Skor Tertinggi: ${user.skorTertinggi ?? 0}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
        isThreeLine: user.role.toLowerCase() == 'siswa',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit, 
                color: isSelf ? Colors.grey.shade400 : Colors.blue,
                size: 20,
              ),
              onPressed: isSelf ? null : () => _showEditRoleDialog(context, user),
              tooltip: isSelf ? "Tidak dapat mengubah role sendiri" : "Ubah Role",
            ),
            IconButton(
              icon: Icon(
                Icons.delete, 
                color: isSelf ? Colors.grey.shade400 : Colors.red,
                size: 20,
              ),
              onPressed: isSelf ? null : () => _showDeleteUserDialog(context, user),
              tooltip: isSelf ? "Tidak dapat menghapus akun sendiri" : "Hapus Akun",
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'guru':
        return Icons.school;
      case 'siswa':
        return Icons.person;
      default:
        return Icons.help_outline;
    }
  }

  void _showEditRoleDialog(BuildContext context, UserModel user) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                "Ubah Role Pengguna",
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mengubah role untuk:",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Pilih role baru:",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...['Siswa', 'Guru', 'Admin'].map((role) {
                    return RadioListTile<String>(
                      title: Text(role),
                      value: role,
                      groupValue: selectedRole,
                      onChanged: (value) {
                        setDialogState(() => selectedRole = value!);
                      },
                      dense: true,
                    );
                  }).toList(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    setState(() => _isLoading = true);
                    
                    try {
                      await firestoreService.updateUserRole(user.uid, selectedRole);
                      _showSnackBar("Role ${user.username} berhasil diubah menjadi $selectedRole");
                    } catch (e) {
                      _showSnackBar("Gagal mengubah role: $e", isError: true);
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
                  child: const Text("Simpan Perubahan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteUserDialog(BuildContext context, UserModel user) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Konfirmasi Hapus",
          style: TextStyle(color: Colors.red),
        ),
        icon: const Icon(Icons.warning, color: Colors.orange, size: 48),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Apakah Anda yakin ingin menghapus pengguna:",
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              user.username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: const Text(
                "PERHATIAN: Tindakan ini hanya menghapus data Firestore pengguna. "
                "Akun login (Auth) mereka harus dihapus manual dari Firebase Console.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              
              try {
                await firestoreService.deleteUserDocument(user.uid);
                _showSnackBar("Pengguna ${user.username} berhasil dihapus");
              } catch (e) {
                _showSnackBar("Gagal menghapus pengguna: $e", isError: true);
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}