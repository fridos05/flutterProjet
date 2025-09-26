import 'package:flutter/material.dart';
import 'package:edumanager/models/user_model.dart';
import 'package:edumanager/widgets/common/custom_card.dart';

class ReportsScreen extends StatefulWidget {
  final Teacher teacher;

  const ReportsScreen({super.key, required this.teacher});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.assessment,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mes rapports',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Suivi et évaluations',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateReportDialog(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nouveau'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher dans les rapports...',
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ],
          ),
        ),
        
        // Tab Bar
        Container(
          color: theme.colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.description), text: 'Rapports'),
              Tab(icon: Icon(Icons.assignment), text: 'Modèles'),
            ],
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            indicatorColor: theme.colorScheme.primary,
          ),
        ),
        
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ReportsTab(teacher: widget.teacher, searchQuery: _searchQuery),
              _TemplatesTab(teacher: widget.teacher),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateReportDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateReportDialog(teacher: widget.teacher),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  final Teacher teacher;
  final String searchQuery;

  const _ReportsTab({required this.teacher, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reports = _getSampleReports();
    final filteredReports = searchQuery.isEmpty 
        ? reports 
        : reports.where((r) => 
            r.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            r.studentName.toLowerCase().contains(searchQuery.toLowerCase())
          ).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total rapports',
                  '${reports.length}',
                  Icons.description,
                  theme.colorScheme.primary,
                  theme,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Ce mois',
                  '${reports.where((r) => r.date.month == DateTime.now().month).length}',
                  Icons.calendar_month,
                  theme.colorScheme.secondary,
                  theme,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Reports List
          Text(
            'Historique des rapports',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (filteredReports.isEmpty)
            _buildEmptyState(theme)
          else
            ...filteredReports.map((report) => _ReportCard(
              report: report,
              onTap: () => _viewReport(context, report),
              onEdit: () => _editReport(context, report),
              onDelete: () => _deleteReport(context, report),
            )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return CustomCard(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
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

  Widget _buildEmptyState(ThemeData theme) {
    return CustomCard(
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun rapport trouvé',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              'Créez votre premier rapport ou modifiez votre recherche',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<_Report> _getSampleReports() {
    return [
      _Report(
        id: '1',
        title: 'Évaluation mensuelle - Mathématiques',
        studentName: 'Ama Adjovi',
        subject: 'Mathématiques',
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: _ReportType.evaluation,
        content: 'Excellents progrès en algèbre. Ama montre une très bonne compréhension des concepts...',
      ),
      _Report(
        id: '2',
        title: 'Rapport de séance - Géométrie',
        studentName: 'Kossi Agbeko',
        subject: 'Mathématiques',
        date: DateTime.now().subtract(const Duration(days: 5)),
        type: _ReportType.session,
        content: 'Séance productive sur les théorèmes de géométrie. Kossi a bien assimilé...',
      ),
      _Report(
        id: '3',
        title: 'Bilan trimestriel',
        studentName: 'Ama Adjovi',
        subject: 'Sciences Physiques',
        date: DateTime.now().subtract(const Duration(days: 12)),
        type: _ReportType.quarterly,
        content: 'Bilan très positif pour ce trimestre. Les notions de physique sont bien maîtrisées...',
      ),
    ];
  }

  void _viewReport(BuildContext context, _Report report) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ReportDetailScreen(report: report),
      ),
    );
  }

  void _editReport(BuildContext context, _Report report) {
    showDialog(
      context: context,
      builder: (context) => _EditReportDialog(report: report),
    );
  }

  void _deleteReport(BuildContext context, _Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le rapport'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${report.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rapport supprimé')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class _TemplatesTab extends StatelessWidget {
  final Teacher teacher;

  const _TemplatesTab({required this.teacher});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templates = _getReportTemplates();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modèles de rapports',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Utilisez ces modèles pour créer rapidement vos rapports',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          
          ...templates.map((template) => _TemplateCard(
            template: template,
            onUse: () => _useTemplate(context, template),
          )),
        ],
      ),
    );
  }

  List<_ReportTemplate> _getReportTemplates() {
    return [
      _ReportTemplate(
        name: 'Rapport de séance',
        description: 'Résumé d\'une séance de cours avec objectifs et acquis',
        icon: Icons.class_,
        color: Colors.blue,
        content: '''Séance du [DATE]
Élève: [ÉLÈVE]
Matière: [MATIÈRE]
Durée: [DURÉE]

Objectifs de la séance:
- [OBJECTIF 1]
- [OBJECTIF 2]

Contenu abordé:
[DESCRIPTION DU CONTENU]

Évaluation des acquis:
[ÉVALUATION]

Recommandations:
[RECOMMANDATIONS]

Prochaine séance:
[PROCHAINE SÉANCE]''',
      ),
      _ReportTemplate(
        name: 'Évaluation mensuelle',
        description: 'Bilan complet des progrès de l\'élève sur un mois',
        icon: Icons.assessment,
        color: Colors.green,
        content: '''Évaluation mensuelle - [MOIS] [ANNÉE]
Élève: [ÉLÈVE]
Matière: [MATIÈRE]

Progrès généraux:
[DESCRIPTION DES PROGRÈS]

Points forts:
- [POINT FORT 1]
- [POINT FORT 2]

Points à améliorer:
- [AMÉLIORATION 1]
- [AMÉLIORATION 2]

Notes obtenues:
[NOTES]

Recommandations pour le mois prochain:
[RECOMMANDATIONS]''',
      ),
      _ReportTemplate(
        name: 'Bilan trimestriel',
        description: 'Synthèse complète des résultats et progression',
        icon: Icons.trending_up,
        color: Colors.orange,
        content: '''Bilan trimestriel - [TRIMESTRE] [ANNÉE]
Élève: [ÉLÈVE]
Matière: [MATIÈRE]

Résumé général:
[RÉSUMÉ]

Évolution depuis le début du trimestre:
[ÉVOLUTION]

Compétences acquises:
- [COMPÉTENCE 1]
- [COMPÉTENCE 2]

Difficultés rencontrées:
[DIFFICULTÉS]

Objectifs pour le prochain trimestre:
[OBJECTIFS]

Recommandations aux parents:
[RECOMMANDATIONS]''',
      ),
    ];
  }

  void _useTemplate(BuildContext context, _ReportTemplate template) {
    showDialog(
      context: context,
      builder: (context) => _CreateReportFromTemplateDialog(
        template: template,
        teacher: teacher,
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final _Report report;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReportCard({
    required this.report,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: report.type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  report.type.icon,
                  color: report.type.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${report.studentName} • ${report.subject}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, size: 20),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: onEdit,
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: onDelete,
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '${report.date.day}/${report.date.month}/${report.date.year}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: report.type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report.type.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: report.type.color,
                    fontWeight: FontWeight.w600,
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

class _TemplateCard extends StatelessWidget {
  final _ReportTemplate template;
  final VoidCallback onUse;

  const _TemplateCard({
    required this.template,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: template.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              template.icon,
              color: template.color,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  template.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: onUse,
            style: ElevatedButton.styleFrom(
              backgroundColor: template.color,
              foregroundColor: Colors.white,
            ),
            child: const Text('Utiliser'),
          ),
        ],
      ),
    );
  }
}

// Dialog classes and data models would continue here...
// For brevity, I'll include the essential dialog classes

class _CreateReportDialog extends StatefulWidget {
  final Teacher teacher;

  const _CreateReportDialog({required this.teacher});

  @override
  State<_CreateReportDialog> createState() => _CreateReportDialogState();
}

class _CreateReportDialogState extends State<_CreateReportDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedStudent = 'Ama Adjovi';
  String _selectedSubject = 'Mathématiques';
  final _ReportType _selectedType = _ReportType.session;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau rapport'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre du rapport',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedStudent,
                decoration: const InputDecoration(
                  labelText: 'Élève',
                  border: OutlineInputBorder(),
                ),
                items: ['Ama Adjovi', 'Kossi Agbeko']
                    .map((student) => DropdownMenuItem(
                          value: student,
                          child: Text(student),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedStudent = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Matière',
                  border: OutlineInputBorder(),
                ),
                items: widget.teacher.subjects
                    .map((subject) => DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSubject = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenu du rapport',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rapport créé avec succès')),
            );
          },
          child: const Text('Créer'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}

// Additional dialogs...
class _EditReportDialog extends StatelessWidget {
  final _Report report;

  const _EditReportDialog({required this.report});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le rapport'),
      content: Text('Fonctionnalité de modification du rapport "${report.title}"'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rapport modifié')),
            );
          },
          child: const Text('Modifier'),
        ),
      ],
    );
  }
}

class _CreateReportFromTemplateDialog extends StatelessWidget {
  final _ReportTemplate template;
  final Teacher teacher;

  const _CreateReportFromTemplateDialog({
    required this.template,
    required this.teacher,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Utiliser le modèle "${template.name}"'),
      content: const Text('Créer un rapport à partir de ce modèle ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Rapport créé à partir du modèle')),
            );
          },
          child: const Text('Créer'),
        ),
      ],
    );
  }
}

class _ReportDetailScreen extends StatelessWidget {
  final _Report report;

  const _ReportDetailScreen({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(report.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share report
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit report
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        report.type.icon,
                        color: report.type.color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${report.studentName} • ${report.subject}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              '${report.date.day}/${report.date.month}/${report.date.year}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    report.content,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Models
class _Report {
  final String id;
  final String title;
  final String studentName;
  final String subject;
  final DateTime date;
  final _ReportType type;
  final String content;

  _Report({
    required this.id,
    required this.title,
    required this.studentName,
    required this.subject,
    required this.date,
    required this.type,
    required this.content,
  });
}

enum _ReportType {
  session('Séance', Icons.class_, Colors.blue),
  evaluation('Évaluation', Icons.assessment, Colors.green),
  quarterly('Trimestriel', Icons.trending_up, Colors.orange);

  const _ReportType(this.name, this.icon, this.color);
  final String name;
  final IconData icon;
  final Color color;
}

class _ReportTemplate {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String content;

  _ReportTemplate({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.content,
  });
}