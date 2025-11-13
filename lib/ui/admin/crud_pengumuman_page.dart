import 'package:flutter/material.dart';

class CrudPengumumanPage extends StatefulWidget {
  const CrudPengumumanPage({super.key});

  @override
  State<CrudPengumumanPage> createState() => _CrudPengumumanPageState();
}

class _CrudPengumumanPageState extends State<CrudPengumumanPage> {
  final List<Map<String, String>> pengumuman = [];

  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();

  void _showForm([Map<String, String>? data, int? index]) {
    if (data != null) {
      _judulCtrl.text = data["judul"]!;
      _isiCtrl.text = data["isi"]!;
    } else {
      _judulCtrl.clear();
      _isiCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(data == null ? "Tambah Pengumuman" : "Edit Pengumuman"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _judulCtrl, decoration: const InputDecoration(labelText: "Judul")),
            TextField(controller: _isiCtrl, decoration: const InputDecoration(labelText: "Isi")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final newData = {"judul": _judulCtrl.text, "isi": _isiCtrl.text};
                if (index == null) {
                  pengumuman.add(newData);
                } else {
                  pengumuman[index] = newData;
                }
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CRUD Pengumuman")),
      body: ListView.builder(
        itemCount: pengumuman.length,
        itemBuilder: (_, i) {
          final p = pengumuman[i];
          return ListTile(
            title: Text(p['judul']!),
            subtitle: Text(p['isi']!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(p, i)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => pengumuman.removeAt(i)),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showForm(), child: const Icon(Icons.add)),
    );
  }
}
