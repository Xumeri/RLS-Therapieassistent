import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/application/calendar_provider.dart';
import 'package:flutterapp/screens/kalender_fresponse_screen.dart';
import 'package:flutterapp/screens/kalender_tresponse_screen.dart';

/*
COMMIT_MESSAGE:
  feat: KalenderAuswahlScreen auf Riverpod umgestellt

Neue Dateien:
- domain/kalender_tag.dart: KalenderTag-Modell
- data/calendar_repository.dart: fetchData() mit Future.wait –
  Fragebogen- und Tagebuchdaten werden parallel geladen
- application/calendar_provider.dart: FutureProvider.family
  mit Datum (String) als Parameter, Rückgabe als Tuple

Geänderte Dateien:
- screens/kalender_auswahl_screen.dart:
  ConsumerStatefulWidget → ConsumerWidget,
  getResponses() + isLoading-Bug durch .when() ersetzt,
  buildfresponselist/buildtresponselist/getCircleAvatar
  in die Klasse verschoben,
  Tuple wird direkt in data-Zweig aufgelöst
 */

class KalenderAuswahlScreen extends ConsumerWidget {  //wird angezeigt wenn auf dem Kalender ein Tag ausgewählt wird

  final String date;   //erhält dafür das Datum des ausgewählten Tages (als String)

const KalenderAuswahlScreen({
    super.key,
    required this.date
});

  String get title => "Kalender Tag ${date.substring(0,10)} ausgewählt";

  // ------------- Build Methode --------------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentdate = date.substring(0,10);
    final calendarAsync = ref.watch(calendarProvider(currentdate));
    return calendarAsync.when(
        loading: () =>
        const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) =>
            Scaffold(
              body: Center(child: Text('Fehler: $err')),
            ),
        data: (tuple) {
          return RefreshIndicator(
            onRefresh: () async{
              ref.invalidate(calendarProvider(currentdate));
            },
              child: _buildContent(context,  tuple.$1, tuple.$2),
          );
        }
    );
  }

  Widget _buildContent(BuildContext context, List<dynamic> questionItems, List<dynamic> diaryItems){

    return Scaffold(  // Zeigt Liste mit Fragebogen- und Tagebuch-Antworten
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ListView(
        children: [
            SizedBox(height:10),
            Center(child: Text("Fragebögen:", style: TextStyle(fontSize: 30),)),
            buildfresponselist(questionItems),
            SizedBox(height:10),
            Divider(),
            SizedBox(height:10),
            Center(child: Text("Tagebucheinträge:", style: TextStyle(fontSize: 30),)),
            buildtresponselist(diaryItems),
          ],
      )
    );
  }

  // ------------------------ baut eine Liste aller Fragebogen-Antworten ---------------------------------------------------------
  Widget buildfresponselist(List questionItems){
    if (questionItems.isEmpty) {
      return Column(
        children: [
          SizedBox(height: 10,),
          Center(child: Text("An diesem Tag haben Sie keine Fragebögen ausgefüllt", style: TextStyle(fontSize: 20),)), // wird angezeigt wenn keine Fragebogen-Antworten vorliegen
        ],
      );
    }
    else {
      return ListView.builder(
        shrinkWrap: true, // stellt sicher dass ListView nur den Platz einnimmt den sie braucht -> macht es möglich Listview zusammen mit anderen Widgets in eine Column zu tun
        itemCount: questionItems.length,
        itemBuilder: (context, index) {
          return GestureDetector( onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) { //Weiterleiten auf KalenderfResponseScreen, mit Zurückknopf
            return KalenderfResponseScreen(responsejson: questionItems[index],
            );
          }));
        },
        child: Card(
          child: ListTile(
            title: Text(questionItems[index]["questionnairetitle"]),
            subtitle: Text("Score: ${questionItems[index]["score"]} / ${questionItems[index]["maxscore"]}"),
          ),
        ),
        );
        },
        );
      }
    }

    // ------------------ baut eine Liste aller Tagebuch-Antworten --------------------------------------------------------------------
  Widget buildtresponselist(List diaryItems){
  if (diaryItems.isEmpty) {
    return Column(
      children: [
        SizedBox(height: 10,),
        Center(child: Text("An diesem Tag haben Sie keine Tagebucheinträge gemacht", style: TextStyle(fontSize: 20),)),  // Wird angezeigt wenn keine Fragebogen Antworten vorliegen
      ],
    );
  }
  else {
    return ListView.builder(
      shrinkWrap: true, // stellt sicher dass ListView nur den Platz einnimmt den sie braucht -> macht es möglich Listview zusammen mit anderen Widgets in eine Column zu tun
      itemCount: diaryItems.length,
      itemBuilder: (context, index) {
        return GestureDetector( onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) { //Weiterleiten auf KalendertresponseScreen, mit Zurückknopf
          return KalendertResponseScreen(responsejson: diaryItems[index],);
        }));
      },
      child: Card(    // auf jeder Tagebuch-Antwort Karte wird die Kategorie als farbiger CircleAvatar mit Icon angzeigt
        child: ListTile(
          leading: getCircleAvatar(diaryItems[index]["questionnaireid"]),
          title: Text(diaryItems[index]["questionnairetitle"]),
          subtitle: Text("Score: ${diaryItems[index]["score"]} / ${diaryItems[index]["maxscore"]}"),
        ),
      ),
      );
      },
      );
    }
  }

  // ---------------------- erstellt für jede Kategorie den richtigen CircleAvatar -----------------------------------------------------------
  CircleAvatar getCircleAvatar(id) {
    if (id == "tschlaf") {
      return CircleAvatar(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.nights_stay_rounded),
      );
    }
    if (id == "tsport") {
      return CircleAvatar(
        backgroundColor: Colors.orange,
        child: Icon(Icons.directions_run),
      );
    }
    if (id == "ternaehrung") {
      return CircleAvatar(
        backgroundColor: Colors.yellow,
        child: Icon(Icons.restaurant),
      );
    }
    if (id == "twohlbefinden") {
      return CircleAvatar(
        backgroundColor: Colors.pinkAccent,
        child: Icon(Icons.favorite_outline_sharp),
      );
    } else { //avatar der zurückgegeben wird falls die ID zu keinem von den Tagebuchkategorie-Fragebögen passt.
      return CircleAvatar(
        backgroundColor: Colors.black,
        child: Icon(Icons.error),
      );
    }
  }
}