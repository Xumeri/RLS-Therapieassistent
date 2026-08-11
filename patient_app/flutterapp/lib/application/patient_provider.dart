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
