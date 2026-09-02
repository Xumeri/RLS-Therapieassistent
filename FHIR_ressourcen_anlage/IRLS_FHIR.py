import json
from fhir.resources.questionnaire import Questionnaire

json_obj = {
  "resourceType" : "Questionnaire",
  "id" : "f1",
  "url" : "https://www.med.upenn.edu/cbti/assets/user-content/documents/International%20Restless%20Legs%20Syndrome%20Study%20Group%20Rating%20Scale.pdf",
  "status" : "active",
  "subjectType" : ["Patient"],
  "title" : "International RLS Rating Scale",
  "date" : "2025",
  "purpose" : "fragebogen",
  "item" : [{
    "linkId" : "0.1",
    "text" : "Score",
    "type" : "integer",
    "extension": [
        {
          "url": "http://hl7.org/fhir/StructureDefinition/maxValue",
          "valueInteger": 40
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
            "text" : "Wie stark würden Sie die RLS-Beschwerden in Ihren Armen oder Beinen einschätzen?",
            "type": "choice",
            "required": True,
            "answerOption": [
                        {"valueString": "0Nicht vorhanden"},
                        {"valueString": "1Leicht"},
                        {"valueString": "2Mäßig"},
                        {"valueString": "3Ziemlich"},
                        {"valueString": "4Sehr"}
            ]
          },
          {
            "linkId" : "1.2",
            "text" : "Wie stark würden Sie Ihren Drang einschätzen, sich wegen Ihrer RLS-Beschwerden bewegen zu müssen?",
            "type": "choice",
            "required": True,
            "answerOption": [
                        {"valueString": "0Nicht vorhanden"},
                        {"valueString": "1Leicht"},
                        {"valueString": "2Mäßig"},
                        {"valueString": "3Ziemlich"},
                        {"valueString": "4Sehr"}
            ]
          },
          {
            "linkId" : "1.3",
            "text" : "Wie sehr wurden die RLS-Beschwerden in Ihren Armen und Beinen durch Bewegung gelindert?",
            "type": "choice",
            "required": True,
            "answerOption": [
                        {"valueString": "0Keine RLS-Beschwerden"},
                        {"valueString": "1(fast) vollständig"},
                        {"valueString": "2Mäßig"},
                        {"valueString": "3Wenig"},
                        {"valueString": "4Überhaupt nicht"}
            ]
          },
            {
            "linkId" : "1.4",
            "text" : "Wie sehr wurde Ihr Schalf durch Ihre RLS-Beschwerden gestört?",
            "type": "choice",
            "required": True,
            "answerOption": [
                        {"valueString": "0Überhaupt nicht"},
                        {"valueString": "1Leicht"},
                        {"valueString": "2Mäßig"},
                        {"valueString": "3Ziemlich"},
                        {"valueString": "4Sehr"}
            ]
          },
          {
            "linkId" : "1.5",
            "text" : "Wie müde oder schläfrig waren Sie tagsüber wegen Ihrer RLS-Beschwerden?",
            "type": "choice",
            "required": True,
            "answerOption": [
                        {"valueString": "0Überhaupt nicht"},
                        {"valueString": "1Leicht"},
                        {"valueString": "2Mäßig"},
                        {"valueString": "3Ziemlich"},
                        {"valueString": "4Sehr"}
            ]
          },
          {
            "linkId" : "1.6",
            "text" : "Wie stark waren Ihre RLS-Beschwerden insgesamt?",
            "type": "choice",
            "required": True,
            "answerOption": [
                        {"valueString": "0Nicht vorhanden"},
                        {"valueString": "1Leicht"},
                        {"valueString": "2Mäßig"},
                        {"valueString": "3Ziemlich"},
                        {"valueString": "4Sehr"}
            ]
          },
          {
            "linkId" : "1.7",
            "text" : "Wie oft sind Ihre RLS-Beschwerden aufgetreten?",
            "type": "choice",
            "required": True,
            "answerOption": [
                        {"valueString": "0Überhaupt nicht"},
                        {"valueString": "1Selten (1 Tag/Woche)"},
                        {"valueString": "2Manchmal (2-3 Tage/Woche)"},
                        {"valueString": "3Oft (4-5 Tage/Woche)"},
                        {"valueString": "4Sehr oft (6-7 Tage/Woche)"}
            ]
          },
          {
            "linkId" : "1.8",
            "text" : "Wenn Sie RLS-Beschwerden hatten, wie stark waren diese durchschnittlich?",
            "type": "choice",
            "required": True,
            "answerOption": [
                        {"valueString": "0Nicht vorhanden"},
                        {"valueString": "1Leicht (<1 h/Tag)"},
                        {"valueString": "2Mäßig (1-3 h/Tag)"},
                        {"valueString": "3Ziemlich (3-8 h/Tag)"},
                        {"valueString": "4Sehr (>8 h/Tag)"}
            ]
          },
            {
            "linkId" : "1.9",
            "text" : "Wie sehr haben sich Ihre RLS-Beschwerden auf Ihre Fähigkeiten ausgewirkt, Ihren Alltagstätigkeiten nachzugehen, z.B. ein zufriedenstellendes Familien-, Privat-, Schul- oder Arbeitsleben zu führen?",
            "type": "choice",
            "required": True,
            "answerOption": [
                        {"valueString": "0Überhaupt nicht"},
                        {"valueString": "1Leicht"},
                        {"valueString": "2Mäßig"},
                        {"valueString": "3Ziemlich"},
                        {"valueString": "4Sehr"}
            ]
          },
            {
            "linkId" : "1.10",
            "text" : "Wie stark haben Ihre RLS-Beschwerden Ihre Stimmung beeinträchtigt, waren Sie z.B. wütend, niedergeschlagen, traurig, ängstlich oder gereizt?",
            "type": "choice",
            "required": True,
            "answerOption": [
                        {"valueString": "0Überhaupt nicht"},
                        {"valueString": "1Leicht"},
                        {"valueString": "2Mäßig"},
                        {"valueString": "3Ziemlich"},
                        {"valueString": "4Sehr"}
            ]
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

response = requests.get(server_url + "/Questionnaire/" + "f1", verify=False)

print("Status: " + str(response.status_code))
print(response.content)