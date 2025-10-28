import 'package:flutter/foundation.dart';
import 'models/student.dart';
import 'models/violation.dart';
import 'models/sanction.dart';

class AppState extends ChangeNotifier {
  AppState._private();
  static final AppState instance = AppState._private();

  final List<Student> _students = [];
  final List<Violation> _violations = [];
  final List<Sanction> _sanctions = [
    Sanction(tingkat: 'Ringan', keterangan: 'Surat peringatan ringan', minPoin: 1, maxPoin: 4),
    Sanction(tingkat: 'Sedang', keterangan: 'Kerja bakti sekolah', minPoin: 5, maxPoin: 9),
    Sanction(tingkat: 'Berat', keterangan: 'Pemanggilan orang tua siswa', minPoin: 10, maxPoin: 999),
  ];

  List<Student> get students => List.unmodifiable(_students);
  List<Violation> get violations => List.unmodifiable(_violations);
  List<Sanction> get sanctions => List.unmodifiable(_sanctions);

  void initSampleData() {
    addViolationForFirstIfAny();
  }

  void addViolationForFirstIfAny() {
    if (_students.isNotEmpty) {
      addViolation(
        Violation(
          studentId: _students[0].id!,
          jenis: 'Terlambat datang',
          poin: 5,
          tanggal: DateTime.now(),
        ),
      );
    }
  }

  // Students
  Student addStudent(Student s) {
    final newS = Student(
      id: DateTime.now().millisecondsSinceEpoch,
      name: s.name,
      kelas: s.kelas,
    );
    _students.add(newS);
    notifyListeners();
    return newS;
  }

  void updateStudent(Student s) {
    final idx = _students.indexWhere((e) => e.id == s.id);
    if (idx >= 0) {
      _students[idx] = s;
      notifyListeners();
    }
  }

  void deleteStudent(int id) {
    _students.removeWhere((s) => s.id == id);
    // remove violations for student
    _violations.removeWhere((v) => v.studentId == id);
    notifyListeners();
  }

  // Violations
  Violation addViolation(Violation v) {
    final newV = Violation(
      id: DateTime.now().millisecondsSinceEpoch,
      studentId: v.studentId,
      jenis: v.jenis,
      poin: v.poin,
      tanggal: v.tanggal,
    );
    _violations.insert(0, newV); // newest first
    notifyListeners();
    return newV;
  }

  void deleteViolation(int id) {
    _violations.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // Sanctions
  Sanction addSanction(Sanction s) {
    final newS = Sanction(
      tingkat: s.tingkat,
      keterangan: s.keterangan,
      minPoin: s.minPoin,
      maxPoin: s.maxPoin,
    );
    _sanctions.add(newS);
    notifyListeners();
    return newS;
  }

  void updateSanction(Sanction oldS, Sanction updated) {
    final idx = _sanctions.indexWhere((e) => e == oldS);
    if (idx >= 0) {
      _sanctions[idx] = updated;
      notifyListeners();
    }
  }

  void deleteSanction(Sanction s) {
    _sanctions.removeWhere((e) => e == s);
    notifyListeners();
  }

  Sanction? getSanctionForPoints(int totalPoin) {
    try {
      return _sanctions.firstWhere((s) => totalPoin >= s.minPoin && totalPoin <= s.maxPoin);
    } catch (_) {
      return null;
    }
  }

  // helpers
  int totalViolationsCount() => _violations.length;

  int totalPointsForStudent(int studentId) {
    return _violations
        .where((v) => v.studentId == studentId)
        .fold(0, (a, b) => a + b.poin);
  }

  Student? findStudentById(int id) {
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // reset (for testing)
  void clearAll() {
    _students.clear();
    _violations.clear();
    // keep _sanctions as defaults; remove below line to clear sanctions as well
    notifyListeners();
  }
}
