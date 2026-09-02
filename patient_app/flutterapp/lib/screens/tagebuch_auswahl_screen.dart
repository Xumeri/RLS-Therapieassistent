import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/application/questionnaire_provider.dart';
import 'package:flutterapp/domain/questionnaire_result.dart';


class TagebuchAuswahlScreen extends ConsumerStatefulWidget {   //Stellt auf einer Seite mit gegebenem Titel "title" den Fragebogen mit der gegebenen ID "id" dar
  final String title;
  final String id;

  const TagebuchAuswahlScreen({
    super.key,
    required this.title,
    required this.id
  });

  @override
  ConsumerState<TagebuchAuswahlScreen> createState() => _TagebuchAuswahlScreenState();
}

class _TagebuchAuswahlScreenState extends ConsumerState<TagebuchAuswahlScreen> {
  late var id = widget.id;   //holt Titel und ID des Widgets
  late var title = widget.title;
  final Map<String, String> _answers = {};
  QuestionnaireResult? _result;

  final privateController = TextEditingController(); //Erstellt einen Controller um Eingaben im privaten Tagebuchfeld zu speichern
  final publicController = TextEditingController(); //Erstellt einen Controller um Eingaben im öffentlichen (also für den Arzt sichbaren) Textfeld zu speichern


  @override
  void dispose(){
    privateController.dispose();
    publicController.dispose();
    super.dispose();
  }


  //-------------------Pop-Up Fenster das den Score anzeigt----------------------------------------------
  Future<void> showMyDialog(int maxScore) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Benutzer muss den Knopf drücken um weiter zu kommen
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Antworten gespeichert!', textAlign: TextAlign.center,),  //Titel des Pop-up Fensters
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Ihr Score ist ${_result?.score}/$maxScore!', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,), //Text des Pop-up Fensters
              Text(' -> ${_result?.interpretation}', textAlign: TextAlign.center,),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center, //"Okay" Button steht mittig vom Pop-up
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop();  //schließt Pop-up (navigiert zurück zum RLSQOLScreen)
              Navigator.of(context).pop();  //navigiert zurück zum FragebogenScreen

            },
          ),
        ],
      );
      },
    );
  }

  Future<void> _sendResponse(Map<String, dynamic> questionnaire) async {
    try {
      final service = ref.read(questionnaireServiceProvider);
      final result = await service.submitResponse(
        id: widget.id,
        questionnaire: questionnaire,
        answers: _answers,
        publicEntry: publicController.text.trim(),
        privateEntry: privateController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern: $e')),
      );
    }
  }


  // ------------------------------- Build Methode ------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final questionnaireAsync = ref.watch(questionnaireDefinitionProvider(widget.id));
    return questionnaireAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      data: (questionnaire) => _buildcontent(questionnaire),
    );
  }

    // Fragen aus dem Fragebogen holen
  Widget  _buildcontent(Map<String, dynamic> questionnaire) {
    final maxScore = questionnaire["item"][0]["extension"][0]["valueInteger"] as int? ?? 0;
    final items = (questionnaire['item'] as List?)?[2]?['item'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //Jede Frage anzeigen
          for (final item in items)
            _buildQuestionItem(item),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Öffentliche Tagebucheinträge", style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height:5),
                TextField(    //Eingabefeld für öffentliche Einträge
                    controller: publicController,   //Eingaben werden über den publicController überwacht
                    minLines: 4,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: 'Auf Einträge in diesem Feld kann Ihr Arzt auch zugreifen',  //HintText; steht anfangs auf dem Textfeld und geht weg sobald man das Feld anklickt
                      border: OutlineInputBorder(),
                    ),
                ),
              ]
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Private Tagebucheinträge", style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height:3),
                TextField(    //Eingabefeld für private Einträge
                    controller: privateController,   //Eingaben werden über den privateController überwacht
                    minLines: 4,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: 'Auf Einträge in diesem Feld können nur Sie zugreifen', //HintText; steht anfangs auf dem Textfeld und geht weg sobald man das Feld anklickt
                      border: OutlineInputBorder(),
                    ),
                ),
              ]
            ),
          ),
          SizedBox(height:40),
          // Button zum Absenden der Antworten
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

  bool antwortenVollstaendig(List<dynamic> items) {
    for (final item in items) {
      final linkId = item["linkId"];
      if (!_answers.containsKey(linkId)) {
        return false;
      }
    }
    return true;
  }

  // ------------------------ Methode die Eingabefeld für die Choice-Fragen baut --------------------------------------------
  Widget _buildQuestionItem(Map<String, dynamic> item) {
    final linkId = item["linkId"];
    final text = item["text"];

    final options = (item["answerOption"] as List)
          .map((opt) => opt["valueString"] as String)
          .toList();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)), //Frage anzeigen
          //Für jede Option einen Button erstellen
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
}