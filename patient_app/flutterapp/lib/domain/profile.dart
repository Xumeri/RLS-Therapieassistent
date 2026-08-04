/// Repräsentiert das Profil eines Patienten.
class Profile {
  /// Der Vorname des Patienten.
  final String name;

  /// Der Nachname des Patienten.
  final String surname;

  /// Das Geburtsdatum des Patienten.
  final String birthdate;

  Profile({
    required this.name,
    required this.surname,
    required this.birthdate,
  });

  /// Erstellt eine [Profile]-Instanz aus einem JSON-Map.
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
        name: (json['vorname'] ?? '').toString(),
        surname: (json['nachname'] ?? '').toString(),
        birthdate: (json['geburtsdatum'] ?? '').toString());
  }
}
