import 'package:flutter/material.dart';
import 'package:flutterapp/screens/auswertung_fragebogen_screen.dart';
import 'package:flutterapp/screens/auswertung_tagebuch_screen.dart';

class AuswertungScreen extends StatelessWidget {
  final String title = "Auswertung auswählen:";

  const AuswertungScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,   //Buttons werden mittig in der Column angezeigt
          children: [
            ElevatedButton.icon(    //Knopf zur Tagebuch-Auswertung Seite
              icon: Icon(Icons.query_stats),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {  //Weiterleiten auf FragebogenScreen, mit Zurückknopf
                  return AuswertungTagebuchScreen();
                }));
              },
              label: const Text('Tagebuch', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(   //Knopf zur Fragebogen-Auswertung Seite
              icon: Icon(Icons.query_stats),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {    //Weiterleiten auf TagebuchScreen, mit Zurückknopf
                  return AuswertungFragebogenScreen();
                }));
              },
              label: const Text('Fragebögen', style: TextStyle(fontSize: 25),),
            ),
          ],
        ),
      ),
    );
  }
}
