import 'package:flutter/material.dart';

/// A screen that displays frequently asked questions about RLS and the application.
///
/// Uses an [ExpansionTile] to present questions and their respective answers.
class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  /// A list of FAQ items, where each item is a map with 'question' and 'answer' keys.
  final List<Map<String, String>> faqs = const [
     {
      "question": "Was ist RLS (Restless-Legs-Syndrom)?",
      "answer": "Das Restless-Legs-Syndrom ist eine neurologische Erkrankung, "
          "die durch einen unangenehmen Bewegungsdrang in den Beinen gekennzeichnet ist. "
          "Meist wird dieser von unangenehmen Missempfindungen begleitet. "
          "Die Beschwerden treten typischerweise in Ruhe auf und bessern sich durch Bewegung.,"


    },
    {
      "question": "Wann treten die Beschwerden am häufigsten auf?",
      "answer": "Die Symptome treten meistens abends und nachts auf, "
          "besonders in Ruhe oder beim Liegen. "
          "Viele Betroffene haben daher Schlafstörungen. "
          "Die Beschwerden können jedoch auch tagsüber auftreten, zum Beispiel bei längerem Sitzen."
    },
    {
      "question": "Was kann ich selbst gegen RLS tun?",
      "answer": "Regelmäßige Bewegung, der Verzicht auf Alkohol und Koffein am Abend, "
          "feste Schlafzeiten und Entspannungstechniken können helfen. "
          "Auch Wechselduschen oder Massagen der Beine werden von vielen Betroffenen als hilfreich empfunden."
    },
    { "question": "Wie werden die Medikamente richtig eingenommen?",
      "answer": "Nehmen Sie Ihre Medikamente genau nach ärztlicher Verordnung ein. "
          "Die meisten RLS-Medikamente werden am Abend eingenommen, "
          "etwa 1–2 Stunden vor dem Schlafengehen. "
          "Ändern Sie niemals selbstständig die Dosis. Nutzen Sie die Erinnerungsfunktion dieser App, "
          "um die Einnahme nicht zu vergessen."
    },
    {
      "question": "Wie oft sollte ich das Tagebuch ausfüllen?",
      "answer": "Am besten füllen Sie das Tagebuch täglich aus, "
          "möglichst zur gleichen Tageszeit."
          " So können Sie und Ihr Arzt den Verlauf Ihrer Erkrankung besser nachvollziehen und die Behandlung optimal anpassen."
    },
    {
      "question": "Was sind die IRLSS-Fragebögen?",
      "answer": "Der Internationale RLS Severity Scale (IRLSS) ist ein standardisierter Fragebogen zur Bewertung des Schweregrads von RLS. "
          "Er hilft Ihrem Arzt, die Wirksamkeit der Behandlung zu beurteilen. "
          "Füllen Sie ihn am besten wöchentlich oder nach ärztlicher Empfehlung aus."
    },
    {
      "question": "Wann sollte ich meinen Arzt kontaktieren?",
      "answer": "kontaktieren Sie Ihren Arzt, "
          "wenn sich Ihre Symptome deutlich verschlechtern, "
          "die Medikamente nicht mehr wirken, starke Nebenwirkungen auftreten oder Sie neue Beschwerden bemerken. Nutzen Sie die Erinnerungsfunktion dieser App für Ihre Kontrolltermine."
    },
    {
      "question": "Ist RLS heilbar?",
      "answer": "Das primäre RLS ist nicht heilbar, aber sehr gut behandelbar. "
          "Mit der richtigen Therapie können die meisten Betroffenen eine deutliche Verbesserung ihrer Lebensqualität erreichen. "
          "Das sekundäre RLS kann manchmal durch die Behandlung der Grunderkrankung verbessert werden."
    },
    {
      "question": "Kann ich trotz RLS Sport treiben?",
      "answer": "Ja, regelmäßige moderate Bewegung wird sogar empfohlen. "
          "Sport kann die Symptome lindern. "
          "Vermeiden Sie jedoch intensive Trainingseinheiten kurz vor dem Schlafengehen, "
          "da dies die Beschwerden verstärken kann."
    },
    {
      "question": "Wie funktioniert die Auswertung in der App",
      "answer": "Die App analysiert Ihre Tagebucheinträge und stellt sie grafisch dar. "
          "So können Sie Muster und Zusammenhänge erkennen, "
          "zum Beispiel zwischen Schlafqualität, Ernährung und Ihren RLS-Symptomen. "
          "Diese Informationen sind auch für Ihren Arzt wertvoll."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Häufig gestellte Fragen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: faqs.map((faq) {
          return ExpansionTile(
            title: Text(faq['question']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(faq['answer']!),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
