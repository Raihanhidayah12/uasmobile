import 'package:flutter/foundation.dart';
import '../data/local/dao/schedule_dao.dart';
import '../models/schedule.dart';

class ScheduleProvider extends ChangeNotifier {
  final ScheduleDao _dao = ScheduleDao();
  List<Schedule> _items = [];
  bool _loading = false;

  List<Schedule> get items => _items;
  bool get loading => _loading;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    _items = await _dao.getAll();
    _loading = false;
    notifyListeners();
  }

  Future<void> loadByKelasJurusan(String kelas, String jurusan) async {
    _loading = true;
    notifyListeners();
    _items = await _dao.getByKelasJurusan(kelas, jurusan);
    _loading = false;
    notifyListeners();
  }

  Future<void> add(Schedule s) async {
    await _dao.insert(s);
    await loadAll();
  }

  Future<void> update(Schedule s) async {
    await _dao.update(s);
    await loadAll();
  }

  Future<void> delete(int id) async {
    await _dao.delete(id);
    await loadAll();
  }
}
