import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dio_setup.dart';
import '../domain/profile.dart';

/// Provider für den [ProfileRepository].
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// Repository für den Zugriff auf Profil-Daten.
class ProfileRepository {
  /// Ruft das Profil des aktuell angemeldeten Benutzers vom Server ab.
  ///
  /// Wirft eine [Exception], wenn die Anfrage fehlschlägt oder der Server einen Fehler zurückgibt.
  Future<Profile> fetchProfile() async {
    try {
      final response = await dio.get('/rls/profil/');
      if (response.statusCode == 200) {
        return Profile.fromJson(response.data);
      } else {
        throw Exception('Serverfehler: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fehler beim Laden des Profils: $e');
    }
  }
}
