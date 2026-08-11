import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/dio_setup.dart';
import '../domain/data_point.dart';


/// Provider für den [HistoryRepository], ermöglicht den Zugriff auf die Datenquelle.
final historyRepositoryProvider = Provider<HistoryRepository>((ref){
  return HistoryRepository();
});

/// Repository für den Abruf von historischen Auswertungsdaten (Diagramme, KPIs).
class HistoryRepository {
  /// Lädt eine Liste von [DataPoint]-Objekten für eine bestimmte Fragebogen-ID.
  ///
  /// [questionnarieId]: Die ID des Fragebogens (z. B. 'f1' für IRLS).
  ///
  /// Wirft eine [Exception], falls der Server mit einem Fehlercode antwortet
  /// oder ein Netzwerkproblem auftritt.
  Future<List<DataPoint>> fetchData(String questionnarieId) async{
    try{
      final response = await dio.get("/rls/diagramm/$questionnarieId");
      if (response.statusCode==200){
        final List data = response.data;
        return data.map((e) => DataPoint.fromJson(e as Map<String, dynamic>)).toList();
      }else{
        throw Exception('Serverfehler: ${response.statusCode}');
      }
    }catch(e){
      throw Exception('Fehler beim Laden der Diagrammdaten: $e');
    }
  }

  /// Lädt die Daten und berechnet KPI-Strings
  Future<Map<String, String>> loadKpis() async {
    // Daten aus Backend holen (über fetchData)
    final sleep = await fetchData('tschlaf');
    final nutrition = await fetchData('ternaehrung');
    final wellbeing = await fetchData('twohlbefinden');
    final sport = await fetchData('tsport');

    // Durchschnitt der letzten 7 Tage berechnen
    final sleepAvg = avgLast7Days(sleep);
    final nutritionAvg = avgLast7Days(nutrition);
    final wellbeingAvg = avgLast7Days(wellbeing);
    final sportAvg = avgLast7Days(sport);

    // MaxScore (für Anzeige "x / max")
    final sleepMax = sleep.isNotEmpty ? sleep.first.maxScore : 5.0;
    final nutritionMax = nutrition.isNotEmpty ? nutrition.first.maxScore : 5.0;
    final wellbeingMax = wellbeing.isNotEmpty ? wellbeing.first.maxScore : 5.0;
    final sportMax = sport.isNotEmpty ? sport.first.maxScore : 5.0;

    return {
      'sleep': '${sleepAvg.toStringAsFixed(1)} / ${sleepMax.toStringAsFixed(0)}',
      'nutrition': '${nutritionAvg.toStringAsFixed(1)} / ${nutritionMax.toStringAsFixed(0)}',
      'wellbeing': '${wellbeingAvg.toStringAsFixed(1)} / ${wellbeingMax.toStringAsFixed(0)}',
      'sport': '${sportAvg.toStringAsFixed(1)} / ${sportMax.toStringAsFixed(0)}',
    };
  }

  double avgLast7Days(List<DataPoint> points) {
    if (points.isEmpty) return 0;

    final now = DateTime.now();

    // Start: heute minus 6 Tage (inkl. heute = 7 Tage insgesamt)
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));

    // Filter: nur Einträge innerhalb der letzten 7 Tage
    final weekPoints = points
        .where((p) => !p.datetime.isBefore(startOfWeek) && !p.datetime.isAfter(now))
        .toList();

    if (weekPoints.isEmpty) return 0;

    final sum = weekPoints.fold<double>(0, (acc, p) => acc + p.score);
    return sum / weekPoints.length;
  }
}
