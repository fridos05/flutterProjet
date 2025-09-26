import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:edumanager/models/user_model.dart';
import 'package:edumanager/models/course.dart';
import 'package:edumanager/models/notification.dart';
import 'package:edumanager/services/enseignant_service.dart';
import 'package:edumanager/services/eleve_service.dart';
import 'package:edumanager/widgets/common/custom_card.dart';
import 'package:edumanager/widgets/common/user_avatar.dart';
import 'package:edumanager/screens/parent/account_management.dart';
import 'package:edumanager/screens/parent/statistics_payments.dart';
import 'package:edumanager/screens/parent/rescheduling_screen.dart';
import 'package:edumanager/screens/auth/login_screen.dart';
import 'package:edumanager/screens/parent/parametre.dart';

class ParentDashboard extends StatefulWidget {
  final User currentUser;

  const ParentDashboard({super.key, required this.currentUser});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedIndex = 0;

  // Backend data
  Map<String, dynamic> _stats = {};
  List<Course> _courses = [];
  List<AppNotification> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final eleveService = EleveService();
      final enseignantService = EnseignantService();

      // Récupérer stats élèves et enseignants
     final eleves = await EleveService().getParentEleves();
      final enseignants = await enseignantService.getEnseignants();

      final stats = {
        'totalEleves': eleves.length,
        'totalEnseignants': enseignants.length,
        'totalCourses': 0, // à lier avec CourseService si dispo
        'teacherAttendance': 0, // idem si API dispo
        'monthlyRevenue': 0,
        'pendingReschedules': 0,
      };

      setState(() {
        _stats = stats;
        _courses = []; // quand tu auras CourseService
        _notifications = []; // quand tu auras NotificationService
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      debugPrint('Erreur dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _DashboardHome(
        currentUser: widget.currentUser,
        stats: _stats,
        courses: _courses,
        notifications: _notifications,
        loading: _loading,
      ),
      const AccountManagementScreen(),
      const StatisticsPaymentsScreen(),
      const ReschedulingScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EduManager',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotifications(context),
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
                    user: widget.currentUser,
                    size: 60,
                    showStatus: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.currentUser.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.currentUser.role.displayName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lomé', // on remplace city par une valeur par défaut
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
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
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Tableau de bord',
                  isSelected: _selectedIndex == 0,
                  onTap: () {
                    setState(() => _selectedIndex = 0);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.people_outline,
                  title: 'Gestion des comptes',
                  isSelected: _selectedIndex == 1,
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.analytics_outlined,
                  title: 'Statistiques & Paiements',
                  isSelected: _selectedIndex == 2,
                  onTap: () {
                    setState(() => _selectedIndex = 2);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.schedule_outlined,
                  title: 'Reprogrammation',
                  isSelected: _selectedIndex == 3,
                  onTap: () {
                    setState(() => _selectedIndex = 3);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Parametres',
                  isSelected: _selectedIndex == 4,
                  onTap: () {
                    setState(() => _selectedIndex = 4);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.help_outline,
                  title: 'Aide',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          _DrawerItem(
            icon: Icons.logout_outlined,
            title: 'Déconnexion',
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    final notifications = _notifications
        .where((n) => n.userId == widget.currentUser.id || n.userId == null)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationTile(notification: notification);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Drawer Item
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
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
              : theme.colorScheme.onSurface.withOpacity(0.6),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// Dashboard Home
class _DashboardHome extends StatefulWidget {
  final User currentUser;
  final Map<String, dynamic> stats;
  final List<Course> courses;
  final List<AppNotification> notifications;
  final bool loading;

  const _DashboardHome({
    required this.currentUser,
    required this.stats,
    required this.courses,
    required this.notifications,
    required this.loading,
  });

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = widget.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
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
                  'Bonjour, ${widget.currentUser.name}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bienvenue dans votre espace EduManager',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Stats Cards
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              StatCard(
                title: 'Cours ce mois',
                value: '${stats['totalCourses'] ?? 0}',
                icon: Icons.school,
                iconColor: theme.colorScheme.primary,
              ),
              StatCard(
                title: 'Présence profs',
                value: '${stats['teacherAttendance'] ?? 0}%',
                icon: Icons.check_circle,
                iconColor: theme.colorScheme.secondary,
              ),
              StatCard(
                title: 'En attente',
                value: '${(stats['monthlyRevenue'] ?? 0).toString()} FCFA',
                icon: Icons.payments,
                iconColor: theme.colorScheme.tertiary,
                subtitle: 'Paiements dus',
              ),
              StatCard(
                title: 'À reprogrammer',
                value: '${stats['pendingReschedules'] ?? 0}',
                icon: Icons.schedule,
                iconColor: Colors.orange,
                subtitle: 'Cours en attente',
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Calendar Section
          Text(
            'Calendrier des cours',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: TableCalendar<Course>(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _selectedDay,
              calendarFormat: _calendarFormat,
              eventLoader: (day) => widget.courses.where((course) => isSameDay(course.startTime, day)).toList(),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                formatButtonTextStyle: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() => _selectedDay = selectedDay);
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Upcoming Courses
          Text(
            'Prochains cours',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...widget.courses.where((c) => c.startTime.isAfter(DateTime.now())).take(3).map((course) => _CourseCard(course: course)),

          const SizedBox(height: 24),

          // Recent Notifications
          Text(
            'Notifications récentes',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...widget.notifications.take(3).map((notification) => _NotificationTile(notification: notification)),
        ],
      ),
    );
  }
}

// CourseCard et NotificationTile restent les mêmes que précédemment


// ---------- Course Card ----------
class _CourseCard extends StatelessWidget {
  final Course course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.subject,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.dayOfWeek} ${course.timeString}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${course.pricePerSession.toInt()} FCFA',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  course.status.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
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

// ---------- Notification Tile ----------
class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      backgroundColor: notification.isRead
          ? theme.cardColor
          : theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(int.parse(notification.type.color)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                notification.type.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notification.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  notification.timeAgo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
