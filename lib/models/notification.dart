class AppNotification {
  final int id;
  final int? userId; // null si global
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;

  AppNotification({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.type,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      type: NotificationTypeExtension.fromString(json['type'] ?? 'info'),
    );
  }

  String get timeAgo {
    final duration = DateTime.now().difference(createdAt);
    if (duration.inMinutes < 60) return '${duration.inMinutes} min';
    if (duration.inHours < 24) return '${duration.inHours} h';
    return '${duration.inDays} j';
  }
}

enum NotificationType { info, success, warning, error }

extension NotificationTypeExtension on NotificationType {
  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'info': return NotificationType.info;
      case 'success': return NotificationType.success;
      case 'warning': return NotificationType.warning;
      case 'error': return NotificationType.error;
      default: return NotificationType.info;
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.info: return 'ℹ️';
      case NotificationType.success: return '✅';
      case NotificationType.warning: return '⚠️';
      case NotificationType.error: return '❌';
    }
  }

  String get color {
    switch (this) {
      case NotificationType.info: return '0xFF2196F3';      // Bleu
      case NotificationType.success: return '0xFF4CAF50';   // Vert
      case NotificationType.warning: return '0xFFFFC107';   // Jaune
      case NotificationType.error: return '0xFFF44336';     // Rouge
    }
  }
}
