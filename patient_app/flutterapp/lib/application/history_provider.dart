import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/history_repository.dart';
import '../domain/data_point.dart';

/// Provider für den Abruf von Diagrammdaten basierend auf einer Fragebogen-ID.
final dataPointProvider = FutureProvider.family<List<DataPoint>, String>((ref, id) async{
  final respository = ref.watch(historyRepositoryProvider);
  return respository.fetchData(id);
});

/// Aggregiert Daten aus verschiedenen Fragebögen für die KPI-Übersicht.
final kpiDataProvider = FutureProvider<Map<String, List<DataPoint>>>((ref) async{
  final irlsDaten = await ref.watch(dataPointProvider('f1').future);
  final rlsqolDaten = await ref.watch(dataPointProvider('f2').future);

  return {
    'f1': irlsDaten,
    'f2': rlsqolDaten,
  };
});
