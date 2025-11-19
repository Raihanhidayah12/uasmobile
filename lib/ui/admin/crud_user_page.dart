import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/local/dao/user_dao.dart';
import '../../data/local/dao/student_dao.dart';
import '../../data/local/dao/teacher_dao.dart';
import '../../models/student.dart';
import '../../models/teacher.dart';

class CrudUserPage extends StatefulWidget {
  const CrudUserPage({super.key});
  @override
  State<CrudUserPage> createState() => _CrudUserPageState();
}

class _CrudUserPageState extends State<CrudUserPage> {
  final _userDao = UserDao();
  final _studentDao = StudentDao();
  final _teacherDao = TeacherDao();

  List<AppUser> _users = [];
  bool _loading = true;
  static const String domain = "@Brawijaya.com";

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Color getTextColor(Color bg) =>
      bg.computeLuminance() < 0.5 ? Colors.white : Colors.black;

  void showAccountSuccessNotif(String role, String email, String password) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.20),
      builder: (c) => Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 410),
          tween: Tween(begin: 0.8, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF38ef7d), Color(0xFF11998e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.31),
                  blurRadius: 27,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, color: Colors.white, size: 48),
                  const SizedBox(height: 13),
                  Text(
                    "Akun ${role.toUpperCase()} berhasil dibuat!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 19.6,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    "Password (NIS/NIP):",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 18,
                    ),
                    margin: const EdgeInsets.only(bottom: 8, top: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.90),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      password,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Consolas',
                        fontWeight: FontWeight.bold,
                        fontSize: 16.5,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Text(
                    "Segera ganti password setelah login.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.81),
                      fontSize: 12.3,
                    ),
                  ),
                  const SizedBox(height: 9),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: const Text("OK"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final users = await _userDao.getAll();
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  Future<void> _addUserDialog() async {
    final nameCtrl = TextEditingController();
    String role = "siswa";
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Tambah Akun Baru"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nama Lengkap",
                    prefixIcon: Icon(Icons.person),
                    helperText: "Nama asli user",
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(
                    labelText: "Role",
                    prefixIcon: Icon(Icons.person_3_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: "siswa", child: Text("Siswa")),
                    DropdownMenuItem(value: "guru", child: Text("Guru")),
                  ],
                  onChanged: (val) => setState(() {
                    role = val ?? "siswa";
                  }),
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
                final userName = nameCtrl.text.trim().toLowerCase().replaceAll(
                  RegExp(r'\s+'),
                  '',
                );
                final email = "$userName$domain";
                final existedUser = await _userDao.findByEmail(email);
                if (existedUser != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "⚠️ Email/Nama sudah terdaftar! Masukkan nama lain.",
                      ),
                    ),
                  );
                  return;
                }
                String numberId;
                if (role == "siswa") {
                  numberId = await _studentDao.generateNextNis();
                } else {
                  numberId = await _teacherDao.generateNextNip();
                }
                final password = numberId;
                final salt = _userDao.generateSalt();
                final hash = _userDao.hashPassword(password, salt);
                final user = AppUser(
                  id: null,
                  email: email,
                  passwordHash: hash,
                  salt: salt,
                  role: role,
                );
                final userId = await _userDao.insert(user);

                if (role == "siswa") {
                  await _studentDao.insert(
                    Student(
                      id: null,
                      userId: userId,
                      nis: numberId,
                      name: nameCtrl.text,
                      kelas: "-",
                      jurusan: "-",
                    ),
                  );
                } else {
                  try {
                    await _teacherDao.insert(
                      Teacher(
                        id: null,
                        userId: userId,
                        nip: numberId,
                        name: nameCtrl.text,
                        subject: "-",
                        email: '',
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '❌ Gagal tambah guru di tabel teachers: $e',
                        ),
                      ),
                    );
                    await _userDao.delete(userId);
                    return;
                  }
                }
                if (!mounted) return;
                Navigator.pop(context);
                _loadUsers();
                showAccountSuccessNotif(role, email, password);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editUserDialog(AppUser user) async {
    if (user.role == "siswa_pending") return;
    final nameCtrl = TextEditingController(text: user.email.split('@').first);
    String role = user.role;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Akun"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Username",
                prefixIcon: Icon(Icons.person),
                helperText: "Email akan otomatis @Brawijaya.com",
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(
                labelText: "Role",
                prefixIcon: Icon(Icons.person),
              ),
              items: const [
                DropdownMenuItem(value: "siswa", child: Text("Siswa")),
                DropdownMenuItem(value: "guru", child: Text("Guru")),
              ],
              onChanged: (val) => role = val ?? user.role,
            ),
          ],
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
                  const SnackBar(content: Text("⚠️ Username wajib diisi")),
                );
                return;
              }
              final email = "${nameCtrl.text.trim()}$domain";
              final updatedUser = AppUser(
                id: user.id,
                email: email,
                passwordHash: user.passwordHash,
                salt: user.salt,
                role: role,
              );
              await updateRoleAndSync(
                updatedUser.id!,
                role,
                nameCtrl.text.trim(),
                kelas: "XI",
                jurusan: "RPL",
                subject: "Matematika",
              );
              if (!mounted) return;
              Navigator.pop(context);
              _loadUsers();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Akun berhasil diperbarui")),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text("Yakin ingin menghapus user ${user.email}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _userDao.delete(user.id!);
      _loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🗑️ User ${user.email} berhasil dihapus")),
      );
    }
  }

  Future<void> updateRoleAndSync(
    int userId,
    String newRole,
    String name, {
    required String kelas,
    required String jurusan,
    required String subject,
  }) async {
    await _userDao.updateRole(userId, newRole);
    if (newRole == "guru") {
      await _studentDao.deleteByUserId(userId);
      final exists = await _teacherDao.findByUserId(userId);
      if (exists == null) {
        final nipBaru = await _teacherDao.generateNextNip();
        await _teacherDao.insert(
          Teacher(
            id: null,
            userId: userId,
            nip: nipBaru,
            name: name,
            subject: subject,
            email: '',
          ),
        );
      }
    } else if (newRole == "siswa") {
      await _teacherDao.deleteByUserId(userId);
      final exists = await _studentDao.findByUserId(userId);
      if (exists == null) {
        final nisBaru = await _studentDao.generateNextNis();
        await _studentDao.insert(
          Student(
            id: null,
            userId: userId,
            nis: nisBaru,
            name: name,
            kelas: kelas,
            jurusan: jurusan,
          ),
        );
      }
    }
  }

  Widget _buildUserList(String title, List<AppUser> users, String role) {
    return ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(Icons.people_alt_rounded, color: Colors.blueAccent),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.5),
      ),
      children: users.map((u) {
        final isPending = u.role == "siswa_pending";
        final userColor = u.role == "guru"
            ? const Color(0xFFD7C8EF).withOpacity(0.92)
            : u.role == "siswa"
            ? const Color(0xFFD9F3FF).withOpacity(0.92)
            : const Color(0xFFFFEDD6).withOpacity(0.93);
        final textColor = getTextColor(userColor);

        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.4, sigmaY: 3.4),
            child: Card(
              color: userColor,
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(
                  color: isPending
                      ? Colors.orange.withOpacity(0.38)
                      : Colors.grey[300]!,
                  width: isPending ? 2.2 : 1,
                ),
              ),
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 15,
                ),
                leading: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: isPending
                          ? Colors.orange[200]
                          : u.role == "guru"
                          ? Colors.deepPurple[200]
                          : Colors.blue[200],
                      child: Icon(
                        isPending
                            ? Icons.hourglass_bottom_rounded
                            : u.role == "guru"
                            ? Icons.school
                            : Icons.person,
                        color: isPending
                            ? Colors.deepOrange
                            : u.role == "guru"
                            ? Colors.deepPurple
                            : Colors.blue,
                        size: 28,
                      ),
                    ),
                    if (u.role == "guru")
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Text(
                          "GURU",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (u.role == "siswa")
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Text(
                          "SISWA",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  u.email,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 3.5),
                  child: Text(
                    isPending ? "MENUNGGU VERIFIKASI" : "Role: ${u.role}",
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isPending
                          ? Colors.deepOrange[700]
                          : textColor.withOpacity(0.80),
                      fontWeight: isPending ? FontWeight.bold : FontWeight.w500,
                      letterSpacing: 0.02,
                    ),
                  ),
                ),
                trailing: isPending
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.green[100]!.withOpacity(
                                0.60,
                              ),
                            ),
                            child: const Text(
                              "YES",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            onPressed: () async {
                              await _userDao.updateRole(u.id!, "siswa");
                              await _studentDao.insert(
                                Student(
                                  id: null,
                                  userId: u.id!,
                                  nis: await _studentDao.generateNextNis(),
                                  name: u.email.split('@').first,
                                  kelas: "-",
                                  jurusan: "-",
                                ),
                              );
                              _loadUsers();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        color: Colors.greenAccent,
                                        size: 21,
                                      ),
                                      SizedBox(width: 7),
                                      Text(
                                        "Aktivasi berhasil: user ini jadi Siswa",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.black87,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 5),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red[700],
                              backgroundColor: Colors.red[100]!.withOpacity(
                                0.45,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "NO",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            onPressed: () async {
                              await _userDao.delete(u.id!);
                              _loadUsers();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_forever,
                                        color: Colors.redAccent,
                                        size: 21,
                                      ),
                                      SizedBox(width: 7),
                                      Text(
                                        "Akun pending telah DIHAPUS",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.black87,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.orange,
                              size: 22,
                            ),
                            tooltip: "Edit User",
                            onPressed: () => _editUserDialog(u),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 22,
                            ),
                            tooltip: "Hapus User",
                            onPressed: () => _deleteUser(u),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final siswaUsers = _users
        .where((u) => u.role == "siswa" || u.role == "siswa_pending")
        .toList();
    final guruUsers = _users.where((u) => u.role == "guru").toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kelola Akun",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 2,
        backgroundColor: Colors.blueAccent,
        leading: const BackButton(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: _addUserDialog,
        child: const Icon(Icons.person_add, size: 27),
        shape: const StadiumBorder(),
      ),
      backgroundColor: isDark
          ? const Color(0xFF12121D)
          : const Color(0xFFF3F9FE), // <- ini!
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? const Center(child: Text("Belum ada user terdaftar"))
          : ListView(
              children: [
                _buildUserList("Akun Siswa", siswaUsers, "siswa"),
                _buildUserList("Akun Guru", guruUsers, "guru"),
              ],
            ),
    );
  }
}
