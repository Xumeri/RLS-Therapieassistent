import 'package:flutter/material.dart';
import 'package:flutterapp/screens/auswertung_nav_screen.dart';
import 'package:flutterapp/screens/erinnerungen_screen.dart';
import 'package:flutterapp/screens/fragebogen_nav_screen.dart';
import 'package:flutterapp/screens/infos_screen.dart';
import 'package:flutterapp/screens/sensor_screen.dart';
import 'package:flutterapp/screens/tagebuch_nav_screen.dart';
import 'package:flutterapp/screens/faq_screen.dart';


//--------------------- Homepage --------------------------------------------------

class HomeScreen extends StatelessWidget {
  final String title = "Home Screen";

  const HomeScreen({super.key});

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
            ElevatedButton.icon(    //Knopf zur Fragebogen Seite
              icon: Icon(Icons.edit_note),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {  //Weiterleiten auf FragebogenScreen, mit Zurückknopf
                  return FragebogenScreen();
                }));
              },
              label: const Text('Fragebögen', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(   //Knopf zur Tagebuch Seite
              icon: Icon(Icons.menu_book_sharp),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {    //Weiterleiten auf TagebuchScreen, mit Zurückknopf
                  return TagebuchScreen();
                }));
              },
              label: const Text('Tagebuch', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height:10,),
            ElevatedButton.icon(   //Knopf zur Erinnerungen Seite
              icon: Icon(Icons.notification_add),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {    //Weiterleiten auf ErinnerungenScreen, mit Zurückknopf
                  return ErinnerungenScreen();
                }));
              },
              label: const Text('Erinnerungen', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(    //Knopf zur Sensor Seite
              icon: Icon(Icons.query_stats),   
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {   //Weiterleiten auf SensorScreen, mit Zurückknopf
                  return SensorScreen();
                }));
              },
              label: const Text('Sensordaten', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(    //Knopf zur Infos Seite
              icon: Icon(Icons.info_outline),   
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {   //Weiterleiten auf InfosScreen, mit Zurückknopf
                  return InfosScreen();
                }));
              },
              label: const Text('Infos', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(    //Knopf zur FAQ Seite
              icon: Icon(Icons.chat),   
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {   //Weiterleiten auf FAQScreen, mit Zurückknopf
                  return FAQScreen();
                }));
              },
              label: const Text('Häufig gestellte Fragen', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 10,),   //Abstand zwischen Knöpfen
            ElevatedButton.icon(    //Knopf zur Auswertungs Seite
              icon: Icon(Icons.bar_chart),   
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {    //Weiterleiten auf AuswertungenScreen, mit Zurückknopf
                  return AuswertungScreen();
                }));
              },
              label: const Text('Auswertungen', style: TextStyle(fontSize: 25),),
            ),
          ],
        ),
      ),
    );
  }
}
