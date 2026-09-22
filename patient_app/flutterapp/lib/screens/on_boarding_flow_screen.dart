import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'rechtliches_screen.dart';
import 'login_screen.dart';

class OnBoardingFlowScreen extends StatelessWidget {
  const OnBoardingFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalTextScreen(
      title: 'Datenschutzerklärung',
      assetPath: 'assets/legal/de/privacy_policy.md',
      isMandatory: true,
      buttonLabel: 'Akzeptieren & weiter',
      onAccept: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return LegalTextScreen(
                title: 'Nutzungsbedingungen',
                assetPath: 'assets/legal/de/terms_of_service.md',
                isMandatory: true,
                buttonLabel: 'Akzeptieren',
                onAccept: () async{
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('hasAcceptedPolicy', true);
                  if(!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}