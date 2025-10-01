import 'package:flutter/material.dart';
import 'package:edumanager/services/enseignant_service.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({Key? key}) : super(key: key);

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final EnseignantService _enseignantService = EnseignantService();
  Map<String, dynamic>? _mesEleves;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final data = await _enseignantService.getMesEleves();
      setState(() {
        _mesEleves = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mesEleves == null || (_mesEleves!['eleves'] as List).isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun élève',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos élèves apparaîtront ici',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    final eleves = _mesEleves!['eleves'] as List;
    final temoins = _mesEleves!['temoins'] as List? ?? [];

    return RefreshIndicator(
      onRefresh: _loadStudents,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Élèves
          Text(
            'Mes élèves',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...eleves.map((eleve) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      '${eleve['eleve_prenom']?[0] ?? ''}${eleve['eleve_nom']?[0] ?? ''}'.toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text('${eleve['eleve_prenom']} ${eleve['eleve_nom']}'),
                  subtitle: Text('Élève'),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              )),

          if (temoins.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Témoins',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...temoins.map((temoin) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Icon(
                        Icons.visibility,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    title: Text('${temoin['temoin_prenom']} ${temoin['temoin_nom']}'),
                    subtitle: Text('Témoin'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
