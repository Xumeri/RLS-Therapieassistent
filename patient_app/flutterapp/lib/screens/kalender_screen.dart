import 'package:flutter/material.dart';
import 'package:flutterapp/screens/kalender_auswahl_screen.dart';
import 'package:table_calendar/table_calendar.dart';


/// A screen that displays a calendar view to the user.
///
/// Users can select a specific date to view related questionnaire results and diary entries.
class KalenderScreen extends StatefulWidget {
  const KalenderScreen({super.key});

  @override
  State<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  /// The title of the screen.
  final String title = "Kalender";
  /// Today's date and time.
  DateTime today = DateTime.now();
  /// The currently focused day in the calendar.
  DateTime _focusedDay = DateTime.now();

  // ------------------------------ Build Methode -------------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(   //App bar im Farbschema der App die den Titel des Screens anzeigt
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: TableCalendar(    //Kalender Widget
        firstDay: DateTime(today.year - 2, today.month, today.day), //Tag ab dem der Kalender anfängt = aktueller Tag - 2 Jahre
        lastDay: today, //Tag ab dem der Kalender aufhört = aktueller Tag
        focusedDay: _focusedDay,   //bestimmt welcher Monat angezeigt wird (wird auf _focusedDay gesetzt -> wenn man Kalender öffnet sieht man immer den aktuellen Monat)
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color:Theme.of(context).colorScheme.inversePrimary, shape: BoxShape.circle) //macht grünen Kreis um den aktuellen Tag
        ),
        headerStyle: HeaderStyle(formatButtonVisible: false), //macht den "2 weeks" Knopf oben rechts weg
        locale: "de_DE", //setzt Sprache des Kalenders auf Deutsch
        onDaySelected: (selectedDay, focusedDay) {   //Wenn Benutzer einen Tag auswählt....
            setState(() {        //ruft Funktion setState auf
              _focusedDay = focusedDay;    //der augewählte Tag wird als focusedDay gesetzt 
                                           //-> wenn man nachdem ein Tag ausgewählt wurde zurück zum KalenderScreen geht, bekommt man den Monat angezeigt, bei dem man zuletzt den Tag ausgewählt hat
            });

            String datestring = selectedDay.toIso8601String();  //Variable datestring speichert Datum des ausgewählten Tages als String
            
            Navigator.push(    //Navigiert zum KalenderAuswahlScreen, übergibt datestring (String Variable mit dem ausgewählten Tag)
              context, 
              MaterialPageRoute(
                builder: (context) {
                  return KalenderAuswahlScreen(date: datestring);
                }));
            }
      ),
    );
  }
}
