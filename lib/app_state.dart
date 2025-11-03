import 'package:flutter/foundation.dart';
import 'models/student.dart';
import 'models/violation.dart';
import 'models/sanction.dart';
<<<<<<< HEAD
import 'models/student_sanction_record.dart';
=======
>>>>>>> origin/azki

class AppState extends ChangeNotifier {
  AppState._private();
  static final AppState instance = AppState._private();

  final List<Student> _students = [];
  final List<Violation> _violations = [];
  final List<Sanction> _sanctions = [
<<<<<<< HEAD
    Sanction(id: 1, tingkat: 'Ringan', keterangan: 'Surat peringatan ringan', minPoin: 1, maxPoin: 4),
    Sanction(id: 2, tingkat: 'Sedang', keterangan: 'Kerja bakti sekolah', minPoin: 5, maxPoin: 9),
    Sanction(id: 3, tingkat: 'Berat', keterangan: 'Pemanggilan orang tua siswa', minPoin: 10, maxPoin: 999),
  ];

  final List<StudentSanctionRecord> _studentSanctionRecords = [];

  List<Student> get students => List.unmodifiable(_students);
  List<Violation> get violations => List.unmodifiable(_violations);
  List<Sanction> get sanctions => List.unmodifiable(_sanctions);
  List<StudentSanctionRecord> get studentSanctionRecords => List.unmodifiable(_studentSanctionRecords);
=======
    Sanction(tingkat: 'Ringan', keterangan: 'Surat peringatan ringan', minPoin: 1, maxPoin: 4),
    Sanction(tingkat: 'Sedang', keterangan: 'Kerja bakti sekolah', minPoin: 5, maxPoin: 9),
    Sanction(tingkat: 'Berat', keterangan: 'Pemanggilan orang tua siswa', minPoin: 10, maxPoin: 999),
  ];

  List<Student> get students => List.unmodifiable(_students);
  List<Violation> get violations => List.unmodifiable(_violations);
  List<Sanction> get sanctions => List.unmodifiable(_sanctions);
>>>>>>> origin/azki

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
<<<<<<< HEAD
    _violations.removeWhere((v) => v.studentId == id);
    _studentSanctionRecords.removeWhere((r) => r.studentId == id);
=======
    // remove violations for student
    _violations.removeWhere((v) => v.studentId == id);
>>>>>>> origin/azki
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
<<<<<<< HEAD
    _violations.insert(0, newV);
=======
    _violations.insert(0, newV); // newest first
>>>>>>> origin/azki
    notifyListeners();
    return newV;
  }

  void deleteViolation(int id) {
    _violations.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // Sanctions
  Sanction addSanction(Sanction s) {
<<<<<<< HEAD
    final id = DateTime.now().millisecondsSinceEpoch;
    final newS = s.copyWith(id: id);
=======
    final newS = Sanction(
      tingkat: s.tingkat,
      keterangan: s.keterangan,
      minPoin: s.minPoin,
      maxPoin: s.maxPoin,
    );
>>>>>>> origin/azki
    _sanctions.add(newS);
    notifyListeners();
    return newS;
  }

<<<<<<< HEAD
  void updateSanctionById(int sanctionId, Sanction updated) {
    final idx = _sanctions.indexWhere((e) => e.id == sanctionId);
    if (idx >= 0) {
      _sanctions[idx] = updated.copyWith(id: sanctionId);
=======
  void updateSanction(Sanction oldS, Sanction updated) {
    final idx = _sanctions.indexWhere((e) => e == oldS);
    if (idx >= 0) {
      _sanctions[idx] = updated;
>>>>>>> origin/azki
      notifyListeners();
    }
  }

<<<<<<< HEAD
  void updateSanction(Sanction oldS, Sanction updated) {
    if (oldS.id == null) return;
    updateSanctionById(oldS.id!, updated);
  }

  void deleteSanction(Sanction s) {
    if (s.id == null) return;
    _sanctions.removeWhere((e) => e.id == s.id);
    _studentSanctionRecords.removeWhere((r) => r.sanctionId == s.id);
=======
  void deleteSanction(Sanction s) {
    _sanctions.removeWhere((e) => e == s);
>>>>>>> origin/azki
    notifyListeners();
  }

  Sanction? getSanctionForPoints(int totalPoin) {
    try {
      return _sanctions.firstWhere((s) => totalPoin >= s.minPoin && totalPoin <= s.maxPoin);
    } catch (_) {
      return null;
    }
  }

<<<<<<< HEAD
  // Student-Sanction records (per-student status for a sanction)
  StudentSanctionRecord? getStudentSanctionRecord({required int sanctionId, required int studentId}) {
    try {
      return _studentSanctionRecords.firstWhere((r) => r.sanctionId == sanctionId && r.studentId == studentId);
    } catch (_) {
      return null;
    }
  }

  void setStudentSanctionStatus({required int sanctionId, required int studentId, required StudentSanctionStatus status}) {
    final idx = _studentSanctionRecords.indexWhere((r) => r.sanctionId == sanctionId && r.studentId == studentId);
    if (idx >= 0) {
      _studentSanctionRecords[idx] = _studentSanctionRecords[idx].copyWith(status: status);
    } else {
      _studentSanctionRecords.add(StudentSanctionRecord(sanctionId: sanctionId, studentId: studentId, status: status));
    }
    notifyListeners();
  }

=======
>>>>>>> origin/azki
  // helpers
  int totalViolationsCount() => _violations.length;

  int totalPointsForStudent(int studentId) {
<<<<<<< HEAD
    return _violations.where((v) => v.studentId == studentId).fold(0, (a, b) => a + b.poin);
=======
    return _violations
        .where((v) => v.studentId == studentId)
        .fold(0, (a, b) => a + b.poin);
>>>>>>> origin/azki
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
<<<<<<< HEAD
    _studentSanctionRecords.clear();
=======
    // keep _sanctions as defaults; remove below line to clear sanctions as well
>>>>>>> origin/azki
    notifyListeners();
  }
}
