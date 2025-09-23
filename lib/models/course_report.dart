class CourseReport {
  final String id;
  final String courseId;
  final String teacherId;
  final String studentId;
  final DateTime sessionDate;
  final DateTime createdAt;
  final String content; // Contenu du cours
  final String studentProgress; // Progrès de l'élève
  final String difficulties; // Difficultés rencontrées
  final String recommendations; // Recommandations
  final int studentAttention; // Note d'attention (1-5)
  final int studentParticipation; // Note de participation (1-5)
  final String? homework; // Devoirs donnés
  final String? nextSessionPrep; // Préparation pour la prochaine séance
  final List<String> attachments; // Pièces jointes
  final ReportStatus status;

  const CourseReport({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.studentId,
    required this.sessionDate,
    required this.createdAt,
    required this.content,
    required this.studentProgress,
    required this.difficulties,
    required this.recommendations,
    required this.studentAttention,
    required this.studentParticipation,
    this.homework,
    this.nextSessionPrep,
    this.attachments = const [],
    this.status = ReportStatus.draft,
  });

  bool get isCompleted => status == ReportStatus.completed;
  bool get isValidated => status == ReportStatus.validated;
  
  String get formattedDate => '${sessionDate.day}/${sessionDate.month}/${sessionDate.year}';
  
  double get averageScore => (studentAttention + studentParticipation) / 2;
  
  String get progressSummary {
    if (averageScore >= 4.5) return 'Excellent';
    if (averageScore >= 3.5) return 'Très bien';
    if (averageScore >= 2.5) return 'Bien';
    if (averageScore >= 1.5) return 'À améliorer';
    return 'Difficultés';
  }
}

enum ReportStatus {
  draft('Brouillon'),
  completed('Terminé'),
  validated('Validé'),
  disputed('Contesté');

  const ReportStatus(this.displayName);
  final String displayName;
}

class StudentProgressSummary {
  final String studentId;
  final String subject;
  final List<CourseReport> reports;
  final DateTime periodStart;
  final DateTime periodEnd;

  const StudentProgressSummary({
    required this.studentId,
    required this.subject,
    required this.reports,
    required this.periodStart,
    required this.periodEnd,
  });

  double get averageAttention => reports.isEmpty 
    ? 0.0 
    : reports.map((r) => r.studentAttention).reduce((a, b) => a + b) / reports.length;

  double get averageParticipation => reports.isEmpty 
    ? 0.0 
    : reports.map((r) => r.studentParticipation).reduce((a, b) => a + b) / reports.length;

  double get overallAverage => (averageAttention + averageParticipation) / 2;

  int get totalSessions => reports.length;

  String get progressTrend {
    if (reports.length < 2) return 'Insuffisant de données';
    
    final recent = reports.take(3).map((r) => r.averageScore).reduce((a, b) => a + b) / 3;
    final older = reports.skip(3).take(3).map((r) => r.averageScore).reduce((a, b) => a + b) / 3;
    
    if (recent > older + 0.5) return 'En progression';
    if (recent < older - 0.5) return 'En régression';
    return 'Stable';
  }
}

class WitnessObservation {
  final String id;
  final String witnessId;
  final String studentId;
  final String? courseId;
  final DateTime observationDate;
  final String generalBehavior; // Comportement général
  final String discipline; // Respect des règles
  final String motivation; // Niveau de motivation
  final String assiduity; // Assiduité
  final String remarks; // Remarques générales
  final int behaviorScore; // Note de comportement (1-5)
  final WitnessObservationType type;

  const WitnessObservation({
    required this.id,
    required this.witnessId,
    required this.studentId,
    this.courseId,
    required this.observationDate,
    required this.generalBehavior,
    required this.discipline,
    required this.motivation,
    required this.assiduity,
    required this.remarks,
    required this.behaviorScore,
    required this.type,
  });

  String get formattedDate => '${observationDate.day}/${observationDate.month}/${observationDate.year}';
}

enum WitnessObservationType {
  daily('Observation quotidienne'),
  weekly('Bilan hebdomadaire'),
  incident('Rapport d\'incident'),
  progress('Suivi de progrès');

  const WitnessObservationType(this.displayName);
  final String displayName;
}