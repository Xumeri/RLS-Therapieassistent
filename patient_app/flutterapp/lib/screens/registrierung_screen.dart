import 'package:flutter/material.dart';
import 'package:flutterapp/screens/login_screen.dart';
import 'package:flutterapp/services/jwt_service.dart';
import 'package:flutterapp/data/patient_repository.dart';


/// A screen that allows new users to register an account.
///
/// Collects user details like username, password, name, and birthdate.
/// It performs account creation and saves initial patient profile data.
class RegistrierungScreen extends StatefulWidget {
  /// The title of the screen.
  final String title = "Registrierung Screen";

  const RegistrierungScreen({super.key});

  @override
  State<RegistrierungScreen> createState() => _RegistrierungScreenPageState();
}

class _RegistrierungScreenPageState extends State<RegistrierungScreen> {
  /// Controller for the username input.
  final usernameController = TextEditingController(); 
  /// Controller for the primary password input.
  final passwort1Controller = TextEditingController(); 
  /// Controller for the password confirmation input.
  final passwort2Controller = TextEditingController(); 
  /// Controller for the first name input.
  final vornameController = TextEditingController(); 
  /// Controller for the last name input.
  final nachnameController = TextEditingController(); 
  /// Controller for the birthdate input.
  final geburtsdatumController = TextEditingController(); 
  /// Service for handling JWT operations.
  final jwtService = JwtService(); 
  /// Repository for patient data operations.
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