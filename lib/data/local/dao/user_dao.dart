import 'package:sqflite/sqflite.dart';
import '../../../models/user.dart';
import '../app_db.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class UserDao {
  // Generate salt (public)
  String generateSalt([int length = 16]) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64Url.encode(bytes);
  }

  // Hash password: gabungkan SALT + PASSWORD (order penting)
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(salt + password); // SALT + PASSWORD (BENAR)
    final digest = sha256.convert(bytes);
    return digest.toString();
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
}

class AppUser {
  final int? id;
  final String email;
  final String passwordHash;
  final String salt;
  final String role;
  String? password; // tidak perlu simpan plain password, hanya untuk regis

  AppUser({
    this.id,
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.role,
    this.password,
  });

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
        id: map['id'] as int?,
        email: map['email'] as String,
        passwordHash: map['password_hash'] as String,
        salt: map['salt'] as String,
        role: map['role'] as String,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'email': email,
        'password_hash': passwordHash,
        'salt': salt,
        'role': role,
      };
}
