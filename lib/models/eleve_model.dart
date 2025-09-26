import 'user_model.dart';

class Eleve extends User {
  final int? niveauId;

  Eleve({
    required super.id,
    required super.name,
    required super.email,
    super.role = UserRole.student,
    super.prenom,
    super.nomFamille,
    super.createdAt,
    super.updatedAt,
    this.niveauId,
  });

  factory Eleve.fromJson(Map<String, dynamic> json) {
    final eleveData = json['eleve'] ?? json;

    return Eleve(
      id: eleveData['id'] ?? json['id_eleve'],
      name:
          '${eleveData['prenom'] ?? ''} ${eleveData['nom_famille'] ?? ''}'.trim(),
      email: eleveData['courriel'] ?? '',
      prenom: eleveData['prenom'],
      nomFamille: eleveData['nom_famille'],
      niveauId: eleveData['niveau_id'],
      createdAt: eleveData['created_at'] != null
          ? DateTime.parse(eleveData['created_at'])
          : null,
      updatedAt: eleveData['updated_at'] != null
          ? DateTime.parse(eleveData['updated_at'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toApiJson() {
    return {
      'prenom': prenom,
      'nom_famille': nomFamille,
      'courriel': email,
      if (niveauId != null) 'niveau_id': niveauId,
    };
  }
}
