import 'package:flutter/material.dart';

import '../resources/faq_texts.dart';

/// A screen that displays frequently asked questions about RLS and the application.
///
/// Uses an [ExpansionTile] to present questions and their respective answers.
class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Häufig gestellte Fragen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: FaqTexts.faqs.map((faq) {
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
