// lib/ui/admin/crud_user_page.dart
import 'package:flutter/material.dart';
import '../../data/local/dao/user_dao.dart';
import '../../data/local/dao/student_dao.dart';
import '../../models/user.dart';
import '../../models/student.dart';

class CrudUserPage extends StatefulWidget {
  const CrudUserPage({super.key});

  @override
  State<CrudUserPage> createState() => _CrudUserPageState();
}

class _CrudUserPageState extends State<CrudUserPage> {
  final _userDao = UserDao();
  final _studentDao = StudentDao();
  List<AppUser> _users = [];
  bool _loading = true;

  static const String domain = "@Brawijaya.com";

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final users = await _userDao.getAll();
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  /// 🔹 Tambah akun baru (siswa/guru)
  Future<void> _addUserDialog() async {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String role = "siswa";

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Tambah Akun Baru"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userCtrl,
                decoration: const InputDecoration(
                  labelText: "Username",
                  prefixIcon: Icon(Icons.person),
                  helperText: "Email akan otomatis @Brawijaya.com",
                ),
              ),
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
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
                onChanged: (val) => role = val ?? "siswa",
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
              if (userCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("⚠️ Username & Password wajib diisi")),
                );
                return;
              }

              final email = "${userCtrl.text.trim()}$domain";

              // 🔹 1. Simpan ke tabel users
              final user = AppUser(
                id: null,
                email: email,
                password: passCtrl.text, // TODO: hash password
                role: role,
                passwordHash: '',
                salt: '',
              );
              final userId = await _userDao.insert(user);

              // 🔹 2. Jika siswa → tambahkan juga ke tabel students
              if (role == "siswa") {
                final nis = await _studentDao.generateNextNis();
                await _studentDao.insert(Student(
                  id: null,
                  userId: userId,
                  nis: nis,
                  name: "Siswa Baru",
                  kelas: "-",
                  jurusan: "-",
                ));
              }

              if (!mounted) return;
              Navigator.pop(context);
              _loadUsers();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("✅ Akun ${role.toUpperCase()} berhasil dibuat")),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 🔹 Edit akun (ubah username & role)
  Future<void> _editUserDialog(AppUser user) async {
    final userCtrl = TextEditingController(text: user.email.split('@').first);
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
              controller: userCtrl,
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
              if (userCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("⚠️ Username wajib diisi")),
                );
                return;
              }

              final email = "${userCtrl.text.trim()}$domain";

              final updatedUser = AppUser(
                id: user.id,
                email: email,
                password: user.password,
                role: role,
                passwordHash: user.passwordHash,
                salt: user.salt,
              );

              await _userDao.update(updatedUser);

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

  /// ✅ Verifikasi user pending → siswa
  Future<void> _verifyUser(AppUser user, bool accept) async {
    if (accept) {
      await _userDao.updateRole(user.id!, "siswa");

      final nextNis = await _studentDao.generateNextNis();
      await _studentDao.insert(Student(
        userId: user.id!,
        nis: nextNis,
        name: "Siswa Baru",
        kelas: "-",
        jurusan: "-",
      ));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ${user.email} diverifikasi sebagai Siswa")),
      );
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Konfirmasi Tolak"),
          content: Text("Yakin ingin menolak pendaftaran ${user.email}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Tolak"),
            ),
          ],
        ),
      );

      if (confirm != true) return;
      await _userDao.delete(user.id!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🗑️ Pendaftaran ${user.email} ditolak")),
      );
    }
    _loadUsers();
  }

  /// ✅ Hapus user
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

  /// 🔹 Widget builder untuk list user per role
  Widget _buildUserList(String title, List<AppUser> users, String role) {
    return ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(Icons.people),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: users.map((u) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(u.email),
            subtitle: Text("Role: ${u.role}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (u.role.endsWith("_pending") && role == "siswa") ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: "Terima sebagai Siswa",
                    onPressed: () => _verifyUser(u, true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    tooltip: "Tolak Pendaftaran",
                    onPressed: () => _verifyUser(u, false),
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    tooltip: "Edit User",
                    onPressed: () => _editUserDialog(u),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: "Hapus User",
                    onPressed: () => _deleteUser(u),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final siswaUsers = _users
        .where((u) => u.role == "siswa" || u.role == "siswa_pending")
        .toList();
    final guruUsers = _users.where((u) => u.role == "guru").toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Akun")),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUserDialog,
        child: const Icon(Icons.person_add),
      ),
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
