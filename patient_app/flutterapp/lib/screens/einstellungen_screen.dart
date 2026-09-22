import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'package:flutterapp/screens/login_screen.dart';
import 'package:flutterapp/services/jwt_service.dart';

import '../application/patient_provider.dart';

/// Screen für die App-Einstellungen.
///
/// Ermöglicht es dem Benutzer, sein Profil einzusehen, das Passwort zu ändern
/// und sich abzumelden.
class EinstellungenScreen extends ConsumerWidget {
  EinstellungenScreen({super.key});

  /// Der Titel des Screens, der in der AppBar angezeigt wird.
  final String title = "Einstellungen";

  /// Service zur Handhabung von JWT-Token (z. B. für den Logout).
  final jwtService = JwtService();

  // Vorbereitung für zukünftige Benachrichtigungseinstellungen
  //final bool pushNotifications = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(patientProvider);
    return profileAsyncValue.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('Fehler: $err'),
      ),
      data: (patientProfile) {
        return Scaffold(
          appBar: AppBar(
            /// Verwendet die im Theme definierte Farbe für die AppBar.
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(title),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// Sektion: Profil-Informationen des Patienten.
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: const Text(
                    'Profil',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  /// Zeigt Vorname, Nachname und Geburtsdatum vom Backend an.
                  subtitle: Text(
                    "Vorname: ${patientProfile.name}\nNachname: ${patientProfile.surname}\nGeburtsdatum: ${patientProfile.birthdate}",
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Sektion: Konto & Sicherheit.
              const Text(
                'Konto & Sicherheit',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Card(
                /// Eintrag zum Ändern des Passworts.
                child: ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Passwort ändern'),
                  onTap: () => _openChangePasswordDialog(context, ref),
                ),
              ),

              const SizedBox(height: 20),

              /// Sektion: Rechtliche Hinweise.
              const Text(
                'Rechtliches',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Impressum'),
                        onPressed: () => _showLegalContent(
                          context,
                          'Impressum',
                          'assets/legal/de/imprint.md',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 2. Button: Datenschutzerklärung
                      ElevatedButton.icon(
                        icon: const Icon(Icons.security),
                        label: const Text('Datenschutzerklärung'),
                        onPressed: () => _showLegalContent(
                          context,
                          'Datenschutzerklärung',
                          'assets/legal/de/privacy_policy.md',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3. Button: AGB
                      ElevatedButton.icon(
                        icon: const Icon(Icons.description),
                        label: const Text('AGB'),
                        onPressed: () => _showLegalContent(
                          context,
                          'Allgemeine Geschäftsbedingungen',
                          'assets/legal/de/terms_of_service.md',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Button zur Abmeldung vom System.
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Abmelden'),
              ),
              const SizedBox(height: 12),

              /// Button zum Löschen des Accounts.
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _delete(context, ref),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Account löschen'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Meldet den Benutzer ab.
  ///
  /// Zeigt einen Bestätigungsdialog an, löscht das JWT-Token über den [jwtService]
  /// und navigiert zurück zum Login-Screen.
  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Abmelden'),
            content: const Text('Möchten Sie sich wirklich abmelden?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Abmelden'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    /// Löscht das AccessToken aus dem sicheren Speicher.

    await jwtService.logout();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sie wurden abgemeldet.')),
    );

    /// Leert den Navigationsstapel und öffnet den Login-Screen.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
    );
  }

  /// Löscht das Benutzerkonto dauerhaft aus dem System.
  ///
  /// Fragt den Benutzer über einen [AlertDialog] nach einer Bestätigung.
  /// Bei Zustimmung wird das Konto über das Patienten-Service gelöscht,
  /// der Token entfernt und der Benutzer zum [LoginScreen] zurückgeleitet.
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final service = ref.read(patientServiceProvider);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Account löschen'),
            content: const Text('Möchten Sie wirklich diesen Account löschen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Löschen'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    var success = await service.deleteAccount();
    if (!context.mounted) return;
    if (success) {
      await jwtService.logout();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ihr Account wurde gelöscht')),
      );

      /// Leert den Navigationsstapel und öffnet den Login-Screen.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
            'Das Löschen des Accounts fehlgeschlagen. Versuchen Sie es später noch einmal.')),
      );
    }
  }


  /// ---------------- Dialog: Passwort ändern ----------------
  /// Öffnet einen Dialog zum Ändern des Passworts.
  void _openChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final service = ref.read(patientServiceProvider);
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Passwort ändern'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: 'Aktuelles Passwort'),
                  ),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Neues Passwort'),
                  ),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: 'Passwort bestätigen'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final oldPasswordText = oldPasswordController.text.trim();
                    final newPasswordText = newPasswordController.text.trim();
                    final confirmPasswordText = confirmPasswordController.text
                        .trim();

                    if (oldPasswordText.isEmpty || newPasswordText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(
                              'Bitte alle Felder ausfüllen'))
                      );
                      return;
                    }
                    if (confirmPasswordText != newPasswordText) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(
                              'Passwörter stimmen nicht überein'))
                      );
                      return;
                    }
                    var success = await service.changePassword(
                        oldPasswordText, newPasswordText);
                    if (success) {
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(
                            'Passwort wurde erfolgreich geändert')),
                      );
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(
                            'Das Passwort konnte nicht geändert werden. Versuchen Sie es später noch einmal.')),
                      );
                    }
                  },
                  child: const Text('Passwort ändern'),
                ),
              ],
            );
          });
        }).then((_) {
      oldPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    });
  }

  /// Öffnet ein modales BottomSheet zur Anzeige von rechtlichen Texten im Markdown-Format.
  ///
  /// Lädt die entsprechende `.md`-Datei asynchron über [assetPath] und stellt sie
  /// mithilfe von [MarkdownBody] in einer scrollbaren Ansicht ([DraggableScrollableSheet]) dar.
  /// 
  /// [title] bestimmt die Kopfzeile des geöffneten Fensters.
  void _showLegalContent(BuildContext context, String title, String assetPath) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                Expanded(
                  child: FutureBuilder<String>(
                    future: rootBundle.loadString(assetPath),
                    // Lädt die Datei aus den Assets
                    builder: (context, snapshot) {
                      // Während die Datei geladen wird: Ladebalken anzeigen
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Fehler beim Laden der Datei.'),
                        );
                      }

                      return ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          MarkdownBody(data: snapshot.data ?? ''),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}