import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/calendar_repository.dart';

/// Provider for fetching calendar data (questionnaires and diary entries) for a specific date.
final calendarProvider = FutureProvider.family<(List<dynamic>, List<dynamic>), String>((ref,date) async{
  final repository = ref.watch(calendarRepositoryProvider);
  return repository.fetchData(date);
});