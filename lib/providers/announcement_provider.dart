import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementProvider extends ChangeNotifier {
  final _fs = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _items = [];
  bool _loading = false;

  List<Map<String, dynamic>> get items => _items;
  bool get loading => _loading;

  AnnouncementProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    final snap = await _fs
        .collection('pengumuman')
        .orderBy('created_at', descending: true)
        .get();
    _items = snap.docs.map((d) {
      final m = d.data();
      m['id'] = d.id;
      return m;
    }).toList();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(String judul, String isi) async {
    await _fs.collection('pengumuman').add({
      'title': judul,
      'content': isi,
      'created_at': FieldValue.serverTimestamp(),
    });
    await loadAll();
  }

  Future<void> update(String id, String judul, String isi) async {
    await _fs.collection('pengumuman').doc(id).update({
      'title': judul,
      'content': isi,
      'updated_at': FieldValue.serverTimestamp(),
    });
    await loadAll();
  }

  Future<void> delete(String id) async {
    await _fs.collection('pengumuman').doc(id).delete();
    await loadAll();
  }
}
