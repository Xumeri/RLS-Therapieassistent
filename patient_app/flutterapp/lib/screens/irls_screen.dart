import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/application/questionnaire_provider.dart';

import '../domain/questionnaire_result.dart';

/// Ein Screen zur Anzeige und Beantwortung von IRLS-Fragebögen.
///
/// Dieser Screen lädt die Fragebogendefinition dynamisch anhand einer ID
/// und ermöglicht es dem Benutzer, Antworten auszuwählen und abzusenden.
class IRLSScreen  extends ConsumerStatefulWidget{

  final String id;
  final String title;

  const IRLSScreen({
    super.key,
    required this.id,
    required this.title
});
  @override
  ConsumerState<IRLSScreen> createState()  => _IRLSScreenState();
}

class _IRLSScreenState extends ConsumerState<IRLSScreen>{
  final Map<String, String> _answers = {};
  QuestionnaireResult? _result;

  @override
  Widget build(BuildContext context) {
    final questionnaireAsync = ref.watch(
        questionnaireDefinitionProvider(widget.id));
    return questionnaireAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Fehler: $err')),
      ),
      data: (questionnaire) => _buildcontent(questionnaire),
    );
  }

  /// Baut den Inhalt des Fragebogens auf, wenn die Daten erfolgreich geladen wurden.
  Widget _buildcontent(Map<String, dynamic> questionnaire){

    final items = (questionnaire['item'] as List?)?[2]?['item'] as List? ?? [];
    final maxScore = questionnaire["item"][0]["extension"][0]["valueInteger"] as int? ?? 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final item in items)
            _buildQuestionItem(item),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (antwortenVollstaendig(items) == false) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sie haben einige Fragen nicht beantwortet.\nBitte füllen Sie den Fragebogen vollständig aus.')),
                );
              }
              else {
                try{
                  await _sendResponse(questionnaire);
                  if (!mounted) return;
                  showMyDialog(maxScore);
                }catch(e){
                  if(!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fehler beim Speichern:  $e')),
                  );
                }
              }
            },
            child: const Text("Antworten senden"),
          ),
        ],
      ),
    );
  }

  /// Sendet die Antworten an den Backend-Service.
  Future<void> _sendResponse(Map<String, dynamic> questionnaire) async {
    final service = ref.read(questionnaireServiceProvider);
    final result = await service.submitResponse(
      id: widget.id,
      questionnaire: questionnaire,
      answers: _answers,
    );
    setState(() => _result = result);
  }

  /// Erstellt das UI für eine einzelne Frage.
  Widget _buildQuestionItem(Map<String, dynamic> item){
    final linkId = item["linkId"];
    final text = item["text"];

    final options = (item["answerOption"] as List)
        .map((opt) => opt["valueString"] as String)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          RadioGroup<String>(
            groupValue: _answers[linkId],
            onChanged: (value) {
              if (value != null) {
                setState(() => _answers[linkId] = value);
              }
            },
            child: Column(
              children: options.map((opt) => RadioListTile<String>(
                value: opt,
                title: Text(opt.substring(1)),
              )).toList(),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Überprüft, ob alle Fragen im Fragebogen beantwortet wurden.
  bool antwortenVollstaendig(List<dynamic> items) {
    for (final item in items) {
      final linkId = item["linkId"];
      if (!_answers.containsKey(linkId)) {
        return false;
      }
    }
    return true;
  }

  /// Zeigt einen Dialog mit dem Ergebnis des Fragebogens an.
  Future<void> showMyDialog(int maxScore) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Antworten gespeichert!', textAlign: TextAlign.center,),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Ihr Score ist ${_result?.score}/$maxScore!'),
                Text(' -> ${_result?.interpretation}'),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();

              },
            ),
          ],
        );
      },
    );
  }
}