import 'package:flutter/foundation.dart';

/// Represents the result of a completed questionnaire.
///
/// Contains the calculated [score] and its clinical [interpretation].
@immutable
class QuestionnaireResult {
  /// The numerical score calculated from the questionnaire answers.
  final int score;

  /// The clinical interpretation or meaning of the calculated [score].
  final String interpretation;

  const QuestionnaireResult({
    required this.score,
    required this.interpretation,
  });

  /// Creates a [QuestionnaireResult] from a JSON map.
  ///
  /// Expects 'score' (parsable to int) and 'interpretation' fields.
  factory QuestionnaireResult.fromJson(Map<String, dynamic> json) {
    return QuestionnaireResult(
      score: int.tryParse(json['score']?.toString() ?? '') ?? 0,
      interpretation: json['interpretation']?.toString() ?? '',
    );
  }
}