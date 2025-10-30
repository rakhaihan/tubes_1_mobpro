import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/violation.dart';
import '../models/student.dart';

class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});
  @override
  State<CatatanPage> createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  int? _selectedStudentId;
  final _jenisCtrl = TextEditingController();
  final _poinCtrl = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onChange);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onChange);
    _jenisCtrl.dispose();
    _poinCtrl.dispose();
    super.dispose();
  }

  void _onChange() {
    // Reset selection when the currently selected id no longer exists
    final ids = AppState.instance.students.map((s) => s.id).toSet();
    if (_selectedStudentId != null && !ids.contains(_selectedStudentId)) {
      _selectedStudentId = null;
    }
    // notify UI
    if (mounted) setState(() {});
  }

  void _addViolation() {
    final jenis = _jenisCtrl.text.trim();
    final poin = int.tryParse(_poinCtrl.text) ?? 1;
    final sid = _selectedStudentId;
    if (jenis.isEmpty || sid == null) {
      // user feedback
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi pilihan murid dan jenis pelanggaran')));
      return;
    }
    AppState.instance.addViolation(Violation(
      studentId: sid,
      jenis: jenis,
      poin: poin,
      tanggal: DateTime.now(),
    ));
    _jenisCtrl.clear();
    _poinCtrl.text = '1';
    _selectedStudentId = null;
  }

  void _deleteViolation(int id) => AppState.instance.deleteViolation(id);

  @override
  Widget build(BuildContext context) {
    final students = AppState.instance.students;
    final violations = AppState.instance.violations;

    // Build unique student list (dedupe by id) and ignore null ids
    final Map<int, Student> uniqueMap = {};
    for (final s in students) {
      if (s.id != null) {
        uniqueMap[s.id!] = s;
      }
    }
    final uniqueStudents = uniqueMap.values.toList();

    // DEBUG: print ids to console to help trace duplicates
    // Remove or comment out in production
    final idsList = uniqueStudents.map((s) => s.id).toList();
    // ignore: avoid_print
    print('CatatanPage: student ids = $idsList, selectedId=$_selectedStudentId');

    // If selectedId no longer in unique IDs, set to null to avoid assertion
    if (_selectedStudentId != null && !uniqueMap.containsKey(_selectedStudentId)) {
      _selectedStudentId = null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Catatan & Laporan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown - use integer generic type
            DropdownButtonFormField<int>(
              value: uniqueMap.containsKey(_selectedStudentId) ? _selectedStudentId : null,
              hint: const Text('Pilih murid'),
              items: uniqueStudents.map((s) {
                // Each DropdownMenuItem must have unique value
                return DropdownMenuItem<int>(
                  value: s.id!,
                  child: Text(s.name),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedStudentId = v),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _jenisCtrl,
              decoration: const InputDecoration(labelText: 'Jenis Pelanggaran'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _poinCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Poin'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _addViolation,
                  child: const Text('Tambah Catatan'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _jenisCtrl.clear();
                    _poinCtrl.text = '1';
                    setState(() => _selectedStudentId = null);
                  },
                  child: const Text('Bersihkan'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Riwayat Pelanggaran', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: violations.isEmpty
                  ? const Center(child: Text('Belum ada catatan pelanggaran'))
                  : ListView.separated(
                      itemCount: violations.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, i) {
                        final v = violations[i];
                        final s = uniqueMap[v.studentId] ??
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
            )
          ],
        ),
      ),
    );
  }
}