import 'package:flutter/material.dart';

/// Screen for displaying detailed answers and text entries of a specific diary response.
///
/// This screen is typically reached from the [KalenderAuswahlScreen].
class KalendertResponseScreen extends StatefulWidget {
  /// The JSON data representing the diary response.
  final Map<String, dynamic>? responsejson;
  const KalendertResponseScreen({super.key, required this.responsejson});

  @override
  State<KalendertResponseScreen> createState() => _KalendertResponseScreenState();
}

class _KalendertResponseScreenState extends State<KalendertResponseScreen> {
  /// The title of the screen.
  final String title = "Tagebucheintrag Details";

  // -------------------------------- Build Methode ------------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ListView(  // macht eine scrollbare Liste
          children: [
            Column(
              children: [
                // ----------------------------- Abschnitt für allgemeine Infos über den Fragebogen ----------------------------------------------
                SizedBox(height: 10,),
                Text("${widget.responsejson?["questionnairetitle"]}", style: TextStyle(fontSize: 20),),  // zeigt Titel des Fragebogens
                Text("ausgefüllt am ${widget.responsejson?["date"].substring(0,10)}, um ${widget.responsejson?["date"].substring(11,16)} Uhr", style: TextStyle(fontSize: 15),), // Datum und Uhrzeit
                SizedBox(height: 10,),
                Card(  // grüne Karte die den Score darstellt
                  color: Theme.of(context).colorScheme.inversePrimary,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Score: ${widget.responsejson?["score"]} / ${widget.responsejson?["maxscore"]}", style: TextStyle(fontSize: 20),),
                  ),
                ),
                SizedBox(height: 5,),
                Card(  // grüne Karte die die Score Interpretation darstellt
                  color: Theme.of(context).colorScheme.inversePrimary,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("---> ${widget.responsejson?["interpretation"]}", style: TextStyle(fontSize: 20,), textAlign: TextAlign.center,),
                  ),
                ),
              ],
            ),
            Divider(),  // Trennstrich
            // ------------------------- Abschnitt für Fragen + Antworten ---------------------------------------------------------
            SizedBox(height:10),
            Center(child: Text("Antworten:", style: TextStyle(fontSize: 20),)),
            ListView.builder(   // generiert eine Liste mit allen Fragebogen-Fragen und den Antworten
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), //macht die kleine 2te Listview nicht-scrollable
                  itemCount: widget.responsejson?["questions"].length,
                  itemBuilder: (context, index) {
                    return ListTile(
                          title: Text(
                            "Frage ${index+1}: ${widget.responsejson?["questions"][index]["question"]}",
                            style: TextStyle(fontSize: 15,),),
                          subtitle: Text(
                            "---> ${widget.responsejson?["questions"][index]["answer"].substring(1)}", 
                            style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary),),
                    );
                  }
            ),
            SizedBox(height:10),
            Divider(),  // Trennstrich
            // --------------------------- Abschnitt für Tagebucheinträge ---------------------------------------------------
            SizedBox(height:10),
            Center(child: Text("Tagebucheinträge:", style: TextStyle(fontSize: 20),)),
            SizedBox(height: 10,),
            ListTile(
              title: Text("öffentlich:", style: TextStyle(fontSize: 15,),),   // ListTile für öffentliche Einträge
              subtitle: formatiereEntry(widget.responsejson?["publicentry"]),
            ),
            SizedBox(height:5),
            ListTile(
              title: Text("privat:", style: TextStyle(fontSize: 15),),    // ListTile für private Einträge
              subtitle: formatiereEntry(widget.responsejson?["privateentry"]),
            ),
          ],
        ),
    );
  }
}


// --------------------------- Methode die Einträge formattiert-------------------------------------------------------
// (gibt Eintrag zurück, falls ein Eintrag vorhnaden ist, "Kein Tagebucheintrag vorhanden" wenn nicht)
Widget formatiereEntry(text) {
  if (text == "null") {
    return Text("Kein Tagebucheintrag vorhanden", style: TextStyle(color: Colors.grey[500]),);
  }
  else {
    return Text(text);
  }
}