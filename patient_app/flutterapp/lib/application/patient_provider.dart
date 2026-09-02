import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/data/patient_repository.dart';
import 'package:flutterapp/domain/patient_profile.dart';

/// Provider, der das [PatientProfile] des Benutzers asynchron bereitstellt.
///
/// Nutzt den [patientRepositoryProvider], um die Daten abzurufen.
final patientProvider = FutureProvider<PatientProfile>((ref) async {
  final repository = ref.watch(patientRepositoryProvider);
  return repository.fetchProfile();
});

final patientServiceProvider = Provider<PatientService>((ref){
  final repository = ref.watch(patientRepositoryProvider);
  return PatientService(repository);
});

class PatientService{
  final PatientRepository repository;
  PatientService(this.repository);

  Future<bool> changePassword(String oldPassword, String newPassword){
    return repository.changePassword(oldPassword, newPassword);
  }
}
