import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dio_setup.dart';

/// Provider for the [CalendarRepository].
final calendarRepositoryProvider = Provider<CalendarRepository>((ref){
  return CalendarRepository();
});

/// Repository for fetching calendar-related data from the backend.
class  CalendarRepository {
    /// Fetches both questionnaire and diary responses for a specific [date].
    ///
    /// Returns a tuple containing a list of questionnaires and a list of diary entries.
    /// Throws an [Exception] if the requests fail.
    Future<(List<dynamic>, List<dynamic>)> fetchData(String date) async{
      final urlQuestionnaire = "/rls/getresponse/$date";
      final urlDiary = "/rls/gettagebuchresponse/$date";

      try{
        final responseList = await Future.wait([
        dio.get(urlQuestionnaire), dio.get(urlDiary)
        ]);

        final listQuestionnaire = responseList[0].data as List<dynamic>;
        final listDiary = responseList[1].data as List<dynamic>;

        return (listQuestionnaire, listDiary);
      }catch(e){
        throw Exception("Fehler beim Abruf der Daten: $e");
      }
}

}

