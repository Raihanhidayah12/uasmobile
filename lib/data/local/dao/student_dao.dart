import 'package:sqflite/sqflite.dart';
import '../app_db.dart';
import '../../../models/student.dart';

/// Wrapper Student + email user
class StudentWithUser {
  final Student student;
  final String email;

  StudentWithUser({required this.student, required this.email});
}

class StudentDao {
  /// Generate NIS otomatis (mulai 202500000)
  Future<String> generateNextNis() async {
    final db = await AppDb().database;
    final rows = await db.rawQuery(
      'SELECT nis FROM students ORDER BY id DESC LIMIT 1'
    );

    if (rows.isEmpty || rows.first['nis'] == null) {
      return "202500000";
    } else {
      final lastNis = int.tryParse(rows.first['nis'] as String) ?? 202500000;
      return (lastNis + 1).toString();
    }
  }

  /// Hitung jumlah siswa dalam 1 kelas + jurusan
  Future<int> countByClassAndMajor(String kelas, String jurusan) async {
    final db = await AppDb().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM students WHERE kelas = ? AND jurusan = ?',
      [kelas, jurusan],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Insert siswa baru
  Future<int> insert(Student student) async {
    final db = await AppDb().database;

    // ✅ Validasi kapasitas kelas + jurusan
    final total = await countByClassAndMajor(student.kelas, student.jurusan);
    if (total >= 30) {
      throw Exception(
          "Kelas ${student.kelas} - ${student.jurusan} sudah penuh (maks 30 siswa)");
    }

    // 📌 Auto generate NIS jika kosong
    final nis = (student.nis?.isEmpty ?? true)
        ? await generateNextNis()
        : student.nis!;

    return await db.insert(
      'students',
      {
        ...student.toMap(),
        'nis': nis,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Ambil semua siswa (urut per kelas lalu nama)
  Future<List<Student>> getAll() async {
    final db = await AppDb().database;
    final rows = await db.query(
      'students',
      orderBy: 'kelas ASC, name ASC',
    );
    return rows.map((r) => Student.fromMap(r)).toList();
  }

  /// Ambil semua siswa + email user
  Future<List<StudentWithUser>> getAllWithUser() async {
    final db = await AppDb().database;
    final rows = await db.rawQuery('''
      SELECT s.*, u.email 
      FROM students s
      JOIN users u ON u.id = s.user_id
      ORDER BY s.kelas ASC, s.name ASC
    ''');

    return rows.map((r) {
      return StudentWithUser(
        student: Student.fromMap(r),
        email: r['email'] as String,
      );
    }).toList();
  }

  /// Cari siswa berdasarkan id
  Future<Student?> findById(int id) async {
    final db = await AppDb().database;
    final rows = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Student.fromMap(rows.first);
  }

  /// Cari siswa berdasarkan user_id
  Future<Student?> findByUserId(int userId) async {
    final db = await AppDb().database;
    final rows = await db.query(
      'students',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return rows.isEmpty ? null : Student.fromMap(rows.first);
  }

  /// Update data siswa
  Future<int> update(Student student) async {
    final db = await AppDb().database;

    // Jika pindah kelas/jurusan, validasi kuota lagi
    final total = await countByClassAndMajor(student.kelas, student.jurusan);
    if (total >= 30) {
      throw Exception(
          "Kelas ${student.kelas} - ${student.jurusan} sudah penuh (maks 30 siswa)");
    }

    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  /// Hapus siswa
  Future<int> delete(int id) async {
    final db = await AppDb().database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hapus siswa berdasarkan userId
  Future<int> deleteByUserId(int userId) async {
    final db = await AppDb().database;
    return await db.delete(
      'students',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Ambil siswa berdasarkan kelas
  Future<List<Student>> getByKelas(String kelas) async {
    final db = await AppDb().database;
    final rows = await db.query(
      'students',
      where: 'kelas = ?',
      whereArgs: [kelas],
      orderBy: 'name ASC',
    );
    return rows.map((r) => Student.fromMap(r)).toList();
  }
}
