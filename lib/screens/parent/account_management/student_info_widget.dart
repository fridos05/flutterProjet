import 'package:flutter/material.dart';
import 'package:edumanager/models/eleve_model.dart';
import 'package:edumanager/services/eleve_service.dart';
import 'package:edumanager/widgets/common/custom_card.dart';
import 'info_row_widget.dart';

class StudentInfoWidget extends StatefulWidget {
  final int eleveId;
  const StudentInfoWidget({required this.eleveId, super.key});

  @override
  State<StudentInfoWidget> createState() => _StudentInfoWidgetState();
}

class _StudentInfoWidgetState extends State<StudentInfoWidget> {
  Eleve? _eleve;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEleve();
  }

  Future<void> _fetchEleve() async {
    try {
      final data = await EleveService().getEleveById(widget.eleveId);
      setState(() {
        _eleve = Eleve.fromJson(data);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement de l\'élève';
        _loading = false;
      });
      debugPrint('Erreur API Eleve: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: theme.textTheme.bodyMedium));
    if (_eleve == null) return Center(child: Text('Aucune information disponible', style: theme.textTheme.bodyMedium));

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations scolaires',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          InfoRowWidget(
            icon: Icons.person,
            label: 'Nom',
            value: '${_eleve!.prenom ?? ''} ${_eleve!.nomFamille ?? ''}',
          ),
          InfoRowWidget(
            icon: Icons.email,
            label: 'Email',
            value: _eleve!.email,
          ),
          if (_eleve!.niveauId != null)
            InfoRowWidget(
              icon: Icons.school,
              label: 'Niveau ID',
              value: '${_eleve!.niveauId}',
            ),
          if (_eleve!.createdAt != null)
            InfoRowWidget(
              icon: Icons.calendar_today,
              label: 'Date création',
              value: _eleve!.createdAt!.toLocal().toString(),
            ),
          if (_eleve!.updatedAt != null)
            InfoRowWidget(
              icon: Icons.update,
              label: 'Dernière mise à jour',
              value: _eleve!.updatedAt!.toLocal().toString(),
            ),
        ],
      ),
    );
  }
}
