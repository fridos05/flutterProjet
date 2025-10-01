import 'package:flutter/material.dart';
import 'package:edumanager/services/seance_service.dart';
import 'package:edumanager/models/seance_model.dart';

class RescheduleSeanceDialog extends StatefulWidget {
  final Seance seance;

  const RescheduleSeanceDialog({Key? key, required this.seance}) : super(key: key);

  @override
  State<RescheduleSeanceDialog> createState() => _RescheduleSeanceDialogState();
}

class _RescheduleSeanceDialogState extends State<RescheduleSeanceDialog> {
  String? _selectedJour;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  final List<String> _jours = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  @override
  void initState() {
    super.initState();
    _selectedJour = widget.seance.jourComplet;
    // Parse l'heure actuelle
    try {
      final parts = widget.seance.heure.split(':');
      if (parts.length == 2) {
        _selectedTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      _selectedTime = TimeOfDay.now();
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _reprogrammer() async {
    if (_selectedJour == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un jour et une heure')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final seanceService = SeanceService();
      final heure = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
      
      await seanceService.reprogrammerSeance(
        widget.seance.id,
        _selectedJour!,
        heure,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Séance reprogrammée ! En attente de validation du parent.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.edit_calendar, color: Colors.blue),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Reprogrammer la séance'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations actuelles
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Séance actuelle',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Matière: ${widget.seance.matiere}'),
                  Text('Jour: ${widget.seance.jourComplet}'),
                  Text('Heure: ${widget.seance.heureFormatee}'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Nouveau jour
            const Text(
              'Nouveau planning',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Jour',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              value: _selectedJour,
              items: _jours.map((jour) {
                return DropdownMenuItem<String>(
                  value: jour,
                  child: Text(jour),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedJour = value);
              },
            ),
            const SizedBox(height: 16),
            
            // Nouvelle heure
            InkWell(
              onTap: _selectTime,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Heure',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _selectedTime != null
                      ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                      : 'Sélectionner une heure',
                  style: TextStyle(
                    color: _selectedTime != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Avertissement
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La séance devra être à nouveau validée par le parent',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _reprogrammer,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Reprogrammer'),
        ),
      ],
    );
  }
}
