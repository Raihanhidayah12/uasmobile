import 'package:flutter/material.dart';
import '../../data/local/dao/student_dao.dart';
import '../../data/local/dao/user_dao.dart';
import '../../models/student.dart';
import '../../core/hashing.dart'; // hash password

class CrudSiswaPage extends StatefulWidget {
  const CrudSiswaPage({super.key});

  @override
  State<CrudSiswaPage> createState() => _CrudSiswaPageState();
}

class _CrudSiswaPageState extends State<CrudSiswaPage> {
  final _studentDao = StudentDao();
  final _userDao = UserDao();
  List<StudentWithUser> siswaList = [];
  bool _loading = true;

  final List<String> _kelasList = ['X', 'XI', 'XII'];
  final List<String> _jurusanList = ['RPL', 'TKJ', 'MM', 'DKV'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _loading = true);
      final data = await _studentDao.getAllWithUser();
      // 🚩 Filtering pakai role: hanya siswa aktif
      final filtered = data.where((s) => s.role == 'siswa').toList();
      setState(() {
        siswaList = filtered;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: $e")),
      );
    }
  }

  Map<String, List<StudentWithUser>> _groupByKelas(List<StudentWithUser> data) {
    final Map<String, List<StudentWithUser>> grouped = {};
    for (var s in data) {
      final key = '${s.student.kelas}-${s.student.jurusan}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(s);
    }
    return grouped;
  }

  void _showForm([StudentWithUser? studentWU]) {
    final nisCtrl = TextEditingController(text: studentWU?.student.nis ?? "");
    final nameCtrl = TextEditingController(text: studentWU?.student.name ?? "");
    String selectedKelas = _kelasList.contains(studentWU?.student.kelas)
        ? (studentWU?.student.kelas ?? _kelasList.first)
        : _kelasList.first;
    String selectedJurusan = _jurusanList.contains(studentWU?.student.jurusan)
        ? (studentWU?.student.jurusan ?? _jurusanList.first)
        : _jurusanList.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: isDark ? Colors.blueGrey[900] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 29, horizontal: 28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentWU == null ? "Tambah Siswa" : "Edit Siswa",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Colors.blueAccent),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: nisCtrl,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: "NIS (auto jika kosong)",
                    labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.blueGrey,
                        fontWeight: FontWeight.w500),
                    prefixIcon: const Icon(Icons.confirmation_number),
                    filled: true,
                    fillColor: isDark ? Colors.blueGrey[800] : Colors.blue[50],
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 13),
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: "Nama",
                    labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.blueGrey,
                        fontWeight: FontWeight.w500),
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: isDark ? Colors.blueGrey[800] : Colors.blue[50],
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 13),
                DropdownButtonFormField<String>(
                  value: selectedKelas,
                  decoration: InputDecoration(
                    labelText: "Kelas",
                    labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.blueGrey,
                        fontWeight: FontWeight.w500),
                    prefixIcon: const Icon(Icons.class_),
                    filled: true,
                    fillColor: isDark ? Colors.blueGrey[800] : Colors.blue[50],
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  items: _kelasList
                      .map((kelas) =>
                          DropdownMenuItem(value: kelas, child: Text(kelas)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) selectedKelas = val;
                  },
                ),
                const SizedBox(height: 13),
                DropdownButtonFormField<String>(
                  value: selectedJurusan,
                  decoration: InputDecoration(
                    labelText: "Jurusan",
                    labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.blueGrey,
                        fontWeight: FontWeight.w500),
                    prefixIcon: const Icon(Icons.book),
                    filled: true,
                    fillColor: isDark ? Colors.blueGrey[800] : Colors.blue[50],
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  items: _jurusanList
                      .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) selectedJurusan = val;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? Colors.cyan[200] : Colors.blueGrey,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 13),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 11, horizontal: 20),
                      ),
                      icon: Icon(studentWU == null ? Icons.add : Icons.save),
                      label: Text(studentWU == null ? "Tambah" : "Simpan",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        if (nameCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("⚠️ Nama wajib diisi")),
                          );
                          return;
                        }
                        final count = await _studentDao.countByClassAndMajor(
                            selectedKelas, selectedJurusan);
                        if (studentWU == null && count >= 30) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "🚫 Kelas $selectedKelas - $selectedJurusan sudah penuh (30 siswa)")),
                          );
                          return;
                        }
                        if (studentWU == null) {
                          final username = nameCtrl.text
                              .trim()
                              .toLowerCase()
                              .replaceAll(RegExp(r'\s+'), '');
                          final email = '$username@Brawijaya.com';
                          const rawPass = '123456';
                          final salt = generateSalt();
                          final hash = hashPassword(rawPass, salt);

                          final userId = await _userDao.insert(AppUser(
                            id: null,
                            email: email,
                            passwordHash: hash,
                            salt: salt,
                            role: 'siswa',
                          ));
                          await _studentDao.insert(Student(
                            id: null,
                            userId: userId,
                            nis: nisCtrl.text.isEmpty ? "" : nisCtrl.text,
                            name: nameCtrl.text,
                            kelas: selectedKelas,
                            jurusan: selectedJurusan,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "✅ Siswa & akun berhasil dibuat ($email / $rawPass)")),
                          );
                        } else {
                          await _studentDao.update(Student(
                            id: studentWU.student.id,
                            userId: studentWU.student.userId,
                            nis: nisCtrl.text,
                            name: nameCtrl.text,
                            kelas: selectedKelas,
                            jurusan: selectedJurusan,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("✅ Data siswa diperbarui")),
                          );
                        }
                        if (mounted) {
                          Navigator.pop(context);
                          _loadData();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteStudent(StudentWithUser s) async {
    await _userDao.delete(s.student.userId);
    await _studentDao.delete(s.student.id!);
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🗑️ Siswa & akun berhasil dihapus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grouped = _groupByKelas(siswaList);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kelola Data Siswa",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: Colors.blueAccent,
        shape: const StadiumBorder(),
        child: const Icon(Icons.add),
      ),
      backgroundColor:
          isDark ? const Color(0xFF12121D) : const Color(0xFFF3F9FE),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : siswaList.isEmpty
              ? const Center(child: Text("Belum ada data siswa"))
              : ListView(
                  children: grouped.entries.map((entry) {
                    final key = entry.key;
                    final siswas = entry.value;
                    return ExpansionTile(
                      title: Text(
                        "Kelas $key (${siswas.length}/30)",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      leading:
                          const Icon(Icons.people_alt_rounded, color: Colors.blue),
                      children: siswas.map((s) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19)),
                          elevation: 3,
                          child: ListTile(
                            leading: const Icon(Icons.school, color: Colors.blue),
                            title: Text("${s.student.name} (${s.student.nis})"),
                            subtitle: Text(
                                "${s.student.kelas} - ${s.student.jurusan}\n📧 ${s.email}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () => _showForm(s),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteStudent(s),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
    );
  }
}
