{{-- resources/views/emails/send-password.blade.php --}}
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vos identifiants de connexion</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            background-color: #4CAF50;
            color: white;
            padding: 20px;
            text-align: center;
            border-radius: 5px 5px 0 0;
        }
        .content {
            background-color: #f9f9f9;
            padding: 30px;
            border: 1px solid #ddd;
        }
        .password-box {
            background-color: #e3f2fd;
            border: 2px solid #2196F3;
            padding: 20px;
            margin: 20px 0;
            text-align: center;
            border-radius: 5px;
        }
        .password {
            font-size: 24px;
            font-weight: bold;
            letter-spacing: 3px;
            color: #1976D2;
            font-family: monospace;
        }
        .warning {
            background-color: #fff3cd;
            border: 1px solid #ffc107;
            padding: 15px;
            margin: 20px 0;
            border-radius: 5px;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            color: #666;
            font-size: 12px;
        }
        .button {
            display: inline-block;
            padding: 12px 30px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Bienvenue sur EduManager</h1>
    </div>
    
    <div class="content">
        <p>Bonjour <strong>{{ $nomComplet }}</strong>,</p>
        
        <p>Votre compte <strong>{{ $roleLabel }}</strong> a été créé avec succès sur la plateforme EduManager.</p>
        
        <p>Voici vos identifiants de connexion :</p>
        
        <div class="password-box">
            <p style="margin: 0; color: #666;">Mot de passe temporaire</p>
            <p class="password">{{ $motDePasse }}</p>
        </div>
        
        <div class="warning">
            <strong>⚠️ Important :</strong>
            <ul style="margin: 10px 0;">
                <li>Conservez ce mot de passe en lieu sûr</li>
                <li>Vous devrez le changer lors de votre première connexion</li>
                <li>Ne partagez jamais votre mot de passe avec qui que ce soit</li>
            </ul>
        </div>
        
        <p style="text-align: center;">
            <a href="http://votre-app.com/login" class="button">Se connecter</a>
        </p>
        
        <p>Si vous n'avez pas demandé la création de ce compte, veuillez ignorer cet email ou contacter l'administrateur.</p>
    </div>
    
    <div class="footer">
        <p>Cet email a été envoyé automatiquement, merci de ne pas y répondre.</p>
        <p>&copy; {{ date('Y') }} EduManager. Tous droits réservés.</p>
    </div>
</body>
</html>

{{-- resources/views/emails/welcome-user.blade.php --}}
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bienvenue sur EduManager</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
            border-radius: 5px 5px 0 0;
        }
        .content {
            background-color: #ffffff;
            padding: 30px;
            border: 1px solid #ddd;
        }
        .info-box {
            background-color: #f5f5f5;
            padding: 20px;
            margin: 20px 0;
            border-left: 4px solid #667eea;
        }
        .password-box {
            background-color: #e8eaf6;
            border: 2px solid #5c6bc0;
            padding: 20px;
            margin: 20px 0;
            text-align: center;
            border-radius: 5px;
        }
        .password {
            font-size: 28px;
            font-weight: bold;
            letter-spacing: 4px;
            color: #3f51b5;
            font-family: monospace;
        }
        .steps {
            background-color: #e8f5e9;
            padding: 20px;
            margin: 20px 0;
            border-radius: 5px;
        }
        .steps ol {
            margin: 10px 0;
            padding-left: 20px;
        }
        .steps li {
            margin: 10px 0;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            color: #666;
            font-size: 12px;
        }
        .button {
            display: inline-block;
            padding: 15px 40px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 25px;
            margin: 20px 0;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎓 Bienvenue sur EduManager !</h1>
        <p style="margin: 0;">Votre plateforme de gestion éducative</p>
    </div>
    
    <div class="content">
        <p>Bonjour <strong>{{ $nomComplet }}</strong>,</p>
        
        <p>Nous sommes ravis de vous accueillir sur <strong>EduManager</strong> en tant que <strong>{{ $roleLabel }}</strong> !</p>
        
        @if($messagePersonnalise)
        <div class="info-box">
            <p><strong>Message personnalisé :</strong></p>
            <p>{{ $messagePersonnalise }}</p>
        </div>
        @endif
        
        <h3>🔐 Vos identifiants de connexion</h3>
        
        <div class="password-box">
            <p style="margin: 0; color: #666; font-size: 14px;">Mot de passe temporaire</p>
            <p class="password">{{ $motDePasse }}</p>
        </div>
        
        <div class="steps">
            <h4 style="margin-top: 0;">📝 Premiers pas :</h4>
            <ol>
                <li>Cliquez sur le bouton ci-dessous pour accéder à la plateforme</li>
                <li>Connectez-vous avec votre email et le mot de passe ci-dessus</li>
                <li>Changez votre mot de passe lors de votre première connexion</li>
                <li>Explorez les fonctionnalités disponibles selon votre rôle</li>
            </ol>
        </div>
        
        <p style="text-align: center;">
            <a href="http://votre-app.com/login" class="button">Accéder à EduManager</a>
        </p>
        
        <div style="background-color: #fff3cd; padding: 15px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #ffc107;">
            <p style="margin: 0;"><strong>⚠️ Sécurité :</strong></p>
            <ul style="margin: 10px 0;">
                <li>Ne partagez jamais votre mot de passe</li>
                <li>Déconnectez-vous après chaque session</li>
                <li>Changez régulièrement votre mot de passe</li>
            </ul>
        </div>
        
        <p>Si vous avez des questions ou besoin d'aide, n'hésitez pas à contacter le support.</p>
        
        <p>Bonne utilisation !</p>
        <p><strong>L'équipe EduManager</strong></p>
    </div>
    
    <div class="footer">
        <p>Cet email a été envoyé automatiquement, merci de ne pas y répondre.</p>
        <p>Si vous n'avez pas demandé la création de ce compte, veuillez contacter l'administrateur.</p>
        <p>&copy; {{ date('Y') }} EduManager. Tous droits réservés.</p>
    </div>
</body>
</html>
