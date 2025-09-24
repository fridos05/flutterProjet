import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:edumanager/data/sample_data.dart';
import 'package:edumanager/models/course.dart';
import 'package:edumanager/widgets/common/custom_card.dart';

class ReschedulingScreen extends StatefulWidget {
  const ReschedulingScreen({super.key});

  @override
  State<ReschedulingScreen> createState() => _ReschedulingScreenState();
}

class _ReschedulingScreenState extends State<ReschedulingScreen> {
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Course> _pendingReschedules = [];
  
  @override
  void initState() {
    super.initState();
    // Simulate some pending reschedules
    _pendingReschedules = SampleData.courses
        .where((course) => course.status == CourseStatus.scheduled)
        .take(2)
        .map((course) => Course(
              id: '${course.id}_reschedule',
              subject: course.subject,
              teacherId: course.teacherId,
              studentId: course.studentId,
              startTime: course.startTime,
              endTime: course.endTime,
              status: CourseStatus.rescheduled,
              pricePerSession: course.pricePerSession,
              location: course.location,
              notes: 'À reprogrammer - Demande du ${DateTime.now().subtract(const Duration(days: 2)).day}/${DateTime.now().subtract(const Duration(days: 2)).month}',
            ))
        .toList();
  }

  List<Course> _getCoursesForDay(DateTime day) {
    return SampleData.courses
        .where((course) => isSameDay(course.startTime, day))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            // Tab Bar
            Container(
              color: theme.colorScheme.surface,
              child: TabBar(
                tabs: const [
                  Tab(icon: Icon(Icons.schedule_send), text: 'Demandes'),
                  Tab(icon: Icon(Icons.calendar_month), text: 'Planning'),
                ],
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                indicatorColor: theme.colorScheme.primary,
              ),
            ),
            
            Expanded(
              child: TabBarView(
                children: [
                  _PendingReschedulesTab(_pendingReschedules),
                  _CalendarTab(
                    selectedDay: _selectedDay,
                    calendarFormat: _calendarFormat,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() => _selectedDay = selectedDay);
                    },
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    getCoursesForDay: _getCoursesForDay,
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

class _PendingReschedulesTab extends StatelessWidget {
  final List<Course> pendingReschedules;

  const _PendingReschedulesTab(this.pendingReschedules);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          CustomCard(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.secondaryContainer,
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demandes de reprogrammation',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${pendingReschedules.length} cours en attente',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.schedule_send,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Glissez-déposez les cours vers de nouveaux créneaux ou utilisez les boutons d\'action.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Pending Reschedules List
          Text(
            'Cours à reprogrammer',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (pendingReschedules.isEmpty)
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
                      'Aucune demande de reprogrammation',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      'Tous vos cours sont planifiés',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...pendingReschedules.map((course) => _RescheduleCourseCard(
              course: course,
              onReschedule: () => _showRescheduleDialog(context, course),
              onCancel: () => _showCancelDialog(context, course),
            )),
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => _RescheduleDialog(course: course),
    );
  }

  void _showCancelDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la reprogrammation'),
        content: Text('Voulez-vous annuler la demande de reprogrammation pour le cours de ${course.subject} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demande de reprogrammation annulée')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }
}

class _CalendarTab extends StatelessWidget {
  final DateTime selectedDay;
  final CalendarFormat calendarFormat;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) getCoursesForDay;

  const _CalendarTab({
    required this.selectedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.getCoursesForDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coursesForSelectedDay = getCoursesForDay(selectedDay);
    
    return Column(
      children: [
        // Calendar
        CustomCard(
          margin: const EdgeInsets.all(16),
          child: TableCalendar<Course>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: selectedDay,
            calendarFormat: calendarFormat,
            eventLoader: (day) => getCoursesForDay(day),
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
              markersMaxCount: 3,
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
            onDaySelected: onDaySelected,
            onFormatChanged: onFormatChanged,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          ),
        ),
        
        // Selected Day Courses
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cours du ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (coursesForSelectedDay.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _showAddCourseDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Ajouter'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (coursesForSelectedDay.isEmpty)
                  CustomCard(
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 48,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun cours programmé',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            'Cette journée est libre',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showAddCourseDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Programmer un cours'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...coursesForSelectedDay.map((course) => _CalendarCourseCard(
                    course: course,
                    onEdit: () => _showEditCourseDialog(context, course),
                    onReschedule: () => _showRescheduleDialog(context, course),
                  )),
                
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddCourseDialog(selectedDate: selectedDay),
    );
  }

  void _showEditCourseDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => _EditCourseDialog(course: course),
    );
  }

  void _showRescheduleDialog(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (context) => _RescheduleDialog(course: course),
    );
  }
}

class _RescheduleCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  const _RescheduleCourseCard({
    required this.course,
    required this.onReschedule,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teacher = SampleData.users.firstWhere((u) => u.id == course.teacherId);
    final student = SampleData.users.firstWhere((u) => u.id == course.studentId);
    
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule_send,
                  color: Colors.orange,
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
                    Text(
                      '${course.dayOfWeek} ${course.timeString}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '${teacher.name} • ${student.name}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${course.pricePerSession.toInt()} FCFA',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          
          if (course.notes != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      course.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onReschedule,
                  icon: const Icon(Icons.schedule, size: 18),
                  label: const Text('Reprogrammer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Annuler'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
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

class _CalendarCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onReschedule;

  const _CalendarCourseCard({
    required this.course,
    required this.onEdit,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teacher = SampleData.users.firstWhere((u) => u.id == course.teacherId);
    final student = SampleData.users.firstWhere((u) => u.id == course.studentId);
    
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      course.subject,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
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
                          onTap: onReschedule,
                          child: const Row(
                            children: [
                              Icon(Icons.schedule, size: 18),
                              SizedBox(width: 8),
                              Text('Reprogrammer'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  course.timeString,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${teacher.name} • ${student.name}',
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

class _RescheduleDialog extends StatefulWidget {
  final Course course;

  const _RescheduleDialog({required this.course});

  @override
  State<_RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<_RescheduleDialog> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text('Reprogrammer le cours'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cours de ${widget.course.subject}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(_selectedDate != null 
              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : 'Choisir une date'),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
          
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(_selectedTime != null 
              ? '${_selectedTime!.hour}h${_selectedTime!.minute.toString().padLeft(2, '0')}'
              : 'Choisir l\'heure'),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(widget.course.startTime),
              );
              if (time != null) {
                setState(() => _selectedTime = time);
              }
            },
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _selectedDate != null && _selectedTime != null
            ? () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cours reprogrammé avec succès')),
                );
              }
            : null,
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}

class _AddCourseDialog extends StatefulWidget {
  final DateTime selectedDate;

  const _AddCourseDialog({required this.selectedDate});

  @override
  State<_AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<_AddCourseDialog> {
  String _selectedSubject = 'Mathématiques';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Programmer un cours'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedSubject,
            decoration: const InputDecoration(
              labelText: 'Matière',
              border: OutlineInputBorder(),
            ),
            items: ['Mathématiques', 'Français', 'Sciences Physiques', 'Anglais']
                .map((subject) => DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedSubject = value!),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text('${_selectedTime.hour}h${_selectedTime.minute.toString().padLeft(2, '0')}'),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (time != null) {
                setState(() => _selectedTime = time);
              }
            },
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cours programmé avec succès')),
            );
          },
          child: const Text('Programmer'),
        ),
      ],
    );
  }
}

class _EditCourseDialog extends StatelessWidget {
  final Course course;

  const _EditCourseDialog({required this.course});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le cours'),
      content: Text('Fonctionnalité de modification du cours de ${course.subject}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cours modifié avec succès')),
            );
          },
          child: const Text('Modifier'),
        ),
      ],
    );
  }
}