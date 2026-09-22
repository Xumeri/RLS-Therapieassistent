import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A screen that provides educational information about RLS and links to external resources.
///
/// Features information sections and a button to visit the official RLS website.
class InfosScreen extends StatelessWidget {
  /// The URI for the official RLS website.
  static final Uri rlsUrl = Uri.parse('https://www.restless-legs.org');

  const InfosScreen({super.key});

  /// Asynchronously opens the RLS website in an external browser.
  Future<void> openRlsWebsite() async {
    if (!await launchUrl(rlsUrl, mode: LaunchMode.externalApplication)) {
      throw Exception('Konnte die Website nicht öffnen.');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(             // Obere App-Leiste mit Titel
        title: const Text('Informationen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,           // Farbe passend zum Theme der App
      ),
      body: SingleChildScrollView(      // Scrollbare Seite 
        padding: const EdgeInsets.all(16),

        // Alles wird vertikal untereinander dargestellt
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(        //Oberer Info-Container mit Link zur Webseite 
              width: double.infinity, 
              padding: const EdgeInsets.all(16), 
              decoration: BoxDecoration(    
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.inversePrimary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16), 
              ),

              child: Column(                  // Inhalt innerhalb des Containers
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Offizielle RLS Website',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),                   // Abstand zwischen Titel und Beschreibung

                  const Text(                                 // Beschreibungstext
                    'Besuchen Sie die offizielle Website der Deutschen '
                    'Restless Legs Vereinigung für weitere Informationen, '
                    'aktuelle Forschung und Patientennetzwerke.',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(                       // Button öffnet die Website
                    onPressed: openRlsWebsite,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Website besuchen',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const _InfoSection(                 //Info-Abschnitte 
              title: 'Was ist RLS?',
              body:
                  'Das Restless-Legs-Syndrom (RLS) ist eine neurologische '
                  'Erkrankung, die durch einen starken Bewegungsdrang in den '
                  'Beinen gekennzeichnet ist. Dieser tritt typischerweise in '
                  'Ruhe auf und wird von unangenehmen Missempfindungen wie '
                  'Kribbeln, Ziehen oder Stechen begleitet. Die Beschwerden '
                  'bessern sich meist durch Bewegung.',
            ),

            const _InfoSection(
              title: 'Ursachen und Formen',
              body:
                  'Man unterscheidet zwischen primärem (idiopathischem) und '
                  'sekundärem RLS. Das primäre RLS hat oft eine genetische '
                  'Komponente. Sekundäres RLS kann z.B. durch Eisenmangel, Schwangerschaft, Nierenerkrankungen oder bestimmte '
                  'Medikamente ausgelöst werden.\n\n',
            ),

            const _InfoSection(
              title: 'Symptome erkennen',
              body:
                  'Typische Symptome sind: Bewegungsdrang in den Beinen, unangenehme Missempfindungen,'
                  'Verschlechterung in Ruhe und am Abend, Besserung durch Bewegung.'
                  'Viele Betroffene leiden unter Schlafstörungen und sind tagsüber müde.',
            ),

            const _InfoSection(
              title: 'Diagnose',
              body:
                  'Die Diagnose wird hauptsächlich anhand der Symptome gestellt.'
                  'Ihr Arzt wird Sie ausführlich befragen und eine körperliche Untersuchung durchführen.'
                  'Blutuntersuchungen (vor allem Eisenwerte) und manchmal auch eine Schlaflabor-Untersuchung können hilfreich sein.',
            ),

            const _InfoSection(
              title: 'Behandlungsmöglichkeiten',
              body:
                  'Die Behandlung umfasst nicht-medikamentöse Maßnahmen (Bewegung, Schlafhygiene, Vermeidung von Triggern)'
                  'und bei Bedarf Medikamente. Häufig eingesetzte Medikamente sind Dopamin-Agonisten, Alpha-2-Delta-Liganden'
                  'oder Opioide. Die Wahl hängt von der Schwere Ihrer Beschwerden ab.',
            ),

            const _InfoSection(
              title: 'Lebensstil und Selbsthilfe',
              body:
                  'Regelmäßige, moderate Bewegung kann helfen. Vermeiden Sie Koffein, Alkohol und Nikotin,'
                  'besonders am Abend. Etablieren Sie feste Schlafzeiten. Wechselduschen, Massagen oder'
                  'das Hochlagern der Beine können Linderung verschaffen. Führen Sie ein Symptom-Tagebuch.',
            ),

            const _InfoSection(
              title: 'Ernährung bei RLS',
              body:
                  'Achten Sie auf eine ausgewogene, eisenreiche Ernährung (rotes Fleisch, Hülsenfrüchte, grünes Blattgemüse).'
                  'Vitamin C verbessert die Eisenaufnahme. Bei nachgewiesenem Eisenmangel kann eine Supplementierung sinnvoll'
                  'sein - sprechen Sie mit Ihrem Arzt.',
            ),

            const _InfoSection(
              title: 'Umgang mit der Erkrankung',
              body:
                  'RLS ist eine chronische Erkrankung, die aber gut behandelbar ist. Informieren Sie Ihr Umfeld über'
                  'Ihre Erkrankung. Suchen Sie sich gegebenenfalls Unterstützung in Selbsthilfegruppen.'
                  'Mit der richtigen Behandlung können die meisten Betroffenen eine gute Lebensqualität erreichen.',
            ),
          ],
        ),
      ),
    );
  }
}
class _InfoSection extends StatelessWidget {
  final String title; 
  final String body;  

  const _InfoSection({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),         //  gleichmäßige Abstände unter jeder Card 
      child: Card(
        elevation: 0, 
        margin: EdgeInsets.zero, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titel
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),                  /// Abstand zwischen Titel und Text
              Text(                 /// eigentlicher Fließtext
                body,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
