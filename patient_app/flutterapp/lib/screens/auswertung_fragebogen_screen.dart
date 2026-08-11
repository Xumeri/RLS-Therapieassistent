import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../application/history_provider.dart';
import '../domain/data_point.dart';

import 'package:flutter/widget_previews.dart';

/// Screen zur Anzeige der Auswertungsergebnisse der RLS-Fragebögen.
///
/// Dieser Screen bietet eine Übersicht über die zeitliche Entwicklung der
/// Fragebogen-Scores (IRLS und RLSQoL) mithilfe von Diagrammen und KPIs.
///
/// ### Funktionen:
/// - **Tabs:** Wechsel zwischen IRLS (International RLS Scale) und RLSQoL (RLS Quality of Life).
/// - **KPI-Bereich:** Anzeige des aktuellsten Scores für beide Fragebögen im Kopfbereich.
/// - **Diagramm:** Visualisierung des Score-Verlaufs als Liniendiagramm (Tagesdurchschnitte).
/// - **Historie:** Auflistung aller bisherigen Antworten im unteren Bereich ("Antwortverlauf").
///
/// ### Datenfluss:
/// Die Daten werden über Riverpod-Provider (`kpiDataProvider` und `diagrammDatenProvider`)
/// bezogen, welche die `DiagrammPunkt`-Modelle aus dem Backend/Repository laden.
class AuswertungFragebogenScreen extends StatelessWidget {
  const AuswertungFragebogenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Obere Leiste + Tabs
              SliverAppBar(
                title: const Text('Fragebogendaten im Überblick'),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'IRLS'),
                    Tab(text: 'RLSQoL'),
                  ],
                ),
              ),

              // KPI-Übersicht oben (zeigt Wochendurchschnitt)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: KpiRow(),
                ),
              ),
            ];
          },

          // Inhalte der Tabs: pro Kategorie wird lade_diagrammdaten(id) aufgerufen
          body: const TabBarView(
            children: [
              EvaluationTab(title: 'International RLS Scale', fragebogenId: 'f1'),
              EvaluationTab(title: 'RLS Quality of Life', fragebogenId: 'f2'),
            ],
          ),
        ),
      ),
    );
  }
}

//KPI-ROW: lädt Daten und zeigt neuesten Score für jeden Fragebogen
class KpiRow extends ConsumerWidget {
  const KpiRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiAsyncValue = ref.watch(kpiDataProvider);

    return kpiAsyncValue.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('KPI Fehler: $err'),
      ),
      data: (data){
        final f1 = data['f1'] ?? [];
        final f2 = data['f2'] ??  [];

        final irlsNewest = newestScore(f1);
        final rlsqolNewest = newestScore(f2);

        final irlsMax  = f1.isNotEmpty ? f1.first.maxScore : 5.0;
        final rlsqolMax = f2.isNotEmpty ? f2.first.maxScore : 5.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 2.5,
                children: [
                  KpiCard(
                      title: 'IRLS',
                      value: '${irlsNewest.toStringAsFixed(1)} / ${irlsMax.toStringAsFixed(0)}'
                  ),
                  KpiCard(
                      title: 'RLSQoL',
                      value: '${rlsqolNewest.toStringAsFixed(1)} / ${rlsqolMax.toStringAsFixed(0)}'
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const  Text("Score des letzten ausgefüllten Fragebogens)"),
            ],
          ),
        );
      },
    );
  }
}

/// Kleine Karte für KPI-Anzeige
class KpiCard extends StatelessWidget {
  final String title;
  final String value;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// EVALUATION TAB - Verwendet ConsumerWidget
// -----------------------------------------------------------------------------
class EvaluationTab extends ConsumerWidget {
  final String title;
  final String fragebogenId;

  const EvaluationTab({
    super.key,
    required this.title,
    required this.fragebogenId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hier greifen wir auf die gecachten Daten zu!
    final diagrammAsyncValue = ref.watch(dataPointProvider(fragebogenId));

    return diagrammAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Fehler: $err')),
      data: (pointsList) {
        // Da die Liste "final" übergeben wird, machen wir eine Kopie zum Sortieren
        final points = List<DataPoint>.from(pointsList);

        if (points.isEmpty) {
          return const Center(child: Text('Keine Daten vorhanden.'));
        }

        final maxScore = points.first.maxScore;
        points.sort((a, b) => a.datetime.compareTo(b.datetime));
        final dailyPoints = aggrDailyAverage(points);

        final start = DateTime(
          dailyPoints.first.datetime.year,
          dailyPoints.first.datetime.month,
          dailyPoints.first.datetime.day,
        );

        final spots = dailyPoints.map((p) {
          final d = DateTime(p.datetime.year, p.datetime.month, p.datetime.day);
          final x = d.difference(start).inDays.toDouble();
          return FlSpot(x, p.score);
        }).toList();

        final minX = spots.first.x;
        final maxX = spots.last.x;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  minY: 0,
                  maxY: maxScore,
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,  //zeigt auf y-Achse für Fragebögen nur jeden 10ten Score Wert (damit y-Achse nicht so voll wird)
                        reservedSize: 35,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2, // zeigt nur von jedem 2ten Tag das Datum auf der x-Achse
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final startDate = DateTime(
                            dailyPoints.first.datetime.year,
                            dailyPoints.first.datetime.month,
                            dailyPoints.first.datetime.day,
                          );
                          final date = startDate.add(Duration(days: value.toInt()));
                          final label =
                              '${date.day.toString().padLeft(2, '0')}.'
                              '${date.month.toString().padLeft(2, '0')}';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              label,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(    // Einstellungen wenn der Nutzer einen Punkt auf dem Diagramm anklickt....
                    touchTooltipData: LineTouchTooltipData(
                      maxContentWidth: 100,
                      tooltipBgColor: Theme.of(context).colorScheme.inversePrimary,   //Zeigt ein Feld mit hellgrünem Hintergrund
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          return LineTooltipItem(
                            'Score: ${touchedSpot.y.toStringAsFixed(2)}',    // Test des Felds ist "Score: [Scorewert]"
                            TextStyle(fontSize: 14,),
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                    getTouchLineStart: (data, index) => 0,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      gradient: LinearGradient(  //Farbe der Linie (Farbverlauf)
                        colors: [
                          Theme.of(context).colorScheme.inversePrimary,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary,
                        ],
                      ),
                      isCurved: true,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      spots: spots,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Antwortverlauf', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            ...points.reversed.map((p) {
              final d = p.datetime;
              final dateText = '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
              return ListTile(
                leading: const Icon(Icons.event_note),
                title: Text(dateText),
                subtitle: Text(p.interpretation),
                trailing: Text('${p.score} / ${p.maxScore}'),
              );
            }),
          ],
        );
      },
    );
  }
}

// =====================================================================
// WIDGET PREVIEW WRAPPER
// =====================================================================
// WICHTIG: Klicke für deine Vorschau ab sofort HIER auf diesen
// Wrapper und NICHT mehr oben auf den "AuswertungFragebogenScreen".

class AuswertungPreviewWrapper extends StatelessWidget {
  @Preview(
      name: "Auswertung Screen",
      textScaleFactor: 1.0,
      brightness: Brightness.light)
  const AuswertungPreviewWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuswertungFragebogenScreen(),
      ),
    );
  }
}