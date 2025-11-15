import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/local/dao/schedule_dao.dart';
import '../../data/local/dao/teacher_dao.dart';
import '../../models/schedule.dart';
import '../../models/teacher.dart';

class CrudJadwalPage extends StatefulWidget {
  const CrudJadwalPage({super.key});
  @override
  State<CrudJadwalPage> createState() => _CrudJadwalPageState();
}

class _CrudJadwalPageState extends State<CrudJadwalPage> {
  final _scheduleDao = ScheduleDao();
  final _teacherDao = TeacherDao();
  List<ScheduleWithDetails> _schedules = [];
  List<Teacher> _teachers = [];
  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
  final List<String> _times = ['07.00-09.00', '09.00-11.00', '13.00-15.00', '15.00-17.00'];
  final List<String> _kelasList = ['X', 'XI', 'XII'];
  final List<String> _jurusanList = ['RPL', 'TKJ', 'MM', 'DKV'];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    _teachers = await _teacherDao.getAll();
    _schedules = (await _scheduleDao.getAllWithDetails()).cast<ScheduleWithDetails>();
    setState(() => _loading = false);
  }

  void _showForm([ScheduleWithDetails? sched]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayController = TextEditingController(text: sched?.schedule.day ?? _days.first);
    String selectedTime = sched?.schedule.time ?? _times.first;
    String selectedKelas = sched?.schedule.kelas ?? _kelasList.first;
    String selectedJurusan = sched?.schedule.jurusan ?? _jurusanList.first;
    Teacher? selectedTeacher = sched != null
        ? _teachers.firstWhere((t) => t.id == sched.schedule.teacherId, orElse: () => _teachers.first)
        : (_teachers.isNotEmpty ? _teachers.first : null);
    // *** Gunakan ValueNotifier untuk mapel biar auto-rebuild ***
    final ValueNotifier<String> selectedMapel = ValueNotifier<String>(selectedTeacher?.subject ?? "-");

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          backgroundColor: isDark ? Colors.blueGrey[900] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          insetPadding: const EdgeInsets.all(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sched == null ? '➕ Tambah Jadwal' : '✏ Edit Jadwal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blue[700],
                      letterSpacing: .7,
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    value: dayController.text,
                    icon: const Icon(Icons.arrow_drop_down),
                    dropdownColor: isDark ? Colors.blueGrey[900] : Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Hari',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    items: _days
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) => setStateDialog(() {
                      if (val != null) dayController.text = val;
                    }),
                  ),
                  const SizedBox(height: 11),
                  DropdownButtonFormField<String>(
                    value: selectedTime,
                    decoration: InputDecoration(
                      labelText: 'Jam',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.access_time_rounded),
                    dropdownColor: isDark ? Colors.blueGrey[900] : Colors.white,
                    items: _times
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setStateDialog(() {
                      if (val != null) selectedTime = val;
                    }),
                  ),
                  const SizedBox(height: 11),
                  DropdownButtonFormField<String>(
                    value: selectedKelas,
                    decoration: InputDecoration(
                      labelText: "Kelas",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    items: _kelasList
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (val) => setStateDialog(() {
                      if (val != null) selectedKelas = val;
                    }),
                  ),
                  const SizedBox(height: 11),
                  DropdownButtonFormField<String>(
                    value: selectedJurusan,
                    decoration: InputDecoration(
                      labelText: "Jurusan",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    items: _jurusanList
                        .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                        .toList(),
                    onChanged: (val) => setStateDialog(() {
                      if (val != null) selectedJurusan = val;
                    }),
                  ),
                  const SizedBox(height: 11),
                  DropdownButtonFormField<Teacher>(
                    value: selectedTeacher,
                    decoration: InputDecoration(
                      labelText: "Guru",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.person),
                    dropdownColor: isDark ? Colors.blueGrey[900] : Colors.white,
                    items: _teachers
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                        .toList(),
                    onChanged: (val) => setStateDialog(() {
                      if (val != null) {
                        selectedTeacher = val;
                        selectedMapel.value = val.subject;
                      }
                    }),
                  ),
                  const SizedBox(height: 13),

                  // Gunakan ValueListenableBuilder untuk update mapel instan!
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ValueListenableBuilder(
                      valueListenable: selectedMapel,
                      builder: (context, value, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mata Pelajaran (otomatis dari guru)",
                            style: TextStyle(
                              color: isDark ? Colors.teal[50] : Colors.indigo,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            value,
                            style: TextStyle(
                              color: isDark ? Colors.teal[100] : Colors.indigo[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16.5,
                              letterSpacing: .1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? Colors.cyan[200] : Colors.blueGrey,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.6),
                        ),
                        onPressed: () async {
                          if (selectedTeacher == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pilih guru dulu')));
                            return;
                          }
                          if (dayController.text.isEmpty ||
                              selectedTime.isEmpty ||
                              selectedKelas.isEmpty ||
                              selectedJurusan.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Lengkapi semua data')));
                            return;
                          }
                          if (sched == null) {
                            await _scheduleDao.insert(Schedule(
                              id: null,
                              day: dayController.text,
                              time: selectedTime,
                              teacherId: selectedTeacher!.id!,
                              subject: selectedMapel.value,
                              kelas: selectedKelas,
                              jurusan: selectedJurusan,
                              grade: '',
                            ));
                          } else {
                            await _scheduleDao.update(Schedule(
                              id: sched.schedule.id,
                              day: dayController.text,
                              time: selectedTime,
                              teacherId: selectedTeacher!.id!,
                              subject: selectedMapel.value,
                              kelas: selectedKelas,
                              jurusan: selectedJurusan,
                              grade: '',
                            ));
                          }
                          Navigator.pop(context);
                          _loadData();
                        },
                        child: Text(sched == null ? 'Tambah' : 'Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSchedule(int id) async {
    await _scheduleDao.delete(id);
    _loadData();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Jadwal berhasil dihapus')));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Pelajaran',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, letterSpacing: 0.5)),
        elevation: 2,
        backgroundColor: Colors.blueAccent,
        leading: const BackButton(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, size: 28),
        shape: const StadiumBorder(),
      ),
      backgroundColor: isDark ? const Color(0xFF101219) : const Color(0xFFF0F6FF),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? Center(
                  child: Text("Belum ada jadwal",
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      )),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 11),
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    final sched = _schedules[index];
                    return Card(
                      elevation: 5,
                      shadowColor: Colors.indigo.withOpacity(.22),
                      color: isDark ? Colors.blueGrey[900] : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 23, vertical: 14),
                        leading: CircleAvatar(
                          backgroundColor: Colors.cyan[100],
                          child: Icon(Icons.schedule, color: Colors.blue[800], size: 28),
                          radius: 24,
                        ),
                        title: Text(
                          "${sched.schedule.day} | ${sched.schedule.time}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.teal[100] : Colors.blueAccent,
                            fontSize: 17,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                                "Kelas ${sched.schedule.kelas} - ${sched.schedule.jurusan}",
                                style: TextStyle(
                                    color: isDark ? Colors.cyan : Colors.green[900],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.6)),
                            Text(
                                "Guru: ${sched.teacherName}     Mapel: ${sched.schedule.subject}",
                                style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.blueGrey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.4)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange, size: 24),
                              onPressed: () => _showForm(sched),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                              onPressed: () => _deleteSchedule(sched.schedule.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
    );
  }
}
