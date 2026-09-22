# RLSApp – Patientenapp für Restless Legs Syndrom

Eine mobile App für RLS-Patienten zur Erfassung von Symptomen,
Fragebögen und Tagebucheinträgen. Entwickelt mit Flutter (Frontend)
und Django (Backend), mit FHIR-konformer Datenspeicherung.

---

## Projektstruktur

```
RLSApp/
├── patient_app/            # Django Backend
│   └── api/                # REST API (Views, Models, Serializers)
├── arzt_app/               # Django Backend (Arzt-Seite, in Entwicklung)
├── flutterapp/             # Flutter App
│   └── lib/
│       ├── application/    # Riverpod Provider
│       ├── data/           # Repositories (API-Calls)
│       ├── domain/         # Datenmodelle
│       ├── screens/        # UI-Screens
│       ├── services/       # JWT, Notifications
│       └── dio_setup.dart
├── mockup_patient/         # UI-Mockup Patienten (TypeScript)
├── mockup_arzt/            # UI-Mockup Arzt (TypeScript)
└── FHIR_ressourcen_anlage/ # Skripte zum Einspeichern von FHIR-Ressourcen
```

## Tech-Stack

| Bereich | Technologie |
|---|---|
| Mobile Frontend | Flutter / Dart |
| State Management | Riverpod |
| HTTP Client | Dio |
| Backend | Django + Django REST Framework |
| Authentifizierung | JWT (djangorestframework-simplejwt) |
| Medizinische Daten | FHIR (Firely Server) |
| Lokale Datenbank | SQLite3 (gemeinsam für patient_app und arzt_app) |
| Sichere Tokenspeicherung | Flutter Secure Storage |

---

## Voraussetzungen

- Python 3.9+
- Flutter SDK 3.x+
- Android Studio oder VS Code
- Zugang zum Firely FHIR-Server (intern)

---

## Setup Backend

```bash
# 1. Virtuelle Umgebung erstellen
py -3 -m venv .venv

# 2. Aktivieren
# Windows:
.venv\Scripts\activate
# Mac/Linux:
source .venv/bin/activate

# 3. Abhängigkeiten installieren
pip install -r requirements.txt

# 4. Datenbank migrieren
cd patient_app
python manage.py migrate

# 5. Server starten
python manage.py runserver
```

---

## Setup Flutter App

```bash
cd flutterapp

# Abhängigkeiten laden
flutter pub get

# App starten (Emulator oder Gerät)
flutter run
```

---

## Architektur (Flutter)

Das Projekt folgt einer geschichteten Architektur:
domain/ → Datenmodelle (was ist ein Objekt?)
data/ → Repositories (API-Calls, Datenbankzugriff)
application/ → Riverpod Provider (verbindet Daten und UI)
screens/ → UI (was sieht der Nutzer?)


Beispiel für den Datenfluss:

Screen → ref.watch(provider) → Provider → Repository → Django API → FHIR Server


---

## API-Endpunkte (Patient)

| Methode | URL | Beschreibung |
|---|---|---|
| POST | `/api/token/` | Login, gibt JWT zurück |
| POST | `/api/register/` | Neuen Patienten registrieren |
| GET | `/api/rls/questionnaire/{id}` | Fragebogen laden |
| POST | `/api/rls/response/` | Fragebogen-Antwort speichern |
| GET | `/api/rls/diagramm/{id}` | Auswertungsdaten laden |
| GET | `/api/rls/getresponse/{date}` | Fragebogen-Antworten eines Tages |
| GET | `/api/rls/gettagebuchresponse/{date}` | Tagebucheinträge eines Tages |
| GET | `/api/rls/profil/` | Patientenprofil laden |
| POST | `/api/rls/patient/` | FHIR Patient-Ressource anlegen |
| POST | `/api/rls/change-password/` | Passwort ändern |

---

## Fragebogen-IDs

| ID | Fragebogen |
|---|---|
| `f1` | IRLSS (International RLS Study Group Rating Scale) |
| `f2` | RLS Quality of Life |
| `tschlaf` | Tagebuch – Schlaf |
| `ternaehrung` | Tagebuch – Ernährung |
| `twohlbefinden` | Tagebuch – Wohlbefinden |
| `tsport` | Tagebuch – Aktivität |

---

## Hinweise

- `verify=False` bei Django HTTP-Requests ist nur für den
  Testbetrieb (selbst-signiertes SSL-Zertifikat).
  Vor Produktivbetrieb durch gültiges Zertifikat ersetzen.
- Die Arzt-App (`arzt_app/`) ist noch in Entwicklung.
- Sensordaten-Integration ist noch nicht implementiert.
