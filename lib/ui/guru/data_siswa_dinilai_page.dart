import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'grade_detail_page.dart';

class DataSiswaDinilaiPage extends StatefulWidget {
  const DataSiswaDinilaiPage({super.key});

  @override
  State<DataSiswaDinilaiPage> createState() => _DataSiswaDinilaiPageState();
}

class _DataSiswaDinilaiPageState extends State<DataSiswaDinilaiPage> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  String? _teacherDocId;
  bool _loadingTeacher = true;

  // no grouping — show flat list like CRUD siswa design
  final Map<String, Map<String, dynamic>> _studentCache = {};

  // fetch students by ids (chunked whereIn on documentId, then fallback to field 'student_id')
  Future<void> _ensureStudents(List<String> ids) async {
    final missing = ids.where((id) => !_studentCache.containsKey(id)).toList();
    if (missing.isEmpty) return;

    // helper to chunk list
    Iterable<List<T>> _chunks<T>(List<T> list, int size) sync* {
      for (var i = 0; i < list.length; i += size) {
        yield list.sublist(i, i + size > list.length ? list.length : i + size);
      }
    }

    // First try fetching by document ID
    final notFound = <String>[];
    for (var chunk in _chunks<String>(missing, 10)) {
      try {
        final snap = await _fs
            .collection('siswa')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        final foundIds = <String>{};
        for (var doc in snap.docs) {
          _studentCache[doc.id] = doc.data();
          foundIds.add(doc.id);
        }
        for (var id in chunk) {
          if (!foundIds.contains(id)) notFound.add(id);
        }
      } catch (_) {
        // if whereIn on documentId fails for any reason, mark all as not found
        notFound.addAll(chunk);
      }
    }

    // Fallback: query by field 'student_id'
    if (notFound.isNotEmpty) {
      for (var chunk in _chunks<String>(notFound, 10)) {
        try {
          final snap = await _fs
              .collection('siswa')
              .where('student_id', whereIn: chunk)
              .get();
          final foundIds = <String>{};
          for (var doc in snap.docs) {
            // try to get id from field or doc id
            final sid = (doc.data())['student_id']?.toString() ?? doc.id;
            _studentCache[sid] = doc.data();
            foundIds.add(sid);
          }
          // remaining not found will be left absent
        } catch (_) {
          // ignore
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTeacherDocId();
  }

  Future<void> _loadTeacherDocId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _teacherDocId = null;
        _loadingTeacher = false;
      });
      return;
    }

    try {
      final snap = await _fs
          .collection('guru')
          .where('user_id', isEqualTo: user.uid)
          .get();
      if (snap.docs.isNotEmpty) {
        setState(() {
          _teacherDocId = snap.docs.first.id;
          _loadingTeacher = false;
        });
      } else {
        setState(() {
          _teacherDocId = null;
          _loadingTeacher = false;
        });
      }
    } catch (_) {
      setState(() {
        _teacherDocId = null;
        _loadingTeacher = false;
      });
    }
  }

  String _computePredikatFromScore(String scoreStr) {
    if (scoreStr.isEmpty ||
        scoreStr == '-' ||
        scoreStr.toLowerCase() == 'null') {
      return 'Tidak Dinilai';
    }
    final num? score = num.tryParse(scoreStr);
    if (score == null) return 'Tidak Dinilai';
    if (score >= 85) return 'A';
    if (score >= 70) return 'B';
    if (score >= 55) return 'C';
    if (score >= 40) return 'D';
    return 'E';
  }

  String _getStudentNameFromCache(String studentId) {
    final data = _studentCache[studentId];
    if (data == null) return 'Nama siswa tidak tersedia';
    return (data['name'] ?? data['nama'] ?? data['student_name'] ?? studentId)
        .toString();
  }

  String _getClassFromCache(String studentId) {
    final data = _studentCache[studentId];
    if (data == null) return '';
    return (data['class'] ?? data['kelas'] ?? '').toString();
  }

  String _getMajorFromCache(String studentId) {
    final data = _studentCache[studentId];
    if (data == null) return '';
    return (data['major'] ?? data['jurusan'] ?? '').toString();
  }

  String _getStudentName(Map<String, dynamic> data) {
    return (data['student_name'] ??
            data['student'] ??
            'Nama siswa tidak tersedia')
        .toString();
  }

  String _extractStudentId(Map<String, dynamic> data, String docId) {
    return (data['student_id'] ?? data['student'] ?? data['studentId'] ?? docId)
        .toString();
  }

  String _getSubject(Map<String, dynamic> data) {
    return (data['subject'] ?? data['mapel'] ?? '').toString();
  }

  String _formatDate(dynamic ts) {
    try {
      if (ts is Timestamp) {
        final dt = ts.toDate();
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget _buildHeader() {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.teal.shade800, Colors.green.shade700]
                : [Colors.teal.shade600, Colors.green.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_search,
                    color: Colors.teal[700],
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Siswa Dinilai',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Lihat daftar siswa yang sudah dinilai',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF12121D)
          : const Color(0xFFF3F9FE),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (_loadingTeacher) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }

            if (_teacherDocId == null) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  const Center(child: Text('Data guru tidak ditemukan.')),
                ],
              );
            }

            return StreamBuilder<QuerySnapshot>(
              stream: _fs
                  .collection('grade')
                  .where('teacher_id', isEqualTo: _teacherDocId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text('Belum ada siswa yang dinilai.'),
                      ),
                    ],
                  );
                }

                final docs = snapshot.data!.docs;

                // ensure we have student details cached (async fire-and-forget)
                final ids = docs
                    .map(
                      (d) => _extractStudentId(
                        d.data() as Map<String, dynamic>? ?? {},
                        d.id,
                      ),
                    )
                    .toSet()
                    .toList();
                // fetch missing students in background
                _ensureStudents(ids);

                // flat list — sort by subject then student name
                final sorted = docs.toList()
                  ..sort((a, b) {
                    final ma = _getSubject(
                      a.data() as Map<String, dynamic>? ?? {},
                    );
                    final mb = _getSubject(
                      b.data() as Map<String, dynamic>? ?? {},
                    );
                    final cmp = ma.compareTo(mb);
                    if (cmp != 0) return cmp;
                    final na = _extractStudentId(
                      a.data() as Map<String, dynamic>? ?? {},
                      a.id,
                    );
                    final nb = _extractStudentId(
                      b.data() as Map<String, dynamic>? ?? {},
                      b.id,
                    );
                    final sa = _studentCache.containsKey(na)
                        ? _getStudentNameFromCache(na)
                        : _getStudentName(
                            a.data() as Map<String, dynamic>? ?? {},
                          );
                    final sb = _studentCache.containsKey(nb)
                        ? _getStudentNameFromCache(nb)
                        : _getStudentName(
                            b.data() as Map<String, dynamic>? ?? {},
                          );
                    return sa.compareTo(sb);
                  });

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Data Siswa Dinilai",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(height: 8),
                          // list of grades as cards
                          ...sorted.map((doc) {
                            final data =
                                doc.data() as Map<String, dynamic>? ?? {};
                            final studentId = _extractStudentId(data, doc.id);
                            final name = _studentCache.containsKey(studentId)
                                ? _getStudentNameFromCache(studentId)
                                : _getStudentName(data);
                            final kelas = _studentCache.containsKey(studentId)
                                ? _getClassFromCache(studentId)
                                : (data['kelas'] ?? data['class'] ?? '')
                                      .toString();
                            final jurusan =
                                data['jurusan']?.toString() ??
                                data['major']?.toString() ??
                                _getMajorFromCache(studentId);
                            final subject = _getSubject(data);
                            final createdAt = _formatDate(data['created_at']);
                            final akhir =
                                (data['akhir'] ??
                                        data['akhir_nilai'] ??
                                        data['final'] ??
                                        data['score'] ??
                                        data['nilai'])
                                    ?.toString() ??
                                '-';
                            final predikat =
                                (data['predikat'] ?? data['grade_predikat'])
                                    ?.toString() ??
                                _computePredikatFromScore(akhir);

                            return Card(
                              color: isDark
                                  ? Colors.blueGrey[900]
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade600,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.school,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  subject.isNotEmpty ? subject : 'Umum',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.cyan[100]
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text(
                                      name,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      [
                                        if (kelas.isNotEmpty) kelas,
                                        if (jurusan.isNotEmpty) jurusan,
                                        if (createdAt.isNotEmpty) createdAt,
                                      ].join(' • '),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.blueGrey[300]
                                            : Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          predikat,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          akhir == '-' ? '' : akhir,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.blueGrey[200]
                                                : Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black54,
                                      ),
                                      onPressed: () async {
                                        // open detail/edit page; if it returns true, refresh state
                                        final result =
                                            await Navigator.of(context).push(
                                              MaterialPageRoute<bool>(
                                                builder: (_) => GradeDetailPage(
                                                  gradeDocId: doc.id,
                                                ),
                                              ),
                                            );
                                        if (result == true && mounted) {
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 30),
                          Center(
                            child: Text(
                              "© 2025 Dashboard Guru Brawijaya",
                              style: TextStyle(
                                color: isDark
                                    ? Colors.blueGrey[300]
                                    : Colors.grey[700],
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
