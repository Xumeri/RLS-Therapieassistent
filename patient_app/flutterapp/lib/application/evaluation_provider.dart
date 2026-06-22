import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/evaluation_repository.dart';
import '../domain/data_point.dart';

/// Provider für den Abruf von Diagrammdaten basierend auf einer Fragebogen-ID.
///
/// Nutzt das [evaluationRepositoryProvider], um die Daten asynchron zu laden.
/// Da es sich um einen [FutureProvider.family] handelt, wird für jede ID (z.B. 'f1', 'f2')
/// eine eigene Instanz und ein eigener Cache verwaltet.
final diagrammDatenProvider = FutureProvider.family<List<DiagrammPunkt>, String>((ref, id) async{
  final respository = ref.watch(evaluationRepositoryProvider);
  return respository.fetchData(id);
});

/// Aggregiert Daten aus verschiedenen Fragebögen für die KPI-Übersicht.
///
/// Dieser Provider kombiniert die Ergebnisse von 'f1' (IRLS) und 'f2' (RLSQoL),
/// um eine Map bereitzustellen, die für die globale Score-Anzeige (KPI-Cards)
/// im Kopfbereich des Auswertung-Screens genutzt wird.
final kpiDataProvider = FutureProvider<Map<String, List<DiagrammPunkt>>>((ref) async{
  final irlsDaten = await ref.watch(diagrammDatenProvider('f1').future);
  final rlsqolDaten = await ref.watch(diagrammDatenProvider('f2').future);

  return {
    'f1': irlsDaten,
    'f2': rlsqolDaten,
  };
});
