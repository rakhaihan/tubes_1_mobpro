import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/violation.dart';
import '../models/student.dart';

enum JenisPelanggaran {
  option('Pilih Jenis Pelanggaran', 0),
  membuangSampahSembarangan('Membuang Sampah Sembarangan', 2),
  tidakMembawaBuku('Tidak Membawa Buku', 5),
  tidakMemakaiSeragamLengkap('Tidak Memakai Seragam Lengkap', 5),
  tidakIkutUpacara('Tidak Ikut Upacara', 10),
  terlambatMasuk('Terlambat Masuk', 10),
  keluarLingkunganSekolah('Keluar Lingkungan Sekolah', 10),
  membolosTanpaAlasan('Membolos Tanpa Alasan', 15),
  merokok('Merokok', 20),
  membawaSenjataTajam('Membawa Senjata Tajam', 20),
  berkelahiDenganSiswaLain('Berkelahi Dengan Siswa Lain', 25),
  merusakFasilitasSekolah('Merusak Fasilitas Sekolah', 25),
  mengonsumsiNarkotika('Mengonsumsi Narkotika', 30),
  melakukanTindakanAsusila('Melakukan Tindakan Asusila', 30);

  final String label;
  final int poin;

  const JenisPelanggaran(this.label, this.poin);
}

class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});

  @override
  State<CatatanPage> createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  int? _selectedStudentId;
  JenisPelanggaran? selectedPelanggaran = JenisPelanggaran.option;
  final _poinCtrl = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onChange);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onChange);
    _poinCtrl.dispose();
    super.dispose();
  }

  void _onChange() {
    final ids = AppState.instance.students.map((s) => s.id).toSet();
    if (_selectedStudentId != null && !ids.contains(_selectedStudentId)) {
      _selectedStudentId = null;
    }
    if (mounted) setState(() {});
  }

  void _addViolation() {
    final sid = _selectedStudentId;
    if (sid == null ||
        selectedPelanggaran == null ||
        selectedPelanggaran == JenisPelanggaran.option) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi pilihan murid dan jenis pelanggaran'),
        ),
      );
      return;
    }

    AppState.instance.addViolation(
      Violation(
        studentId: sid,
        jenis: selectedPelanggaran!.label,
        poin: selectedPelanggaran!.poin,
        tanggal: DateTime.now(),
      ),
    );

    setState(() {
      _selectedStudentId = null;
      selectedPelanggaran = JenisPelanggaran.option;
      _poinCtrl.text = '1';
    });
  }

  void _deleteViolation(int id) => AppState.instance.deleteViolation(id);

  @override
  Widget build(BuildContext context) {
    final students = AppState.instance.students;
    final violations = AppState.instance.violations;

    final Map<int, Student> uniqueMap = {};
    for (final s in students) {
      if (s.id != null) uniqueMap[s.id!] = s;
    }
    final uniqueStudents = uniqueMap.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Catatan & Laporan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _selectedStudentId,
              hint: const Text('Pilih murid'),
              decoration: const InputDecoration(
                labelText: 'Nama Murid',
                border: OutlineInputBorder(),
              ),
              items: uniqueStudents.map((s) {
                return DropdownMenuItem<int>(value: s.id!, child: Text(s.name));
              }).toList(),
              onChanged: (v) => setState(() => _selectedStudentId = v),
            ),

            const SizedBox(height: 12),
            DropdownButtonFormField<JenisPelanggaran>(
              value: selectedPelanggaran,
              decoration: const InputDecoration(
                labelText: 'Jenis Pelanggaran',
                border: OutlineInputBorder(),
              ),
              items: JenisPelanggaran.values.map((jenis) {
                return DropdownMenuItem<JenisPelanggaran>(
                  value: jenis,
                  child: Text(jenis.label),
                );
              }).toList(),
              onChanged: (JenisPelanggaran? value) {
                setState(() {
                  selectedPelanggaran = value;
                  _poinCtrl.text = (value?.poin ?? 1).toString();
                });
              },
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _poinCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Poin',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _addViolation,
                  child: const Text('Tambah Catatan'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStudentId = null;
                      selectedPelanggaran = JenisPelanggaran.option;
                      _poinCtrl.text = '1';
                    });
                  },
                  child: const Text('Bersihkan'),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const Text(
              'Riwayat Pelanggaran',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: violations.isEmpty
                  ? const Center(child: Text('Belum ada catatan pelanggaran'))
                  : ListView.separated(
                      itemCount: violations.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, i) {
                        final v = violations[i];
                        final s =
                            uniqueMap[v.studentId] ??
                            Student(id: v.studentId, name: '(–)', kelas: '-');
                        return ListTile(
                          title: Text(s.name),
                          subtitle: Text('${v.jenis} • ${v.poin} poin'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteViolation(v.id!),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
