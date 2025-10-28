import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/sanction.dart';
import '../models/student.dart';

class SanksiPage extends StatefulWidget {
  const SanksiPage({super.key});

  @override
  State<SanksiPage> createState() => _SanksiPageState();
}

class _SanksiPageState extends State<SanksiPage> {
  void _openSanctionForm({Sanction? sanction}) {
    final tingkatCtrl = TextEditingController(text: sanction?.tingkat ?? '');
    final keteranganCtrl = TextEditingController(text: sanction?.keterangan ?? '');
    final minCtrl = TextEditingController(text: sanction?.minPoin.toString() ?? '');
    final maxCtrl = TextEditingController(text: sanction?.maxPoin.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(sanction == null ? 'Tambah Sanksi' : 'Ubah Sanksi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: tingkatCtrl, decoration: const InputDecoration(labelText: 'Tingkat')),
                TextField(controller: keteranganCtrl, decoration: const InputDecoration(labelText: 'Keterangan')),
                TextField(controller: minCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min Poin')),
                TextField(controller: maxCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max Poin')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final tingkat = tingkatCtrl.text.trim();
                final keterangan = keteranganCtrl.text.trim();
                final min = int.tryParse(minCtrl.text) ?? -1;
                final max = int.tryParse(maxCtrl.text) ?? -1;
                if (tingkat.isEmpty || keterangan.isEmpty || min < 0 || max < 0 || min > max) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Periksa input sanksi'))); 
                  return;
                }

                if (sanction == null) {
                  final newS = Sanction(tingkat: tingkat, keterangan: keterangan, minPoin: min, maxPoin: max);
                  AppState.instance.addSanction(newS);
                } else {
                  final updated = Sanction(tingkat: tingkat, keterangan: keterangan, minPoin: min, maxPoin: max);
                  AppState.instance.updateSanction(sanction, updated);
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            )
          ],
        );
      },
    );
  }

  void _confirmDelete(Sanction s) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus Sanksi'),
        content: Text('Hapus sanksi "${s.tingkat}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              AppState.instance.deleteSanction(s);
              Navigator.pop(c);
            },
            child: const Text('Hapus'),
          )
        ],
      ),
    );
  }

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
    final sanctions = AppState.instance.sanctions;
    final students = AppState.instance.students;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanksi & Pembinaan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openSanctionForm(),
            tooltip: 'Tambah sanksi',
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sanctions.length,
        itemBuilder: (context, i) {
          final s = sanctions[i];

          // daftar murid yang berada di rentang poin ini
          final matched = students.where((st) {
            final pts = AppState.instance.totalPointsForStudent(st.id!);
            return pts >= s.minPoin && pts <= s.maxPoin;
          }).toList();

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ExpansionTile(
              leading: CircleAvatar(backgroundColor: Colors.indigo.shade100, child: Text(s.tingkat[0], style: const TextStyle(fontWeight: FontWeight.bold))),
              title: Text(s.tingkat, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              subtitle: Text('Poin: ${s.minPoin} - ${s.maxPoin}\n${s.keterangan}', style: const TextStyle(height: 1.4)),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Murid terpengaruh', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (matched.isEmpty)
                        const Text('- Tidak ada murid pada rentang ini -')
                      else
                        ...matched.map((Student st) {
                          final pts = AppState.instance.totalPointsForStudent(st.id!);
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.person, size: 20),
                            title: Text(st.name),
                            subtitle: Text('Kelas: ${st.kelas} • Poin: $pts'),
                          );
                        }).toList(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _openSanctionForm(sanction: s),
                            icon: const Icon(Icons.edit),
                            label: const Text('Ubah'),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => _confirmDelete(s),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
