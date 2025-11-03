enum StudentSanctionStatus { pending, applied, reviewed }

class StudentSanctionRecord {
  final int sanctionId;
  final int studentId;
  final StudentSanctionStatus status;

  StudentSanctionRecord({
    required this.sanctionId,
    required this.studentId,
    this.status = StudentSanctionStatus.pending,
  });

  StudentSanctionRecord copyWith({StudentSanctionStatus? status}) {
    return StudentSanctionRecord(
      sanctionId: sanctionId,
      studentId: studentId,
      status: status ?? this.status,
    );
  }
}
