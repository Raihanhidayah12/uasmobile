import 'package:flutter/material.dart';
import '../../data/local/dao/announcement_dao.dart';
import '../../models/announcement.dart';

class CrudPengumumanPage extends StatefulWidget {
  const CrudPengumumanPage({super.key});

  @override
  State<CrudPengumumanPage> createState() => _CrudPengumumanPageState();
}

class _CrudPengumumanPageState extends State<CrudPengumumanPage> {
  final dao = AnnouncementDao();
  List<Announcement> _items = [];
  bool _loading = true;
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    _items = await dao.getAll();
    setState(() => _loading = false);
  }

  void _showForm([Announcement? data]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (data != null) {
      _judulCtrl.text = data.title;
      _isiCtrl.text = data.content;
    } else {
      _judulCtrl.clear();
      _isiCtrl.clear();
    }
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data == null ? "📝 Tambah Pengumuman" : "✍️ Edit Pengumuman",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: isDark ? Colors.white : Colors.blueAccent,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _judulCtrl,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.7,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: "Judul Pengumuman",
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.blueAccent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.blue[300]!)),
                  filled: true,
                  fillColor: isDark ? Colors.blueGrey[800] : Colors.blue[50],
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _isiCtrl,
                minLines: 3,
                maxLines: 5,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: "Tulis isi pengumuman di sini...",
                  hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey[700]),
                  contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.blueAccent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.blue[300]!)),
                  filled: true,
                  fillColor: isDark ? Colors.blueGrey[800] : Colors.blue[50],
                ),
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : Colors.blueGrey,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                    onPressed: () async {
                      if (_judulCtrl.text.isEmpty || _isiCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Judul dan isi wajib diisi!")),
                        );
                        return;
                      }
                      if (data == null) {
                        await dao.insert(
                          Announcement(
                              title: _judulCtrl.text,
                              content: _isiCtrl.text,
                              createdAt: DateTime.now().toIso8601String()),
                        );
                      } else {
                        await dao.update(
                          Announcement(
                            id: data.id,
                            title: _judulCtrl.text,
                            content: _isiCtrl.text,
                            createdAt: data.createdAt,
                          ),
                        );
                      }
                      Navigator.pop(context);
                      _loadData();
                    },
                    child: Text(data == null ? "Tambah" : "Simpan"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deletePengumuman(int id) async {
    await dao.delete(id);
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pengumuman dihapus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pengumuman",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, letterSpacing: 0.7),
        ),
        elevation: 2,
        backgroundColor: Colors.blueAccent,
        leading: const BackButton(color: Colors.white),
      ),
      backgroundColor: isDark ? const Color(0xFF111216) : const Color(0xFFF8F9FF),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text("Belum ada pengumuman",
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                      )),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final a = _items[i];
                    final date = DateTime.tryParse(a.createdAt)?.toLocal();
                    final prettyDate = date != null
                        ? "${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute}"
                        : "-";
                    return Card(
                      elevation: 6,
                      color: isDark ? Colors.blueGrey[900] : Colors.white,
                      shadowColor: Colors.blueAccent.withOpacity(.23),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue[50]),
                              child: const Icon(Icons.campaign_rounded, color: Colors.blue, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.title,
                                    style: TextStyle(
                                        color: Colors.blueAccent[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.7,
                                        letterSpacing: 0.5,
                                        height: 1.18),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(a.content,
                                      style: TextStyle(
                                        color: isDark ? Colors.white70 : Colors.black87,
                                        fontSize: 15.3,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.1,
                                      )),
                                  const SizedBox(height: 7),
                                  Text(prettyDate,
                                      style: TextStyle(
                                        color:
                                            isDark ? Colors.white38 : Colors.blueGrey[400],
                                        fontSize: 13.5,
                                      )),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  splashRadius: 22,
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () => _showForm(a),
                                ),
                                IconButton(
                                  splashRadius: 22,
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deletePengumuman(a.id!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, size: 28),
        shape: const StadiumBorder(),
      ),
    );
  }
}
