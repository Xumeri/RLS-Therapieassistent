/// Represents the profile of a patient.
class PatientProfile {
  /// The first name of the patient.
  final String name;

  /// The last name of the patient.
  final String surname;

  /// The birthdate of the patient (ISO-8601 string or formatted date).
  final String birthdate;

  PatientProfile({
    required this.name,
    required this.surname,
    required this.birthdate,
  });

  /// Erstellt eine [PatientProfile]-Instanz aus einem JSON-Map.
  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
        name: (json['vorname'] ?? '').toString(),
        surname: (json['nachname'] ?? '').toString(),
        birthdate: (json['geburtsdatum'] ?? '').toString());
  }
}
