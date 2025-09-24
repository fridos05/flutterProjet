import 'package:flutter/material.dart';
import 'package:edumanager/data/sample_data.dart';
import 'package:edumanager/models/user.dart';
import 'package:edumanager/models/course.dart';
import 'package:edumanager/widgets/common/custom_card.dart';
import 'package:edumanager/widgets/common/user_avatar.dart';

class StudentsScreen extends StatefulWidget {
  final Teacher teacher;

  const StudentsScreen({super.key, required this.teacher});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Student> get teacherStudents {
    final studentIds = SampleData.courses
        .where((course) => course.teacherId == widget.teacher.id)
        .map((course) => course.studentId)
        .toSet();
    
    return SampleData.users
        .where((user) => user.role == UserRole.student && studentIds.contains(user.id))
        .cast<Student>()
        .toList();
  }

  List<Student> get filteredStudents {
    if (_searchQuery.isEmpty) return teacherStudents;
    return teacherStudents
        .where((student) =>
            student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            student.grade.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            student.school.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Header with search
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.05),
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
                      Icons.people,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mes élèves',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${teacherStudents.length} élève${teacherStudents.length > 1 ? 's' : ''} en cours',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un élève...',
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
                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
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
        
        // Students List
        Expanded(
          child: filteredStudents.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return _StudentCard(
                      student: student,
                      teacher: widget.teacher,
                      onTap: () => _viewStudentProfile(student),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun élève trouvé',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            'Essayez de modifier votre recherche',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _viewStudentProfile(Student student) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _StudentProfileScreen(student: student, teacher: widget.teacher),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final Teacher teacher;
  final VoidCallback onTap;

  const _StudentCard({
    required this.student,
    required this.teacher,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses = SampleData.courses
        .where((c) => c.studentId == student.id && c.teacherId == teacher.id)
        .toList();
    final totalCourses = courses.length;
    final completedCourses = courses.where((c) => c.status == CourseStatus.completed).length;
    final upcomingCourses = courses.where((c) => c.startTime.isAfter(DateTime.now())).length;
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              UserAvatar(
                user: student,
                size: 60,
                showStatus: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.school,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${student.grade} • ${student.age} ans',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      student.school,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      student.city ?? 'Lomé',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalCourses cours',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (upcomingCourses > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$upcomingCourses à venir',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progression',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$completedCourses/$totalCourses cours',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: totalCourses > 0 ? completedCourses / totalCourses : 0,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                minHeight: 6,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Subjects
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: student.subjects.map((subject) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                subject,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _StudentProfileScreen extends StatelessWidget {
  final Student student;
  final Teacher teacher;

  const _StudentProfileScreen({required this.student, required this.teacher});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses = SampleData.courses
        .where((c) => c.studentId == student.id && c.teacherId == teacher.id)
        .toList();
    
    // Récupérer les cours à venir pour les rappels
    final upcomingCourses = courses
        .where((c) => c.startTime.isAfter(DateTime.now()))
        .take(3) // Limiter à 3 rappels
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(student.name),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              // Send message to parent
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Gérer les rappels'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to manage reminders
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Programmer cours'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to schedule course
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
          children: [
            // Profile Header
            CustomCard(
              child: Column(
                children: [
                  UserAvatar(user: student, size: 80, showStatus: true),
                  const SizedBox(height: 16),
                  Text(
                    student.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${student.grade} • ${student.age} ans',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    student.school,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    student.city ?? 'Lomé',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Statistics
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.school,
                    label: 'Cours total',
                    value: '${courses.length}',
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    label: 'Terminés',
                    value: '${courses.where((c) => c.status == CourseStatus.completed).length}',
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.schedule,
                    label: 'À venir',
                    value: '${courses.where((c) => c.startTime.isAfter(DateTime.now())).length}',
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.trending_up,
                    label: 'Assiduité',
                    value: '95%',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Rappels de cours (remplace la section rapport)
            if (upcomingCourses.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rappels de cours',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Show all reminders
                    },
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              ...upcomingCourses.map((course) => _ReminderCard(course: course)),
              
              const SizedBox(height: 16),
            ],
            
            // Recent Courses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cours récents',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Show all courses
                  },
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            ...courses
                .where((c) => c.startTime.isBefore(DateTime.now()))
                .take(3)
                .map((course) => _CourseHistoryItem(course: course)),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              'Actions rapides',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Set reminder
                    },
                    icon: const Icon(Icons.notifications),
                    label: const Text('Rappel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Send message
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      backgroundColor: color.withOpacity(0.1),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
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
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Course course;

  const _ReminderCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final difference = course.startTime.difference(now);
    final daysUntil = difference.inDays;
    final hoursUntil = difference.inHours.remainder(24);

    String timeRemaining;
    if (daysUntil > 0) {
      timeRemaining = 'Dans $daysUntil jour${daysUntil > 1 ? 's' : ''}';
    } else if (hoursUntil > 0) {
      timeRemaining = 'Dans $hoursUntil heure${hoursUntil > 1 ? 's' : ''}';
    } else {
      timeRemaining = 'Bientôt';
    }

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.1),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      course.subject,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        timeRemaining,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course.startTime.day}/${course.startTime.month}/${course.startTime.year}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course.timeString,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.notifications_active,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                      onPressed: () {
                        // Configure reminder
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseHistoryItem extends StatelessWidget {
  final Course course;

  const _CourseHistoryItem({required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPast = course.startTime.isBefore(DateTime.now());
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      backgroundColor: isPast 
        ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
        : theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: _getStatusColor(course.status),
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
                      course.subject,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(course.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        course.status.displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(course.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course.startTime.day}/${course.startTime.month} ${course.timeString}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${course.pricePerSession.toInt()} FCFA',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CourseStatus status) {
    switch (status) {
      case CourseStatus.scheduled:
        return Colors.blue;
      case CourseStatus.completed:
        return Colors.green;
      case CourseStatus.cancelled:
        return Colors.red;
      case CourseStatus.rescheduled:
        return const Color.fromARGB(255, 5, 103, 249);
      case CourseStatus.inProgress:
        return Colors.purple;
    }
  }
}