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
  /// Saves a FHIR Patient resource to the backend.
  ///
  /// Takes [username], [firstname], [surname], and [birthdate] as parameters.
  /// Returns `true` if the resource was successfully created (HTTP 201).
  Future<bool> saveFhirPatient(String username, String firstname,String surname,String birthdate) async{
    try {
      final response = await dio.post("/rls/patient/",
        data: {
          'username': username,
          'vorname': firstname,
          'nachname': surname,
          'geburtsdatum': birthdate
        },
      );
      if (response.statusCode == 201) return true;
    }catch(e){
      return false;
    }
    return false;
  }

  /// Changes the patient's password on the server.
  ///
  /// Takes the [oldPassword] and the [newPassword].
  /// Returns `true` if the password was successfully changed.
  Future<bool> changePassword(String oldPassword, String newPassword) async{
    try{
      final response = await dio.post('/rls/change-password/',
      data:{'old_password': oldPassword,'new_password': newPassword},
      );
      return response.statusCode ==200;
    }catch(e){
      return false;
    }
  }
  Future<bool> deleteAccount() async{
    try{
      final response = await dio.delete('/rls/delete-account/');
      return response.statusCode == 200;
    }catch(e){
      return false;
    }
  }
}
