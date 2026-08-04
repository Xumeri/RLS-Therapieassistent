import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutterapp/screens/login_screen.dart';
import 'package:flutterapp/services/jwt_service.dart';

import '../application/profile_provider.dart';

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
    // build-Methode baut die Benutzeroberfläche
    // ...

    final profileAsyncValue = ref.watch(profileProvider);
    return profileAsyncValue.when(
      loading: () =>
      const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) =>
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('Fehler: $err'),
          ),
      data: (profile) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme
                .of(
              context,
            )
                .colorScheme
                .inversePrimary, // die vorgegebene Farbe wird benutzt
            title: Text(title),
          ),
          body: ListView(
            // Liste für alle Einstellungen
            padding: const EdgeInsets.all(16),
            children: [

              /// ------------------ Profil ----------------------
              Card(
                child: ListTile(
                  // Profil-Icon
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: const Text(
                    'Profil',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // zeigt die vom Backend erhaltenen Patienteninformationen an:
                  subtitle: Text(
                    "Vorname: ${profile.name}\nNachname: ${profile
                        .surname}\nGeburtsdatum: ${profile.birthdate}",
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ---------------- Konto & Sicherheit ----------------
              const Text(
                'Konto & Sicherheit',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Card(
                // Eintrag zum Passwortänderung
                child: ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Passwort ändern'),
                  onTap: () => _openChangePasswordDialog(context),
                ),
              ),

              const SizedBox(height: 20),

              /// ---------------- Rechtliches ----------------
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

              /// ---------------- Abmelden ----------------
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>_logout(context),
                // Beim Klick wird die Logout-Funktion aufgerufen
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
  /// Zeigt einen Bestätigungsdialog an, löscht das JWT-Token und navigiert
  /// zum Login-Screen.
  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      // Dialog zur Bestätigung
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

    await jwtService.logout(); //Meldet den User ab indem AcessToken aus dem Speicher gelöscht wird

    ScaffoldMessenger.of(context).showSnackBar(
      // Kurze Rückmeldung für den Nutzer
      const SnackBar(content: Text('Sie wurden abgemeldet.')),
    );

    Navigator.pushAndRemoveUntil(
      //  öffnet den Login-Screen
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