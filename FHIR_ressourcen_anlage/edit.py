# Vorlage für das Bearbeiten von FHIR Ressourcen

import requests
import json
from config import SERVER_URL

server_url = SERVER_URL
id = "p000000014"

# Ressource vom Server holen
response = requests.get(
    server_url + "/Patient/" + id, 
    verify=False  #deaktiviert Zertifikat-Verifikation -> funktioniert für Self Signed Zertifikate
  )

patient_data = response.json()

# Ressource bearbeiten
patient_data ["generalPractitioner"] = {
        "reference" : "Practitioner/" + "678964456",
    }

# bearbeitete Ressource speichern
response = requests.put(
    server_url + "/Patient/" + id, 
    json = patient_data,
    verify=False  #deaktiviert Zertifikat-Verifikation -> funktioniert für Self Signed Zertifikate
)
