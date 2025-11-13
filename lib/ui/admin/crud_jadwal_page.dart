import 'package:flutter/material.dart';

class CrudJadwalPage extends StatefulWidget {
  const CrudJadwalPage({super.key});

  @override
  State<CrudJadwalPage> createState() => _CrudJadwalPageState();
}

class _CrudJadwalPageState extends State<CrudJadwalPage> {
  final List<Map<String, String>> jadwal = [];

  final _hariCtrl = TextEditingController();
  final _jamCtrl = TextEditingController();
  final _mapelCtrl = TextEditingController();
  final _guruCtrl = TextEditingController();

  void _showForm([Map<String, String>? data, int? index]) {
    if (data != null) {
      _hariCtrl.text = data["hari"]!;
      _jamCtrl.text = data["jam"]!;
      _mapelCtrl.text = data["mapel"]!;
      _guruCtrl.text = data["guru"]!;
    } else {
      _hariCtrl.clear();
      _jamCtrl.clear();
      _mapelCtrl.clear();
      _guruCtrl.clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(data == null ? "Tambah Jadwal" : "Edit Jadwal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _hariCtrl, decoration: const InputDecoration(labelText: "Hari")),
            TextField(controller: _jamCtrl, decoration: const InputDecoration(labelText: "Jam")),
            TextField(controller: _mapelCtrl, decoration: const InputDecoration(labelText: "Mata Pelajaran")),
            TextField(controller: _guruCtrl, decoration: const InputDecoration(labelText: "Guru Pengampu")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final newData = {
                  "hari": _hariCtrl.text,
                  "jam": _jamCtrl.text,
                  "mapel": _mapelCtrl.text,
                  "guru": _guruCtrl.text,
                };
                if (index == null) {
                  jadwal.add(newData);
                } else {
                  jadwal[index] = newData;
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
      appBar: AppBar(title: const Text("CRUD Jadwal")),
      body: ListView.builder(
        itemCount: jadwal.length,
        itemBuilder: (_, i) {
          final j = jadwal[i];
          return ListTile(
            title: Text("${j['mapel']} - ${j['guru']}"),
            subtitle: Text("${j['hari']}, ${j['jam']}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(j, i)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => jadwal.removeAt(i)),
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
