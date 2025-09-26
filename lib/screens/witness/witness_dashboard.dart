import 'package:flutter/material.dart';
import 'package:edumanager/data/sample_data.dart';
import 'package:edumanager/models/user_model.dart';
import 'package:edumanager/widgets/common/custom_card.dart';
import 'package:edumanager/screens/auth/login_screen.dart';

class WitnessDashboard extends StatefulWidget {
  const WitnessDashboard({super.key});

  @override
  State<WitnessDashboard> createState() => _WitnessDashboardState();
}

class _WitnessDashboardState extends State<WitnessDashboard> {
  final User _currentUser = SampleData.users
      .firstWhere((u) => u.role == UserRole.witness);
  
  List<_ValidationRequest> _pendingValidations = [];
  List<_ValidationRecord> _validationHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    _pendingValidations = [
      _ValidationRequest(
        id: '1',
        courseId: 'course_1',
        studentName: 'Ama Adjovi',
        teacherName: 'Mme Akosua Koffi',
        subject: 'Mathématiques',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        duration: const Duration(hours: 1),
        requestedBy: 'parent',
        reason: 'Validation de présence',
      ),
      _ValidationRequest(
        id: '2',
        courseId: 'course_2',
        studentName: 'Kossi Agbeko',
        teacherName: 'M. Edem Togo',
        subject: 'Français',
        date: DateTime.now().subtract(const Duration(hours: 5)),
        duration: const Duration(hours: 1),
        requestedBy: 'teacher',
        reason: 'Confirmation de cours',
      ),
    ];

    _validationHistory = [
      _ValidationRecord(
        id: '1',
        courseId: 'course_3',
        studentName: 'Ama Adjovi',
        teacherName: 'Mme Akosua Koffi',
        subject: 'Sciences Physiques',
        validatedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: _ValidationStatus.validated,
        notes: 'Cours effectué correctement',
      ),
      _ValidationRecord(
        id: '2',
        courseId: 'course_4',
        studentName: 'Kossi Agbeko',
        teacherName: 'M. Edem Togo',
        subject: 'Français',
        validatedAt: DateTime.now().subtract(const Duration(days: 3)),
        status: _ValidationStatus.validated,
        notes: 'Élève présent et attentif',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.visibility,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EduManager',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Espace Témoin',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        actions: [
          PopupMenuButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey,
              child: Text(
                _currentUser.name.split(' ').map((n) => n[0]).take(2).join(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Mon profil'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to profile
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Aide'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to help
                  },
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            
            const SizedBox(height: 24),
            
            // Stats Overview
            _buildStatsOverview(),
            
            const SizedBox(height: 32),
            
            // Pending Validations
            _buildPendingValidations(),
            
            const SizedBox(height: 32),
            
            // Recent History
            _buildRecentHistory(),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.withValues(alpha: 0.1),
            Colors.grey.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: Colors.grey,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue, ${_currentUser.name}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Témoin officiel EduManager',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Votre rôle est de valider la réalisation des cours et d\'assurer la transparence du processus éducatif.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    final theme = Theme.of(context);
    final totalValidations = _validationHistory.length;
    final pendingCount = _pendingValidations.length;
    final thisWeekValidations = _validationHistory
        .where((v) => v.validatedAt.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vue d\'ensemble',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'En attente',
                '$pendingCount',
                Icons.pending_actions,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total validé',
                '$totalValidations',
                Icons.verified,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Cette semaine',
                '$thisWeekValidations',
                Icons.today,
                theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return CustomCard(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingValidations() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Validations en attente',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_pendingValidations.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_pendingValidations.length} en attente',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_pendingValidations.isEmpty)
          CustomCard(
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune validation en attente',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    'Toutes les demandes sont traitées',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._pendingValidations.map((request) => _ValidationRequestCard(
                request: request,
                onValidate: () => _validateRequest(request, true),
                onReject: () => _validateRequest(request, false),
              )),
      ],
    );
  }

  Widget _buildRecentHistory() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Historique récent',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Show full history
              },
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        ..._validationHistory.take(3).map((record) => _ValidationHistoryCard(record: record)),
      ],
    );
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: CustomCard(
                onTap: () {
                  // View all validations
                },
                backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Column(
                  
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomCard(
                onTap: () {
                  // Generate report
                },
                backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                child: Column(
                  children: [
                    Icon(
                      Icons.assessment,
                      color: theme.colorScheme.secondary,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Synthèse d\'activité',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _validateRequest(_ValidationRequest request, bool isValid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isValid ? 'Valider le cours' : 'Rejeter le cours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cours: ${request.subject}'),
            Text('Élève: ${request.studentName}'),
            Text('Enseignant: ${request.teacherName}'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _pendingValidations.remove(request);
                _validationHistory.insert(0, _ValidationRecord(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  courseId: request.courseId,
                  studentName: request.studentName,
                  teacherName: request.teacherName,
                  subject: request.subject,
                  validatedAt: DateTime.now(),
                  status: isValid ? _ValidationStatus.validated : _ValidationStatus.rejected,
                  notes: isValid ? 'Cours validé' : 'Cours rejeté',
                ));
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isValid ? 'Cours validé avec succès' : 'Cours rejeté'),
                  backgroundColor: isValid ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isValid ? 'Valider' : 'Rejeter'),
          ),
        ],
      ),
    );
  }
}

class _ValidationRequestCard extends StatelessWidget {
  final _ValidationRequest request;
  final VoidCallback onValidate;
  final VoidCallback onReject;

  const _ValidationRequestCard({
    required this.request,
    required this.onValidate,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = DateTime.now().difference(request.date);
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      backgroundColor: Colors.orange.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pending_actions,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Validation requise',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      'Il y a ${_formatTimeAgo(timeAgo)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.subject,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Élève: ${request.studentName}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'Enseignant: ${request.teacherName}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'Durée: ${request.duration.inMinutes} min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              request.reason,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onValidate,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Valider'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Rejeter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h${duration.inMinutes.remainder(60)}min';
    } else {
      return '${duration.inMinutes}min';
    }
  }
}

class _ValidationHistoryCard extends StatelessWidget {
  final _ValidationRecord record;

  const _ValidationHistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: record.status == _ValidationStatus.validated ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      record.subject,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (record.status == _ValidationStatus.validated ? Colors.green : Colors.red).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        record.status == _ValidationStatus.validated ? 'Validé' : 'Rejeté',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: record.status == _ValidationStatus.validated ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.studentName} • ${record.teacherName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  '${record.validatedAt.day}/${record.validatedAt.month} ${record.validatedAt.hour}h${record.validatedAt.minute.toString().padLeft(2, '0')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data Models
class _ValidationRequest {
  final String id;
  final String courseId;
  final String studentName;
  final String teacherName;
  final String subject;
  final DateTime date;
  final Duration duration;
  final String requestedBy;
  final String reason;

  _ValidationRequest({
    required this.id,
    required this.courseId,
    required this.studentName,
    required this.teacherName,
    required this.subject,
    required this.date,
    required this.duration,
    required this.requestedBy,
    required this.reason,
  });
}

class _ValidationRecord {
  final String id;
  final String courseId;
  final String studentName;
  final String teacherName;
  final String subject;
  final DateTime validatedAt;
  final _ValidationStatus status;
  final String notes;

  _ValidationRecord({
    required this.id,
    required this.courseId,
    required this.studentName,
    required this.teacherName,
    required this.subject,
    required this.validatedAt,
    required this.status,
    required this.notes,
  });
}

enum _ValidationStatus {
  validated,
  rejected,
}