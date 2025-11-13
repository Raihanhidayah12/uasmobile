import 'package:flutter/material.dart';

class CrudGuruPage extends StatefulWidget {
  const CrudGuruPage({super.key});

  @override
  State<CrudGuruPage> createState() => _CrudGuruPageState();
}

class _CrudGuruPageState extends State<CrudGuruPage> {
  final List<Map<String, String>> guru = [];

  final _nipCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _mapelCtrl = TextEditingController();

  void _showForm([Map<String, String>? data, int? index]) {
    if (data != null) {
      _nipCtrl.text = data["nip"]!;
      _namaCtrl.text = data["nama"]!;
      _mapelCtrl.text = data["mapel"]!;
    } else {
      _nipCtrl.clear();
      _namaCtrl.clear();
      _mapelCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(data == null ? "Tambah Guru" : "Edit Guru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nipCtrl, decoration: const InputDecoration(labelText: "NIP")),
            TextField(controller: _namaCtrl, decoration: const InputDecoration(labelText: "Nama")),
            TextField(controller: _mapelCtrl, decoration: const InputDecoration(labelText: "Mata Pelajaran")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final newData = {"nip": _nipCtrl.text, "nama": _namaCtrl.text, "mapel": _mapelCtrl.text};
                if (index == null) {
                  guru.add(newData);
                } else {
                  guru[index] = newData;
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
      appBar: AppBar(title: const Text("CRUD Guru")),
      body: ListView.builder(
        itemCount: guru.length,
        itemBuilder: (_, i) {
          final g = guru[i];
          return ListTile(
            title: Text("${g['nama']} (${g['nip']})"),
            subtitle: Text("Mapel: ${g['mapel']}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(g, i)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => guru.removeAt(i)),
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
