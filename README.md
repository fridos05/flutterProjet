# 📚 EduManager

**Application Flutter premium pour la gestion des cours particuliers**

Une solution complète qui révolutionne la gestion des cours particuliers avec des interfaces utilisateur distinctes et un design élégant inspiré du Togo.

## ✨ Fonctionnalités

### 👥 Gestion Multi-Rôles
- **Parents** : Suivi des cours, paiements et statistiques
- **Enseignants** : Planning, gestion des élèves et revenus  
- **Élèves** : Consultation des cours et devoirs
- **Témoins** : Supervision et médiation
- **Administrateurs** : Contrôle global de la plateforme

### 🎯 Fonctionnalités Clés
- 📅 **Planning Intelligent** - Calendrier interactif avec gestion des créneaux
- 💰 **Gestion Financière** - Suivi des paiements et statistiques
- 📊 **Tableaux de Bord** - Interfaces personnalisées par rôle
- 🔔 **Notifications** - Alertes en temps réel
- 👤 **Authentification** - Système sécurisé multi-rôles
- 📱 **Design Responsive** - Interface adaptée à tous les écrans

## 🚀 Installation

### Prérequis
- Flutter SDK (>=3.9.2)
- Dart SDK
- Android Studio / VS Code

### Démarrage
```bash
# Cloner le projet
git clone [your-repo-url]
cd edumanager

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

## 🛠️ Technologies

- **Flutter** - Framework mobile cross-platform
- **Dart** - Langage de programmation
- **Material Design** - Interface utilisateur moderne
- **Provider** - Gestion d'état
- **Table Calendar** - Calendrier interactif
- **Google Fonts** - Typographie élégante

## 📱 Captures d'écran

### Tableau de Bord Parent
- Suivi des cours de l'enfant
- Évolution des dépenses
- Gestion des paiements

### Interface Enseignant  
- Planning des cours
- Gestion des élèves
- Statistiques de revenus

### Panel Administrateur
- Vue d'ensemble globale
- Gestion des utilisateurs
- Contrôle qualité

## 📦 Structure du Projet

```
lib/
├── models/          # Modèles de données
├── screens/         # Écrans par rôle
│   ├── auth/        # Authentification
│   ├── parent/      # Interface parent
│   ├── teacher/     # Interface enseignant
│   ├── student/     # Interface élève
│   ├── witness/     # Interface témoin
│   └── admin/       # Panel administrateur
├── widgets/         # Composants réutilisables
└── data/           # Données d'exemple
```

## 🎨 Design

Interface moderne avec :
- Couleurs inspirées du patrimoine togolais
- Animations fluides
- Navigation intuitive
- Accessibilité optimisée

## 📋 Roadmap

- [ ] Intégration notifications push
- [ ] Module de messagerie intégrée
- [ ] Système de notation et avis
- [ ] Export de rapports PDF
- [ ] Mode hors ligne
- [ ] API REST backend

## 👨‍💻 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit (`git commit -m 'Ajout nouvelle fonctionnalité'`)
4. Push (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence privée. Tous droits réservés.

---

**EduManager** - Révolutionner l'éducation particulière au Togo 🇹🇬
