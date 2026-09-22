import requests
from config import SERVER_URL
server_url = SERVER_URL


fhir_practitioner = {
        "resourceType": "Practitioner",
        "id": "678964456",
        "name" : [{
            "use": "official",
            "family" : "Scholz",
            "given" : ["Noah"],
            "prefix" : ["Dr"]
        }],
}

response = requests.put(
        server_url + "/Practitioner/" + fhir_practitioner["id"], 
        json=fhir_practitioner,
        verify=False) #verifizierung deaktiviert da wir ein selbst signiertes zertifikat verwenden
