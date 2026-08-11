import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dio_setup.dart';
import '../domain/questionnaire_result.dart';

/// Provider for the [QuestionnaireRepository].
final questionnaireRepositoryProvider = Provider<QuestionnaireRepository>((ref) {
  return QuestionnaireRepository();
});

/// Repository responsible for sending questionnaire responses and fetching definitions.
class QuestionnaireRepository {
  /// Sends a completed questionnaire response to the server.
  ///
  /// Takes the questionnaire [id], the [questionnaire] definition, and the user's [answers].
  /// Formats the data into a FHIR-style QuestionnaireResponse resource.
  ///
  /// Returns a [QuestionnaireResult] if successful.
  /// Throws an [Exception] if the server returns an error.
  Future<QuestionnaireResult> sendResponse({
    required String id,
    required Map<String, dynamic> questionnaire,
    required Map<String, String> answers,
  }) async {

    final date = DateTime.now();


    final items = answers.entries.map((entry) {
      return <String, dynamic>{
        'linkId': entry.key,
        'answer': [
          {'valueString': entry.value}
        ]
      };
    }).toList();


    items.sort((a, b) {
      final aLinkId = a['linkId'].toString();
      final bLinkId = b['linkId'].toString();

      final aNum = int.tryParse(aLinkId.contains('.') ? aLinkId.split('.').last : aLinkId) ?? 0;
      final bNum = int.tryParse(bLinkId.contains('.') ? bLinkId.split('.').last : bLinkId) ?? 0;

      return aNum.compareTo(bNum);
    });


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

  /// Fetches a questionnaire definition by its [id].
  ///
  /// Returns a [Map] representing the FHIR Questionnaire resource.
  /// Throws an [Exception] if the request fails.
  Future<Map<String, dynamic>> fetchFragebogen(String id) async {
    try {
      final response = await dio.get('/rls/questionnaire/$id');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Serverfehler: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fehler beim Laden des Fragebogens: $e');
    }
  }


}
