import json
from fhir.resources.questionnaire import Questionnaire
from config import SERVER_URL

json_obj = {
  "resourceType" : "Questionnaire",
  "id" : "ternaehrung",
  "status" : "active",
  "subjectType" : ["Patient"],
  "title" : "Ernährung Fragebogen",
  "date" : "2025",
  "purpose" : "tagebuch",
  "item" : [{
    "linkId" : "0.1",
    "text" : "Score",
    "type" : "integer",
    "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/maxValue",
          "valueInteger": 6
        }
      ]
    },
    {
        "linkId" : "0.2",
        "text" : "Score Interpretation",
        "type": "string",
    },
    {
    "linkId" : "1",
    "text" : "Fragebogen Fragen",
    "type" : "group",
    "item" : [{
        "linkId" : "1.1",
        "text" : "Eisen-/nährstoffreich gegessen? (Fleisch, Fisch, Hülsenfrüchte, grünes Gemüse)",
        "type": "choice",
        "answerOption": [
                    {"valueString": "0Nein"},
                    {"valueString": "1Wenig"},
                    {"valueString": "2Ja"}
        ]
      },
      {
        "linkId" : "1.2",
        "text" : "Haben sie heute magnesiumreich gegessen? (Nüsse, Samen, Vollkorn, Hülsenfrüchte)",
        "type": "choice",
        "answerOption": [
                    {"valueString": "0Nein"},
                    {"valueString": "1Wenig"},
                    {"valueString": "2Ja"}
        ]
      },
      {
        "linkId" : "1.3",
        "text" : "Wie waren Ihre RLS-Symptome heute im Vergleich zu sonst?",
        "type": "choice",
        "answerOption": [
                    {"valueString": "0Schlechter"},
                    {"valueString": "1Wie üblich"},
                    {"valueString": "2Besser"}
        ]
      }]
    },
    {
    "linkId" : "2",
    "text" : "Tagebucheinträge",
    "type" : "group",
    "item" : [{
        "linkId" : "2.1",
        "text" : "öffentlich",
        "type": "text",
      },
      {
        "linkId" : "2.2",
        "text" : "privat",
        "type": "text",
      }]
    }
    ]
}


quest = Questionnaire(**json_obj)   #macht aus json_obj eine Questionnaire Ressource



import requests
server_url = SERVER_URL

quest_object = quest.model_dump() 

#Verwendung von PUT um den Fragebogen genau an seine ID zu kriegen: https://stackoverflow.com/questions/107390/whats-the-difference-between-a-post-and-a-put-http-request
response = requests.put(
    server_url + "/Questionnaire/" + json_obj["id"], 
    json=quest_object,
    verify=False  #deaktiviert Zertifikat-Verifikation -> funktioniert für Self Signed Zertifikate
  )

print("Status:" + str(response.status_code))
print(response.content)