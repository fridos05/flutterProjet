import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

/// Widget pour afficher les erreurs de manière conviviale avec détails techniques
class ErrorDisplay extends StatelessWidget {
  final String message;
  final String? technicalDetails;
  final VoidCallback? onRetry;
  final bool showTechnicalDetails;

  const ErrorDisplay({
    Key? key,
    required this.message,
    this.technicalDetails,
    this.onRetry,
    this.showTechnicalDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Une erreur est survenue',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            if (technicalDetails != null) ...[
              const SizedBox(height: 16),
              _TechnicalDetailsExpansion(
                details: technicalDetails!,
                showByDefault: showTechnicalDetails,
              ),
            ],
            
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Méthode statique pour afficher un SnackBar d'erreur
  static void showSnackBar(
    BuildContext context,
    String message, {
    String? technicalDetails,
    Duration duration = const Duration(seconds: 4),
  }) {
    developer.log('❌ Erreur affichée: $message', name: 'ErrorDisplay');
    if (technicalDetails != null) {
      developer.log('Détails: $technicalDetails', name: 'ErrorDisplay');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (technicalDetails != null) ...[
              const SizedBox(height: 8),
              Text(
                technicalDetails,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: duration,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Méthode statique pour afficher un dialog d'erreur
  static Future<void> showErrorDialog(
    BuildContext context,
    String message, {
    String? technicalDetails,
    VoidCallback? onRetry,
  }) {
    developer.log('❌ Dialog d\'erreur: $message', name: 'ErrorDisplay');
    
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text('Erreur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (technicalDetails != null) ...[
              const SizedBox(height: 16),
              _TechnicalDetailsExpansion(details: technicalDetails),
            ],
          ],
        ),
        actions: [
          if (onRetry != null)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Extraire un message d'erreur convivial depuis une exception
  static String extractMessage(dynamic error) {
    if (error == null) return 'Erreur inconnue';
    
    final errorString = error.toString();
    
    // Extraire le message après "Exception: "
    if (errorString.contains('Exception: ')) {
      return errorString.split('Exception: ').last;
    }
    
    // Extraire le message après "Error: "
    if (errorString.contains('Error: ')) {
      return errorString.split('Error: ').last;
    }
    
    return errorString;
  }

  /// Obtenir un message convivial selon le type d'erreur
  static String getFriendlyMessage(dynamic error) {
    final errorMsg = extractMessage(error).toLowerCase();
    
    if (errorMsg.contains('timeout')) {
      return 'Le serveur met trop de temps à répondre. Vérifiez votre connexion internet.';
    }
    
    if (errorMsg.contains('socket') || errorMsg.contains('network')) {
      return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
    }
    
    if (errorMsg.contains('401') || errorMsg.contains('unauthenticated')) {
      return 'Vous devez vous reconnecter pour continuer.';
    }
    
    if (errorMsg.contains('403') || errorMsg.contains('forbidden')) {
      return 'Vous n\'avez pas les permissions nécessaires.';
    }
    
    if (errorMsg.contains('404') || errorMsg.contains('not found')) {
      return 'La ressource demandée est introuvable.';
    }
    
    if (errorMsg.contains('500') || errorMsg.contains('server error')) {
      return 'Une erreur s\'est produite sur le serveur. Veuillez réessayer plus tard.';
    }
    
    return extractMessage(error);
  }
}

class _TechnicalDetailsExpansion extends StatefulWidget {
  final String details;
  final bool showByDefault;

  const _TechnicalDetailsExpansion({
    required this.details,
    this.showByDefault = false,
  });

  @override
  State<_TechnicalDetailsExpansion> createState() => _TechnicalDetailsExpansionState();
}

class _TechnicalDetailsExpansionState extends State<_TechnicalDetailsExpansion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.showByDefault;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.code,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Détails techniques',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    widget.details,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.details));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Détails copiés dans le presse-papiers'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('Copier'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Extension pour faciliter l'affichage des erreurs
extension ErrorHandlingExtension on BuildContext {
  void showError(
    dynamic error, {
    VoidCallback? onRetry,
    bool useDialog = false,
  }) {
    final message = ErrorDisplay.getFriendlyMessage(error);
    final technical = ErrorDisplay.extractMessage(error);
    
    if (useDialog) {
      ErrorDisplay.showErrorDialog(
        this,
        message,
        technicalDetails: technical,
        onRetry: onRetry,
      );
    } else {
      ErrorDisplay.showSnackBar(
        this,
        message,
        technicalDetails: technical,
      );
    }
  }
}
