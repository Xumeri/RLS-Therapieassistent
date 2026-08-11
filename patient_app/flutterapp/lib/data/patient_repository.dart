import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dio_setup.dart';
import '../domain/patient_profile.dart';

/// Provider für den [PatientRepository].
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepository();
});

/// Repository für den Zugriff auf Patienten-Profil-Daten.
class PatientRepository {
  /// Ruft das Profil des aktuell angemeldeten Benutzers vom Server ab.
  ///
  /// Wirft eine [Exception], wenn die Anfrage fehlschlägt oder der Server einen Fehler zurückgibt.
  Future<PatientProfile> fetchProfile() async {
    try {
      final response = await dio.get('/rls/profil/');
      if (response.statusCode == 200) {
        return PatientProfile.fromJson(response.data);
      } else {
        throw Exception('Serverfehler: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fehler beim Laden des Profils: $e');
    }
  }
}
