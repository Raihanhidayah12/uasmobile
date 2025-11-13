import 'package:sqflite/sqflite.dart';
import '../../../models/announcement.dart';
import '../app_db.dart';

class AnnouncementDao {
  Future<int> insert(Announcement ann) async {
    final db = await AppDb().database;
    return db.insert('announcements', ann.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<int> update(Announcement ann) async {
    final db = await AppDb().database;
    return db.update('announcements', ann.toMap(), where: 'id = ?', whereArgs: [ann.id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDb().database;
    return db.delete('announcements', where: 'id = ?', whereArgs: [id]);
  }

  Future<Announcement?> findById(int id) async {
    final db = await AppDb().database;
    final rows = await db.query('announcements', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Announcement.fromMap(rows.first);
  }

  Future<List<Announcement>> getAll() async {
    final db = await AppDb().database;
    final rows = await db.query('announcements');
    return rows.map((row) => Announcement.fromMap(row)).toList();
  }
}
