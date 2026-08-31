
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/questionnaire_result_repository.dart';
import '../domain/questionnaire_result.dart';


final questionnaireResultProvider = FutureProvider.family<QuestionnaireResult, String>((ref, id) async {
  final repository = ref.watch(questionnaireResultRepositoryProvider);
  return repository.fetchQuestionnaireResult(id);
});