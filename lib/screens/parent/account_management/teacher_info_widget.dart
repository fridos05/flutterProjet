import 'package:flutter/material.dart';
import 'package:edumanager/models/enseignant_model.dart';
import 'package:edumanager/services/enseignant_service.dart';
import 'package:edumanager/widgets/common/custom_card.dart';
import 'info_row_widget.dart';

class TeacherInfoWidget extends StatefulWidget {
  final int enseignantId;
  const TeacherInfoWidget({required this.enseignantId, super.key});

  @override
  State<TeacherInfoWidget> createState() => _TeacherInfoWidgetState();
}

class _TeacherInfoWidgetState extends State<TeacherInfoWidget> {
  Enseignant? _enseignant;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEnseignant();
  }

  Future<void> _fetchEnseignant() async {
    try {
      final data = await EnseignantService().getEnseignantById(widget.enseignantId);
      setState(() {
        _enseignant = Enseignant.fromJson(data);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement de l\'enseignant';
        _loading = false;
      });
      debugPrint('Erreur API Enseignant: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: theme.textTheme.bodyMedium));
    if (_enseignant == null) return Center(child: Text('Aucune information disponible', style: theme.textTheme.bodyMedium));

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations professionnelles',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          InfoRowWidget(icon: Icons.person, label: 'Nom', value: '${_enseignant!.prenom ?? ''} ${_enseignant!.nomFamille ?? ''}'),
          InfoRowWidget(icon: Icons.email, label: 'Email', value: _enseignant!.email),
          if (_enseignant!.modePaiement != null)
            InfoRowWidget(icon: Icons.payment, label: 'Mode de paiement', value: _enseignant!.modePaiement!),
          if (_enseignant!.salaire != null)
            InfoRowWidget(icon: Icons.attach_money, label: 'Salaire', value: '${_enseignant!.salaire} FCFA'),
          if (_enseignant!.status != null)
            InfoRowWidget(icon: Icons.info, label: 'Statut', value: _enseignant!.status!),
        ],
      ),
    );
  }
}
