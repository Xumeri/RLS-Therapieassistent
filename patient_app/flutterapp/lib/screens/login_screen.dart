import 'package:flutter/material.dart';
import 'package:flutterapp/screens/navbar_layout.dart';
import 'package:flutterapp/screens/registrierung_screen.dart';
import 'package:flutterapp/services/jwt_service.dart';

// Code für das Login Screen wurde nach Vorlage von
// https://medium.com/@rohan.surve5/building-a-simple-login-screen-in-flutter-my-comeback-to-ui-development-60ebf1cd4bdc
// angepasst und um die login Methode erweitert

class LoginScreen extends StatefulWidget {
  final String title = "Login Screen";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final usernameController = TextEditingController(); //Erstellt einen Controller um Eingaben im Username Textfeld zu speichern
  final passwordController = TextEditingController(); //Erstellt einen Controller um Eingaben im Passwort Textfeld zu speichern
  final jwtService = JwtService(); //erstellt Jwtservice

  // dispose Methode (wird auf Flutter Webseite empfohlen: https://docs.flutter.dev/cookbook/forms/text-field-changes)
  // entfernt Controller wenn sie nicht mehr gebraucht werden
    @override
  void dispose() {  
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ----------------------- Build Methode ----------------------------------------------------------------------------------------------
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
            Text("Bitte Benutzername und Passwort eingeben:", style: TextStyle(fontSize: 20),),  //Text
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
                controller: passwordController,   //Eingaben werden über den passwordController überwacht
                decoration: InputDecoration(
                  labelText: 'Passwort',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            SizedBox(height: 20,),
            ElevatedButton.icon(    //"Login" Knopf
              icon: Icon(Icons.person),
              onPressed: () {    //Wenn der "Login" Knopf gedrückt wird wird die login Methode aufgerufen
                sendLoginData();
              },
              label: const Text('Login', style: TextStyle(fontSize: 25),),
            ),
            SizedBox(height: 20,),
            ElevatedButton(    //Knopf zum RegistrierungsScreen
              onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                return RegistrierungScreen();
              }));
              },
              child: const Text('Kein Account? --> Registrieren', style: TextStyle(fontSize: 25),),
            ),
          ],
        )
      ),
    );
  }

  // ---------------------------- Methode die Nutzer einloggt ----------------------------------------------------------------
  Future<void> sendLoginData() async {
      final username = usernameController.text.trim();  //speichert Eingabe in dem Username Feld unter variable "username"
      final password = passwordController.text.trim();  //speichert Eingabe in dem Passwort Feld unter Variable "password"

      var success = await jwtService.login(username, password); //verwendet JWT Service login Methode um Benutzername und Passwort ans Backend zu senden und Nutzer einzuloggen

      if(!mounted) return;
      if (success) {
          //wenn Login Info erfolgreich gesendet und eine Antwort vom Backend erhalten wurde....

          //Leitet Benutzer auf das Homescreen weiter
          //Navigator.pushReplacement verhindert dass man auf die Login Seite zurückgehen kann 
          //(im Gegensatz zu Navigator.push was oben rechts immer den Zurückknopf hinmacht)
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                    return NavbarLayout();
          }));
      } else {
          ScaffoldMessenger.of(context).showSnackBar(  //Nachricht falls Login fehlschlägt
            SnackBar(content: Text('Login fehlgeschlagen. \nBitte gültigen Benutzernamen und Passwort eingeben.')),
          );
      }
  }

}
