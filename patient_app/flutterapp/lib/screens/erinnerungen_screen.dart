import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ReminderType { medikament, arzttermin, rezept, fragebogen }            // Typen der Erinnerungen 
enum ReminderFrequency { taeglich, woechentlich, alle4wochen, einmalig }    // Wie oft die Erinnerung wiederholt werden soll

class Reminder {    // Datenmodell für eine Erinnerung
  Reminder({
    required this.type,
    required this.title,
    required this.time,
    this.date,
    required this.frequency,
  });

  final ReminderType type;  // Kategorie der Erinnerung (Medikament/Termin/...)
  final String title; // Titel, der in der Liste angezeigt wird
  final TimeOfDay time; // Uhrzeit
  final DateTime? date; // Optionales Datum (z. B. für Arzttermin/Einmalig)
  final ReminderFrequency frequency; // Wiederholungslogik
  

  Map<String, dynamic> toJson() => {      // Umwandlung in JSON-Map, damit es als String gespeichert werden kann
        'type': type.index,
        'title': title,
        'timeHour': time.hour,
        'timeMinute': time.minute,
        'dateMillis': date?.millisecondsSinceEpoch,
        'frequency': frequency.index,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) {    // Baut ein Reminder-Objekt aus einer JSON-Map wieder zusammen (fürs Laden aus dem Speicher)
    return Reminder(
      type: ReminderType.values[json['type'] as int],
      title: json['title'] as String,
      time: TimeOfDay(
        hour: json['timeHour'] as int,
        minute: json['timeMinute'] as int,
      ),
      date: (json['dateMillis'] == null)
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json['dateMillis'] as int),
      frequency: ReminderFrequency.values[json['frequency'] as int],
    );
  }
}

class ErinnerungenScreen extends StatefulWidget {
  const ErinnerungenScreen({super.key});

  @override
  State<ErinnerungenScreen> createState() => _ErinnerungenScreenState();
}

class _ErinnerungenScreenState extends State<ErinnerungenScreen>
    with AutomaticKeepAliveClientMixin {
  static const _storageKey = 'rls_reminders_v1';

  @override
  bool get wantKeepAlive => true;

  final List<Reminder> _reminders = [];   // In-Memory Liste der Erinnerungen 

  @override
  void initState() {
    super.initState();
    _loadReminders();           // Beim Start werden gespeicherte Erinnerungen aus SharedPreferences laden
  }

  Future<void> _loadReminders() async {    // Erinnerungen aus SharedPreferences laden
    final prefs = await SharedPreferences.getInstance();      // Zugriff auf lokalen Speicher
    final list = prefs.getStringList(_storageKey);            // Liste von JSON-Strings holen

    if (list == null) return;

    final loaded = list
        .map((s) => Reminder.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();

    setState(() {             // State aktualisieren -> UI wird neu gebaut
      _reminders
        ..clear()
        ..addAll(loaded);
    });
  }

  Future<void> _saveReminders() async {     // Erinnerungen in SharedPreferences speichern
    final prefs = await SharedPreferences.getInstance();
    final list = _reminders.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_storageKey, list);
  }

  bool _dateIsRequired(ReminderType type, ReminderFrequency freq) {     // Entscheidet, ob ein Datum zwingend ist
    return type == ReminderType.arzttermin || freq == ReminderFrequency.einmalig;
  }

  String _typeToText(ReminderType type) {
    switch (type) {
      case ReminderType.medikament:
        return 'Medikament';
      case ReminderType.arzttermin:
        return 'Arzttermin';
      case ReminderType.rezept:
        return 'Rezept';
      case ReminderType.fragebogen:
        return 'Fragebogen';
    }
  }

  String _frequencyToText(ReminderFrequency f) {
    switch (f) {
      case ReminderFrequency.taeglich:
        return 'Täglich';
      case ReminderFrequency.woechentlich:
        return 'Wöchentlich';
      case ReminderFrequency.alle4wochen:
        return 'Alle 4 Wochen';
      case ReminderFrequency.einmalig:
        return 'Einmalig';
    }
  }

  String _formatTime(TimeOfDay t) =>            // Uhrzeit im Format HH:MM Uhr darstellen
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} Uhr';

  String? _formatDate(DateTime? d) {            // Datum im Format TT.MM.JJJJ darstellen
    if (d == null) return null;
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year}';
  }

  Future<void> _showAddReminderDialog() async {   //Dialog zum Hinzufügen einer neuen Erinnerung
    final formKey = GlobalKey<FormState>();

    ReminderType selectedType = ReminderType.medikament;
    ReminderFrequency selectedFrequency = ReminderFrequency.taeglich;
    final titleController = TextEditingController();

    TimeOfDay? selectedTime;
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(     //erlaubt setDialogState() nur im Dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Neue Erinnerung'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<ReminderType>(      // Auswahl der Art der Erinnerung
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Art der Erinnerung',
                        ),
                        items: ReminderType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_typeToText(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => selectedType = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(                   // Titel-Eingabe (Pflichtfeld)
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Titel',
                          hintText: 'z. B. Medikamentenname oder Termin',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Bitte einen Titel eingeben';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      InkWell(     // Uhrzeit auswählen
                        onTap: () async {
                          final now = TimeOfDay.now();
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? now,
                          );
                          if (picked != null) {
                            setDialogState(() => selectedTime = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Uhrzeit'),
                          child: Text(
                            selectedTime == null
                                ? 'Zeit wählen'
                                : _formatTime(selectedTime!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      InkWell(   // Datum auswählen optional oder erforderlich, je nach Auswahl
                        onTap: () async {
                          final today = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: today,
                            lastDate: DateTime(today.year + 5),
                            initialDate: selectedDate ?? today,
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: _dateIsRequired(selectedType, selectedFrequency)
                                ? 'Datum (erforderlich)'
                                : 'Datum (optional)',
                          ),
                          child: Text(
                            selectedDate == null
                                ? 'Datum wählen'
                                : _formatDate(selectedDate!)!,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<ReminderFrequency>(   // Häufigkeit auswählen (täglich/wöchentlich/...)
                        initialValue: selectedFrequency,
                        decoration: const InputDecoration(labelText: 'Häufigkeit'),
                        items: ReminderFrequency.values.map((freq) {
                          return DropdownMenuItem(
                            value: freq,
                            child: Text(_frequencyToText(freq)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => selectedFrequency = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(                     // Dialog abbrechen
                  child: const Text('Abbrechen'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(                   // Erinnerung anlegen + speichern
                  child: const Text('Erinnerung hinzufügen'),
                  onPressed: () async {                       // Titel validieren
                    if (!formKey.currentState!.validate()) return;

                    if (selectedTime == null) {    //Uhrzeit muss gesetzt sein
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte eine Uhrzeit wählen')),
                      );
                      return;
                    }

                    if (_dateIsRequired(selectedType, selectedFrequency) &&       //Datum, wenn erforderlich ist
                        selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bitte ein Datum wählen')),
                      );
                      return;
                    }

                    final newReminder = Reminder(                       // Neues Reminder Objekt aus den Dialog Eingaben erstellen
                      type: selectedType,
                      title: titleController.text.trim(),
                      time: selectedTime!,
                      date: selectedDate,
                      frequency: selectedFrequency,
                    );

                    setState(() => _reminders.add(newReminder));      // Reminder zur Liste hinzufügen und direkt speichern 
                    await _saveReminders(); 
                    if(!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); 
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Erinnerungen'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Neu'),
              onPressed: _showAddReminderDialog,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _reminders.isEmpty
            ? const Center(child: Text('Noch keine Erinnerungen'))
            : ListView.separated(
                itemCount: _reminders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final r = _reminders[index];
                  final dateText = _formatDate(r.date);

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(    // einfache Icon-Logik
                          r.type == ReminderType.medikament 
                              ? Icons.medication
                              : Icons.calendar_today,
                        ),
                      ),
                      title: Text(r.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_typeToText(r.type)),      // Typ anzeigen
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(_formatTime(r.time)),    // Uhrzeit
                              if (dateText != null) ...[
                                const SizedBox(width: 12),
                                Text('•  $dateText'),   // Datum 
                              ],
                              const SizedBox(width: 12),
                              Text('•  ${_frequencyToText(r.frequency)}'),        // Häufigkeit
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          setState(() => _reminders.removeAt(index));        // Löschen aus Liste + direkt speichern
                          await _saveReminders(); 
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }}
