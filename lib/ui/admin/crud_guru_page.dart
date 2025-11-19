import 'package:flutter/material.dart';
import '../../data/local/dao/teacher_dao.dart';
import '../../data/local/dao/user_dao.dart';
import '../../models/teacher.dart';

class CrudGuruPage extends StatefulWidget {
  const CrudGuruPage({super.key});

  @override
  State<CrudGuruPage> createState() => _CrudGuruPageState();
}

class _CrudGuruPageState extends State<CrudGuruPage> {
  final _teacherDao = TeacherDao();
  final _userDao = UserDao();
  List<Teacher> guruList = [];
  bool _loading = true;

  static const String domain = "@Brawijaya.com";
  final List<String> mapelList = [
    "Matematika", "Bahasa Indonesia", "Bahasa Inggris", "IPA", "IPS",
    "PKN", "Seni Budaya", "Penjaskes", "Agama",
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _loading = true);
      final data = await _teacherDao.getAllWithEmail();
      setState(() {
        guruList = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: $e")),
      );
    }
  }

  Future<void> _showForm([Teacher? guru]) async {
    final nameCtrl = TextEditingController(text: guru?.name ?? "");
    String subject = (guru != null && mapelList.contains(guru.subject))
        ? guru.subject
        : mapelList.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          insetPadding: const EdgeInsets.all(27),
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 27, horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  guru == null ? "➕ Tambah Guru" : "✏ Edit Guru",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                    color: Colors.blueAccent,
                    letterSpacing: .9,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: "Nama Lengkap Guru",
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: isDark ? Colors.blueGrey[800] : Colors.blue[50],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 13),
                DropdownButtonFormField<String>(
                  value: subject,
                  icon: const Icon(Icons.arrow_drop_down),
                  dropdownColor: isDark ? Colors.blueGrey[900] : Colors.white,
                  decoration: InputDecoration(
                    labelText: "Mata Pelajaran",
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.book_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  items: mapelList
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() {
                    subject = val ?? mapelList.first;
                  }),
                ),
                if (guru != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: Text(
                      "Username: ${guru.email}\nPassword: ${guru.nip}",
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.cyan[100] : Colors.grey[700]),
                    ),
                  ),
                const SizedBox(height: 21),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? Colors.blue[100] : Colors.blueGrey,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 9),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      ),
                      icon: const Icon(Icons.save, size: 20),
                      label: Text(guru == null ? "Tambah" : "Simpan", style: const TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        if (nameCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("⚠️ Nama wajib diisi")),
                          );
                          return;
                        }
                        if (guru == null) {
                          final username = nameCtrl.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), "");
                          final email = "$username$domain";
                          final existed = await _userDao.findByEmail(email);
                          if (existed != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Username sudah terdaftar.")),
                            );
                            return;
                          }
                          final nipBaru = await _teacherDao.generateNextNip();
                          final salt = _userDao.generateSalt();
                          final hash = _userDao.hashPassword(nipBaru, salt);
                          final user = AppUser(
                            id: null,
                            email: email,
                            passwordHash: hash,
                            salt: salt,
                            role: "guru",
                          );
                          final userId = await _userDao.insert(user);
                          await _teacherDao.insert(Teacher(
                            id: null,
                            userId: userId,
                            nip: nipBaru,
                            name: nameCtrl.text,
                            subject: subject,
                            email: "",
                          ));
                          Navigator.pop(context);
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Akun guru berhasil dibuat!\nUsername: $email\nPassword: $nipBaru (NIP)")),
                          );
                        } else {
                          await _teacherDao.update(Teacher(
                            id: guru.id,
                            userId: guru.userId,
                            nip: guru.nip,
                            name: nameCtrl.text,
                            subject: subject,
                            email: "",
                          ));
                          Navigator.pop(context);
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Data guru diperbarui")),
                          );
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteGuru(Teacher g) async {
    if (g.userId > 0) {
      await _userDao.delete(g.userId);
    }
    await _teacherDao.delete(g.id!);
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🗑️ Guru & akun user dihapus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Guru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, letterSpacing: 0.5)),
        elevation: 1.8,
        backgroundColor: Colors.blueAccent,
        leading: const BackButton(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, size: 28),
        shape: const StadiumBorder(),
      ),
      backgroundColor: isDark ? const Color(0xFF161825) : const Color(0xFFEFEFFD),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : guruList.isEmpty
              ? Center(
                  child: Text("Belum ada data guru",
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      )),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 11),
                  itemCount: guruList.length,
                  itemBuilder: (context, i) {
                    final g = guruList[i];
                    return Card(
                      elevation: 6,
                      shadowColor: Colors.green.withOpacity(.21),
                      color: isDark ? Colors.blueGrey[900] : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Icon(Icons.person, color: Colors.indigo[700], size: 30),
                          radius: 26,
                        ),
                        title: Text("${g.name}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.cyan[100] : Colors.green[700],
                              fontSize: 17.5,
                            )),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // THIS FIX THE GAP!
                          children: [
                            const SizedBox(height: 4),
                            Text("NIP    : ${g.nip}", style: TextStyle(color: isDark ? Colors.blue[50] : Colors.blueGrey[700], fontSize: 13.4, fontWeight: FontWeight.w600)),
                            Text("Mapel : ${g.subject}", style: TextStyle(color: isDark ? Colors.greenAccent : Colors.teal[700], fontSize: 13.2, fontWeight: FontWeight.w600)),
                            Text("Email : ${g.email}", style: TextStyle(color: isDark ? Colors.white38 : Colors.blueGrey[400], fontSize: 13)),
                          ],
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange, size: 24),
                              tooltip: "Edit data guru",
                              onPressed: () => _showForm(g),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                              tooltip: "Hapus",
                              onPressed: () => _deleteGuru(g),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
