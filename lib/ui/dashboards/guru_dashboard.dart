import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../guru/input_nilai_page.dart';
import '../guru/lihat_jadwal_page.dart';
import '../guru/data_siswa_dinilai_page.dart';
import '../home_page.dart';

class DashboardGuru extends StatefulWidget {
  const DashboardGuru({super.key});

  @override
  State<DashboardGuru> createState() => _DashboardGuruState();
}

class _DashboardGuruState extends State<DashboardGuru> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _scheduleSubscription;

  Map<String, int> _schedulesPerDay = {};
  bool _loading = true;
  String _teacherName = '';
  String _teacherSubject = '';

  @override
  void initState() {
    super.initState();
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() async {
    if (!mounted) return;
    setState(() => _loading = true);

    // Get current firebase user (we need uid to match 'user_id')
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    // Get teacher data by uid
    final teacherSnap = await _fs
        .collection('guru')
        .where('user_id', isEqualTo: firebaseUser.uid)
        .get();

    if (teacherSnap.docs.isNotEmpty) {
      final teacherData = teacherSnap.docs.first.data();
      if (!mounted) return;
      setState(() {
        _teacherName = teacherData['name'] ?? 'Guru';
        _teacherSubject = teacherData['subject'] ?? '';
      });

      // Listener for schedules
      _scheduleSubscription = _fs
          .collection('jadwal')
          .where('teacher_id', isEqualTo: teacherSnap.docs.first.id)
          .snapshots()
          .listen(
            (snapshot) {
              final schedules = snapshot.docs;
              final Map<String, int> schedulesPerDay = {
                'Senin': 0,
                'Selasa': 0,
                'Rabu': 0,
                'Kamis': 0,
                'Jumat': 0,
              };
              for (var doc in schedules) {
                final day = doc.data()['day'] as String?;
                if (day != null && schedulesPerDay.containsKey(day)) {
                  schedulesPerDay[day] = schedulesPerDay[day]! + 1;
                }
              }
              if (!mounted) return;
              setState(() => _schedulesPerDay = schedulesPerDay);
              _checkLoadingComplete();
            },
            onError: (error) {
              if (!mounted) return;
              setState(() => _loading = false);
            },
          );
    } else {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _checkLoadingComplete() {
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _scheduleSubscription?.cancel();
    super.dispose();
  }

  Widget _buildStatisticsCard({
    required Color color,
    required IconData icon,
    required String title,
    required String count,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? Colors.blueGrey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.6), color.withOpacity(0.95)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.cyan[100] : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  count,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    Widget _buildHeader() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.teal,
              Colors.greenAccent,
              Colors.lightGreenAccent.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(.19),
              offset: const Offset(0, 11),
              blurRadius: 34,
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(35),
          ),
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
                    color: Colors.green.withOpacity(.18),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 37,
                backgroundColor: Colors.white,
                child: Icon(Icons.school, color: Colors.teal[700], size: 46),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dashboard Guru - $_teacherSubject",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 19 : 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Selamat datang, $_teacherName!",
                    style: TextStyle(
                      color: Colors.green[50],
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                color: Colors.greenAccent,
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
                  Text(
                    "Statistik",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...["Senin", "Selasa", "Rabu", "Kamis", "Jumat"]
                                .map(
                                  (day) => SizedBox(
                                    width: isMobile
                                        ? (screenWidth - 48) / 2
                                        : (screenWidth - 96) / 5,
                                    child: _buildStatisticsCard(
                                      color: Colors.teal,
                                      icon: Icons.schedule,
                                      title: day,
                                      count: (_schedulesPerDay[day] ?? 0)
                                          .toString(),
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                  const SizedBox(height: 32),
                  Consumer<AnnouncementProvider>(
                    builder: (context, announcementProvider, child) {
                      if (announcementProvider.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final announcements = announcementProvider.items
                          .take(5)
                          .toList();
                      if (announcements.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pengumuman",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...announcements.map(
                            (announcement) => Card(
                              color: isDark
                                  ? Colors.blueGrey[900]
                                  : Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      announcement['title'] ?? '',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.cyan[100]
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      announcement['content'] ?? '',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      announcement['created_at'] != null
                                          ? 'Dibuat: ${DateTime.fromMillisecondsSinceEpoch((announcement['created_at'] as Timestamp).millisecondsSinceEpoch).toString().split(' ')[0]}'
                                          : '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.blueGrey[300]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),
                  Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    color: Colors.teal,
                    icon: Icons.edit_note,
                    title: "Input Nilai Siswa",
                    subtitle: "Masukkan nilai tugas, UTS, dan UAS siswa",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InputNilaiPage()),
                    ),
                  ),
                  _buildMenuCard(
                    color: Colors.green,
                    icon: Icons.schedule,
                    title: "Lihat Jadwal Mengajar",
                    subtitle: "Lihat jadwal pelajaran dan kelas Anda",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LihatJadwalPage(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    color: Colors.indigo,
                    icon: Icons.person_search,
                    title: "Data Siswa Dinilai",
                    subtitle: "Lihat daftar siswa yang sudah dinilai",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DataSiswaDinilaiPage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      "© 2025 Dashboard Guru Brawijaya",
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
