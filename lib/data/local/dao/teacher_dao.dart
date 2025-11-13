import 'package:sqflite/sqflite.dart';
import '../../../models/teacher.dart';
import '../app_db.dart';

class TeacherDao {
  Future<int> insert(Teacher teacher) async {
    final db = await AppDb().database;
    return db.insert('teachers', teacher.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<int> update(Teacher teacher) async {
    final db = await AppDb().database;
    return db.update('teachers', teacher.toMap(), where: 'id = ?', whereArgs: [teacher.id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDb().database;
    return db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }

  Future<Teacher?> findById(int id) async {
    final db = await AppDb().database;
    final rows = await db.query('teachers', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Teacher.fromMap(rows.first);
  }

  Future<List<Teacher>> getAll() async {
    final db = await AppDb().database;
    final rows = await db.query('teachers');
    return rows.map((row) => Teacher.fromMap(row)).toList();
  }
}
