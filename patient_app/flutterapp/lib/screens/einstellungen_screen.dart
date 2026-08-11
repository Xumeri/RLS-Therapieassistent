import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                  onTap: () => _openChangePasswordDialog(context),
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
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Datenschutzerklärung'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 0),
                    ListTile(
                      title: const Text('Nutzungsbedingungen'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 0),
                    ListTile(
                      title: const Text('Impressum'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ],
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
      builder: (context) => AlertDialog(
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


  /// ---------------- Dialog: Passwort ändern ----------------
  /// Öffnet einen Dialog zum Ändern des Passworts.
  void _openChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Passwort ändern'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Aktuelles Passwort'),
                ),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Neues Passwort'),
                ),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Passwort bestätigen'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Passwort ändern'),
              ),
            ],
          ),
    );
  }
}