import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../utils/pdf_helper.dart';

class RaporPage extends StatelessWidget {
  const RaporPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data nilai
    final nilai = [
      {
        "subject": "Matematika",
        "tugas": 80,
        "uts": 85,
        "uas": 90,
        "final": 86.5,
        "predikat": "A"
      },
      {
        "subject": "Bahasa Inggris",
        "tugas": 75,
        "uts": 70,
        "uas": 80,
        "final": 75.5,
        "predikat": "B"
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Rapor Siswa")),
      body: PdfPreview(
        build: (format) => PdfHelper.generateRapor(
          nama: "Budi Santoso",
          nis: "123456",
          nilai: nilai,
        ),
      ),
    );
  }
}
