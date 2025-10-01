<?php
// app/Mail/SendPasswordMail.php
namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

/**
 * Mailable pour envoyer le mot de passe à un nouvel utilisateur
 * À créer dans votre backend Laravel
 */
class SendPasswordMail extends Mailable
{
    use Queueable, SerializesModels;

    public $nomComplet;
    public $motDePasse;
    public $role;

    public function __construct($nomComplet, $motDePasse, $role)
    {
        $this->nomComplet = $nomComplet;
        $this->motDePasse = $motDePasse;
        $this->role = $role;
    }

    public function build()
    {
        $roleLabel = $this->getRoleLabel();
        
        return $this->subject('Vos identifiants de connexion - EduManager')
                    ->view('emails.send-password')
                    ->with([
                        'nomComplet' => $this->nomComplet,
                        'motDePasse' => $this->motDePasse,
                        'role' => $this->role,
                        'roleLabel' => $roleLabel,
                    ]);
    }

    private function getRoleLabel()
    {
        switch ($this->role) {
            case 'eleve':
                return 'Élève';
            case 'enseignant':
                return 'Enseignant';
            case 'temoin':
                return 'Témoin';
            default:
                return $this->role;
        }
    }
}

// app/Mail/WelcomeUserMail.php
namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class WelcomeUserMail extends Mailable
{
    use Queueable, SerializesModels;

    public $nomComplet;
    public $motDePasse;
    public $role;
    public $messagePersonnalise;

    public function __construct($nomComplet, $motDePasse, $role, $messagePersonnalise = null)
    {
        $this->nomComplet = $nomComplet;
        $this->motDePasse = $motDePasse;
        $this->role = $role;
        $this->messagePersonnalise = $messagePersonnalise;
    }

    public function build()
    {
        $roleLabel = $this->getRoleLabel();
        
        return $this->subject('Bienvenue sur EduManager !')
                    ->view('emails.welcome-user')
                    ->with([
                        'nomComplet' => $this->nomComplet,
                        'motDePasse' => $this->motDePasse,
                        'role' => $this->role,
                        'roleLabel' => $roleLabel,
                        'messagePersonnalise' => $this->messagePersonnalise,
                    ]);
    }

    private function getRoleLabel()
    {
        switch ($this->role) {
            case 'eleve':
                return 'Élève';
            case 'enseignant':
                return 'Enseignant';
            case 'temoin':
                return 'Témoin';
            default:
                return $this->role;
        }
    }
}
