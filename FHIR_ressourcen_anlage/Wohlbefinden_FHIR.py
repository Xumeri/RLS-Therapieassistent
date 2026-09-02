import json
from fhir.resources.questionnaire import Questionnaire

json_obj = {
  "resourceType" : "Questionnaire",
  "id" : "twohlbefinden",
  "status" : "active",
  "subjectType" : ["Patient"],
  "title" : "Wohlbefinden Fragebogen",
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
        "text" : "Wie würden Sie ihre Stimmung heute bewerten?",
        "type": "choice",
        "answerOption": [
                    {"valueString": "0Nicht Gut"},
                    {"valueString": "1Normal"},
                    {"valueString": "2Sehr Gut"}
        ]
      },
      {
        "linkId" : "1.2",
        "text" : "Wie war Ihr Stressniveau heute?",
        "type": "choice",
        "answerOption": [
                    {"valueString": "0Stark"},
                    {"valueString": "1Mittel"},
                    {"valueString": "2Gut"}
        ]
      },
      {
        "linkId" : "1.3",
        "text" : "Hatten Sie heute Zeit sich zu entspannen (z.B. durch Yoga, Meditation, Atemübungen, etc.)?",
        "type": "choice",
        "answerOption": [
                    {"valueString": "0Nein"},
                    {"valueString": "1Ein bisschen"},
                    {"valueString": "2Ja"}
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
from config import SERVER_URL
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