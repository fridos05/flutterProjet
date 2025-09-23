class AdminDashboardStats {
  final int totalUsers;
  final int totalParents;
  final int totalTeachers;
  final int totalStudents;
  final int totalWitnesses;
  final int activeCourses;
  final int completedCourses;
  final int pendingPayments;
  final double totalRevenue;
  final double pendingRevenue;
  final int incidentsReported;
  final int disputesResolved;
  final DateTime lastUpdated;

  const AdminDashboardStats({
    required this.totalUsers,
    required this.totalParents,
    required this.totalTeachers,
    required this.totalStudents,
    required this.totalWitnesses,
    required this.activeCourses,
    required this.completedCourses,
    required this.pendingPayments,
    required this.totalRevenue,
    required this.pendingRevenue,
    required this.incidentsReported,
    required this.disputesResolved,
    required this.lastUpdated,
  });

  String get formattedTotalRevenue => '${totalRevenue.toStringAsFixed(0)} FCFA';
  String get formattedPendingRevenue => '${pendingRevenue.toStringAsFixed(0)} FCFA';
  
  double get completionRate => activeCourses > 0 
    ? completedCourses / (activeCourses + completedCourses) 
    : 0.0;
    
  double get paymentRate => pendingPayments > 0 
    ? (totalRevenue / (totalRevenue + pendingRevenue)) 
    : 1.0;
}

class PlatformIncident {
  final String id;
  final String reporterId;
  final IncidentType type;
  final IncidentSeverity severity;
  final String title;
  final String description;
  final List<String> involvedUserIds;
  final DateTime reportedAt;
  final DateTime? resolvedAt;
  final String? resolution;
  final String? adminId; // Admin qui a traité l'incident
  final IncidentStatus status;

  const PlatformIncident({
    required this.id,
    required this.reporterId,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.involvedUserIds,
    required this.reportedAt,
    this.resolvedAt,
    this.resolution,
    this.adminId,
    this.status = IncidentStatus.pending,
  });

  bool get isResolved => status == IncidentStatus.resolved;
  bool get isPending => status == IncidentStatus.pending;
  
  String get formattedReportDate => '${reportedAt.day}/${reportedAt.month}/${reportedAt.year}';
  
  Duration? get resolutionTime => resolvedAt?.difference(reportedAt);
}

enum IncidentType {
  payment('Problème de paiement'),
  behavior('Problème de comportement'),
  quality('Problème de qualité'),
  technical('Problème technique'),
  schedule('Problème d\'horaires'),
  other('Autre');

  const IncidentType(this.displayName);
  final String displayName;
}

enum IncidentSeverity {
  low('Faible'),
  medium('Moyenne'),
  high('Élevée'),
  critical('Critique');

  const IncidentSeverity(this.displayName);
  final String displayName;
}

enum IncidentStatus {
  pending('En attente'),
  investigating('En cours d\'investigation'),
  resolved('Résolu'),
  closed('Fermé');

  const IncidentStatus(this.displayName);
  final String displayName;
}

class QualityControl {
  final String id;
  final String teacherId;
  final String adminId;
  final DateTime evaluationDate;
  final int teachingQuality; // 1-5
  final int punctuality; // 1-5
  final int communication; // 1-5
  final int studentSatisfaction; // 1-5
  final String strengths;
  final String improvements;
  final List<String> recommendations;
  final QualityControlStatus status;

  const QualityControl({
    required this.id,
    required this.teacherId,
    required this.adminId,
    required this.evaluationDate,
    required this.teachingQuality,
    required this.punctuality,
    required this.communication,
    required this.studentSatisfaction,
    required this.strengths,
    required this.improvements,
    required this.recommendations,
    this.status = QualityControlStatus.draft,
  });

  double get overallScore => (teachingQuality + punctuality + communication + studentSatisfaction) / 4;
  
  String get performanceLevel {
    if (overallScore >= 4.5) return 'Excellent';
    if (overallScore >= 3.5) return 'Très bien';
    if (overallScore >= 2.5) return 'Satisfaisant';
    if (overallScore >= 1.5) return 'À améliorer';
    return 'Insuffisant';
  }
}

enum QualityControlStatus {
  draft('Brouillon'),
  completed('Terminé'),
  shared('Partagé'),
  acknowledged('Accusé réception');

  const QualityControlStatus(this.displayName);
  final String displayName;
}

class SystemAuditLog {
  final String id;
  final String userId;
  final String action;
  final String details;
  final DateTime timestamp;
  final String ipAddress;
  final Map<String, dynamic> metadata;

  const SystemAuditLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.details,
    required this.timestamp,
    required this.ipAddress,
    this.metadata = const {},
  });

  String get formattedTimestamp => '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}';
}