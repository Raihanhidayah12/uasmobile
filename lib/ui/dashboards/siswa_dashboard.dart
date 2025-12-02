import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/announcement_provider.dart';
import '../home_page.dart';
import '../siswa/rapor_page.dart';
import '../siswa/lihat_jadwal_page.dart';
import '../siswa/pengumuman_page.dart';

class DashboardSiswa extends StatefulWidget {
  const DashboardSiswa({super.key});

  @override
  State<DashboardSiswa> createState() => _DashboardSiswaState();
}

class _DashboardSiswaState extends State<DashboardSiswa> {
  String _studentName = 'Siswa';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final email = context.read<app_auth.AuthProvider>().current?.email ?? '';
    final name = _formatNameFromEmail(email);
    setState(() => _studentName = name.isNotEmpty ? name : 'Siswa');
  }

  String _formatNameFromEmail(String email) {
    if (email.isEmpty) return '';
    final local = email.split('@').first;
    final parts = local.replaceAll(RegExp(r'[._]'), ' ').split(' ');
    return parts
        .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo,
            Colors.deepPurpleAccent,
            Colors.purpleAccent.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(.12),
            offset: const Offset(0, 11),
            blurRadius: 34,
          ),
        ],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 37,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.indigo[700], size: 46),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, $_studentName",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 24,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  "Selamat datang di dashboard siswa",
                  style: TextStyle(
                    color: Colors.purple[50],
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              splashColor: Colors.white30,
              onTap: () async {
                await context.read<app_auth.AuthProvider>().logout();
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
                child: const Icon(Icons.logout, color: Colors.white, size: 29),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      splashColor: color.withOpacity(.15),
      child: Card(
        color: isDark ? Colors.blueGrey[900] : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 7),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 7),
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
                fontSize: 18,
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
              size: 30,
              color: Colors.deepPurpleAccent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrafikPreview(bool isMobile) {
    return FutureBuilder<Map<String, double>>(
      future: _fetchSubjectAverages(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snap.hasError)
          return Center(child: Text('Gagal memuat grafik: ${snap.error}'));
        final subjects = snap.data ?? {};
        if (subjects.isEmpty) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Grafik Nilai',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Belum ada data nilai untuk ditampilkan.'),
                ],
              ),
            ),
          );
        }

        final entries = subjects.entries.toList();
        final display = entries.take(isMobile ? 3 : 5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grafik Nilai',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: display.map((e) {
                    final pct = (e.value / 100).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              e.key,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 5,
                            child: LinearProgressIndicator(value: pct),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 42,
                            child: Text(e.value.toStringAsFixed(1)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, double>> _fetchSubjectAverages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};
    final fs = FirebaseFirestore.instance;
    final sSnap = await fs
        .collection('siswa')
        .where('user_id', isEqualTo: user.uid)
        .limit(1)
        .get();
    if (sSnap.docs.isEmpty) return {};
    final siswaId = sSnap.docs.first.id;
    final gSnap = await fs
        .collection('grade')
        .where('student_id', isEqualTo: siswaId)
        .get();
    final Map<String, List<double>> accum = {};
    for (final d in gSnap.docs) {
      final data = d.data();
      final subject = (data['subject'] ?? 'Umum') as String;
      final akhir = (data['akhir'] ?? data['final'] ?? 0) as num;
      accum.putIfAbsent(subject, () => []).add(akhir.toDouble());
    }
    return {
      for (final e in accum.entries)
        e.key: (e.value.reduce((a, b) => a + b) / e.value.length),
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF12121D)
          : const Color(0xFFF7F8FF),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(isMobile),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pengumuman ditampilkan langsung di halaman (sama seperti dashboard guru)
                  Consumer<AnnouncementProvider>(
                    builder: (context, announcementProvider, child) {
                      if (announcementProvider.loading)
                        return const Center(child: CircularProgressIndicator());
                      final userRole =
                          context.read<app_auth.AuthProvider>().current?.role ??
                          'siswa';
                      final announcements = announcementProvider.items
                          .where((a) {
                            final aud = (a['audience'] ?? 'all') as String;
                            return aud == 'all' || aud == userRole;
                          })
                          .take(5)
                          .toList();
                      if (announcements.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            "Pengumuman",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: isMobile ? 160 : 200,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: announcements.length,
                              padding: const EdgeInsets.only(right: 16),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final a = announcements[index];
                                final cardWidth = isMobile
                                    ? MediaQuery.of(context).size.width * 0.78
                                    : (MediaQuery.of(context).size.width - 96) /
                                          3;
                                return SizedBox(
                                  width: cardWidth,
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            a['title'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: Text(
                                              a['content'] ?? '',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 18),
                  // Compact Grafik Nilai preview on dashboard
                  _buildGrafikPreview(isMobile),

                  const SizedBox(height: 18),
                  // Menu header moved after Grafik Nilai
                  Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Menu section (jadwal & rapor)
                  _buildMenuCard(
                    color: Colors.indigo,
                    icon: Icons.schedule,
                    title: "Lihat Jadwal",
                    subtitle: "Lihat jadwal pelajaran Anda",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LihatJadwalSiswaPage(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    color: Colors.indigo,
                    icon: Icons.receipt_long,
                    title: "Lihat Nilai / Rapor",
                    subtitle: "Lihat rapor dan detail nilai Anda",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RaporPage()),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      "© 2025 Aplikasi Sekolah",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blueGrey[300]
                            : Colors.grey[700],
                        fontSize: 13,
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
