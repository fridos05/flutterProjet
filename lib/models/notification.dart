class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? userId;
  final String? actionUrl;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.userId,
    this.actionUrl,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}

enum NotificationType {
  courseReminder('Rappel de cours', '📚', '0xFF2196F3'),
  paymentDue('Paiement dû', '💰', '0xFFFF9800'),
  courseCompleted('Cours terminé', '✅', '0xFF4CAF50'),
  courseCancelled('Cours annulé', '❌', '0xFFF44336'),
  newMessage('Nouveau message', '💬', '0xFF9C27B0'),
  systemUpdate('Mise à jour système', '🔄', '0xFF607D8B');

  const NotificationType(this.displayName, this.icon, this.color);
  final String displayName;
  final String icon;
  final String color;
}