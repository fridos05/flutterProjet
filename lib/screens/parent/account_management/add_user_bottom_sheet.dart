import 'package:edumanager/services/enseignant_service.dart';
import 'package:edumanager/services/eleve_service.dart';
import 'package:edumanager/services/parent_service.dart';
import 'package:edumanager/services/temoin_service.dart';
import 'package:flutter/material.dart';
import 'package:edumanager/models/user_model.dart';

class AddUserBottomSheet extends StatefulWidget {
  const AddUserBottomSheet({super.key});
  @override
  State<AddUserBottomSheet> createState() => _AddUserBottomSheetState();
}

class _AddUserBottomSheetState extends State<AddUserBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  UserRole _selectedRole = UserRole.teacher;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ajouter un utilisateur',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollController,
                  children: [
                    TextFormField(
                      controller: _prenomController,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Téléphone'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<UserRole>(
                      value: _selectedRole,
                      items: [
                        UserRole.teacher,
                        UserRole.student,
                        UserRole.witness,
                        UserRole.parent,
                      ]
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedRole = v!),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: const Text('Ajouter'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prenom = _prenomController.text;
      final nom = _nomController.text;
      final email = _emailController.text;
      final phone = _phoneController.text;

      switch (_selectedRole) {
        case UserRole.teacher:
          await EnseignantService().createEnseignant({
            'prenom': prenom,
            'nom_famille': nom,
            'courriel': email,
            'telephone': phone,
          });
          break;

        case UserRole.student:
          await EleveService().createEleve({
            'prenom': prenom,
            'nom_famille': nom,
            'courriel': email,
            'telephone': phone,
          });
          break;

        case UserRole.witness:
          await TemoinService().createTemoin({
            'prenom': prenom,
            'nom': nom, // ⚠️ témoin utilise `nom`
            'courriel': email,
            'telephone': phone,
          });
          break;

        case UserRole.parent:
          
      }

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Erreur ajout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la création')),
      );
    }
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
