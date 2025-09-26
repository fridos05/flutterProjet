class Course {
  final int id;
  final int teacherId;
  final int studentId;
  final String subject;
  final DateTime startTime;
  final DateTime endTime;
  final double pricePerSession;
  final CourseStatus status;

  Course({
    required this.id,
    required this.teacherId,
    required this.studentId,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.pricePerSession,
    required this.status,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      teacherId: json['teacher_id'],
      studentId: json['student_id'],
      subject: json['subject'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      pricePerSession: (json['price_per_session'] as num).toDouble(),
      status: CourseStatusExtension.fromString(json['status']),
    );
  }

  String get dayOfWeek => startTime.weekdayName();
  String get timeString => '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
}

enum CourseStatus { pending, completed, cancelled, reschedule }

extension CourseStatusExtension on CourseStatus {
  static CourseStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending': return CourseStatus.pending;
      case 'completed': return CourseStatus.completed;
      case 'cancelled': return CourseStatus.cancelled;
      case 'reschedule': return CourseStatus.reschedule;
      default: return CourseStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case CourseStatus.pending: return 'En attente';
      case CourseStatus.completed: return 'Terminé';
      case CourseStatus.cancelled: return 'Annulé';
      case CourseStatus.reschedule: return 'À reprogrammer';
    }
  }
}

extension WeekdayName on int {
  String weekdayName() {
    switch (this) {
      case 1: return 'Lundi';
      case 2: return 'Mardi';
      case 3: return 'Mercredi';
      case 4: return 'Jeudi';
      case 5: return 'Vendredi';
      case 6: return 'Samedi';
      case 7: return 'Dimanche';
      default: return '';
    }
  }
}
