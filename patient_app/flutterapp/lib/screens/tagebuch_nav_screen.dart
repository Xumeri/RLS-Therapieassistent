import 'package:flutter/material.dart';
import 'package:flutterapp/screens/tagebuch_auswahl_screen.dart';

/// A navigation screen for selecting different diary categories.
///
/// Provides access to sleep, nutrition, activity, and well-being diaries.
class TagebuchScreen extends StatelessWidget {
  /// The title of the screen.
  final String title = "Tagebuch";

  const TagebuchScreen({super.key});

  // ------------------------------ Build Methode (für ListView mit mehreren Cards) ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: <Widget>[
            Card(     //Karte zum Weiterleiten auf die Schlaf-Fragen; übergibt dafür dem TagebuchAuswahlScreen den Titel des es haben soll + die ID des Schlaf-Fragebogens auf dem FHIR Server
              child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.nights_stay_rounded),
                        ),
                        title: Text("Schlaf"),
                        subtitle: Text("Am besten morgens ausfüllen"),
                        onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return TagebuchAuswahlScreen(id :"tschlaf", title: "Schlaf");
                        }));
                      }
              )
            ),
            Card(     //Karte zum Weiterleiten auf die Ernährungs-Fragen; übergibt dafür dem TagebuchAuswahlScreen den Titel des es haben soll + die ID des Ernährungs-Fragebogens auf dem FHIR Server
              child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.yellow,
                          child: Icon(Icons.restaurant),
                        ),
                        title: Text("Ernährung"),
                        onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {   
                          return TagebuchAuswahlScreen(id :"ternaehrung", title: "Ernährung");
                        }));
                      }
              )
            ),
            Card(     //Karte zum Weiterleiten auf die Sport-Fragen; übergibt dafür dem TagebuchAuswahlScreen den Titel des es haben soll + die ID des Sport-Fragebogens auf dem FHIR Server
              child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.directions_run),
                        ),
                        title: Text("Sport & Bewegung"),
                        onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {  
                          return TagebuchAuswahlScreen(id :"tsport", title: "Sport & Bewegung");
                        }));
                      }
              )
            ),
            Card(   //Karte zum Weiterleiten auf die Wohlbefinden-Fragen; übergibt dafür dem TagebuchAuswahlScreen den Titel des es haben soll + die ID des Wohlbefinden-Fragebogens auf dem FHIR Server
              child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.pinkAccent,
                          child: Icon(Icons.favorite_outline_sharp),
                        ),
                        title: Text("Seelisches Wohlbefinden"),
                        onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {    //Weiterleiten auf AuswertungenScreen, mit Zurückknopf
                          return TagebuchAuswahlScreen(id :"twohlbefinden", title: "Seelisches Wohlbefinden");
                        }));
                      }
              )
            ),
          ]
        ),
        ),
    );
  }
}
