# Guide d'installation - Envoi d'emails

Ce guide explique comment configurer l'envoi automatique de mots de passe par email dans votre application EduManager.

---

## 📋 Table des matières

1. [Configuration Backend (Laravel)](#configuration-backend-laravel)
2. [Configuration Frontend (Flutter)](#configuration-frontend-flutter)
3. [Utilisation](#utilisation)
4. [Tests](#tests)
5. [Dépannage](#dépannage)

---

## 🔧 Configuration Backend (Laravel)

### Étape 1 : Créer le contrôleur Email

Créez le fichier `app/Http/Controllers/EmailController.php` :

```php
<?php
// Voir le fichier backend_email_controller.php fourni
```

### Étape 2 : Créer les Mailables

Créez `app/Mail/SendPasswordMail.php` et `app/Mail/WelcomeUserMail.php` :

```bash
php artisan make:mail SendPasswordMail
php artisan make:mail WelcomeUserMail
```

Puis copiez le contenu du fichier `backend_email_mailable.php` fourni.

### Étape 3 : Créer les templates email

Créez les vues Blade dans `resources/views/emails/` :

- `send-password.blade.php`
- `welcome-user.blade.php`

Copiez le contenu du fichier `backend_email_templates.blade.php` fourni.

### Étape 4 : Ajouter les routes

Dans `routes/api.php`, ajoutez :

```php
use App\Http\Controllers\EmailController;

// Routes pour l'envoi d'emails (protégées par auth:sanctum)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/send-password', [EmailController::class, 'sendPassword']);
    Route::post('/send-welcome-email', [EmailController::class, 'sendWelcomeEmail']);
    Route::post('/send-sms-password', [EmailController::class, 'sendSMSPassword']);
});
```

### Étape 5 : Configurer le service d'email

Dans `.env`, configurez votre service d'email :

#### Option 1 : Gmail (développement)

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=votre-email@gmail.com
MAIL_PASSWORD=votre-mot-de-passe-app
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=votre-email@gmail.com
MAIL_FROM_NAME="EduManager"
```

**Note** : Pour Gmail, vous devez créer un "Mot de passe d'application" :
1. Allez dans les paramètres de votre compte Google
2. Sécurité → Validation en deux étapes
3. Mots de passe des applications
4. Générez un nouveau mot de passe

#### Option 2 : Mailtrap (tests)

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=votre-username-mailtrap
MAIL_PASSWORD=votre-password-mailtrap
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@edumanager.com
MAIL_FROM_NAME="EduManager"
```

#### Option 3 : SendGrid (production)

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.sendgrid.net
MAIL_PORT=587
MAIL_USERNAME=apikey
MAIL_PASSWORD=votre-api-key-sendgrid
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@votre-domaine.com
MAIL_FROM_NAME="EduManager"
```

### Étape 6 : Tester la configuration

```bash
php artisan tinker
```

Puis dans tinker :

```php
Mail::raw('Test email', function ($message) {
    $message->to('votre-email@example.com')
            ->subject('Test EduManager');
});
```

---

## 📱 Configuration Frontend (Flutter)

### Étape 1 : Vérifier les fichiers créés

Les fichiers suivants ont été créés automatiquement :

- ✅ `lib/services/email_service.dart`
- ✅ `lib/widgets/password_display_dialog.dart`
- ✅ Mises à jour dans `eleve_service.dart`, `enseignant_service.dart`, `temoin_service.dart`

### Étape 2 : Pas de configuration supplémentaire nécessaire

Le frontend est prêt à utiliser ! Les services enverront automatiquement les emails via le backend.

---

## 🚀 Utilisation

### Créer un élève avec envoi d'email automatique

```dart
final eleveService = EleveService();

try {
  final result = await eleveService.createEleve({
    'nom_famille': 'Martin',
    'prenom': 'Marie',
    'courriel': 'marie.martin@example.com',
    'niveau_id': 1,
  }, envoyerEmail: true); // Par défaut true
  
  // Vérifier si l'email a été envoyé
  if (result['email_envoye'] == true) {
    print('✅ Email envoyé avec succès');
  } else {
    print('⚠️ Email non envoyé: ${result['email_erreur']}');
    
    // Afficher le dialog avec le mot de passe
    await PasswordDisplayDialog.show(
      context,
      nomComplet: '${result['eleve']['prenom']} ${result['eleve']['nom_famille']}',
      email: result['eleve']['courriel'],
      motDePasse: result['password'],
      role: 'eleve',
      emailEnvoye: false,
      emailErreur: result['email_erreur'],
    );
  }
} catch (e) {
  print('Erreur: $e');
}
```

### Créer un enseignant avec envoi d'email

```dart
final enseignantService = EnseignantService();

final result = await enseignantService.createEnseignant({
  'prenom': 'Jean',
  'nom_famille': 'Dupont',
  'courriel': 'jean.dupont@example.com',
  'mode_paiement': 'virement',
  'salaire': 2500,
}, envoyerEmail: true);

// Le mot de passe par défaut est 'password'
if (result['email_envoye'] == true) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Enseignant créé et email envoyé !')),
  );
}
```

### Désactiver l'envoi d'email

```dart
// Si vous voulez créer un utilisateur sans envoyer d'email
final result = await eleveService.createEleve(
  data,
  envoyerEmail: false, // Désactiver l'envoi
);

// Puis afficher le dialog manuellement
await PasswordDisplayDialog.show(
  context,
  nomComplet: nomComplet,
  email: email,
  motDePasse: result['password'],
  role: 'eleve',
  emailEnvoye: false,
);
```

### Afficher le dialog de mot de passe

```dart
import 'package:edumanager/widgets/password_display_dialog.dart';

// Méthode simple
await PasswordDisplayDialog.show(
  context,
  nomComplet: 'Marie Martin',
  email: 'marie.martin@example.com',
  motDePasse: 'abc12345',
  role: 'eleve',
  emailEnvoye: true, // ou false si échec
  emailErreur: null, // ou message d'erreur
);
```

---

## 🧪 Tests

### Test 1 : Vérifier la configuration email (Backend)

```bash
# Dans le terminal Laravel
php artisan tinker
```

```php
use App\Mail\SendPasswordMail;
use Illuminate\Support\Facades\Mail;

Mail::to('votre-email@example.com')->send(
    new SendPasswordMail('Test User', 'test123', 'eleve')
);
```

### Test 2 : Tester l'endpoint API

Avec Postman ou curl :

```bash
curl -X POST http://localhost:8000/api/send-password \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "destinataire": "test@example.com",
    "nom_complet": "Test User",
    "mot_de_passe": "abc12345",
    "role": "eleve"
  }'
```

### Test 3 : Tester depuis Flutter

```dart
final emailService = EmailService();

try {
  await emailService.envoyerMotDePasse(
    destinataire: 'test@example.com',
    nomComplet: 'Test User',
    motDePasse: 'test123',
    role: 'eleve',
  );
  print('✅ Email envoyé');
} catch (e) {
  print('❌ Erreur: $e');
}
```

---

## 🔍 Dépannage

### Problème : Les emails ne sont pas envoyés

**Solutions :**

1. **Vérifier la configuration `.env`**
   ```bash
   php artisan config:clear
   php artisan cache:clear
   ```

2. **Vérifier les logs Laravel**
   ```bash
   tail -f storage/logs/laravel.log
   ```

3. **Tester la connexion SMTP**
   ```bash
   php artisan tinker
   ```
   ```php
   Mail::raw('Test', function($m) { $m->to('test@example.com'); });
   ```

### Problème : Gmail bloque les emails

**Solutions :**

1. Activer "Accès moins sécurisé" (non recommandé)
2. Utiliser un "Mot de passe d'application" (recommandé)
3. Utiliser un service d'email dédié (SendGrid, Mailgun, etc.)

### Problème : L'email arrive dans les spams

**Solutions :**

1. Configurer SPF, DKIM et DMARC pour votre domaine
2. Utiliser un service d'email professionnel
3. Éviter les mots "spam" dans le contenu
4. Ajouter un lien de désinscription

### Problème : Le dialog ne s'affiche pas

**Vérifications :**

```dart
// Assurez-vous d'avoir un BuildContext valide
if (!mounted) return;

await PasswordDisplayDialog.show(
  context,
  // ...
);
```

### Problème : Erreur CORS depuis Flutter

**Solution :** Vérifier `config/cors.php` dans Laravel :

```php
'paths' => ['api/*', 'sanctum/csrf-cookie'],
'allowed_methods' => ['*'],
'allowed_origins' => ['*'], // ou votre domaine spécifique
'allowed_headers' => ['*'],
'supports_credentials' => true,
```

---

## 📊 Statistiques et monitoring

### Suivre les emails envoyés

Vous pouvez ajouter une table `email_logs` dans votre base de données :

```php
// Migration
Schema::create('email_logs', function (Blueprint $table) {
    $table->id();
    $table->string('destinataire');
    $table->string('type'); // 'password', 'welcome', etc.
    $table->string('role');
    $table->boolean('envoye')->default(false);
    $table->text('erreur')->nullable();
    $table->timestamps();
});
```

Puis logger chaque envoi dans `EmailController` :

```php
EmailLog::create([
    'destinataire' => $validated['destinataire'],
    'type' => 'password',
    'role' => $validated['role'],
    'envoye' => true,
]);
```

---

## 🔐 Sécurité

### Bonnes pratiques

1. **Ne jamais logger les mots de passe en clair**
2. **Utiliser HTTPS en production**
3. **Limiter le taux d'envoi d'emails** (rate limiting)
4. **Valider tous les inputs**
5. **Utiliser des tokens d'authentification sécurisés**

### Rate limiting (Laravel)

Dans `app/Http/Kernel.php` :

```php
'api' => [
    'throttle:60,1', // 60 requêtes par minute
    \Illuminate\Routing\Middleware\SubstituteBindings::class,
],
```

---

## 📚 Ressources supplémentaires

- [Documentation Laravel Mail](https://laravel.com/docs/mail)
- [Documentation Flutter HTTP](https://pub.dev/packages/http)
- [SendGrid Documentation](https://sendgrid.com/docs/)
- [Mailtrap (tests)](https://mailtrap.io/)

---

## ✅ Checklist finale

- [ ] Backend Laravel configuré
- [ ] EmailController créé
- [ ] Mailables créés
- [ ] Templates email créés
- [ ] Routes API ajoutées
- [ ] Configuration `.env` complétée
- [ ] Test d'envoi d'email réussi
- [ ] Frontend Flutter mis à jour
- [ ] Dialog de mot de passe testé
- [ ] Gestion des erreurs implémentée
- [ ] Documentation lue et comprise

---

**Date de création** : 2025-09-29
**Version** : 1.0
