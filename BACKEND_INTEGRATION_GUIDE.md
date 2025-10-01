# Guide d'intégration Backend - EduManager

## 📋 Résumé des modifications

Ce document décrit les mises à jour effectuées pour que le frontend Flutter consomme correctement les API du backend Laravel.

---

## 🏗️ Architecture Backend

### Structure des utilisateurs

Le backend utilise une architecture hiérarchique :

- **Parent** (table `inscription`) : Utilisateur principal qui crée tous les autres comptes
- **Élèves** (table `eleves`) : Créés par le parent via `parent_eleve`
- **Enseignants** (table `enseignants`) : Créés par le parent via `parent_enseignant`
- **Témoins** (table `temoins`) : Créés par le parent via `parent_temoin`

### Authentification

- **Système** : Laravel Sanctum
- **Login** : Requiert 3 paramètres : `courriel`, `mot_de_passe`, **`role`**
- **Rôles disponibles** : `parent`, `eleve`, `enseignant`, `temoin`

---

## 🔧 Services mis à jour

### 1. **AuthService** (`lib/services/auth_service.dart`)

#### Changements principaux :
- ✅ Le login nécessite maintenant le paramètre `role`
- ✅ Méthode `register()` renommée pour clarté (inscription parent uniquement)
- ✅ Correction du bug dans `logout()` (variable `token` non définie)

#### Utilisation :

```dart
// Connexion
final authService = AuthService();
final result = await authService.login(
  'email@example.com',
  'password',
  'parent' // ou 'eleve', 'enseignant', 'temoin'
);

// Inscription (parent uniquement)
final result = await authService.register(
  prenomNom: 'Jean',
  nomFamille: 'Dupont',
  courriel: 'jean.dupont@example.com',
  motDePasse: 'password123',
  motDePasseConfirmation: 'password123',
);
```

---

### 2. **EleveService** (`lib/services/eleve_service.dart`)

#### Structure de réponse backend :

```json
// GET /api/eleve/index
[
  {
    "id": 1,
    "id_parent": 1,
    "id_eleve": 2,
    "eleve": {
      "id": 2,
      "nom_famille": "Martin",
      "prenom": "Marie",
      "courriel": "marie.martin@example.com",
      "niveau_id": 1
    },
    "parent": { ... }
  }
]

// POST /api/eleve/store
{
  "message": "Enregistrement d'élève réussi",
  "eleve": { ... },
  "parent_relation": { ... },
  "password": "abc12345" // Mot de passe généré automatiquement
}
```

#### Utilisation :

```dart
final eleveService = EleveService();

// Récupérer les élèves du parent
final eleves = await eleveService.getParentEleves();

// Créer un élève (le mot de passe est généré automatiquement)
final result = await eleveService.createEleve({
  'nom_famille': 'Martin',
  'prenom': 'Marie',
  'courriel': 'marie.martin@example.com',
  'niveau_id': 1,
});

// Le mot de passe généré est dans result['password']
print('Mot de passe: ${result['password']}');
```

---

### 3. **EnseignantService** (`lib/services/enseignant_service.dart`)

#### Structure de réponse backend :

```json
// GET /api/enseignant/index
[
  {
    "id": 1,
    "id_parent": 1,
    "id_enseignant": 2,
    "enseignant": {
      "id": 2,
      "prenom": "Jean",
      "nom_famille": "Dupont",
      "courriel": "jean.dupont@example.com",
      "mode_paiement": "virement",
      "salaire": 2500
    },
    "parent": { ... },
    "associations": [
      {
        "enseignant_id": 2,
        "eleve_id": 3,
        "temoin_id": 4,
        "eleve": { ... },
        "temoin": { ... }
      }
    ]
  }
]

// GET /api/mes-eleves (pour enseignant connecté)
{
  "enseignant_id": 2,
  "parent": {
    "parent_id": 1,
    "parent_nom": "Dupont",
    "parent_prenom": "Pierre"
  },
  "eleves": [
    {
      "eleve_id": 3,
      "eleve_nom": "Martin",
      "eleve_prenom": "Marie"
    }
  ],
  "temoins": [
    {
      "temoin_id": 4,
      "temoin_nom": "Durand",
      "temoin_prenom": "Paul"
    }
  ]
}
```

#### Utilisation :

```dart
final enseignantService = EnseignantService();

// Récupérer les enseignants du parent avec leurs associations
final enseignants = await enseignantService.getEnseignants();

// Créer un enseignant
final result = await enseignantService.createEnseignant({
  'prenom': 'Jean',
  'nom_famille': 'Dupont',
  'courriel': 'jean.dupont@example.com',
  'mode_paiement': 'virement',
  'salaire': 2500,
});

// Pour un enseignant connecté : voir ses élèves
final mesEleves = await enseignantService.getMesEleves();
```

---

### 4. **TemoinService** (`lib/services/temoin_service.dart`)

#### Structure de réponse backend :

```json
// GET /api/temoin/index
[
  {
    "id": 1,
    "id_parent": 1,
    "id_temoin": 2,
    "temoin": {
      "id": 2,
      "nom": "Durand",
      "prenom": "Paul",
      "courriel": "paul.durand@example.com"
    },
    "parent": { ... }
  }
]
```

#### Utilisation :

```dart
final temoinService = TemoinService();

// Récupérer les témoins
final temoins = await temoinService.getTemoins();

// Créer un témoin
final result = await temoinService.createTemoin({
  'nom': 'Durand',
  'prenom': 'Paul',
  'courriel': 'paul.durand@example.com',
});
```

---

### 5. **AssociationService** (`lib/services/association_service.dart`) ⭐ NOUVEAU

Service pour créer des associations entre enseignants, élèves et témoins.

#### Utilisation :

```dart
final associationService = AssociationService();

// Créer une association
final result = await associationService.createAssociation(
  enseignantId: 2,
  eleveId: 3,
  temoinId: 4, // Optionnel
);

// Réponse
{
  "message": "Association enregistrée avec succès",
  "association": {
    "enseignant_id": 2,
    "eleve_id": 3,
    "temoin_id": 4
  }
}
```

---

### 6. **RapportService** (`lib/services/rapport_service.dart`)

#### Endpoints mis à jour :

- `GET /api/rapports` - Liste des rapports de l'enseignant
- `POST /api/rapports` - Créer un rapport
- `GET /api/rapports/{id}` - Détails d'un rapport
- `DELETE /api/rapports/{id}` - Supprimer un rapport
- `GET /api/mes-rapports` - Rapports du parent avec détails

#### Structure pour créer un rapport :

```dart
final rapportService = RapportService();

final result = await rapportService.createRapport({
  'parent_id': 1,
  'date': '2024-01-15',
  'heure_debut': '14:00',
  'heure_fin': '15:00',
  'contenu': 'Séance de mathématiques...',
});
```

#### Réponse de `/api/mes-rapports` (pour parent) :

```json
[
  {
    "id": 1,
    "date_rapport": "2024-01-15",
    "heure_debut": "14:00",
    "heure_fin": "15:00",
    "contenu": "...",
    "enseignant_nom": "Dupont",
    "enseignant_prenom": "Jean",
    "eleves": "Marie Martin, Paul Durand"
  }
]
```

---

### 7. **ParentService** (`lib/services/parent_service.dart`)

#### Endpoint principal : `/api/parent/stats`

```json
{
  "enseignants": 5,
  "eleves": 10,
  "temoins": 3,
  "seances": 0
}
```

#### Utilisation :

```dart
final parentService = ParentService();

// Statistiques du parent
final stats = await parentService.getStats();
print('Nombre d\'enseignants: ${stats['enseignants']}');

// Rapports du parent
final rapports = await parentService.getRapports();

// Séances du parent
final seances = await parentService.getSeances();
```

---

### 8. **NiveauService** (`lib/services/niveau_service.dart`) ⭐ NOUVEAU

Service pour récupérer les niveaux scolaires.

```dart
final niveauService = NiveauService();
final niveaux = await niveauService.getNiveaux();

// Réponse
[
  { "id": 1, "nom": "Primaire" },
  { "id": 2, "nom": "Collège" },
  { "id": 3, "nom": "Lycée" }
]
```

---

## 📊 Flux de travail typique

### 1. **Inscription et connexion (Parent)**

```dart
// 1. Inscription du parent
final authService = AuthService();
await authService.register(
  prenomNom: 'Pierre',
  nomFamille: 'Dupont',
  courriel: 'pierre.dupont@example.com',
  motDePasse: 'password123',
  motDePasseConfirmation: 'password123',
);

// 2. Connexion
await authService.login(
  'pierre.dupont@example.com',
  'password123',
  'parent'
);
```

### 2. **Création d'un élève par le parent**

```dart
final eleveService = EleveService();
final result = await eleveService.createEleve({
  'nom_famille': 'Martin',
  'prenom': 'Marie',
  'courriel': 'marie.martin@example.com',
  'niveau_id': 1,
});

// ⚠️ IMPORTANT : Envoyer le mot de passe généré à l'élève
String motDePasse = result['password'];
// TODO: Envoyer par email/SMS
```

### 3. **Création d'un enseignant par le parent**

```dart
final enseignantService = EnseignantService();
await enseignantService.createEnseignant({
  'prenom': 'Jean',
  'nom_famille': 'Dupont',
  'courriel': 'jean.dupont@example.com',
  'mode_paiement': 'virement',
  'salaire': 2500,
});

// Le mot de passe est généré automatiquement (défaut: 'password')
```

### 4. **Création d'un témoin par le parent**

```dart
final temoinService = TemoinService();
await temoinService.createTemoin({
  'nom': 'Durand',
  'prenom': 'Paul',
  'courriel': 'paul.durand@example.com',
});
```

### 5. **Association enseignant-élève-témoin**

```dart
final associationService = AssociationService();
await associationService.createAssociation(
  enseignantId: 2,
  eleveId: 3,
  temoinId: 4,
);
```

### 6. **Connexion de l'élève/enseignant/témoin**

```dart
// L'élève se connecte avec le mot de passe reçu
await authService.login(
  'marie.martin@example.com',
  'abc12345', // Mot de passe reçu
  'eleve'
);

// L'enseignant se connecte
await authService.login(
  'jean.dupont@example.com',
  'password', // Mot de passe par défaut
  'enseignant'
);
```

---

## ⚠️ Points importants

### 1. **Gestion des mots de passe**

- **Élèves** : Le backend génère un mot de passe aléatoire retourné dans `result['password']`
- **Enseignants/Témoins** : Mot de passe par défaut = `'password'` (hashé)
- **Action requise** : Implémenter l'envoi du mot de passe par email/SMS

### 2. **Routes manquantes dans le backend**

Les routes suivantes n'existent pas encore côté backend :

- `PUT /api/eleve/{id}` - Mise à jour d'un élève
- `DELETE /api/eleve/{id}` - Suppression d'un élève
- `PUT /api/enseignant/{id}` - Mise à jour d'un enseignant
- `DELETE /api/enseignant/{id}` - Suppression d'un enseignant
- `PUT /api/temoin/{id}` - Mise à jour d'un témoin
- `DELETE /api/temoin/{id}` - Suppression d'un témoin

**Action requise** : Ajouter ces routes dans le backend Laravel si nécessaire.

### 3. **Authentification multi-rôle**

Le login backend vérifie le rôle et retourne des données différentes :

```dart
// Réponse pour 'parent'
{
  "token": "...",
  "role": "parent",
  "user": { ... },
  "parent_info": { ... }
}

// Réponse pour 'eleve'
{
  "token": "...",
  "role": "eleve",
  "user": { ... },
  "parent_eleve": { ... }
}
```

### 4. **Structure des données imbriquées**

Les réponses du backend incluent souvent des relations imbriquées :

```json
{
  "id": 1,
  "id_parent": 1,
  "id_eleve": 2,
  "eleve": { "id": 2, "nom_famille": "...", ... },
  "parent": { "id": 1, "prenom_nom": "...", ... }
}
```

Accéder aux données : `response['eleve']['nom_famille']`

---

## 🧪 Tests recommandés

### 1. Tester l'inscription et la connexion

```dart
// Test parent
final auth = AuthService();
await auth.register(...);
await auth.login('email', 'password', 'parent');

// Test élève
await auth.login('eleve@example.com', 'motdepasse', 'eleve');
```

### 2. Tester la création d'utilisateurs

```dart
// Créer un élève et vérifier le mot de passe généré
final result = await eleveService.createEleve({...});
assert(result['password'] != null);
```

### 3. Tester les associations

```dart
// Créer une association et vérifier la réponse
final assoc = await associationService.createAssociation(...);
assert(assoc['message'] == 'Association enregistrée avec succès');
```

---

## 📝 Checklist d'intégration

- [x] AuthService mis à jour avec paramètre `role`
- [x] EleveService aligné avec les endpoints backend
- [x] EnseignantService aligné avec les endpoints backend
- [x] TemoinService aligné avec les endpoints backend
- [x] AssociationService créé
- [x] RapportService mis à jour
- [x] ParentService mis à jour
- [x] NiveauService créé
- [ ] Implémenter l'envoi de mot de passe par email/SMS
- [ ] Ajouter les routes update/delete manquantes dans le backend
- [ ] Tester tous les flux utilisateur
- [ ] Gérer les erreurs de validation du backend
- [ ] Ajouter un système de changement de mot de passe

---

## 🔗 Endpoints API disponibles

| Méthode | Endpoint | Description | Authentification |
|---------|----------|-------------|------------------|
| POST | `/api/register` | Inscription parent | Non |
| POST | `/api/login` | Connexion (tous rôles) | Non |
| POST | `/api/logout` | Déconnexion | Oui |
| GET | `/api/parent/stats` | Statistiques parent | Oui (parent) |
| GET | `/api/eleve/index` | Liste élèves du parent | Oui (parent) |
| POST | `/api/eleve/store` | Créer un élève | Oui (parent) |
| GET | `/api/enseignant/index` | Liste enseignants du parent | Oui (parent) |
| POST | `/api/enseignant/store` | Créer un enseignant | Oui (parent) |
| GET | `/api/mes-eleves` | Élèves de l'enseignant | Oui (enseignant) |
| GET | `/api/temoin/index` | Liste témoins du parent | Oui (parent) |
| POST | `/api/temoin/store` | Créer un témoin | Oui (parent) |
| POST | `/api/associations` | Créer une association | Oui (parent) |
| GET | `/api/rapports` | Rapports de l'enseignant | Oui (enseignant) |
| POST | `/api/rapports` | Créer un rapport | Oui (enseignant) |
| GET | `/api/mes-rapports` | Rapports du parent | Oui (parent) |
| DELETE | `/api/rapports/{id}` | Supprimer un rapport | Oui |
| GET | `/api/emploi` | Séances de l'enseignant | Oui (enseignant) |
| POST | `/api/emploi` | Créer des séances | Oui (enseignant) |
| GET | `/api/emplois-eleve` | Séances de l'élève | Oui (eleve) |
| GET | `/api/emplois-parent` | Séances du parent | Oui (parent) |
| GET | `/api/emplois-temoin` | Séances du témoin | Oui (temoin) |
| GET | `/api/niveau/index` | Liste des niveaux | Oui |

---

## 💡 Conseils d'utilisation

1. **Toujours vérifier le rôle** avant d'appeler une API
2. **Gérer les erreurs** avec try-catch
3. **Afficher le mot de passe généré** à l'utilisateur parent
4. **Valider les données** avant l'envoi
5. **Utiliser les tokens** pour toutes les requêtes authentifiées

---

## 📞 Support

Pour toute question sur l'intégration, référez-vous aux contrôleurs backend :
- `AuthController.php`
- `EleveController.php`
- `EnseignantController.php`
- `TemoinController.php`
- `AssociationController.php`
- `RapportController.php`
- `ParentController.php`
- `SeanceController.php`
- `NiveauController.php`

---

**Date de mise à jour** : 2025-09-29
**Version** : 1.0
