import 'package:edumanager/models/user_model.dart';
import 'package:edumanager/screens/admin/incidentscreen.dart';
import 'package:flutter/material.dart';
import 'package:edumanager/models/admin_models.dart';
import 'package:edumanager/widgets/common/custom_card.dart';
import 'package:edumanager/widgets/common/user_avatar.dart';
import 'package:edumanager/screens/auth/login_screen.dart';

// 🔴 VÉRIFIE LE NOM EXACT DE TON FICHIER D'INCIDENT
// Exemples possibles :
// import 'package:edumanager/screens/admin/incident_admin_screen.dart';
// import 'package:edumanager/screens/admin/incident_screen.dart';
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final Admin _currentUser = const Admin(
    id: 'admin_1',
    name: 'Administrateur Principal',
    email: 'admin@edumanager.com',
    department: 'Supervision',
    permissions: ['all'],
  );

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _DashboardOverview(currentUser: _currentUser), // index 0
      const IncidentAdminScreen(),                    // index 1
    ];

    // 🔒 Sécurité : évite les index invalides
    if (_selectedIndex < 0 || _selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Admin EduManager',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Panneau d\'administration',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showSystemAlerts(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSystemSettings(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: pages[_selectedIndex],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    user: _currentUser,
                    size: 60,
                    showStatus: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUser.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentUser.role.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentUser.department,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _AdminDrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Vue d\'ensemble',
                  isSelected: _selectedIndex == 0,
                  onTap: () {
                    setState(() => _selectedIndex = 0);
                    Navigator.pop(context);
                  },
                ),
                _AdminDrawerItem(
                  icon: Icons.report_problem_outlined,
                  title: 'Gestion des incidents',
                  isSelected: _selectedIndex == 1,
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                _AdminDrawerItem(
                  icon: Icons.logout_outlined,
                  title: 'Déconnexion',
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showSystemAlerts(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aucune alerte système critique')),
    );
  }

  void _showSystemSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paramètres système'),
        content: const Text('Configuration avancée du système'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

// =============== WIDGETS RÉUTILISABLES ===============

class _AdminDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdminDrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? theme.colorScheme.primaryContainer : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected 
            ? theme.colorScheme.primary 
            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _DashboardOverview extends StatelessWidget {
  final Admin currentUser;

  const _DashboardOverview({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final stats = AdminDashboardStats(
      totalUsers: 156,
      totalParents: 45,
      totalTeachers: 23,
      totalStudents: 67,
      totalWitnesses: 21,
      activeCourses: 89,
      completedCourses: 234,
      pendingPayments: 12,
      totalRevenue: 450000,
      pendingRevenue: 85000,
      incidentsReported: 3,
      disputesResolved: 8,
      lastUpdated: DateTime.now(),
    );
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tableau de bord administrateur',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Supervision globale de la plateforme EduManager',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.update, color: Colors.white.withValues(alpha: 0.8), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Dernière mise à jour : ${stats.lastUpdated.hour}:${stats.lastUpdated.minute}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Utilisateurs de la plateforme',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _AdminStatCard(
                title: 'Total utilisateurs',
                value: '${stats.totalUsers}',
                icon: Icons.people,
                color: theme.colorScheme.primary,
                subtitle: 'Actifs',
              ),
              _AdminStatCard(
                title: 'Parents',
                value: '${stats.totalParents}',
                icon: Icons.family_restroom,
                color: Colors.blue,
                subtitle: 'Familles inscrites',
              ),
              _AdminStatCard(
                title: 'Enseignants',
                value: '${stats.totalTeachers}',
                icon: Icons.school,
                color: Colors.green,
                subtitle: 'Professeurs actifs',
              ),
              _AdminStatCard(
                title: 'Élèves',
                value: '${stats.totalStudents}',
                icon: Icons.person,
                color: Colors.orange,
                subtitle: 'Étudiants',
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Aperçu financier',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _AdminStatCard(
                  title: 'Revenus totaux',
                  value: stats.formattedTotalRevenue,
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                  subtitle: 'Ce mois',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _AdminStatCard(
                  title: 'En attente',
                  value: '${stats.pendingPayments}',
                  icon: Icons.hourglass_empty,
                  color: Colors.orange,
                  subtitle: 'Paiements dus',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Qualité et incidents',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _AdminStatCard(
                  title: 'Incidents actifs',
                  value: '${stats.incidentsReported}',
                  icon: Icons.warning,
                  color: stats.incidentsReported > 0 ? Colors.red : Colors.green,
                  subtitle: 'À traiter',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _AdminStatCard(
                  title: 'Résolus',
                  value: '${stats.disputesResolved}',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  subtitle: 'Ce mois',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Actions rapides',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _AdminActionCard(
                icon: Icons.person_add,
                title: 'Nouvel utilisateur',
                onTap: () {},
              ),
              _AdminActionCard(
                icon: Icons.backup,
                title: 'Sauvegarde',
                onTap: () {},
              ),
              _AdminActionCard(
                icon: Icons.analytics,
                title: 'Rapport mensuel',
                onTap: () {},
              ),
              _AdminActionCard(
                icon: Icons.announcement,
                title: 'Annonce globale',
                onTap: () {},
              ),
            ],
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.trending_up, color: color, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon, 
                    color: theme.colorScheme.primary, 
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}