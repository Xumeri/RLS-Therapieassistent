import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dio_setup.dart';
import '../domain/questionnaire_result.dart';

final questionnaireResultRepositoryProvider = Provider<QuestionnaireResultRepository>((ref) {
  return QuestionnaireResultRepository();
});

class QuestionnaireResultRepository {
  Future<QuestionnaireResult?> sendResponse({
    required String id,
    required Map<String, dynamic>? questionnaire,
    required Map<String, dynamic>? answers,
  }) async {
    if (questionnaire == null || answers == null) return null;

    final date = DateTime.now();

    // 1. Liste aufbauen (Korrektur: 'linkId' mit großem 'D')
    final items = answers.entries.map((entry) {
      return <String, dynamic>{
        'linkId': entry.key, // FEHLER BEHOBEN: War vorher 'linkid'
        'answer': [
          {'valueString': entry.value}
        ]
      };
    }).toList();

    // 2. Sicheres Sortieren
    items.sort((a, b) {
      final aLinkId = a['linkId'].toString();
      final bLinkId = b['linkId'].toString();

      final aNum = int.tryParse(aLinkId.contains('.') ? aLinkId.split('.').last : aLinkId) ?? 0;
      final bNum = int.tryParse(bLinkId.contains('.') ? bLinkId.split('.').last : bLinkId) ?? 0;

      return aNum.compareTo(bNum);
    });

    // 3. ISO-8601 Datum formatieren
    final offsetHours = date.timeZoneOffset.inHours.abs().toString().padLeft(2, '0');
    final offsetMinutes = (date.timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final offsetSign = date.timeZoneOffset.isNegative ? '-' : '+';
    final formattedAuthored = "${date.toIso8601String()}$offsetSign$offsetHours:$offsetMinutes";

    final body = {
      "resourceType": "QuestionnaireResponse",
      "id": "r${questionnaire["id"]}${date.year}${date.month}${date.day}${date.hour}${date.minute}${date.second}",
      "questionnaire": id,
      "status": "completed",
      "authored": formattedAuthored,
      "item": [
        {
          "linkId": "0.1",
          "valueInteger": null
        },
        {
          "linkId": "0.2",
          "valueString": "null"
        },
        {
          "linkId": "1",
          "item": items
        }
      ]
    };

    try {
      final response = await dio.post("/rls/response/", data: body);

      if (response.statusCode == 200 && response.data != null) {
        debugPrint("Antwort vom Server: ${response.data}");
        return QuestionnaireResult.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Serverfehler beim Speichern: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Fehler beim Speichern der Fragebogen-Antwort: $e');
      rethrow;
    }
  }

  /// Vorhandenes Ergebnis abrufen
  Future<QuestionnaireResult> fetchQuestionnaireResult(String id) async {
    try {
      final response = await dio.get('/rls/questionaire/$id');
      if (response.statusCode == 200 && response.data != null) {
        return QuestionnaireResult.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Serverfehler: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fehler beim Laden der Ergebnisse: $e');
    }
  }
}