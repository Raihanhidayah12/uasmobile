// lib/ui/dashboards/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home_page.dart';

// Import halaman CRUD di folder admin
import '../admin/crud_siswa_page.dart';
import '../admin/crud_guru_page.dart';
import '../admin/crud_jadwal_page.dart';
import '../admin/crud_pengumuman_page.dart';
import '../admin/crud_user_page.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 🔹 Kelompok Data Siswa
          ExpansionTile(
            initiallyExpanded: true,
            leading: const Icon(Icons.school, color: Colors.indigo),
            title: const Text(
              "Kelola Data Siswa",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text("Data Siswa"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CrudSiswaPage()),
                  );
                },
              ),
            ],
          ),

          /// 🔹 Kelompok Data Guru
          ExpansionTile(
            leading: const Icon(Icons.person, color: Colors.green),
            title: const Text(
              "Kelola Data Guru",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text("Data Guru"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CrudGuruPage()),
                  );
                },
              ),
            ],
          ),

          /// 🔹 Kelompok Akun (gabung siswa + guru)
          ListTile(
            leading: const Icon(Icons.manage_accounts, color: Colors.purple),
            title: const Text("Kelola Akun"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CrudUserPage()),
              );
            },
          ),

          /// 🔹 Manajemen Akademik
          ExpansionTile(
            leading: const Icon(Icons.book, color: Colors.orange),
            title: const Text(
              "Manajemen Akademik",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text("Kelola Jadwal"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CrudJadwalPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.campaign),
                title: const Text("Pengumuman"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CrudPengumumanPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
