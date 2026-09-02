import 'package:flutter/material.dart';
import 'package:flutterapp/screens/login_screen.dart';
import 'package:flutterapp/services/jwt_service.dart';
import 'package:flutterapp/data/patient_repository.dart';
/*
COMMIT_MESSAGE
refactor: Registrierung-Screen und Patient-Repository bereinigt

Geänderte Dateien:
- data/patient_repository.dart: saveFHIRPatient() hinzugefügt –
  POST /rls/patient/ mit String-Typen, try/catch mit false-Fallback
- screens/registrierung_screen.dart:
  saveFhirPatient() aus Screen in PatientRepository ausgelagert,
  dio_setup.dart Import entfernt,
  mounted-Checks nach beiden await-Aufrufen ergänzt
 */

class RegistrierungScreen extends StatefulWidget {
  final String title = "Registrierung Screen";

  @override
  State<RegistrierungScreen> createState() => _RegistrierungScreenPageState();
}

class _RegistrierungScreenPageState extends State<RegistrierungScreen> {
  final usernameController = TextEditingController(); //Erstellt einen Controller um Eingaben im Username Textfeld zu speichern
  final passwort1Controller = TextEditingController(); //Erstellt einen Controller um Eingaben im Passwort Textfeld zu speichern
  final passwort2Controller = TextEditingController(); //Erstellt einen Controller um Eingaben im Passwort2 Textfeld zu speichern
  final vornameController = TextEditingController(); //Erstellt Controller um Eingaben im Vorname Feld zu speichern
  final nachnameController = TextEditingController(); //Erstellt Controller um Eingaben im Nachname Feld zu speichern
  final geburtsdatumController = TextEditingController(); //Erstellt Controller um Eingaben im Geburtsdatum Feld zu speichern
  final jwtService = JwtService(); //erstellt Jwtservice
  final patientRepository = PatientRepository();


  // dispose Methode (wird auf Flutter Webseite empfohlen: https://docs.flutter.dev/cookbook/forms/text-field-changes)
  // entfernt Controller wenn sie nicht mehr gebraucht werden
    @override
  void dispose() {
    usernameController.dispose();
    passwort1Controller.dispose();
    passwort2Controller.dispose();
    vornameController.dispose();
    nachnameController.dispose();
    geburtsdatumController.dispose();
    super.dispose();
  }

  //--------------------------- Build Methode ---------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Bitte geben Sie folgende Informationen ein:", style: TextStyle(fontSize: 20),),  //Text über den Eingabefeldern
            SizedBox(height: 20,),
            TextField(     //Eingabefeld für den Benutzernamen
                controller: usernameController,  //Eingaben werden über den usernameController überwacht
                decoration: InputDecoration(
                  labelText: 'Benutzername',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(     //Eingabefeld für das Passwort
                controller: passwort1Controller,   //Eingaben werden über den passwortController überwacht
                decoration: InputDecoration(
                  labelText: 'Passwort',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(     //Eingabefeld für das Passwort
                controller: passwort2Controller,   //Eingaben werden über den passwortController überwacht
                decoration: InputDecoration(
                  labelText: 'Passwort wiederholen',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(     //Eingabefeld für das Passwort
                controller: vornameController,   //Eingaben werden über den passwortController überwacht
                decoration: InputDecoration(
                  labelText: 'Vorname',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(     //Eingabefeld für das Passwort
                controller: nachnameController,   //Eingaben werden über den passwortController überwacht
                decoration: InputDecoration(
                  labelText: 'Nachname',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(     //Eingabefeld für das Passwort
                controller: geburtsdatumController,   //Eingaben werden über den passwortController überwacht
                decoration: InputDecoration(
                  labelText: 'Geburtsdatum',
                  border: OutlineInputBorder(),
                ),
                onTap: () async {        // Beim Anklicken des Felds Geburtsdatum wird ein DatePicker geöffnet
                  final today = DateTime.now();
                  final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(today.year - 100),  // Datepicker frühestes Datum (heute - 100 Jahre)
                            lastDate: today,  // Datepicker spätestes Datum (heute)
                            initialDate: today,
                          );
                  if (picked != null) {  // sobals ein Datum ausgewählt wurde, wird es im YYYY-MM-DD Format als Text des Textfelds gespeichert
                        String date = picked.toIso8601String().substring(0,10);
                        geburtsdatumController.text = date;
                  }
                },
              ),
              SizedBox(height: 20,),
              ElevatedButton.icon(    //"Registrieren" Knopf
                icon: Icon(Icons.person),
                onPressed: () {    //Wenn der "Registrieren" Knopf gedrückt wird wird die userRegistrieren Methode aufgerufen
                  userRegistrieren();
                },
                label: const Text('Registrieren', style: TextStyle(fontSize: 25),),
              ),
          ],
        )
      ),
    );
  }


  // ------------------------- Methode die Nutzer registriert -----------------------------------------------------------------------
  Future<void> userRegistrieren() async {
      final username = usernameController.text.trim();  //speichert Eingabe in dem Username Feld unter variable "username"
      final passwort1 = passwort1Controller.text.trim();  //speichert Eingabe in dem Passwort Feld unter Variable "passwort1"
      final passwort2 = passwort2Controller.text.trim();  //speichert Eingabe in dem Passwort wiederholen Feld unter Variable "passwort2"
      final vorname = vornameController.text.trim();  //speichert Eingabe in dem Vorname Feld unter variable "vorname"
      final nachname = nachnameController.text.trim();  //speichert Eingabe in dem Nachname Feld unter variable "nachname"
      final geburtsdatum = geburtsdatumController.text.trim();  //speichert Eingabe in dem Geburtsdatum Feld unter variable "geburtsdatum"


      if (passwort1 != passwort2){
         ScaffoldMessenger.of(context).showSnackBar(  // Nachricht die aufpoppt falls Passwörter ungleich sind
          SnackBar(content: Text("Passwörter sind nicht gleich!")),
        );
      }
      else {
            final passwort = passwort1;    //Wenn Passwörter übereinetimmen....
            var success = await jwtService.signup(username, passwort);  //Werden Benutzername + Passwort für die Registrierung an das Backend gesendet
          if(!mounted) return;
          if (success) {
              //wenn Login Info erfolgreich gesendet und eine Antwort vom Backend erhalten wurde....
              await patientRepository.saveFhirPatient(username, vorname, nachname, geburtsdatum); //Daten für FHIR Patient Ressource werden an Backend gesendet
              if(!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(  //Nachricht
                SnackBar(content: Text("Registrierung erfolgreich!")),
              );
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {  //Nuter wird wieder zum LoginScreen geleitet
                        return LoginScreen();
              }));
          } else { //Wenn beim Registrieren ein Fehler auftritt....
              ScaffoldMessenger.of(context).showSnackBar(  //Nachricht wenn Registrierung fehlgeschlagen ist
                SnackBar(content: Text("Registration fehlgeschlagen")),
              );
          }
      }
  }
}