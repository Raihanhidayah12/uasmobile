import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../utils/pdf_helper.dart';

class RaporPage extends StatefulWidget {
  const RaporPage({super.key});

  @override
  State<RaporPage> createState() => _RaporPageState();
}

class _RaporPageState extends State<RaporPage> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  bool _loading = true;
  String _nama = '';
  String _nis = '';
  List<Map<String, dynamic>> _nilai = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'User tidak ditemukan';
        _loading = false;
      });
      return;
    }

    try {
      // find siswa doc by user_id
      final sSnap = await _fs
          .collection('siswa')
          .where('user_id', isEqualTo: user.uid)
          .limit(1)
          .get();
      if (sSnap.docs.isEmpty) {
        setState(() {
          _error = 'Data siswa tidak ditemukan';
          _loading = false;
        });
        return;
      }

      final s = sSnap.docs.first.data();
      final siswaId = sSnap.docs.first.id;
      _nama = (s['name'] ?? s['nama'] ?? '') as String;
      _nis = (s['nis'] ?? '') as String;

      // load grades for this student
      final gSnap = await _fs
          .collection('grade')
          .where('student_id', isEqualTo: siswaId)
          .get();
      _nilai = gSnap.docs.map((d) {
        final data = Map<String, dynamic>.from(
          d.data() as Map<String, dynamic>,
        );
        return {
          'subject': data['subject'] ?? '',
          'tugas': data['tugas'] ?? 0,
          'uts': data['uts'] ?? 0,
          'uas': data['uas'] ?? 0,
          'final': data['akhir'] ?? data['final'] ?? 0,
          'predikat': data['predikat'] ?? '',
        };
      }).toList();

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat rapor: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rapor Siswa')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rapor Siswa')),
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Rapor Siswa')),
      body: PdfPreview(
        build: (format) => PdfHelper.generateRapor(
          nama: _nama.isNotEmpty
              ? _nama
              : (FirebaseAuth.instance.currentUser?.email ?? ''),
          nis: _nis.isNotEmpty ? _nis : '-',
          nilai: _nilai,
        ),
      ),
    );
  }
}
