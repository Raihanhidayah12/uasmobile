import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home_page.dart';

// Import halaman CRUD admin
import '../admin/crud_siswa_page.dart';
import '../admin/crud_guru_page.dart';
import '../admin/crud_jadwal_page.dart';
import '../admin/crud_pengumuman_page.dart';
import '../admin/crud_user_page.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget _buildHeader() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo,
              Colors.blueAccent,
              Colors.cyanAccent.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(.19),
              offset: const Offset(0, 11),
              blurRadius: 34,
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(35),
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(.18),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 37,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue[700], size: 46),
              ),
            ),
            const SizedBox(width: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Welcome, Admin!",
                  style: TextStyle(
                    color: Colors.blue[50],
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                splashColor: Colors.white30,
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 29,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildMenuCard({
      required Color color,
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: color.withOpacity(.15),
        child: Card(
          color: isDark ? Colors.blueGrey[900] : Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 7),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 21, horizontal: 7),
            child: ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.53), color.withOpacity(0.95)],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: Colors.white, size: 31),
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                  color: isDark ? Colors.cyan[100] : color,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13.3,
                  color: isDark ? Colors.blueGrey[100] : Colors.grey[700],
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                size: 31,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF12121D)
          : const Color(0xFFF3F9FE),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMenuCard(
                    color: Colors.indigo,
                    icon: Icons.school,
                    title: "Kelola Data Siswa",
                    subtitle: "Lihat, tambah, edit, dan hapus data siswa",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CrudSiswaPage()),
                    ),
                  ),
                  _buildMenuCard(
                    color: Colors.green,
                    icon: Icons.person,
                    title: "Kelola Data Guru",
                    subtitle: "Lihat, tambah, edit, dan hapus data guru",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CrudGuruPage()),
                    ),
                  ),
                  _buildMenuCard(
                    color: Colors.purple,
                    icon: Icons.manage_accounts,
                    title: "Kelola Akun",
                    subtitle:
                        "Kelola akun siswa dan guru (edit role & password)",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CrudUserPage()),
                    ),
                  ),
                  _buildMenuCard(
                    color: Colors.orange,
                    icon: Icons.schedule,
                    title: "Kelola Jadwal",
                    subtitle: "Manajemen jadwal pelajaran dan kelas",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CrudJadwalPage()),
                    ),
                  ),
                  _buildMenuCard(
                    color: Colors.redAccent,
                    icon: Icons.campaign_rounded,
                    title: "Kelola Pengumuman",
                    subtitle:
                        "Kelola pengumuman sekolah (Info penting dan event!)",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CrudPengumumanPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      "© 2025 Admin Panel Brawijaya",
                      style: TextStyle(
                        color: isDark ? Colors.blueGrey[300] : Colors.grey[700],
                        fontSize: 13,
                        letterSpacing: 0.15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
