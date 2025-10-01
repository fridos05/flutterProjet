<?php
// app/Http/Controllers/EmailController.php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use App\Mail\SendPasswordMail;
use App\Mail\WelcomeUserMail;

/**
 * Contrôleur pour gérer l'envoi d'emails
 * À ajouter dans votre backend Laravel
 */
class EmailController extends Controller
{
    /**
     * Envoyer le mot de passe à un nouvel utilisateur
     * 
     * POST /api/send-password
     * 
     * Body:
     * {
     *   "destinataire": "email@example.com",
     *   "nom_complet": "Jean Dupont",
     *   "mot_de_passe": "abc12345",
     *   "role": "eleve"
     * }
     */
    public function sendPassword(Request $request)
    {
        $validated = $request->validate([
            'destinataire' => 'required|email',
            'nom_complet' => 'required|string',
            'mot_de_passe' => 'required|string',
            'role' => 'required|in:eleve,enseignant,temoin',
        ]);

        try {
            Mail::to($validated['destinataire'])->send(
                new SendPasswordMail(
                    $validated['nom_complet'],
                    $validated['mot_de_passe'],
                    $validated['role']
                )
            );

            return response()->json([
                'message' => 'Email envoyé avec succès',
                'destinataire' => $validated['destinataire']
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de l\'envoi de l\'email',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Envoyer un email de bienvenue personnalisé
     * 
     * POST /api/send-welcome-email
     */
    public function sendWelcomeEmail(Request $request)
    {
        $validated = $request->validate([
            'destinataire' => 'required|email',
            'nom_complet' => 'required|string',
            'mot_de_passe' => 'required|string',
            'role' => 'required|in:eleve,enseignant,temoin',
            'message_personnalise' => 'nullable|string',
        ]);

        try {
            Mail::to($validated['destinataire'])->send(
                new WelcomeUserMail(
                    $validated['nom_complet'],
                    $validated['mot_de_passe'],
                    $validated['role'],
                    $validated['message_personnalise'] ?? null
                )
            );

            return response()->json([
                'message' => 'Email de bienvenue envoyé avec succès',
                'destinataire' => $validated['destinataire']
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de l\'envoi de l\'email',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Envoyer un SMS avec le mot de passe (optionnel)
     * Nécessite un service SMS comme Twilio, Nexmo, etc.
     * 
     * POST /api/send-sms-password
     */
    public function sendSMSPassword(Request $request)
    {
        $validated = $request->validate([
            'telephone' => 'required|string',
            'nom_complet' => 'required|string',
            'mot_de_passe' => 'required|string',
        ]);

        // TODO: Implémenter l'envoi de SMS avec votre service préféré
        // Exemple avec Twilio:
        // $twilio = new Client(config('services.twilio.sid'), config('services.twilio.token'));
        // $message = $twilio->messages->create(
        //     $validated['telephone'],
        //     [
        //         'from' => config('services.twilio.phone'),
        //         'body' => "Bonjour {$validated['nom_complet']}, votre mot de passe est: {$validated['mot_de_passe']}"
        //     ]
        // );

        return response()->json([
            'message' => 'Fonctionnalité SMS non encore implémentée',
        ], 501);
    }
}
