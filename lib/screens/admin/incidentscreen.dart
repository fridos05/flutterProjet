import 'package:flutter/material.dart';

// =============== MODÈLE ===============
enum IncidentStatus {
  pending('En attente'),
  inProgress('En cours'),
  resolved('Résolu');

  final String label;
  const IncidentStatus(this.label);
}

class Incident {
  final String id;
  final String title;
  final String description;
  final String reportedBy;
  final DateTime reportedAt;
  final String location;
  final IncidentStatus status;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.reportedBy,
    required this.reportedAt,
    required this.location,
    required this.status,
  });

  Incident copyWith({IncidentStatus? status}) {
    return Incident(
      id: id,
      title: title,
      description: description,
      reportedBy: reportedBy,
      reportedAt: reportedAt,
      location: location,
      status: status ?? this.status,
    );
  }
}

// =============== SERVICE (mock) ===============
class IncidentService {
  final List<Incident> _incidents = [
    Incident(
      id: '1',
      title: 'Panne d’électricité',
      description: 'Bloc B sans électricité depuis 10h.',
      reportedBy: 'Jean Dupont',
      reportedAt: DateTime(2024, 5, 10, 9, 30),
      location: 'Bloc B, Salle 203',
      status: IncidentStatus.pending,
    ),
    Incident(
      id: '2',
      title: 'Fuite d’eau',
      description: 'Toilettes du 1er étage inondées.',
      reportedBy: 'Marie Lefevre',
      reportedAt: DateTime(2024, 5, 11, 14, 15),
      location: '1er étage, Toilettes',
      status: IncidentStatus.inProgress,
    ),
    Incident(
      id: '3',
      title: 'Problème réseau',
      description: 'Internet coupé dans la salle informatique.',
      reportedBy: 'Paul Martin',
      reportedAt: DateTime(2024, 5, 12, 11, 0),
      location: 'Salle Info, RDC',
      status: IncidentStatus.resolved,
    ),
  ];

  Future<List<Incident>> getIncidents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_incidents);
  }

  Future<void> updateIncidentStatus(String id, IncidentStatus newStatus) async {
    final index = _incidents.indexWhere((incident) => incident.id == id);
    if (index != -1) {
      _incidents[index] = _incidents[index].copyWith(status: newStatus);
    }
  }
}

// =============== ÉCRAN DE DÉTAIL ===============
class _IncidentDetailScreen extends StatelessWidget {
  final Incident incident;
  final Future<void> Function(IncidentStatus) onStatusUpdated;

  const _IncidentDetailScreen({
    required this.incident,
    required this.onStatusUpdated,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(incident.title),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Signalé par: ${incident.reportedBy}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Date: ${_formatDate(incident.reportedAt)}'),
            const SizedBox(height: 8),
            Text('Lieu: ${incident.location}'),
            const SizedBox(height: 16),
            const Text('Description:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(incident.description),
            const SizedBox(height: 24),
            const Text('Statut actuel:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: IncidentStatus.values.map((status) {
                return ChoiceChip(
                  label: Text(status.label),
                  selected: incident.status == status,
                  selectedColor: Colors.blue.withOpacity(0.3),
                  onSelected: (selected) async {
                    if (selected) {
                      await onStatusUpdated(status);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// =============== ÉCRAN PRINCIPAL ===============
class IncidentAdminScreen extends StatefulWidget {
  const IncidentAdminScreen({super.key});

  @override
  State<IncidentAdminScreen> createState() => _IncidentAdminScreenState();
}

class _IncidentAdminScreenState extends State<IncidentAdminScreen> {
  late Future<List<Incident>> _futureIncidents;
  final IncidentService _service = IncidentService();

  @override
  void initState() {
    super.initState();
    _refreshIncidents();
  }

  void _refreshIncidents() {
    setState(() {
      _futureIncidents = _service.getIncidents();
    });
  }

  Widget _buildStatusChip(IncidentStatus status) {
    Color color;
    switch (status) {
      case IncidentStatus.pending:
        color = Colors.orange;
        break;
      case IncidentStatus.inProgress:
        color = Colors.blue;
        break;
      case IncidentStatus.resolved:
        color = Colors.green;
        break;
    }
    return Chip(
      label: Text(status.label),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Incidents'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Incident>>(
        future: _futureIncidents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final incidents = snapshot.data ?? [];
          return ListView.builder(
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(incident.title),
                  subtitle: Text(
                    '${incident.location} • ${incident.reportedAt.day}/${incident.reportedAt.month}/${incident.reportedAt.year}',
                  ),
                  trailing: _buildStatusChip(incident.status),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _IncidentDetailScreen(
                          incident: incident,
                          onStatusUpdated: (newStatus) async {
                            await _service.updateIncidentStatus(incident.id, newStatus);
                            _refreshIncidents();
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshIncidents,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}