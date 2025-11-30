import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InputNilaiPage extends StatefulWidget {
  const InputNilaiPage({super.key});

  @override
  State<InputNilaiPage> createState() => _InputNilaiPageState();
}

class _InputNilaiPageState extends State<InputNilaiPage> {
  final _fs = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // selections
  String? _selectedKelas;
  String? _selectedJurusan;
  Map<String, dynamic>? _selectedSiswa;

  // teacher info
  String _teacherSubject = '-';
  String? _teacherId;

  // UI state
  bool _loading = true;

  // controllers
  final _tugasCtrl = TextEditingController();
  final _utsCtrl = TextEditingController();
  final _uasCtrl = TextEditingController();

  // choices
  final List<String> _kelasList = ['X', 'XI', 'XII'];
  final List<String> _jurusanList = ['RPL', 'TKJ', 'MM', 'DKV'];
  List<Map<String, dynamic>> _siswaList = [];

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final teacherSnap = await _fs
        .collection('guru')
        .where('user_id', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (teacherSnap.docs.isNotEmpty) {
      final t = teacherSnap.docs.first;
      setState(() {
        _teacherSubject = (t.data()['subject'] ?? '-') as String;
        _teacherId = t.id;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadSiswaByKelasJurusan() async {
    if (_selectedKelas == null || _selectedJurusan == null) return;

    setState(() {
      _selectedSiswa = null;
      _siswaList = [];
      _loading = true;
    });

    try {
      final snap = await _fs
          .collection('siswa')
          .where('kelas', isEqualTo: _selectedKelas)
          .where('jurusan', isEqualTo: _selectedJurusan)
          .get();

      final list = snap.docs.map((d) {
        final m = Map<String, dynamic>.from(d.data() as Map);
        m['id'] = d.id;
        return m;
      }).toList();

      // Query existing grades for this teacher, subject, class, and major
      final gradeSnap = await _fs
          .collection('grade')
          .where('teacher_id', isEqualTo: _teacherId)
          .where('subject', isEqualTo: _teacherSubject)
          .where('kelas', isEqualTo: _selectedKelas)
          .where('jurusan', isEqualTo: _selectedJurusan)
          .get();

      final gradedStudentIds = gradeSnap.docs
          .map((d) => d['student_id'] as String)
          .toSet();

      // Filter out students who have already been graded
      final filteredList = list
          .where((s) => !gradedStudentIds.contains(s['id']))
          .toList();

      setState(() {
        _siswaList = filteredList;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat siswa: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  String _predikatFromScore(double akhir) {
    if (akhir >= 85) return 'A';
    if (akhir >= 75) return 'B';
    if (akhir >= 65) return 'C';
    return 'D';
  }

  Future<void> _saveNilai() async {
    if (!_formKey.currentState!.validate()) return;

    final tugas = int.tryParse(_tugasCtrl.text) ?? 0;
    final uts = int.tryParse(_utsCtrl.text) ?? 0;
    final uas = int.tryParse(_uasCtrl.text) ?? 0;
    final akhir = (tugas * 0.3) + (uts * 0.3) + (uas * 0.4);
    final predikat = _predikatFromScore(akhir);

    if (_selectedSiswa == null ||
        _teacherId == null ||
        _selectedKelas == null ||
        _selectedJurusan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi pilihan siswa/kelas/jurusan terlebih dahulu'),
        ),
      );
      return;
    }

    try {
      await _fs.collection('grade').add({
        'student_id': _selectedSiswa!['id'],
        'student_name': _selectedSiswa!['name'],
        'teacher_id': _teacherId,
        'subject': _teacherSubject,
        'kelas': _selectedKelas,
        'jurusan': _selectedJurusan,
        'tugas': tugas,
        'uts': uts,
        'uas': uas,
        'akhir': akhir,
        'predikat': predikat,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Nilai berhasil disimpan')),
      );

      _tugasCtrl.clear();
      _utsCtrl.clear();
      _uasCtrl.clear();
      setState(() => _selectedSiswa = null);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan nilai: $e')));
    }
  }

  @override
  void dispose() {
    _tugasCtrl.dispose();
    _utsCtrl.dispose();
    _uasCtrl.dispose();
    super.dispose();
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
                  child: Icon(Icons.grade, color: Colors.teal[700], size: 38),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Input Nilai Siswa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mata Pelajaran: $_teacherSubject',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pilih Siswa',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // kelas
                          Card(
                            color: isDark ? Colors.blueGrey[900] : Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedKelas,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Kelas',
                                ),
                                items: _kelasList
                                    .map(
                                      (k) => DropdownMenuItem(
                                        value: k,
                                        child: Text(k),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  setState(() => _selectedKelas = v);
                                  _loadSiswaByKelasJurusan();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // jurusan
                          Card(
                            color: isDark ? Colors.blueGrey[900] : Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedJurusan,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Jurusan',
                                ),
                                items: _jurusanList
                                    .map(
                                      (j) => DropdownMenuItem(
                                        value: j,
                                        child: Text(j),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  setState(() => _selectedJurusan = v);
                                  _loadSiswaByKelasJurusan();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // siswa
                          if (_siswaList.isNotEmpty)
                            Card(
                              color: isDark
                                  ? Colors.blueGrey[900]
                                  : Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child:
                                    DropdownButtonFormField<
                                      Map<String, dynamic>
                                    >(
                                      value: _selectedSiswa,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Nama Siswa',
                                      ),
                                      items: _siswaList
                                          .map(
                                            (s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(
                                                '${s['name']} (${s['nis']})',
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _selectedSiswa = v),
                                    ),
                              ),
                            ),

                          if (_selectedKelas != null && _siswaList.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  'Tidak ada siswa di kelas ini',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),

                          if (_selectedSiswa != null) ...[
                            const Text(
                              'Input Nilai',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Card(
                              color: isDark
                                  ? Colors.blueGrey[900]
                                  : Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _tugasCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Nilai Tugas (30%)',
                                        prefixIcon: Icon(Icons.assignment),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty)
                                          return 'Masukkan nilai tugas';
                                        final n = int.tryParse(v);
                                        if (n == null)
                                          return 'Masukkan angka valid';
                                        if (n < 1 || n > 100)
                                          return 'Nilai harus antara 1 dan 100';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _utsCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Nilai UTS (30%)',
                                        prefixIcon: Icon(Icons.quiz),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty)
                                          return 'Masukkan nilai UTS';
                                        final n = int.tryParse(v);
                                        if (n == null)
                                          return 'Masukkan angka valid';
                                        if (n < 1 || n > 100)
                                          return 'Nilai harus antara 1 dan 100';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _uasCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Nilai UAS (40%)',
                                        prefixIcon: Icon(Icons.assessment),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty)
                                          return 'Masukkan nilai UAS';
                                        final n = int.tryParse(v);
                                        if (n == null)
                                          return 'Masukkan angka valid';
                                        if (n < 1 || n > 100)
                                          return 'Nilai harus antara 1 dan 100';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 18),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.save),
                                        label: const Text('Simpan Nilai'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          backgroundColor: Colors.teal,
                                        ),
                                        onPressed: _saveNilai,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
