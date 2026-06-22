import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/evaluation_repository.dart';
import '../domain/data_point.dart';



//SCREEN: Tabs + KPI-Zeile oben

class AuswertungTagebuchScreen extends StatelessWidget {
  const AuswertungTagebuchScreen({super.key});


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
                title: const Text('Tagebuchdaten im Überblick'),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Schlaf'),
                    Tab(text: 'Ernährung'),
                    Tab(text: 'Wohlbefinden'),
                    Tab(text: 'Aktivität'),
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
              EvaluationTab(title: 'Schlaf', fragebogenId: 'tschlaf'),
              EvaluationTab(title: 'Ernährung', fragebogenId: 'ternaehrung'),
              EvaluationTab(title: 'Wohlbefinden', fragebogenId: 'twohlbefinden'),
              EvaluationTab(title: 'Aktivität', fragebogenId: 'tsport'),
            ],
          ),
        ),
      ),
    );
  }
}

//KPI-ROW: lädt Daten und zeigt Durchschnitt
class KpiRow extends ConsumerWidget {
  const KpiRow({super.key});



  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final repo = ref.read(evaluationRepositoryProvider);

    return FutureBuilder<Map<String, String>>(
      future: repo.loadKpis(),
      builder: (context, snapshot) {
        // Laden
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Fehler
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('KPI Fehler: ${snapshot.error}'),
          );
        }

        // Werte anzeigen
        final data = snapshot.data ?? {};
        final sleepText = data['sleep'] ?? '—';
        final nutritionText = data['nutrition'] ?? '—';
        final wellbeingText = data['wellbeing'] ?? '—';
        final sportText = data['sport'] ?? '—';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Container(
                child: GridView.count(
                  shrinkWrap: true,  //Reihe mit den Karten darf nur so hoch sein wie ihr Inhalt
                  crossAxisCount: 4,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  children: [
                    KpiCard(title: 'Schlaf', value: sleepText, icon: Icons.nights_stay_rounded),
                    KpiCard(title: 'Ernährung', value: nutritionText, icon: Icons.restaurant),
                    KpiCard(title: 'Wohlbefinden', value: wellbeingText, icon: Icons.favorite_outline_sharp),
                    KpiCard(title: 'Aktivität', value: sportText, icon: Icons.directions_run),
                  ],
                ),
              ),
              Text("(Durchschnitts-Scores der letzten 7 Tage)",)
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
  final IconData icon;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
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
            Icon(icon, size: 22),
            const SizedBox(height: 4),
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

//TAB: lädt Daten für bestimmte Kategorie und zeigt Liniendiagramm und Liste (Datum + Interpretation + Score)
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
    final repo = ref.read(evaluationRepositoryProvider);
    return FutureBuilder<List<DiagrammPunkt>>(
      future: repo.fetchData(fragebogenId),
      builder: (context, snapshot) {
        // Laden
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        // Fehler
        if (snapshot.hasError) {
          return Center(child: Text('Fehler: ${snapshot.error}'));
        }

        // Keine Daten
        final points = snapshot.data ?? [];
        if (points.isEmpty) {
          return const Center(child: Text('Keine Daten vorhanden.'));
        }

        // Y-Achse im Diagramm: 0..maxScore
        final maxScore = points.first.maxScore;

        // Sortierung nach Datum
        points.sort((a, b) => a.datetime.compareTo(b.datetime));

        final dailyPoints = aggrDailyAverage(points);
        // Startdatum fürs Diagramm (erstes Tagesdatum)
        final start = DateTime(
          dailyPoints.first.datetime.year,
          dailyPoints.first.datetime.month,
          dailyPoints.first.datetime.day,
        );
        // Spots: X = Tage seit Start, Y = Tagesdurchschnitt
        final spots = dailyPoints.map((p) {
          final d = DateTime(p.datetime.year, p.datetime.month, p.datetime.day);
          final x = d.difference(start).inDays.toDouble();
          return FlSpot(x, p.score);
        }).toList();

        // Für Achse: minX/maxX setzen
        final minX = spots.first.x;
        final maxX = spots.last.x;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // ----------------- Diagramm Erstellung -----------------------------------------------------
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
                    leftTitles: AxisTitles(    // zeigt auf der y-Achse alle Scorewerte (1-6) an
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 32,
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
                  lineTouchData: LineTouchData(           // Einstellungen wenn der Nutzer einen Punkt auf dem Diagramm anklickt....
                    touchTooltipData: LineTouchTooltipData(
                      maxContentWidth: 100,
                      tooltipBgColor: Theme.of(context).colorScheme.inversePrimary,  //Zeigt ein Feld mit hellgrünem Hintergrund
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          return LineTooltipItem(                          // Test des Felds ist "Score: [Scorewert]"
                            'Score: ${touchedSpot.y.toStringAsFixed(2)}',
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
            const Text('Antwortverlauf',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Liste unter dem Diagramm:
            ...points.reversed.map((p) {   // geht Diagrammpunkte so herum durch dass der neueste in der Liste oben steht
              final d = p.datetime;
              final dateText =
                  '${d.day.toString().padLeft(2, '0')}.'
                  '${d.month.toString().padLeft(2, '0')}.'
                  '${d.year}';

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
