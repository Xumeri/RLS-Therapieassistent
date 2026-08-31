import 'package:flutter/material.dart';
import 'package:flutterapp/dio_setup.dart';
import 'package:flutterapp/screens/kalender_fresponse_screen.dart';
import 'package:flutterapp/screens/kalender_tresponse_screen.dart';

class KalenderAuswahlScreen extends StatefulWidget {  //wird angezeigt wenn auf dem Kalender ein Tag ausgewählt wird
  final String date;   //erhält dafür das Datum des ausgewählten Tages (als String)
  KalenderAuswahlScreen({super.key, required this.date});

  @override
  State<KalenderAuswahlScreen> createState() => _KalenderAuswahlScreenState();
}

class _KalenderAuswahlScreenState extends State<KalenderAuswahlScreen> {
  String title() => "Kalender Tag ${widget.date.substring(0,10)} ausgewählt";
  List fragebogen_items = [];  
  List tagebuch_items = [];  

  String questionnairetitle = "Titel";
  bool isLoading = true;
  bool fragebogenGeladen = false;
  bool tagebuchGeladen = false;

  
  @override
  void initState() {
    super.initState();
    getResponses();
  }


  // ----------------- holt Fragebogen und Tagebuch Antworten vom Backend ----------------------------------------------------------
  getResponses() async {
    final fResponse = await dio.get("/rls/getresponse/${widget.date.substring(0,10)}");
    if (fResponse.statusCode == 200) {
      setState(() {
        fragebogen_items = fResponse.data;
        fragebogenGeladen = true;
      });
    } else {
      print('Fehler beim Laden der Fragebogen Responses');
    }

    final tResponse = await dio.get("/rls/gettagebuchresponse/${widget.date.substring(0,10)}");
    if (tResponse.statusCode == 200) {
      setState(() {
        tagebuch_items = tResponse.data;
        tagebuchGeladen = true;
      });
    } else {
      print('Fehler beim Laden der Tagebuch Responses');
    }

    if (fragebogenGeladen && tagebuchGeladen) {
      isLoading = false;  // wenn sowohl Fragebogen als auch TagebuchAntworten erfolgreich geladen wurden, wird isLoading auf false gesetzt
    }
  }

  // ------------- Build Methode --------------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (isLoading) {   // Zeigt Ladebildschirm solange Seite läd
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title()),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(  // Zeigt Liste mit Fragebogen- und Tagebuch-Antworten
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title()),
      ),
      body: ListView(
        children: [
            SizedBox(height:10),
            Center(child: Text("Fragebögen:", style: TextStyle(fontSize: 30),)),
            buildfresponselist(fragebogen_items),
            SizedBox(height:10),
            Divider(),
            SizedBox(height:10),
            Center(child: Text("Tagebucheinträge:", style: TextStyle(fontSize: 30),)),
            buildtresponselist(tagebuch_items),
          ],
      )
    );
  }
}


// ------------------------ baut eine Liste aller Fragebogen-Antworten ---------------------------------------------------------
Widget buildfresponselist(List fragebogenItems){
  if (fragebogenItems.isEmpty) {
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
      itemCount: fragebogenItems.length,
      itemBuilder: (context, index) { 
        return GestureDetector( onTap: () { 
          Navigator.push(context, MaterialPageRoute(builder: (context) { //Weiterleiten auf KalenderfResponseScreen, mit Zurückknopf 
          return KalenderfResponseScreen(responsejson: fragebogenItems[index],
          ); 
        })); 
      }, 
      child: Card( 
        child: ListTile( 
          title: Text(fragebogenItems[index]["questionnairetitle"]),
          subtitle: Text("Score: ${fragebogenItems[index]["score"]} / ${fragebogenItems[index]["maxscore"]}"),
        ), 
      ), 
      ); 
      }, 
      ); 
    }
  }


  // ------------------ baut eine Liste aller Tagebuch-Antworten --------------------------------------------------------------------
Widget buildtresponselist(List tagebuchItems){
if (tagebuchItems.isEmpty) {
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
    itemCount: tagebuchItems.length,
    itemBuilder: (context, index) {
      return GestureDetector( onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) { //Weiterleiten auf KalendertresponseScreen, mit Zurückknopf
        return KalendertResponseScreen(responsejson: tagebuchItems[index],);
      }));
    },
    child: Card(    // auf jeder Tagebuch-Antwort Karte wird die Kategorie als farbiger CircleAvatar mit Icon angzeigt
      child: ListTile(
        leading: getCircleAvatar(tagebuchItems[index]["questionnaireid"]),
        title: Text(tagebuchItems[index]["questionnairetitle"]),
        subtitle: Text("Score: ${tagebuchItems[index]["score"]} / ${tagebuchItems[index]["maxscore"]}"),
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
  } else {    //avatar der zurückgegeben wird falls die ID zu keinem von den Tagebuchkategorie-Fragebögen passt.
    return CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.error),
    );
  }
}