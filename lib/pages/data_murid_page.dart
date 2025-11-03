import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/student.dart';
import '../models/student_sanction_record.dart';

class DataMuridPage extends StatefulWidget {
  const DataMuridPage({super.key});
  @override
  State<DataMuridPage> createState() => _DataMuridPageState();
}

class _DataMuridPageState extends State<DataMuridPage> {
  final _nameCtrl = TextEditingController();
  final _kelasCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onChange);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onChange);
    _nameCtrl.dispose();
    _kelasCtrl.dispose();
    super.dispose();
  }

  void _onChange() => setState(() {});

  void _add() {
    final name = _nameCtrl.text.trim();
    final kelas = _kelasCtrl.text.trim();
    if (name.isEmpty || kelas.isEmpty) return;
    final added = AppState.instance.addStudent(Student(name: name, kelas: kelas));
    _nameCtrl.clear();
    _kelasCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Murid "${added.name}" ditambahkan')));
  }

  void _remove(int id) {
    final s = AppState.instance.findStudentById(id);
    if (s == null) return;
    AppState.instance.deleteStudent(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Murid "${s.name}" dihapus')));
  }

  Map<StudentSanctionStatus, int> _countsForStudent(int studentId) {
    final recs = AppState.instance.studentSanctionRecords.where((r) => r.studentId == studentId);
    final Map<StudentSanctionStatus, int> m = {for (var v in StudentSanctionStatus.values) v: 0};
    for (final r in recs) {
      m[r.status] = (m[r.status] ?? 0) + 1;
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final students = AppState.instance.students;
    return Scaffold(
      appBar: AppBar(title: const Text('Data Murid')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _kelasCtrl, decoration: const InputDecoration(labelText: 'Kelas'))),
              IconButton(onPressed: _add, icon: const Icon(Icons.add), color: Colors.green)
            ]),
            const SizedBox(height: 12),
            Expanded(
              child: students.isEmpty
                  ? const Center(child: Text('Belum ada data murid'))
                  : ListView.separated(
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, i) {
                        final s = students[i];
                        final pts = AppState.instance.totalPointsForStudent(s.id!);
                        final sanction = AppState.instance.getSanctionForPoints(pts);

                        final counts = _countsForStudent(s.id!);
                        final pending = counts[StudentSanctionStatus.pending] ?? 0;
                        final applied = counts[StudentSanctionStatus.applied] ?? 0;
                        final reviewed = counts[StudentSanctionStatus.reviewed] ?? 0;

                        Color? tileColor;
                        if (sanction != null) {
                          tileColor = sanction.tingkat.toLowerCase().contains('berat')
                              ? Colors.red.shade50
                              : sanction.tingkat.toLowerCase().contains('sedang')
                                  ? Colors.orange.shade50
                                  : Colors.yellow.shade50;
                        }

                        return Container(
                          color: tileColor,
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(s.name),
                            subtitle: Text('Kelas: ${s.kelas}\nPoin: $pts'),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (sanction != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    margin: const EdgeInsets.only(bottom: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade700,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${sanction.tingkat}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (pending > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        margin: const EdgeInsets.only(right: 4),
                                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                        child: Text('P:$pending', style: const TextStyle(fontSize: 11)),
                                      ),
                                    if (applied > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        margin: const EdgeInsets.only(right: 4),
                                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                                        child: Text('A:$applied', style: const TextStyle(fontSize: 11)),
                                      ),
                                    if (reviewed > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                                        child: Text('R:$reviewed', style: const TextStyle(fontSize: 11)),
                                      ),
                                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _remove(s.id!)),
                                  ],
                                )
                              ],
                            ),
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
