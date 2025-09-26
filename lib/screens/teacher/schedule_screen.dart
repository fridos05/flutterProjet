import 'package:flutter/material.dart';
import 'package:edumanager/models/user_model.dart';
import 'package:edumanager/models/course.dart';
import 'package:edumanager/services/course_service.dart';
import 'package:edumanager/widgets/common/custom_card.dart';
import 'create_course_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final Teacher teacher;

  const ScheduleScreen({required this.teacher, super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final CourseService _courseService = CourseService();
  List<Course> _courses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() => _loading = true);
    try {
      // Appelle ton service pour récupérer les cours de l'enseignant
      final courses = await _courseService.fetchCoursesByTeacher(widget.teacher.id);
      setState(() => _courses = courses);
    } catch (e) {
      debugPrint('Erreur récupération cours: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Erreur récupération cours')));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openCreateCourse() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateCourseScreen(teacher: widget.teacher),
      ),
    );

    if (result == true) {
      // Si un cours a été créé, rafraîchir la liste
      _fetchCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? Center(child: Text('Aucun cours disponible', style: theme.textTheme.bodyMedium))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return _CourseCard(course: course);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateCourse,
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
                Text(course.subject,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${course.dayOfWeek} ${course.timeString}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text('${course.pricePerSession.toInt()} FCFA',
              style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.tertiary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
