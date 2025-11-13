import 'package:flutter/material.dart';
import '../../data/local/dao/student_dao.dart';
import '../../data/local/dao/user_dao.dart';
import '../../models/student.dart';
import '../../models/user.dart';
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

  // ✅ Opsi kelas dan jurusan
  final List<String> _kelasList = ['X', 'XI', 'XII'];
  final List<String> _jurusanList = ['RPL', 'TKJ', 'MM', 'DKV'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await _studentDao.getAllWithUser();
    setState(() {
      siswaList = data;
      _loading = false;
    });
  }

  /// 📊 Group siswa berdasarkan kelas & jurusan
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

    // 🛠 Pastikan value dropdown valid
    String selectedKelas = _kelasList.contains(studentWU?.student.kelas)
        ? (studentWU?.student.kelas ?? _kelasList.first)
        : _kelasList.first;

    String selectedJurusan = _jurusanList.contains(studentWU?.student.jurusan)
        ? (studentWU?.student.jurusan ?? _jurusanList.first)
        : _jurusanList.first;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(studentWU == null ? "Tambah Siswa" : "Edit Siswa"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nisCtrl,
                decoration: const InputDecoration(
                  labelText: "NIS (kosongkan untuk auto-generate)",
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
              ),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Nama",
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedKelas,
                decoration: const InputDecoration(
                  labelText: "Kelas",
                  prefixIcon: Icon(Icons.class_),
                ),
                items: _kelasList
                    .map((kelas) =>
                        DropdownMenuItem(value: kelas, child: Text(kelas)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) selectedKelas = val;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedJurusan,
                decoration: const InputDecoration(
                  labelText: "Jurusan",
                  prefixIcon: Icon(Icons.book),
                ),
                items: _jurusanList
                    .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) selectedJurusan = val;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Simpan"),
            onPressed: () async {
              if (nameCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("⚠️ Nama wajib diisi")),
                );
                return;
              }

              // 🚫 Validasi maksimal 30 siswa per kelas & jurusan
              final count = await _studentDao.countByClassAndMajor(
                  selectedKelas, selectedJurusan);
              if (studentWU == null && count >= 30) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "🚫 Kelas $selectedKelas - $selectedJurusan sudah penuh (30 siswa)"),
                  ),
                );
                return;
              }

              if (studentWU == null) {
                // 🆕 Buat akun user otomatis
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

                // 🧑 Insert data siswa
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
                // ✏️ Update data siswa
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
    );
  }

  Future<void> _deleteStudent(StudentWithUser s) async {
    // 🧹 Hapus akun + data siswa
    if (s.student.userId != null) {
      await _userDao.delete(s.student.userId!);
    }
    await _studentDao.delete(s.student.id!);
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🗑️ Siswa & akun berhasil dihapus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByKelas(siswaList);

    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Data Siswa")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      children: siswas.map((s) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.school,
                                color: Colors.blue),
                            title: Text("${s.student.name} (${s.student.nis})"),
                            subtitle: Text(
                              "${s.student.kelas} - ${s.student.jurusan}\n📧 ${s.email}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.orange),
                                  onPressed: () => _showForm(s),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
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
