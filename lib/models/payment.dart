class Payment {
  final String id;
  final String userId;
  final double amount;
  final DateTime dueDate;
  final PaymentStatus status;
  final String description;
  final DateTime? paidDate;
  final String? transactionId;

  const Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.description,
    this.paidDate,
    this.transactionId,
  });

  String get formattedAmount => '${amount.toStringAsFixed(0)} FCFA';
  bool get isOverdue => status != PaymentStatus.paid && DateTime.now().isAfter(dueDate);
}

enum PaymentStatus {
  pending('En attente'),
  paid('Payé'),
  overdue('En retard'),
  cancelled('Annulé');

  const PaymentStatus(this.displayName);
  final String displayName;
}

class PaymentSummary {
  final double totalPaid;
  final double totalPending;
  final double totalOverdue;
  final int totalTransactions;

  const PaymentSummary({
    required this.totalPaid,
    required this.totalPending,
    required this.totalOverdue,
    required this.totalTransactions,
  });

  double get total => totalPaid + totalPending + totalOverdue;
  String get formattedTotal => '${total.toStringAsFixed(0)} FCFA';
  String get formattedPaid => '${totalPaid.toStringAsFixed(0)} FCFA';
  String get formattedPending => '${totalPending.toStringAsFixed(0)} FCFA';
  String get formattedOverdue => '${totalOverdue.toStringAsFixed(0)} FCFA';
}