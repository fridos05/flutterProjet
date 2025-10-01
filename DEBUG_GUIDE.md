# 🐛 Guide de débogage - EduManager

## 📋 Logs de debug activés

Tous les services ont maintenant des logs détaillés pour faciliter le débogage.

---

## 🔍 Comment voir les logs

### Dans Android Studio / VS Code

1. Ouvrez le terminal **Debug Console** ou **Run**
2. Lancez l'application avec `flutter run`
3. Les logs apparaîtront automatiquement avec des émojis pour faciliter la lecture

### Dans le terminal

```bash
flutter run --verbose
```

### Filtrer les logs par service

```bash
# Voir uniquement les logs HTTP
flutter logs | grep "HTTP"

# Voir uniquement les logs d'authentification
flutter logs | grep "AuthService"

# Voir uniquement les erreurs
flutter logs | grep "❌"
```

---

## 📊 Types de logs

### 🔵 Requêtes GET
```
🔵 GET Request
Data: {"url": "http://192.168.10.101:8000/api/eleve/index"}
```

### 🟢 Requêtes POST
```
🟢 POST Request
Data: {"url": "...", "payload": {...}}
```

### 🟡 Requêtes PUT
```
🟡 PUT Request
Data: {"url": "...", "payload": {...}}
```

### 🔴 Requêtes DELETE
```
🔴 DELETE Request
Data: {"url": "..."}
```

### ✅ Succès
```
✅ GET Response 200
Data: {"url": "...", "status": 200, "body": "..."}
```

### ❌ Erreurs
```
❌ HTTP Error 401
Data: {
  "method": "POST",
  "url": "...",
  "status": 401,
  "error": "Non authentifié",
  "body": "..."
}
```

### ⏱️ Timeout
```
⏱️ Timeout: Le serveur ne répond pas après 30 secondes
```

---

## 🔐 Logs d'authentification

### Connexion réussie
```
🔐 Tentative de connexion
Data: {"courriel": "user@example.com", "role": "parent"}

📥 Réponse login: 200

✅ Connexion réussie
Data: {"user": {...}, "role": "parent"}

💾 Données sauvegardées localement
```

### Connexion échouée
```
🔐 Tentative de connexion
Data: {"courriel": "user@example.com", "role": "parent"}

📥 Réponse login: 401

❌ Échec connexion: Mot de passe incorrect
Data: {"message": "Mot de passe incorrect"}
```

### Token
```
Token récupéré: ✓ Présent
```
ou
```
Token récupéré: ✗ Absent
```

---

## 🛠️ Résolution des problèmes courants

### Problème 1 : "Token récupéré: ✗ Absent"

**Cause** : L'utilisateur n'est pas connecté ou le token a expiré

**Solution** :
1. Vérifier que l'utilisateur s'est bien connecté
2. Vérifier que le token est sauvegardé après le login
3. Relancer l'application

### Problème 2 : "⏱️ Timeout"

**Cause** : Le serveur backend ne répond pas

**Solution** :
1. Vérifier que le serveur Laravel est démarré
2. Vérifier l'URL dans `ApiService.baseUrl`
3. Vérifier la connexion réseau
4. Tester avec `curl` ou Postman

```bash
curl http://192.168.10.101:8000/api/parent/stats
```

### Problème 3 : "❌ HTTP Error 401"

**Cause** : Token invalide ou expiré

**Solution** :
1. Se déconnecter et se reconnecter
2. Vérifier que le token est bien envoyé dans les headers
3. Vérifier la configuration Sanctum côté backend

### Problème 4 : "❌ HTTP Error 404"

**Cause** : Endpoint inexistant

**Solution** :
1. Vérifier l'URL de l'endpoint
2. Vérifier que la route existe dans `routes/api.php`
3. Vérifier les logs Laravel : `tail -f storage/logs/laravel.log`

### Problème 5 : "❌ HTTP Error 500"

**Cause** : Erreur serveur

**Solution** :
1. Vérifier les logs Laravel
2. Vérifier la base de données
3. Vérifier les migrations

---

## 📱 Activer/Désactiver les logs

### Dans ApiService

```dart
// lib/services/api_service.dart
class ApiService {
  static const bool enableDebugLogs = true; // ← Changer ici
  // ...
}
```

**Mettre à `false` en production !**

---

## 🧪 Tester les endpoints

### Avec curl

```bash
# Test login
curl -X POST http://192.168.10.101:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "courriel": "test@example.com",
    "mot_de_passe": "password",
    "role": "parent"
  }'

# Test avec token
curl -X GET http://192.168.10.101:8000/api/parent/stats \
  -H "Authorization: Bearer VOTRE_TOKEN"
```

### Avec Postman

1. Créer une nouvelle requête
2. Ajouter le header `Authorization: Bearer TOKEN`
3. Tester l'endpoint

---

## 📝 Exemple de débogage complet

### Scénario : L'utilisateur ne peut pas se connecter

1. **Vérifier les logs de connexion**
```
🔐 Tentative de connexion
❌ Erreur de connexion: Exception: Mot de passe incorrect
```

2. **Identifier le problème**
   - Le serveur répond (pas de timeout)
   - L'erreur vient du backend (mot de passe incorrect)

3. **Solution**
   - Vérifier le mot de passe
   - Vérifier que l'utilisateur existe dans la base de données

### Scénario : Les données ne se chargent pas

1. **Vérifier les logs HTTP**
```
🔵 GET Request
Data: {"url": "http://192.168.10.101:8000/api/eleve/index"}

Token récupéré: ✗ Absent

❌ HTTP Error 401
Data: {"error": "Unauthenticated"}
```

2. **Identifier le problème**
   - Token absent
   - L'utilisateur n'est pas authentifié

3. **Solution**
   - Se reconnecter
   - Vérifier que le token est bien sauvegardé

---

## 🎯 Checklist de débogage

Avant de signaler un bug, vérifier :

- [ ] Le serveur backend est démarré
- [ ] L'URL du backend est correcte dans `ApiService.baseUrl`
- [ ] L'utilisateur est connecté (token présent)
- [ ] La route existe côté backend
- [ ] Les logs montrent des détails de l'erreur
- [ ] La base de données est accessible
- [ ] Les migrations sont à jour

---

## 📞 Support

Si le problème persiste après avoir vérifié tous les points :

1. Copier les logs complets
2. Noter les étapes pour reproduire le bug
3. Vérifier les logs Laravel : `storage/logs/laravel.log`
4. Tester l'endpoint avec curl ou Postman

---

## 🔧 Outils utiles

### Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Logs Laravel en temps réel

```bash
tail -f storage/logs/laravel.log
```

### Vérifier la connexion réseau

```bash
ping 192.168.10.101
```

### Tester le serveur

```bash
curl http://192.168.10.101:8000/api/health
```

---

**Date de création** : 2025-09-29  
**Version** : 1.0
