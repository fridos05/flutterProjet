import 'package:edumanager/models/eleve_model.dart';
import 'package:edumanager/models/enseignant_model.dart';
import 'package:edumanager/models/user_model.dart';
import 'package:flutter/material.dart';
import 'teacher_info_widget.dart';
import 'student_info_widget.dart';
import 'package:edumanager/widgets/common/custom_card.dart';
import 'package:edumanager/widgets/common/user_avatar.dart';

class UserDetailsScreen extends StatelessWidget {
  final User user;
  const UserDetailsScreen({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomCard(
              child: Column(
                children: [
                  UserAvatar(user: user, size: 80, showStatus: true),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(user.role.displayName, style: theme.textTheme.titleMedium),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 🔹 Passer uniquement l'ID
            if (user is Enseignant)
              TeacherInfoWidget(enseignantId: user.id),
            if (user is Eleve)
              StudentInfoWidget(eleveId: user.id),
          ],
        ),
      ),
    );
  }
}
