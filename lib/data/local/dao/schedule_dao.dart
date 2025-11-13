import 'package:sqflite/sqflite.dart';
import '../../../models/schedule.dart';
import '../app_db.dart';

class ScheduleDao {
  Future<int> insert(Schedule schedule) async {
    final db = await AppDb().database;
    return db.insert('schedules', schedule.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<int> update(Schedule schedule) async {
    final db = await AppDb().database;
    return db.update('schedules', schedule.toMap(), where: 'id = ?', whereArgs: [schedule.id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDb().database;
    return db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<Schedule?> findById(int id) async {
    final db = await AppDb().database;
    final rows = await db.query('schedules', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Schedule.fromMap(rows.first);
  }

  Future<List<Schedule>> getAll() async {
    final db = await AppDb().database;
    final rows = await db.query('schedules');
    return rows.map((row) => Schedule.fromMap(row)).toList();
  }
}
