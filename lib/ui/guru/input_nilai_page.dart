import 'package:flutter/material.dart';

class InputNilaiPage extends StatefulWidget {
  const InputNilaiPage({super.key});

  @override
  State<InputNilaiPage> createState() => _InputNilaiPageState();
}

class _InputNilaiPageState extends State<InputNilaiPage> {
  final _formKey = GlobalKey<FormState>();
  final _nisCtrl = TextEditingController();
  final _mapelCtrl = TextEditingController();
  final _tugasCtrl = TextEditingController();
  final _utsCtrl = TextEditingController();
  final _uasCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Input Nilai Siswa")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nisCtrl,
                decoration: const InputDecoration(labelText: "NIS Siswa"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              TextFormField(
                controller: _mapelCtrl,
                decoration: const InputDecoration(labelText: "Mata Pelajaran"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              TextFormField(
                controller: _tugasCtrl,
                decoration: const InputDecoration(labelText: "Nilai Tugas"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _utsCtrl,
                decoration: const InputDecoration(labelText: "Nilai UTS"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _uasCtrl,
                decoration: const InputDecoration(labelText: "Nilai UAS"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;

                  final tugas = int.tryParse(_tugasCtrl.text) ?? 0;
                  final uts = int.tryParse(_utsCtrl.text) ?? 0;
                  final uas = int.tryParse(_uasCtrl.text) ?? 0;
                  final akhir = (tugas * 0.3) + (uts * 0.3) + (uas * 0.4);

                  String predikat;
                  if (akhir >= 85) {
                    predikat = "A";
                  } else if (akhir >= 75) {
                    predikat = "B";
                  } else if (akhir >= 65) {
                    predikat = "C";
                  } else {
                    predikat = "D";
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Nilai akhir: ${akhir.toStringAsFixed(2)} ($predikat)",
                      ),
                    ),
                  );

                  // TODO: simpan ke database
                },
                child: const Text("Simpan"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
