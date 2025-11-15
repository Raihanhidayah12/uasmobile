import 'package:flutter/material.dart';
import '../data/local/dao/announcement_dao.dart';
import '../models/announcement.dart';

class AnnouncementProvider extends ChangeNotifier {
  final AnnouncementDao _dao = AnnouncementDao();

  List<Announcement> _items = [];
  bool _loading = false;

  List<Announcement> get items => _items;
  bool get loading => _loading;

  AnnouncementProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    _items = await _dao.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> add(String judul, String isi) async {
    await _dao.insert(
      Announcement(
        title: judul,
        content: isi,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
    await loadAll();
  }

  Future<void> update(Announcement a) async {
    await _dao.update(a);
    await loadAll();
  }

  Future<void> delete(int id) async {
    await _dao.delete(id);
    await loadAll();
  }
}
