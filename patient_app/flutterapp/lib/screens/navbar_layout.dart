import 'package:flutter/material.dart';
import 'package:flutterapp/screens/einstellungen_screen.dart';
import 'package:flutterapp/screens/home_screen.dart';
import 'package:flutterapp/screens/kalender_screen.dart';

class NavbarLayout extends StatefulWidget {
  const NavbarLayout({super.key});

  @override
  State<NavbarLayout> createState() => _NavbarLayoutState();
}

class _NavbarLayoutState extends State<NavbarLayout> {
  var selectedIndex = 0;     // Variable für ausgwähltes Ziel, initialisiert mit 0 -> anfangs wird immer Homescreen gezeigt

  @override
  Widget build(BuildContext context) {  //page Widget, dem ja nach selectedIndex Wert ein anderer Bildschrim zugewiesen wird
    Widget page;
      switch (selectedIndex) {
        case 0:
          page = HomeScreen();
          break;
        case 1:
          page = KalenderScreen();
          break;
        case 2:
          page = EinstellungenScreen();
          break;
        default:
          throw UnimplementedError('no widget for $selectedIndex');  //Fehler wenn selectedIndex weder 0 noch 1 ist
      }

    return LayoutBuilder(  //Layoutbuilder ändert die Struktur des Widgets je nach verfügbarem Platz 
      builder: (context, constraints) {
        return Scaffold(
          body: Column(
            children: [
              Expanded(  //Expanded = nimmt den gesamtes Platz ein, der nicht von anderen Widgests (hier Nav Liste) benötigt wird
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,  //Container in dem Expanded Widget ist farbig
                  child: page,  //Container enthält die Page, die man anzeigen möchte
                ),
              ),
              SafeArea(
                child: NavigationBar(  //Navigationbar in Widget Safearea, damit sie nie von irgendwas verdeckt wird
                  destinations: [
                    NavigationDestination(  //1stes Ziel
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(  //2tes Ziel
                      icon: Icon(Icons.calendar_month_outlined),
                      label: 'Kalender',
                    ),
                    NavigationDestination(  //3tes Ziel
                      icon: Icon(Icons.settings),
                      label: 'Einstellungen',
                    ),
                  ],
                  selectedIndex: selectedIndex,  //0 wählt erstes Ziel, 1 wählt 2tes Ziel, usw
                  onDestinationSelected: (value) {  //was passiert wenn Nutzer ein Ziel auswählt
                    setState(() {                //setState Aufruf weist selectedIndex den neuen Wert zu
                      selectedIndex = value;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}