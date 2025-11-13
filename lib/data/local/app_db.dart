import 'dart:io';
import 'package:login_db_demo/core/hashing.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AppDb {
  static final AppDb _i = AppDb._();
  AppDb._();
  factory AppDb() => _i;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    // 📂 Folder project/data/db
    final projectDir = Directory.current.path;
    final dbDir = Directory(p.join(projectDir, 'data', 'db'));

    // Buat folder kalau belum ada
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    // 📂 Path database
    final path = p.join(dbDir.path, 'akademik.db');
    print('📂 Database disimpan di: $path');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        // ✅ Users (login semua role)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            salt TEXT NOT NULL,
            role TEXT NOT NULL
          )
        ''');

        // ✅ Students (profil siswa)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            nis TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            kelas TEXT NOT NULL,
            jurusan TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');

        // ✅ Teachers (profil guru)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS teachers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            nip TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            subject TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');

        // ✅ Schedules (jadwal pelajaran)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS schedules (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            day TEXT NOT NULL,
            time TEXT NOT NULL,
            subject TEXT NOT NULL,
            teacher_id INTEGER,
            FOREIGN KEY (teacher_id) REFERENCES teachers(id)
          )
        ''');

        // ✅ Grades (nilai rapor)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS grades (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER,
            subject TEXT NOT NULL,
            tugas REAL,
            uts REAL,
            uas REAL,
            final_score REAL,
            grade TEXT,
            FOREIGN KEY (student_id) REFERENCES students(id)
          )
        ''');

        // ✅ Announcements (pengumuman sekolah)
        await db.execute('''
          CREATE TABLE IF NOT EXISTS announcements (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        // ✅ Seed data: admin default
        const rawPass = 'admin123';
        const salt = 'default';
        final hash = hashPassword(rawPass, salt);

        await db.insert('users', {
          'email': 'admin@sekolah.com',
          'password_hash': hash,
          'salt': salt,
          'role': 'admin',
        });

        print("✅ Admin default dibuat: admin@sekolah.com / $rawPass");
      },
    );

    return _db!;
  }
}
