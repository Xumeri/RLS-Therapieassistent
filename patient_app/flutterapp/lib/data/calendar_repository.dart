  import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dio_setup.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>((ref){
  return CalendarRepository();
});

class  CalendarRepository {
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

