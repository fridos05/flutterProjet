import 'package:edumanager/models/enseignant_model.dart';
import 'package:flutter/material.dart';
import 'package:edumanager/models/user_model.dart';
import 'package:edumanager/services/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateCourseScreen extends StatefulWidget {
  final Enseignant teacher;
  const CreateCourseScreen({required this.teacher, super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int? _selectedStudentId;
  int? _selectedParentId;
  int? _selectedWitnessId;

  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _loading = true);

    final startTime =
        DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);

    final payload = {
      "seances": [
        {
          "matiere": _subjectController.text,
          "jour": "${_selectedDate!.toIso8601String().split('T')[0]}",
          "heure": "${_selectedTime!.hour.toString().padLeft(2,'0')}:${_selectedTime!.minute.toString().padLeft(2,'0')}",
          "eleve_id": _selectedStudentId,
          "parent_id": _selectedParentId ?? 1, // valeur par défaut si nécessaire
          "temoin_id": _selectedWitnessId ?? 1, // valeur par défaut si nécessaire
        }
      ]
    };

    try {
      final token = await TokenManager.getToken(); // ton helper
      final url = ApiService().buildUrl(ApiEndpoints.seances);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cours créé avec succès')),
        );
        Navigator.pop(context, true);
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Erreur création cours')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un cours')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(labelText: 'Matière'),
                      validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(_selectedDate == null
                          ? 'Sélectionner une date'
                          : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2025),
                        );
                        if (date != null) setState(() => _selectedDate = date);
                      },
                    ),
                    ListTile(
                      title: Text(_selectedTime == null
                          ? 'Sélectionner une heure'
                          : 'Heure: ${_selectedTime!.format(context)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) setState(() => _selectedTime = time);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Ici, tu peux ajouter des Dropdown pour l'élève, parent et témoin
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Créer le cours'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
