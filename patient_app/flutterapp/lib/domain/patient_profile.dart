/// Repräsentiert das Profil eines Patienten.
class PatientProfile {
  /// Der Vorname des Patienten.
  final String name;

  /// Der Nachname des Patienten.
  final String surname;

  /// Das Geburtsdatum des Patienten.
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
