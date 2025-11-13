import 'package:sqflite/sqflite.dart';
import '../../../models/user.dart';
import '../app_db.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class UserDao {
  /// 🔐 Hash password sederhana (gunakan algoritma SHA256)
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 🧂 Generate salt acak
  String _generateSalt() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<AppUser?> findByEmail(String email) async {
    final db = await AppDb().database;
    final rows = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<AppUser?> findById(int id) async {
    final db = await AppDb().database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<AppUser?> findByUsername(String username) async {
    final db = await AppDb().database;
    final rows = await db.query('users', where: 'email = ?', whereArgs: [username]);
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<List<AppUser>> getAll() async {
    final db = await AppDb().database;
    final rows = await db.query('users');
    return rows.map((row) => AppUser.fromMap(row)).toList();
  }

  Future<int> insert(AppUser user) async {
    final db = await AppDb().database;
    return db.insert(
      'users',
      {
        'email': user.email,
        'password_hash': user.passwordHash,
        'salt': user.salt,
        'role': user.role,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> update(AppUser user) async {
    final db = await AppDb().database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> updateRole(int id, String role) async {
    final db = await AppDb().database;
    return db.update(
      'users',
      {'role': role},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDb().database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteByEmail(String email) async {
    final db = await AppDb().database;
    return db.delete('users', where: 'email = ?', whereArgs: [email]);
  }

  /// ✅ Helper: Approve siswa_pending → siswa
  Future<int> approveAsSiswa(int id) async {
    return updateRole(id, "siswa");
  }

  /// ✅ Helper: Tolak siswa_pending → hapus akun
  Future<int> rejectUser(int id) async {
    return delete(id);
  }

  /// 🧑‍🎓 Buat akun login otomatis untuk siswa baru
  Future<int> createUserForStudent(String name) async {
    final db = await AppDb().database;

    // username/email dibuat dari nama siswa (tanpa spasi)
    final username = name.trim().toLowerCase().replaceAll(' ', '');
    final defaultPassword = "123456";
    final salt = _generateSalt();
    final hash = _hashPassword(defaultPassword, salt);

    return db.insert(
      'users',
      {
        'email': username, // username juga sebagai email/identifier login
        'password_hash': hash,
        'salt': salt,
        'role': 'siswa',
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// 🧼 Hapus akun & siswa (jika ingin 1 tombol)
  Future<void> deleteUserAndStudent(int userId) async {
    final db = await AppDb().database;
    await db.delete('students', where: 'user_id = ?', whereArgs: [userId]);
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }
}
