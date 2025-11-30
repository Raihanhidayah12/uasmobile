import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GradeDetailPage extends StatefulWidget {
  final String gradeDocId;
  const GradeDetailPage({super.key, required this.gradeDocId});

  @override
  State<GradeDetailPage> createState() => _GradeDetailPageState();
}

class _GradeDetailPageState extends State<GradeDetailPage> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tugasC = TextEditingController();
  final TextEditingController _utsC = TextEditingController();
  final TextEditingController _uasC = TextEditingController();
  final TextEditingController _akhirC = TextEditingController();
  final TextEditingController _predikatC = TextEditingController();

  bool _initialized = false;
  bool _saving = false;

  String _formatDate(dynamic ts) {
    try {
      if (ts is Timestamp) {
        final dt = ts.toDate();
        return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      }
    } catch (_) {}
    return '';
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

  Future<void> _save(DocumentSnapshot doc) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final docRef = _fs.collection('grade').doc(widget.gradeDocId);
    final Map<String, dynamic> update = {};

    void putParsed(String key, TextEditingController c) {
      final v = c.text.trim();
      if (v.isEmpty) return;
      final parsed = num.tryParse(v);
      update[key] = parsed ?? v;
    }

    putParsed('tugas', _tugasC);
    putParsed('uts', _utsC);
    putParsed('uas', _uasC);
    putParsed('akhir', _akhirC);
    update['predikat'] = _predikatC.text.trim();

    try {
      if (update.isNotEmpty) {
        await docRef.update(update);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Perubahan tersimpan')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _tugasC.dispose();
    _utsC.dispose();
    _uasC.dispose();
    _akhirC.dispose();
    _predikatC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                child: Icon(Icons.edit_note, color: Colors.teal[700], size: 46),
              ),
            ),
            const SizedBox(width: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Detail / Edit Nilai",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Kelola nilai siswa",
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

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF12121D)
          : const Color(0xFFF3F9FE),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: _fs.collection('grade').doc(widget.gradeDocId).snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }
            if (!snap.hasData || !snap.data!.exists) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  const Center(child: Text('Data nilai tidak ditemukan.')),
                ],
              );
            }
            final doc = snap.data!;
            final data = doc.data() as Map<String, dynamic>? ?? {};

            if (!_initialized) {
              _tugasC.text = (data['tugas'] ?? data['tugas_nilai'] ?? '')
                  .toString();
              _utsC.text = (data['uts'] ?? '').toString();
              _uasC.text = (data['uas'] ?? '').toString();
              _akhirC.text =
                  (data['akhir'] ??
                          data['final'] ??
                          data['score'] ??
                          data['nilai'] ??
                          '')
                      .toString();
              _predikatC.text =
                  (data['predikat'] ?? data['grade_predikat'] ?? '').toString();
              _initialized = true;
            }

            final subject = (data['subject'] ?? data['mapel'] ?? '').toString();
            final student =
                (data['student_name'] ??
                        data['student'] ??
                        data['student_id'] ??
                        doc.id)
                    .toString();
            final created = _formatDate(data['created_at']);

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: isDark ? Colors.blueGrey[900] : Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mata Pelajaran: $subject',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: isDark
                                    ? Colors.cyan[100]
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Siswa: $student',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (created.isNotEmpty)
                              Text(
                                'Tanggal: $created',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.blueGrey[300]
                                      : Colors.grey[600],
                                ),
                              ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _akhirC,
                              decoration: InputDecoration(
                                labelText: 'Nilai Akhir',
                                labelStyle: TextStyle(
                                  color: isDark
                                      ? Colors.cyan[100]
                                      : Colors.black87,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final num? score = num.tryParse(v.trim());
                                if (score == null)
                                  return 'Masukkan angka yang valid';
                                if (score > 100)
                                  return 'Nilai tidak boleh lebih dari 100';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _utsC,
                              decoration: InputDecoration(
                                labelText: 'Nilai UTS',
                                labelStyle: TextStyle(
                                  color: isDark
                                      ? Colors.cyan[100]
                                      : Colors.black87,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final num? score = num.tryParse(v.trim());
                                if (score == null)
                                  return 'Masukkan angka yang valid';
                                if (score > 100)
                                  return 'Nilai tidak boleh lebih dari 100';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _uasC,
                              decoration: InputDecoration(
                                labelText: 'Nilai UAS',
                                labelStyle: TextStyle(
                                  color: isDark
                                      ? Colors.cyan[100]
                                      : Colors.black87,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final num? score = num.tryParse(v.trim());
                                if (score == null)
                                  return 'Masukkan angka yang valid';
                                if (score > 100)
                                  return 'Nilai tidak boleh lebih dari 100';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _akhirC,
                              decoration: InputDecoration(
                                labelText: 'Nilai Akhir',
                                labelStyle: TextStyle(
                                  color: isDark
                                      ? Colors.cyan[100]
                                      : Colors.black87,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                if (num.tryParse(v.trim()) == null)
                                  return 'Masukkan angka yang valid';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _predikatC,
                              decoration: InputDecoration(
                                labelText: 'Predikat (A/B/C/D/E)',
                                labelStyle: TextStyle(
                                  color: isDark
                                      ? Colors.cyan[100]
                                      : Colors.black87,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) => null,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _saving
                                        ? null
                                        : () => _save(doc),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _saving
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Simpan'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      final computed =
                                          _computePredikatFromScore(
                                            _akhirC.text.trim(),
                                          );
                                      setState(
                                        () => _predikatC.text = computed,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Predikat dihitung otomatis',
                                          ),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: Colors.teal),
                                      ),
                                    ),
                                    child: const Text('Hitung Predikat'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }
}
