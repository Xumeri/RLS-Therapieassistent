import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/calendar_repository.dart';

final calendarProvider = FutureProvider.family<(List<dynamic>, List<dynamic>), String>((ref,date) async{
  final repository = ref.watch(calendarRepositoryProvider);
  return repository.fetchData(date);
});