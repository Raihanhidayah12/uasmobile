import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LihatJadwalPage extends StatefulWidget {
  const LihatJadwalPage({super.key});

  @override
  State<LihatJadwalPage> createState() => _LihatJadwalPageState();
}

class _LihatJadwalPageState extends State<LihatJadwalPage> {
  List<Map<String, dynamic>> _schedules = [];
  bool _loading = true;
  String? _error;
  String _teacherName = '';
  String _teacherSubject = '';

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'User tidak ditemukan';
          _loading = false;
        });
        return;
      }

      // Find teacher document
      final teacherSnap = await FirebaseFirestore.instance
          .collection('guru')
          .where('user_id', isEqualTo: user.uid)
          .get();

      if (teacherSnap.docs.isEmpty) {
        setState(() {
          _error = 'Data guru tidak ditemukan';
          _loading = false;
        });
        return;
      }

      final teacherData = teacherSnap.docs.first.data();
      _teacherName = teacherData['name'] ?? 'Guru';
      _teacherSubject = teacherData['subject'] ?? '';

      final teacherId = teacherSnap.docs.first.id;

      // Load schedules for this teacher. Avoid server-side composite index
      // requirement by fetching then sorting client-side.
      final scheduleSnap = await FirebaseFirestore.instance
          .collection('jadwal')
          .where('teacher_id', isEqualTo: teacherId)
          .get();

      _schedules = scheduleSnap.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

      // Sort by weekday order (Senin..Jumat) so UI is predictable without
      // requiring Firestore composite indexes. If a day isn't recognized,
      // fall back to string compare.
      final dayOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
      _schedules.sort((a, b) {
        final da = (a['day'] ?? '') as String;
        final db = (b['day'] ?? '') as String;
        final ia = dayOrder.indexOf(da);
        final ib = dayOrder.indexOf(db);
        if (ia == -1 && ib == -1) return da.compareTo(db);
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        return ia.compareTo(ib);
      });

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat jadwal: $e';
        _loading = false;
      });
    }
  }

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
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
      ),
      child: Row(
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
              child: Icon(Icons.schedule, color: Colors.teal[700], size: 46),
            ),
          ),
          const SizedBox(width: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Jadwal Mengajar - $_teacherSubject",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Selamat datang, $_teacherName!",
                style: TextStyle(
                  color: Colors.green[50],
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
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.12),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.arrow_back,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    "Jadwal Mengajar",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : _schedules.isEmpty
                      ? const Center(child: Text("Belum ada jadwal mengajar"))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _schedules.length,
                          itemBuilder: (context, index) {
                            final sched = _schedules[index];
                            return Card(
                              color: isDark
                                  ? Colors.blueGrey[900]
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${sched['subject'] ?? '-'} - ${sched['day'] ?? '-'}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDark
                                            ? Colors.cyan[100]
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Jam: ${sched['time'] ?? '-'}\nKelas: ${sched['kelas'] ?? '-'} ${sched['jurusan'] ?? ''}",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.blueGrey[100]
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
