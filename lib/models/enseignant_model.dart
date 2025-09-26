import 'user_model.dart';

class Enseignant extends User {
  final String? modePaiement;
  final double? salaire;
  final String? status;

  Enseignant({
    required super.id,
    required super.name,
    required super.email,
    super.role = UserRole.teacher,
    super.prenom,
    super.nomFamille,
    super.createdAt,
    super.updatedAt,
    this.modePaiement,
    this.salaire,
    this.status,
  });

  factory Enseignant.fromJson(Map<String, dynamic> json) {
    final enseignantData = json['enseignant'] ?? json;

    return Enseignant(
      id: enseignantData['id'] ?? json['id_enseignant'],
      name:
          '${enseignantData['prenom'] ?? ''} ${enseignantData['nom_famille'] ?? ''}'.trim(),
      email: enseignantData['courriel'] ?? '',
      prenom: enseignantData['prenom'],
      nomFamille: enseignantData['nom_famille'],
      modePaiement: enseignantData['mode_paiement'],
      salaire: enseignantData['salaire']?.toDouble(),
      status: enseignantData['status'] ?? 'actif',
      createdAt: enseignantData['created_at'] != null
          ? DateTime.parse(enseignantData['created_at'])
          : null,
      updatedAt: enseignantData['updated_at'] != null
          ? DateTime.parse(enseignantData['updated_at'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toApiJson() {
    return {
      'prenom': prenom,
      'nom_famille': nomFamille,
      'courriel': email,
      if (modePaiement != null) 'mode_paiement': modePaiement,
      if (salaire != null) 'salaire': salaire,
      if (status != null) 'status': status,
    };
  }
}
