import 'package:flutter/material.dart';
import 'package:flutterapp/dio_setup.dart';


class TagebuchAuswahlScreen extends StatefulWidget {   //Stellt auf einer Seite mit gegebenem Titel "title" den Fragebogen mit der gegebenen ID "id" dar
  final String title;
  final String id;
  const TagebuchAuswahlScreen({super.key, required this.title, required this.id});

  @override
  State<TagebuchAuswahlScreen> createState() => _TagebuchAuswahlScreenState();
}

class _TagebuchAuswahlScreenState extends State<TagebuchAuswahlScreen> {
  late var id = widget.id;   //holt Titel und ID des Widgets
  late var title = widget.title;
  Map<String, dynamic>? questionnaire; // Speichert Antworten pro Frage
  final Map<String, String> answers = {};  //leere Map in der später Fragebogen-Antworten gespeichert werden
  bool loading = true; //True solange Daten geladen werden
  String? error; //Fehlertext, falls etwas schiefgeht
  Map<String, dynamic>? djangotagebuchresponse; //Speichert die Antwort die vom Backend nach Speichern des Fragebogens zurückkommt
  int score = 0; //Integer für den Score (wird bei speichern von Questionnairetagebuchresponse von Django übergeben)
  String interpretation = " "; //String für den Fragebogen Score Interpretation (wird bei speichern von QuestionnaireResponse von Django übergeben)
  int maxscore = 0; //Integer für dem maximalen Score der erzielt werden kann
  final privateController = TextEditingController(); //Erstellt einen Controller um Eingaben im privaten Tagebuchfeld zu speichern
  final publicController = TextEditingController(); //Erstellt einen Controller um Eingaben im öffentlichen (also für den Arzt sichbaren) Textfeld zu speichern


  @override
  void initState() {
    super.initState();
    loadQuestionnaire();  //Beim Start Fragebogen laden
  }

  //---------------Fragebogen vom Django Server laden--------------------------------------------------
  Future<void> loadQuestionnaire() async {
    try {
      final resp = await dio.get("/rls/questionnaire/$id");

      if (resp.statusCode == 200) {
        //JSON erfolgreich erhalten → speichern
        setState(() {
          questionnaire = resp.data;
          loading = false;
          maxscore = questionnaire?["item"][0]["extension"][0]["valueInteger"]; //Speichet maximal erreichbaren Score in Variable Maxscore
        });
      } else {
        setState(() {
          error = 'Fehler: ${resp.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Fehler: $e';
        loading = false;
      });
    }
  }

  //------------------------------Antworten an Django senden-----------------------------------------------
  Future<void> sendtagebuchresponse() async {
    final date = DateTime.now(); //Variable die Zeit speichert zu der der Fragebogen abgesendet wurde
    if (questionnaire == null) return;

    //Antworten im Backend-kompatiblen Format aufbauen
    final items = answers.entries.map((entry) {
      return {
        "linkId": entry.key, //ID der Frage
        "answer": [
          {"valueString": entry.value} //Gewählte Antwort
        ]
      };
    }).toList();

    // sortiert die Antworten Liste nach den LinkIDs (sodass die Antworten trotzdem in der richtigen Reihenfolge gespeichert werden auch wenn die Fragen nicht nach Reihenfolge beantwortet wurden)
    items.sort((a, b) {
      final aNum = int.tryParse(a['linkId'].toString().substring(2)) ?? 0; // nimmt die LinkID eines Eintrags ab der 2ten Stelle und konvertiert sie zu einem integer (also von 1.1 wird nur 1 betrachtet, von 1.10 nur 10)
      final bNum = int.tryParse(b['linkId'].toString().substring(2)) ?? 0; // nimmt die LinkID eines anderen Eintrags und macht daraus auch einen integer
      return aNum.compareTo(bNum); // sortiert nach diesem Schema die Einträge in der Liste items so, dass die Einträge nach aufsteigender Reihenfolge der LinkIds geordnet sind
    });

    // Variablen für die öffentlichen / privaten Tagebucheinträge die "null" sind wenn die Tagebuchfelder leer sind (damit FHIR trotzdem einen String bekommt)
    String publicdiaryentry = "null";
    String privatediaryentry = "null";

    if (publicController.text.isNotEmpty){
          publicdiaryentry = publicController.text.trim();
    }

    if (privateController.text.isNotEmpty){
          privatediaryentry = privateController.text.trim();
    }

    //erstellt eine JSON im FHIR Questionnairetagebuchresponse Format, mit den eingegebenen Antworten und Score=null (wir später im Backend berechnet)
    final body = {
      "resourceType": "Questionnaireresponse", //FHIR-Format
      "id" : "r${questionnaire!["id"]}${date.year}${date.month}${date.day}${date.hour}${date.minute}${date.second}",
      "questionnaire": id, //schickt bei "questionnaire" die ID des Fragebogens (nocht nicht FHIR konform, FHIR möchte hier eine canonical URL, aber wird im Backend dann angepasst)     
      "status": "completed",
      "authored" : "${date.toLocal().toIso8601String()}+0${date.timeZoneOffset.toString().substring(0,4)}", //speichert Datum im YYYY-MM-DDThh:mm:ss.sss+zz:zz Format, wie von FHIR vorgegeben
      "item": [
        {
          "linkId": "0.1",       //Platzhalter für Score (wird vom Backend eingefügt)
          "valueInteger": null
        },
                {
          "linkId": "0.2",       //Platzhalter für Score Interpretation (wird vom Backend eingefügt)
          "valueString": "null"
        },
        {
          "linkId": "1",   //speichert Liste der Antworten unter linkID 1
          "item": items
        },
        {
          "linkId": "2",
          "item" : [{
            "linkId" : "2.1",       //speichert öffentliche Tagebucheinträge unter linkID 2.1
            "text" : publicdiaryentry,
          },
          {
            "linkId" : "2.2",    //speichert private Tagebucheinträge unter linkID 2.2
            "text" : privatediaryentry,
          }]
        }
      ]
    };

    try {
      final resp = await dio.post("/rls/response/",   //verwendet dio das in dio_setup erstellt wurde
        data: body,
      );

      if (resp.statusCode == 200) {
          //wenn Fragebogen erfolgreich gesendet und eine Antwort vom Backend erhalten wurde
          djangotagebuchresponse = resp.data;
          score = djangotagebuchresponse?["score"];   //Score aus der Antwort wird in Variable score gepeichert
          interpretation = djangotagebuchresponse?["interpretation"]; //Interpretation aus der Antwort wird in Variable interpretation gespeichert

      }

      debugPrint("Antwort vom Server:");
      debugPrint(resp.data);//Ausgabe in der Debug-Konsole
    } catch (e) {
      print('Fehler beim Speicher der Fragebogen-Antwort: $e');
    }

  }



  //-------------------Pop-Up Fenster das den Score anzeigt----------------------------------------------
  Future<void> showMyDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Benutzer muss den Knopf drücken um weiter zu kommen
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Antworten gespeichert!', textAlign: TextAlign.center,),  //Titel des Pop-up Fensters
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Ihr Score ist $score/$maxscore!', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,), //Text des Pop-up Fensters
              Text(' -> $interpretation', textAlign: TextAlign.center,),
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


  // ------------------------------- Build Methode ------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(child: Text(error!)),
      );
    }

    // Fragen aus dem Fragebogen holen
    final items = (questionnaire?['item'] as List?)?[2]?['item'] as List? ?? [];

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
                await sendtagebuchresponse();  //Button wartet bis sendtagebuchresponse (Funktion die Antworten zum Django Backend sendet) abgeschlossen ist
                showMyDialog(); //wenn sendtagebuchresponse fertig ist (=wenn Score unter int score gespeichert ist), wird Pop Up angezeigt 
            },
            child: const Text("Antworten senden"),
          ),
        ],
      ),
    );
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
          for (final opt in options)
            RadioListTile<String>(
              title: Text(opt.substring(1)),  //Zeigt die erste Stelle der AntwortOptionen (=den Score-Wert) nicht mit an
              value: opt,
              groupValue: answers[linkId],
              onChanged: (value) {
                setState(() {
                  answers[linkId] = value!;
                });
              },
            ),
          const SizedBox(height: 12),
        ],
    );
  }
}