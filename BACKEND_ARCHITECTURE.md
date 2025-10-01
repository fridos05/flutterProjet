# 🏗️ Architecture Backend Laravel - EduManager

## 📋 Vue d'ensemble

### Hiérarchie des utilisateurs

```
Parent (Inscription)
    ├── Élèves (via parent_eleve)
    ├── Enseignants (via parent_enseignant)
    └── Témoins (via parent_temoin)
```

### Tables de liaison avec mot de passe

- `parent_eleve` : Lie parent et élève + mot de passe hashé
- `parent_enseignant` : Lie parent et enseignant + mot de passe hashé
- `parent_temoin` : Lie parent et témoin + mot de passe hashé

### Table d'association

- `enseignant_eleve_temoin` : Associe un enseignant à un élève et un témoin (optionnel)

---

## 🔐 Authentification (AuthController)

### POST `/api/register` - Inscription parent

**Body:**
```json
{
  "prenom_nom": "Jean",
  "nom_famille": "Dupont",
  "courriel": "jean.dupont@example.com",
  "mot_de_passe": "password123",
  "mot_de_passe_confirmation": "password123"
}
```

**Response:**
```json
{
  "message": "Utilisateur créé avec succès",
  "user": {...},
  "token": "1|abc123..."
}
```

### POST `/api/login` - Connexion multi-rôle

**Body:**
```json
{
  "courriel": "user@example.com",
  "mot_de_passe": "password",
  "role": "parent|eleve|enseignant|temoin"
}
```

**Response (Parent):**
```json
{
  "message": "Connexion réussie",
  "token": "1|abc123...",
  "role": "parent",
  "user": {
    "id": 1,
    "prenom_nom": "Jean",
    "nom_famille": "Dupont",
    "courriel": "jean.dupont@example.com"
  },
  "parent_info": {...}
}
```

**Response (Élève):**
```json
{
  "message": "Connexion réussie",
  "token": "2|def456...",
  "role": "eleve",
  "user": {
    "id": 2,
    "nom_famille": "Martin",
    "prenom": "Marie",
    "courriel": "marie.martin@example.com",
    "niveau_id": 1
  },
  "parent_eleve": {
    "id": 1,
    "id_parent": 1,
    "id_eleve": 2
  }
}
```

### POST `/api/logout` - Déconnexion

**Headers:** `Authorization: Bearer TOKEN`

**Response:**
```json
{
  "message": "Déconnexion réussie"
}
```

---

## 👨‍🎓 Élèves (EleveController)

### GET `/api/eleve/index` - Liste des élèves du parent

**Response:**
```json
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
    "parent": {...}
  }
]
```

### POST `/api/eleve/store` - Créer un élève

**Body:**
```json
{
  "nom_famille": "Martin",
  "prenom": "Marie",
  "courriel": "marie.martin@example.com",
  "niveau_id": 1
}
```

**Response:**
```json
{
  "message": "Enregistrement d'élève réussi",
  "eleve": {...},
  "parent_relation": {...},
  "password": "abc12345"
}
```

⚠️ **Important:** Le mot de passe est généré aléatoirement (8 caractères) et doit être envoyé à l'élève.

---

## 👨‍🏫 Enseignants (EnseignantController)

### GET `/api/enseignant/index` - Liste des enseignants du parent

**Response:**
```json
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
    "parent": {...},
    "associations": [
      {
        "enseignant_id": 2,
        "eleve_id": 3,
        "temoin_id": 4,
        "eleve": {...},
        "temoin": {...}
      }
    ]
  }
]
```

### POST `/api/enseignant/store` - Créer un enseignant

**Body:**
```json
{
  "prenom": "Jean",
  "nom_famille": "Dupont",
  "courriel": "jean.dupont@example.com",
  "mode_paiement": "virement",
  "salaire": 2500
}
```

**Response:**
```json
"Enrégistrement effectué avec succes"
```

⚠️ **Important:** Le mot de passe par défaut est `"password"` (hashé).

### GET `/api/mes-eleves` - Élèves de l'enseignant connecté

**Response:**
```json
{
  "enseignant_id": 2,
  "parent": {
    "parent_id": 1,
    "parent_nom": "Dupont",
    "parent_prenom": "Jean"
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

---

## 👁️ Témoins (TemoinController)

### GET `/api/temoin/index` - Liste des témoins du parent

**Response:**
```json
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
    "parent": {...}
  }
]
```

### POST `/api/temoin/store` - Créer un témoin

**Body:**
```json
{
  "nom": "Durand",
  "prenom": "Paul",
  "courriel": "paul.durand@example.com"
}
```

**Response:**
```json
"Enregistrement reussi"
```

⚠️ **Important:** Le mot de passe par défaut est `"password"` (hashé).

---

## 🔗 Associations (AssociationController)

### POST `/api/associations` - Créer une association

**Body:**
```json
{
  "enseignant_id": 2,
  "eleve_id": 3,
  "temoin_id": 4
}
```

**Response:**
```json
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

## 📝 Rapports (RapportController)

### GET `/api/rapports` - Liste des rapports de l'enseignant

**Response:**
```json
[
  {
    "id": 1,
    "id_enseignant": 2,
    "id_parent": 1,
    "date_rapport": "2024-01-15",
    "heure_debut": "14:00",
    "heure_fin": "15:00",
    "contenu": "Séance de mathématiques..."
  }
]
```

### POST `/api/rapports` - Créer un rapport

**Body:**
```json
{
  "parent_id": 1,
  "date": "2024-01-15",
  "heure_debut": "14:00",
  "heure_fin": "15:00",
  "contenu": "Séance de mathématiques..."
}
```

**Response:**
```json
{
  "message": "Rapport enregistré avec succès",
  "rapport": {...}
}
```

### GET `/api/mes-rapports` - Rapports du parent

**Response:**
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

### GET `/api/rapports/{id}` - Détails d'un rapport

### DELETE `/api/rapports/{id}` - Supprimer un rapport

---

## 📅 Séances (SeanceController)

### GET `/api/emploi` - Séances de l'enseignant

**Response:**
```json
[
  {
    "id": 1,
    "id_enseignant": 2,
    "id_eleve": 3,
    "id_temoin": 4,
    "id_parent": 1,
    "jour": "Lundi",
    "heure": "14:00",
    "matiere": "Mathématiques"
  }
]
```

### POST `/api/emploi` - Créer des séances

**Body:**
```json
{
  "seances": [
    {
      "jour": "Lundi",
      "heure": "14:00",
      "matiere": "Mathématiques",
      "eleve_id": 3,
      "temoin_id": 4,
      "parent_id": 1
    }
  ]
}
```

**Response:**
```json
{
  "message": "Séances enregistrées avec succès",
  "seances": [...]
}
```

### GET `/api/emplois-eleve` - Séances de l'élève connecté

### GET `/api/emplois-temoin` - Séances du témoin connecté

### GET `/api/emplois-parent` - Séances du parent connecté

---

## 👪 Parent (ParentController)

### GET `/api/parent/stats` - Statistiques du parent

**Response:**
```json
{
  "enseignants": 5,
  "eleves": 10,
  "temoins": 3,
  "seances": 0
}
```

---

## 📚 Niveaux (NiveauController)

### GET `/api/niveau/index` - Liste des niveaux

**Response:**
```json
[
  {"id": 1, "nom": "Primaire"},
  {"id": 2, "nom": "Collège"},
  {"id": 3, "nom": "Lycée"}
]
```

---

## 📊 Résumé des endpoints

| Méthode | Endpoint | Description | Auth |
|---------|----------|-------------|------|
| POST | `/api/register` | Inscription parent | Non |
| POST | `/api/login` | Connexion multi-rôle | Non |
| POST | `/api/logout` | Déconnexion | Oui |
| GET | `/api/parent/stats` | Stats parent | Oui |
| GET | `/api/eleve/index` | Liste élèves | Oui |
| POST | `/api/eleve/store` | Créer élève | Oui |
| GET | `/api/enseignant/index` | Liste enseignants | Oui |
| POST | `/api/enseignant/store` | Créer enseignant | Oui |
| GET | `/api/mes-eleves` | Élèves de l'enseignant | Oui |
| GET | `/api/temoin/index` | Liste témoins | Oui |
| POST | `/api/temoin/store` | Créer témoin | Oui |
| POST | `/api/associations` | Créer association | Oui |
| GET | `/api/rapports` | Rapports enseignant | Oui |
| POST | `/api/rapports` | Créer rapport | Oui |
| GET | `/api/mes-rapports` | Rapports parent | Oui |
| DELETE | `/api/rapports/{id}` | Supprimer rapport | Oui |
| GET | `/api/emploi` | Séances enseignant | Oui |
| POST | `/api/emploi` | Créer séances | Oui |
| GET | `/api/emplois-eleve` | Séances élève | Oui |
| GET | `/api/emplois-temoin` | Séances témoin | Oui |
| GET | `/api/emplois-parent` | Séances parent | Oui |
| GET | `/api/niveau/index` | Liste niveaux | Oui |

---

## ⚠️ Points importants

1. **Mots de passe:**
   - Parent: Défini lors de l'inscription
   - Élève: Généré aléatoirement (8 caractères)
   - Enseignant/Témoin: "password" par défaut

2. **Authentification:**
   - Utilise Laravel Sanctum
   - Token dans header: `Authorization: Bearer TOKEN`
   - Paramètre `role` requis pour le login

3. **Tables de liaison:**
   - Toutes ont un champ `mot_de_passe` hashé
   - Utilisées pour l'authentification des sous-utilisateurs

4. **Associations:**
   - Un enseignant peut avoir plusieurs élèves
   - Chaque association peut avoir un témoin (optionnel)

---

**Date:** 2025-09-29  
**Version:** 1.0
