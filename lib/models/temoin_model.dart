import 'user_model.dart';

class Temoin extends User {
  Temoin({
    required super.id,
    required super.name,
    required super.email,
    super.role = UserRole.witness,
    super.prenom,
    super.nomFamille,
    super.createdAt,
    super.updatedAt,
  });

  factory Temoin.fromJson(Map<String, dynamic> json) {
    final temoinData = json['temoin'] ?? json;

    return Temoin(
      id: temoinData['id'] ?? json['id_temoin'],
      name:
          '${temoinData['prenom'] ?? ''} ${temoinData['nom'] ?? ''}'.trim(),
      email: temoinData['courriel'] ?? '',
      prenom: temoinData['prenom'],
      // ⚠️ pour témoin, c’est `nom` au lieu de `nom_famille`
      nomFamille: temoinData['nom'],
      createdAt: temoinData['created_at'] != null
          ? DateTime.parse(temoinData['created_at'])
          : null,
      updatedAt: temoinData['updated_at'] != null
          ? DateTime.parse(temoinData['updated_at'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toApiJson() {
    return {
      'prenom': prenom,
      'nom': nomFamille, // 🔑 API attend "nom" au lieu de "nom_famille"
      'courriel': email,
    };
  }
}
