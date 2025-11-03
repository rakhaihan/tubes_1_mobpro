import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/student.dart';
import '../models/student_sanction_record.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onChange);
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final students = AppState.instance.students;
    final violations = AppState.instance.violations;
    final totalPoin = students.fold<int>(0, (sum, s) => sum + AppState.instance.totalPointsForStudent(s.id!));
    final topStudent = students.isNotEmpty
        ? students.reduce((a, b) => AppState.instance.totalPointsForStudent(a.id!) >= AppState.instance.totalPointsForStudent(b.id!) ? a : b)
        : null;

    // hitung status per murid (prioritize applied > pending > reviewed for summary badge)
    int countPending = 0;
    int countApplied = 0;
    int countReviewed = 0;
    final recs = AppState.instance.studentSanctionRecords;
    final Map<int, StudentSanctionStatus> studentEffectiveStatus = {};

    for (final r in recs) {
      final current = studentEffectiveStatus[r.studentId];
      // preferensi status: applied > reviewed > pending (so applied wins)
      if (current == null) {
        studentEffectiveStatus[r.studentId] = r.status;
      } else {
        if (current == StudentSanctionStatus.pending && r.status != StudentSanctionStatus.pending) {
          studentEffectiveStatus[r.studentId] = r.status;
        } else if (current == StudentSanctionStatus.reviewed && r.status == StudentSanctionStatus.applied) {
          studentEffectiveStatus[r.studentId] = r.status;
        }
      }
    }

    for (final sId in studentEffectiveStatus.keys) {
      final st = studentEffectiveStatus[sId];
      if (st == StudentSanctionStatus.pending) countPending++;
      if (st == StudentSanctionStatus.applied) countApplied++;
      if (st == StudentSanctionStatus.reviewed) countReviewed++;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            children: [
              const Text('Ringkasan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _card('Total Murid', students.length.toString()),
                  _card('Total Catatan', violations.length.toString()),
                  _card('Total Poin', totalPoin.toString()),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Status Pelanggaran (ringkasan)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(spacing: 12, runSpacing: 12, children: [
                _statusCard('Pending', countPending.toString(), Colors.blue),
                _statusCard('Applied', countApplied.toString(), Colors.green),
                _statusCard('Reviewed', countReviewed.toString(), Colors.grey),
              ]),
              const SizedBox(height: 20),
              const Text('Siswa dengan Poin Terbanyak', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (topStudent != null)
                ListTile(
                  leading: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  title: Text(
                    topStudent.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Kelas: ${topStudent.kelas} • Poin: ${AppState.instance.totalPointsForStudent(topStudent.id!)}',
                  ),
                  trailing: _studentStatusBadge(topStudent.id!),
                )
              else
                const Text('- Belum ada data -'),
              const SizedBox(height: 16),
              const Text('Riwayat Terakhir', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...violations.take(6).map((v) {
                final s = students.firstWhere((st) => st.id == v.studentId, orElse: () => Student(id: v.studentId, name: '(–)', kelas: '-',));
                return ListTile(
                  title: Text(s.name),
                  subtitle: Text('${v.jenis} • ${v.poin} poin'),
                  trailing: Text('${v.tanggal.day}/${v.tanggal.month}/${v.tanggal.year}'),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String title, String value) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.black54)), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
    );
  }

  Widget _statusCard(String title, String value, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.circle, size: 12, color: color),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ]),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _studentStatusBadge(int studentId) {
    final recs = AppState.instance.studentSanctionRecords.where((r) => r.studentId == studentId);
    if (recs.isEmpty) return const SizedBox.shrink();

    // determine effective status: applied > reviewed > pending
    StudentSanctionStatus? effective;
    for (final r in recs) {
      if (effective == null) effective = r.status;
      if (r.status == StudentSanctionStatus.applied) {
        effective = r.status;
        break;
      }
      if (r.status == StudentSanctionStatus.reviewed && effective != StudentSanctionStatus.applied) effective = r.status;
    }

    final label = effective?.name ?? '-';
    final color = effective == StudentSanctionStatus.applied
        ? Colors.green
        : effective == StudentSanctionStatus.reviewed
            ? Colors.grey
            : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color.shade700)),
    );
  }
}
