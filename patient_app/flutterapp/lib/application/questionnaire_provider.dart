import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/questionnaire_repository.dart';
import '../domain/questionnaire_result.dart';

/// Provider, der eine Fragebogen-Definition anhand ihrer ID abruft.
final questionnaireDefinitionProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final repository = ref.watch(questionnaireRepositoryProvider);
  return repository.fetchFragebogen(id);
});

/// Provider für den [QuestionnaireService].
final questionnaireServiceProvider = Provider<QuestionnaireService>((ref) {
  final repository = ref.watch(questionnaireRepositoryProvider);
  return QuestionnaireService(repository);
});

/// Eine Service-Klasse, die Operationen rund um Fragebögen orchestriert.
class QuestionnaireService {
  final QuestionnaireRepository repository;

  QuestionnaireService(this.repository);

  /// Sendet die Antworten des Benutzers für einen bestimmten Fragebogen ab.
  Future<QuestionnaireResult> submitResponse({
    required String id,
    required Map<String, dynamic> questionnaire,
    required Map<String, String> answers,
  }) {
    return repository.sendResponse(
      id: id,
      questionnaire: questionnaire,
      answers: answers,
    );
  }
}
