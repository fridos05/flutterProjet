import 'package:flutter/material.dart';
import 'package:edumanager/data/sample_data.dart';
import 'package:edumanager/models/payment.dart';
import 'package:edumanager/widgets/common/custom_card.dart';

class StatisticsPaymentsScreen extends StatefulWidget {
  const StatisticsPaymentsScreen({super.key});

  @override
  State<StatisticsPaymentsScreen> createState() => _StatisticsPaymentsScreenState();
}

class _StatisticsPaymentsScreenState extends State<StatisticsPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isMonthlyView = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.analytics), text: 'Statistiques'),
                Tab(icon: Icon(Icons.payment), text: 'Paiements'),
              ],
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _StatisticsTab(),
                _PaymentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticsTab extends StatefulWidget {
  @override
  State<_StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<_StatisticsTab> {
  bool _isMonthlyView = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = SampleData.statistics;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vue d\'ensemble',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ToggleButtons(
                isSelected: [_isMonthlyView, !_isMonthlyView],
                onPressed: (index) {
                  setState(() => _isMonthlyView = index == 0);
                },
                borderRadius: BorderRadius.circular(8),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Mensuel'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Annuel'),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Key Metrics
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(
                title: 'Cours ${_isMonthlyView ? 'ce mois' : 'cette année'}',
                value: '${_isMonthlyView ? stats['totalCourses'] : stats['totalCourses']! * 12}',
                icon: Icons.school,
                iconColor: theme.colorScheme.primary,
              ),
              StatCard(
                title: 'Présence moyenne',
                value: '${stats['teacherAttendance']}%',
                icon: Icons.check_circle,
                iconColor: theme.colorScheme.secondary,
                subtitle: 'Enseignants',
              ),
              StatCard(
                title: 'Revenus ${_isMonthlyView ? 'mensuels' : 'annuels'}',
                value: '${_isMonthlyView ? stats['monthlyRevenue'] : stats['monthlyRevenue']! * 12} FCFA',
                icon: Icons.trending_up,
                iconColor: theme.colorScheme.tertiary,
              ),
              StatCard(
                title: 'Élèves actifs',
                value: '${stats['totalStudents']}',
                icon: Icons.person,
                iconColor: Colors.green,
                subtitle: 'En cours',
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Progress Evolution Chart
          Text(
            'Évolution des dépenses',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          CustomCard(
            child: Container(
              height: 300,
              child: _ExpensesChart(),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Subject Distribution
          Text(
            'Répartition par matière',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          CustomCard(
            child: Column(
              children: [
                _SubjectItem('Mathématiques', 35, theme.colorScheme.primary),
                _SubjectItem('Français', 25, theme.colorScheme.secondary),
                _SubjectItem('Sciences Physiques', 20, theme.colorScheme.tertiary),
                _SubjectItem('Anglais', 15, Colors.orange),
                _SubjectItem('Autres', 5, Colors.grey),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Course Status Overview
          Text(
            'État des cours',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats['completedCourses']}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        'Terminés',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomCard(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 32,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats['upcomingCourses']}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      Text(
                        'À venir',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentsTab extends StatefulWidget {
  @override
  State<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<_PaymentsTab> {
  PaymentStatus? _statusFilter;

  List<Payment> get filteredPayments {
    var payments = SampleData.payments;
    if (_statusFilter != null) {
      payments = payments.where((p) => p.status == _statusFilter).toList();
    }
    return payments;
  }

  PaymentSummary get paymentSummary {
    final payments = SampleData.payments;
    double totalPaid = 0;
    double totalPending = 0;
    double totalOverdue = 0;

    for (final payment in payments) {
      switch (payment.status) {
        case PaymentStatus.paid:
          totalPaid += payment.amount;
          break;
        case PaymentStatus.pending:
          totalPending += payment.amount;
          break;
        case PaymentStatus.overdue:
          totalOverdue += payment.amount;
          break;
        case PaymentStatus.cancelled:
          break;
      }
    }

    return PaymentSummary(
      totalPaid: totalPaid,
      totalPending: totalPending,
      totalOverdue: totalOverdue,
      totalTransactions: payments.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = paymentSummary;
    
    return Column(
      children: [
        // Payment Summary
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomCard(
                      backgroundColor: theme.colorScheme.surface,
                      child: Column(
                        children: [
                          Text(
                            summary.formattedTotal,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'Total facturé',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomCard(
                      backgroundColor: theme.colorScheme.surface,
                      child: Column(
                        children: [
                          Text(
                            '${summary.totalTransactions}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          Text(
                            'Transactions',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _PaymentStatusCard('Payé', summary.formattedPaid, Colors.green)),
                  const SizedBox(width: 8),
                  Expanded(child: _PaymentStatusCard('En attente', summary.formattedPending, Colors.orange)),
                  const SizedBox(width: 8),
                  Expanded(child: _PaymentStatusCard('En retard', summary.formattedOverdue, Colors.red)),
                ],
              ),
            ],
          ),
        ),
        
        // Filter Chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip('Tous', null),
                const SizedBox(width: 8),
                _FilterChip('Payé', PaymentStatus.paid),
                const SizedBox(width: 8),
                _FilterChip('En attente', PaymentStatus.pending),
                const SizedBox(width: 8),
                _FilterChip('En retard', PaymentStatus.overdue),
              ],
            ),
          ),
        ),
        
        // Payments List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredPayments.length,
            itemBuilder: (context, index) {
              final payment = filteredPayments[index];
              return _PaymentCard(payment: payment);
            },
          ),
        ),
      ],
    );
  }

  Widget _FilterChip(String label, PaymentStatus? status) {
    final theme = Theme.of(context);
    final isSelected = _statusFilter == status;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = selected ? status : null;
        });
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _ExpensesChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Simulate monthly expenses data for parents
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun'];
    final tuitionData = [85000, 85000, 85000, 85000, 90000, 90000]; // Frais de scolarité
    final extraData = [15000, 22000, 18000, 30000, 12000, 25000]; // Frais supplémentaires
    
    return Column(
      children: [
        // Chart Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _LegendItem('Scolarité (k FCFA)', theme.colorScheme.primary),
            _LegendItem('Extras (k FCFA)', theme.colorScheme.secondary),
          ],
        ),
        const SizedBox(height: 16),
        
        // Simple Bar Chart Representation
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(months.length, (index) {
              final tuitionHeight = (tuitionData[index] / 100000) * 200;
              final extraHeight = (extraData[index] / 35000) * 200;
              
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: tuitionHeight,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: extraHeight,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      months[index],
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SubjectItem extends StatelessWidget {
  final String subject;
  final int percentage;
  final Color color;

  const _SubjectItem(this.subject, this.percentage, this.color);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subject,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$percentage%',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusCard extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _PaymentStatusCard(this.label, this.amount, this.color);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Payment payment;

  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  payment.description,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(payment.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  payment.status.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(payment.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                payment.formattedAmount,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Échéance',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '${payment.dueDate.day}/${payment.dueDate.month}/${payment.dueDate.year}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: payment.isOverdue ? Colors.red : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (payment.paidDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Payé le ${payment.paidDate!.day}/${payment.paidDate!.month}/${payment.paidDate!.year}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.overdue:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
    }
  }
}