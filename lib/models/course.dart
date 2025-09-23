class Course {
  final String id;
  final String subject;
  final String teacherId;
  final String studentId;
  final DateTime startTime;
  final DateTime endTime;
  final CourseStatus status;
  final double pricePerSession;
  final String? notes;
  final String? location;

  const Course({
    required this.id,
    required this.subject,
    required this.teacherId,
    required this.studentId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.pricePerSession,
    this.notes,
    this.location,
  });

  Duration get duration => endTime.difference(startTime);
  
  String get dayOfWeek {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[startTime.weekday - 1];
  }

  String get timeString => '${startTime.hour}h${startTime.minute.toString().padLeft(2, '0')}-${endTime.hour}h${endTime.minute.toString().padLeft(2, '0')}';
}

enum CourseStatus {
  scheduled('Programmé'),
  completed('Terminé'),
  cancelled('Annulé'),
  rescheduled('Reprogrammé'),
  inProgress('En cours');

  const CourseStatus(this.displayName);
  final String displayName;
}

class Subject {
  final String id;
  final String name;
  final String icon;
  final String color;

  const Subject({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<Subject> allSubjects = [
    Subject(id: 'math', name: 'Mathématiques', icon: '📐', color: '0xFF2196F3'),
    Subject(id: 'french', name: 'Français', icon: '📚', color: '0xFF4CAF50'),
    Subject(id: 'physics', name: 'Sciences Physiques', icon: '⚗️', color: '0xFF9C27B0'),
    Subject(id: 'biology', name: 'SVT', icon: '🧬', color: '0xFF4CAF50'),
    Subject(id: 'english', name: 'Anglais', icon: '🇬🇧', color: '0xFFFF5722'),
    Subject(id: 'history', name: 'Histoire-Géo', icon: '🌍', color: '0xFF795548'),
    Subject(id: 'chemistry', name: 'Chimie', icon: '🧪', color: '0xFF607D8B'),
    Subject(id: 'philosophy', name: 'Philosophie', icon: '💭', color: '0xFF3F51B5'),
  ];
}