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

/// Provider for the [PatientService].
final patientServiceProvider = Provider<PatientService>((ref){
  final repository = ref.watch(patientRepositoryProvider);
  return PatientService(repository);
});

/// Service class for patient-related operations.
class PatientService{
  final PatientRepository repository;
  PatientService(this.repository);

  /// Changes the patient's password.
  Future<bool> changePassword(String oldPassword, String newPassword){
    return repository.changePassword(oldPassword, newPassword);
  }
  Future<bool> deleteAccount(){
    return repository.deleteAccount();
  }

}
