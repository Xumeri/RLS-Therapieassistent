/// Repräsentiert einen einzelnen Datenpunkt für die Visualisierung in Diagrammen.
///
/// Ein [DataPoint] verknüpft einen Zeitpunkt mit einem numerischen Score
/// und bietet Kontext für die Anzeige in Listen oder Graphen.
class DataPoint {
  /// Der Zeitpunkt, zu dem die Antwort gegeben wurde.
  final DateTime datetime;

  /// Der berechnete Score-Wert (entspricht der Y-Achse im Diagramm).
  final double score;

  /// Optionale textuelle Interpretation oder Zusammenfassung des Ergebnisses.
  final String interpretation;

  /// Der theoretisch erreichbare Maximalwert für diesen Score.
  /// Wichtig für die Skalierung der Diagrammachsen.
  final double maxScore;

  DataPoint({
    required this.datetime,
    required this.score,
    required this.interpretation,
    required this.maxScore,
  });

  /// Erzeugt eine Instanz aus einem JSON-Map vom Backend.
  ///
  /// Erwartet die Schlüssel 'date', 'score', 'maxscore' und optional 'interpretation'.
  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      datetime: DateTime.parse(json['date'] as String),
      score: double.parse(json['score'].toString()),
      interpretation: (json['interpretation'] ?? '').toString(),
      maxScore: double.parse(json['maxscore'].toString()),
    );
  }
}

/// Ermittelt den aktuellsten Score aus einer Liste von Datenpunkten.
///
/// Geht davon aus, dass die Liste bereits sortiert ist oder der erste Eintrag
/// den neuesten Stand repräsentiert. Gibt 0 zurück, falls die Liste leer ist.
double newestScore(List<DataPoint> points) {
  if (points.isEmpty) return 0;
  return points.first.score;
}

/// Aggregiert eine Liste von Punkten zu Tagesdurchschnitten.
///
/// Diese Funktion gruppiert alle Einträge nach ihrem Kalendertag (ohne Uhrzeit)
/// und berechnet für jeden Tag den Mittelwert der Scores.
///
/// Das Ergebnis ist chronologisch aufsteigend sortiert.
List<DataPoint> aggrDailyAverage(List<DataPoint> points) {
  final Map<DateTime, List<DataPoint>> grouped = {};

  // Einträge nach Kalendertag gruppieren
  for (final p in points) {
    final day = DateTime(p.datetime.year, p.datetime.month, p.datetime.day);
    grouped.putIfAbsent(day, () => []).add(p);
  }

  // Für jeden Tag einen Durchschnittspunkt erzeugen
  final dailyPoints = grouped.entries.map((entry) {
    final day = entry.key;
    final list = entry.value;

    final avg =
        list.fold<double>(0, (sum, p) => sum + p.score) / list.length;

    return DataPoint(
      datetime: day,
      score: avg,
      interpretation: 'Ø Tageswert (${list.length} Einträge)',
      maxScore: list.first.maxScore,
    );
  }).toList();

  // Chronologisch sortieren (aufsteigend für das Diagramm)
  dailyPoints.sort((a, b) => a.datetime.compareTo(b.datetime));
  return dailyPoints;
}
