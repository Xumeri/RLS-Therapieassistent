/// Represents a specific day in the calendar with all its associated responses.
///
/// Contains both [questionnaireAnswers] and [diaryEntries] recorded on that day.
class CalendarDay {
  /// List of questionnaire responses for this day.
  final List<dynamic> questionnaireAnswers;
  /// List of diary entries for this day.
  final List<dynamic> diaryEntries;

  const CalendarDay({
    required this.diaryEntries,
    required this.questionnaireAnswers,
});
}
