from datetime import datetime, time, timedelta
from urllib.parse import quote
from zoneinfo import ZoneInfo
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view, permission_classes
import json
import requests
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.views import TokenObtainPairView

from portal.fhir_client import _headers
from .models import CustomPatientUser
from .serializers import UserRegisterSerializer, CustomTokenObtainPairSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import generics, permissions
from rest_framework.permissions import IsAuthenticated
from django.conf import settings

#----------- Klassen für User Authentifizierung --------------------------------------------------------------

# Code für die Authentifizierungs-Views übernommen von
# https://medium.com/@onurmaciit/mastering-jwt-authentication-in-django-rest-framework-best-practices-and-techniques-d47f906f530a

User = get_user_model()

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserRegisterSerializer
    permission_classes = [permissions.AllowAny]

class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

#---------------------Password Änderung------------------------------------------------------------------------
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    user = request.user
    old_password = request.data.get('old_password')
    new_password = request.data.get('new_password')

    if not user.check_password(old_password):
        return JsonResponse({'error': 'Aktuelles Password ist falsch'}, status=400)

    user.set_password(new_password)
    user.save()
    return JsonResponse({'message':'Password erfolgreich geändert'}, status=200)



#----------- Sonstige Views -----------------------------------------------------------------------------------

server_url = "http://localhost:8080/fhir"


#GET questionnaire
@api_view(['GET'])  #Decorator. Macht aus Funktion get_questionnaire eine API view, bei der nur GET requests möglich sind
@permission_classes([IsAuthenticated]) #API kann nur verwendet werden, wenn User authentifiziert ist
def get_questionnaire(request, id):
    print(request.user.username)
    print(request.user.patient_id) #gibt username und ID von dem Patienten zurück der die APi verwendet
    response = requests.get(server_url + "/Questionnaire/" + id, verify=False)  #holt Fragebogen im JSON Format vom FHIR Server
    rls_questionnaire=response.json()  #macht aus JSON ein Python Objekt (hier: ein Dictionary)
    return JsonResponse(rls_questionnaire)


#POST: Empfängt Patientendaten von Flutter Registrierung
@api_view(['POST'])  #Decorator. Macht aus Funktion post_patient eine API view, bei der nur POST requests möglich sind
def post_patient(request):
    patient_data = request.data
    user = CustomPatientUser.objects.get(username=patient_data["username"])  #Holt User mit dem jeweiligen Usernamen von dem CustomPatientUser Model
    user_patient_id = user.patient_id #lässt patient_id für diesen User berechnen

    # erstellt eine Fhir Patient Ressource mit der berechneten User ID + den vom Frontend empfangenen (bei der Registrierung eingegebenen) Daten
    fhir_patient = {
        "resourceType": "Patient",
        "id": user_patient_id,
        "name": [
            {
                "use": "official",
                "family": patient_data["nachname"],
                "given": [patient_data["vorname"]]
            }
        ],
        "birthDate": patient_data["geburtsdatum"]
    }

    #Verwendung von PUT um den Patienten genau an seine ID zu kriegen: https://stackoverflow.com/questions/107390/whats-the-difference-between-a-post-and-a-put-http-request
    response = requests.put(
        server_url + "/Patient/" + user_patient_id, 
        json=fhir_patient,
        verify=False) #verifizierung deaktiviert da wir ein selbst signiertes zertifikat verwenden

    print(response.content)

    return JsonResponse({
        "valid": True,
        "message": "Patient empfangen",
    })


#GET Patient
@api_view(['GET'])  #Decorator. Macht aus Funktion get_patient eine API view, bei der nur GET requests möglich sind
@permission_classes([IsAuthenticated]) #API kann nur verwendet werden wenn User authentifiziert ist
def get_patient(request):
    # holt die Daten des angelemeldeten Patienten vom FHIR Server
    response = requests.get(
        server_url + "/Patient/" + request.user.patient_id, 
        verify=False) #verifizierung deaktiviert, da wir ein selbst signiertes zertifikat verwenden

    patient_data = response.json()

    dictionary = {       #erstellt ein neues Dictionary das Vorname, Nachname und Geburtsdatum des Patienten enthält
        "vorname" : patient_data["name"][0]["given"][0],
        "nachname" : patient_data["name"][0]["family"],
        "geburtsdatum" : patient_data["birthDate"],
    }

    # gibt das Dictionary als JsonResponse zurück
    return JsonResponse(dictionary)



#POST: Empfängt Fragebogen- und Tagebuch-Antworten aus Flutter
@api_view(['POST'])  #Decorator. Macht aus Funktion rls_response eine API view, bei der nur POST requests möglich sind
@permission_classes([IsAuthenticated]) #API kann nur verwendet werden wenn User authentifiziert ist
def post_response(request):
    print(request.user.username)
    print(request.user.patient_id) #prints username + patient ID of anyone who uses the API View

    questionnaire_response = request.data

    #Score hinzufügen
    score = 0
    #Berechnung des Scores:
    for item in questionnaire_response["item"][2]["item"]:
        itemvalue = item["answer"][0]["valueString"][0]  #itemvalue = erste Stelle ([0]) von der gewählten Antwortmöglichkeit (valueString)
        score = score + int(itemvalue)   #castet itemvalue in Typ String und addiert den Wert zu score

    #Für RLSQol Fragebogen: Score mit 5 multiplizieren um auf Skala zwischen 0 bis 100 zu kommen
    if questionnaire_response["questionnaire"] == "f2":
        score = score * 5


    # Score an questionnaire_response dictionary anfügen:
    questionnaire_response["item"][0] = {
        "linkId": "0.1",
        "answer": [
            {"valueInteger": score}
        ]
    }

    # Score Interpretation an questionnaire_response dictionary anfügen:
    questionnaire_id = questionnaire_response["questionnaire"] # speichert ID des Fragebogens; diese steht (noch) bei questionnaire_response["questionnaire"] drin
    questionnaire_response["item"][1] = {
        "linkId": "0.2",
        "answer": [
            {"valueString": interpret_score(questionnaire_id, score)} # lässt die Interpretation des Scores bestimmten und fügt sie an das dictionary an
        ]
    }

    # Fügt bei "questionnaire" statt der ID des Fragebogens den Link zum Fragebogen auf dem Server ein (weil FHIR hier die canonical URL möchte)
    questionnaire_response["questionnaire"] = server_url + "/Questionnaire/" + questionnaire_id


    # fügt Patient (mit id) als Quelle der Antworten hinzu
    questionnaire_response["source"] = {
        "reference" : "Patient/" + request.user.patient_id,
    }

    # hängt Patienten ID ans Ende der QuestionnaireResponse ID an
    questionnaire_response["id"] = questionnaire_response["id"] + request.user.patient_id


    print(questionnaire_response) #druckt Fragebogen Antwort ins Terminal aus

    #Verwendung von PUT um den Fragebogen genau an seine ID zu kriegen: https://stackoverflow.com/questions/107390/whats-the-difference-between-a-post-and-a-put-http-request
    response = requests.put(
        server_url + "/QuestionnaireResponse/" + questionnaire_response["id"], 
        json=questionnaire_response,
        verify=False) #verifizierung deaktiviert da wir eine selbst signiertes zertifikat verwenden

    print(response.content)
    
    return JsonResponse({
        "valid": True,
        "message": "Antwort akzeptiert",
        "score" : score,
        "interpretation" : interpret_score(questionnaire_id, score)
    })

# GET Fragebogen-Antwort
@api_view(['GET'])  #Decorator
@permission_classes([IsAuthenticated]) #API kann nur verwendet werden wenn User authentifiziert ist
def get_questionnaire_response(request, date):  #Funktion alle RLS QuestionnaireResponses von einem bestimmten Tag zurückgibt
    
    responses_list = [] #erstellt eine leere Liste

    #Datum für FHIR Link vorbereiten:
    #wandelt date (String) in datetime um
    local_day = datetime.strptime(date, "%Y-%m-%d").date()

    #bestimmt Tagesanfang und -ende in lokaler Zeit
    start_local = datetime.combine(local_day, time.min, tzinfo=ZoneInfo("Europe/Berlin"))
    end_local = start_local + timedelta(days=1)

    #konvertiert Tagesanfang und -ende in ISO String (mit offset + millisekunden) (so wie "authored" auf FHIR gespeichert ist)
    start_iso = start_local.isoformat(timespec='milliseconds')
    end_iso = end_local.isoformat(timespec='milliseconds')

    #encodiert die ISO String um sie in URLS verwenden zu können (mach aus + bei offset %2B)
    start_iso = quote(start_iso)
    end_iso = quote(end_iso)

    # Request mit Tagesanfang und -ende im FHIR Link senden:    
    responses = requests.get(
        server_url 
        + "/QuestionnaireResponse/?authored=ge" + start_iso + "&authored=lt" + end_iso
        + "&source=Patient/" + request.user.patient_id,
        verify=False).json()  #holt alle Questionnaire_Responses vom gesuchten Tag vom gesuchten Patient (dem der die request gemacht hat) im JSON Format vom FHIR Server + macht daraus ein Python Dictionary

    if "entry" in responses:
        for r in responses["entry"]:
            questionnaire = requests.get(r["resource"]["questionnaire"], verify=False).json()
            if questionnaire["purpose"] == "fragebogen":  # gibt nur Fragebögen zurück, keine Tagebucheinträge
                question_list = []
                dictionary = {
                    "responseid" : r["resource"]["id"],
                    "questionnaireid" : questionnaire["id"],
                    "date" : r["resource"]["authored"],
                    "questionnairetitle" : questionnaire["title"],
                    "numberofquestions" : len(questionnaire["item"][2]["item"]),
                    "score" : r["resource"]["item"][0]["answer"][0]["valueInteger"],
                    "maxscore" : questionnaire["item"][0]["extension"][0]["valueInteger"],
                    "interpretation" : r["resource"]["item"][1]["answer"][0]["valueString"],

                }
                for n in range(dictionary["numberofquestions"]):
                    question_list.append({
                        "question" : questionnaire["item"][2]["item"][n]["text"],
                        "answer" : r["resource"]["item"][2]["item"][n]["answer"][0]["valueString"]
                    })
                dictionary["questions"] = question_list
                responses_list.append(dictionary)
    return JsonResponse(responses_list, safe=False)  #safe=False allows non-dict objects to be serialized


# GET Tagebuch-Antwort
@api_view(['GET'])  #Decorator
@permission_classes([IsAuthenticated]) #API kann nur verwendet werden wenn User authentifiziert ist
def get_tagebuch_response(request, date):  #Funktion die alle RLS TagebuchResponses von einem bestimmten Tag (in der Zeitzone Europe/Berlin, mit aktuellem Offset) zurückgibt
        
    responses_list = [] #erstellt eine leere Liste

    #Datum für FHIR Link vorbereiten:
    #wandelt date (String) in datetime um
    local_day = datetime.strptime(date, "%Y-%m-%d").date()

    #bestimmt Tagesanfang und -ende in lokaler Zeit
    start_local = datetime.combine(local_day, time.min, tzinfo=ZoneInfo("Europe/Berlin"))
    end_local = start_local + timedelta(days=1)

    #konvertiert Tagesanfang und -ende in ISO String (mit offset + millisekunden) (so wie "authored" auf FHIR gespeichert ist)
    start_iso = start_local.isoformat(timespec='milliseconds')
    end_iso = end_local.isoformat(timespec='milliseconds')

    #encodiert die ISO String um sie in URLS verwenden zu können (mach aus + bei offset %2B)
    start_iso = quote(start_iso)
    end_iso = quote(end_iso)

    # Request mit Tagesanfang und -ende im FHIR Link senden:    
    responses = requests.get(
        server_url 
        + "/QuestionnaireResponse/?authored=ge" + start_iso + "&authored=lt" + end_iso
        + "&source=Patient/" + request.user.patient_id,
        verify=False).json()  #holt alle Questionnaire_Responses vom gesuchten Tag vom gesuchten Patient (dem der die request gemacht hat) im JSON Format vom FHIR Server + macht daraus ein Python Dictionary

    if "entry" in responses:
        for r in responses["entry"]:
            questionnaire = requests.get(r["resource"]["questionnaire"], verify=False).json()
            if questionnaire["purpose"] == "tagebuch":  # gibt nur Tagebucheinträge zurück, keine Fragebogen-Antworten
                question_list = []
                dictionary = {
                    "responseid" : r["resource"]["id"],
                    "questionnaireid" : questionnaire["id"],
                    "date" : r["resource"]["authored"],
                    "questionnairetitle" : questionnaire["title"],
                    "numberofquestions" : len(questionnaire["item"][2]["item"]),
                    "score" : r["resource"]["item"][0]["answer"][0]["valueInteger"],
                    "maxscore" : questionnaire["item"][0]["extension"][0]["valueInteger"],
                    "interpretation" : r["resource"]["item"][1]["answer"][0]["valueString"],
                    "publicentry" : r["resource"]["item"][3]["item"][0]["text"],
                    "privateentry" : r["resource"]["item"][3]["item"][1]["text"]

                }
                for n in range(dictionary["numberofquestions"]):
                    question_list.append({
                        "question" : questionnaire["item"][2]["item"][n]["text"],
                        "answer" : r["resource"]["item"][2]["item"][n]["answer"][0]["valueString"]
                    })
                dictionary["questions"] = question_list
                responses_list.append(dictionary)
    return JsonResponse(responses_list, safe=False)  #safe=False allows non-dict objects to be serialized


# GET Daten für Auswertungs-Liniendiagramm
@api_view(['GET'])  #Decorator
@permission_classes([IsAuthenticated]) #API kann nur verwendet werden wenn User authentifiziert ist
def get_diagrammdaten(request, id):  #Funktion die alle Responses für einen einzelnen Fragebogen zurückgibt
    
    responses_list = [] #erstellt eine leere Liste

    responses = requests.get(
        server_url 
        + "/QuestionnaireResponse/"
        + "?source=Patient/" + request.user.patient_id
        + "&_count=1000", 
        verify=False).json()  #holt die letzten 1000 (oder weniger) Questionnaire_Responses vom gesuchten Patient (dem der die request gemacht hat) im JSON Format vom FHIR Server + macht daraus ein Python Dictionary

    questionnaire = requests.get(   #holt gewünschten Fragebogens vom Server
        server_url + "/Questionnaire/" + id, 
        verify=False).json()
    
    maxscore = questionnaire["item"][0]["extension"][0]["valueInteger"] # speichert den maxscore des Fragebogens

    if "entry" in responses:
        for r in responses["entry"]: # durchläuft alle Einträge in dem QuestionnaireResponse Bundle
            if "questionnaire" in r["resource"]:
                if r["resource"]["questionnaire"] == server_url + "/Questionnaire/" + id: # für alle Fragebogen des gewünschten Typs (mit der gegebenen ID)...
                    
                    dictionary = {  # erstellt ein dictionary mit datum, score, max_score und interpretation
                        "date" : r["resource"]["authored"],
                        "score" : r["resource"]["item"][0]["answer"][0]["valueInteger"],
                        "maxscore" : maxscore,
                        "interpretation" : r["resource"]["item"][1]["answer"][0]["valueString"],
                    }
                    
                    responses_list.append(dictionary) # hängt das Dicstionary an die Liste an

    return JsonResponse(responses_list, safe=False)  #safe=False allows non-dict objects to be serialized




#------------ Methode für Score Interpretation -----------------------------------------------------------------------------------

def interpret_score(questionnaire_id, score): #Methode für Interpreatation der Fragebogen scores
    if questionnaire_id == "f1":  # für den IRLS Fragebogen....
        if score <= 10:
            return "milde RLS-Symptomatik"  # score kleiner gleich 10 -> mild
        if 11 <= score <= 20:
            return "moderate RLS-Symptomatik" # score zwischen 11 und 20 -> moderat
        if 21 <= score <= 30:
            return "schwere RLS-Symptomatik" # score zwischen 21 und 30 -> schwer
        if score > 30:
            return "sehr schwere RLS-Symptomatik" # score über 30 -> sehr schwer
        
    if questionnaire_id == "f2":  # für den RLSQol Fragebogen....
        if score <= 25:
            return "sehr eingeschränkte Lebensqualität"  # score kleiner gleich 25 -> sehr einschränkte Qol
        if 26 <= score <= 50:
            return "eingeschränkte Lebensqualität" # score zwischen 26 und 50 -> eingeschränkte Qol
        if 51 <= score <= 75:
            return "mäßig gute Lebensqualität" # score zwischen 51 und 75 -> mäßig gute Qol
        if score > 75:
            return "gute Lebensqualität" # score über 75 -> gute Qol
    
    if questionnaire_id == "twohlbefinden": # Interpretation / Feedback-Texte für die Wohlbefinden Fragen....
        if score <= 2:
            return "Ihr Wohlbefinden war niedrig. Kleine Pausen und bewusste Entspannung können helfen"
        if 3 <= score <= 4 :
            return "Ihr Wohlbefinden war ausgeglichen. Mit etwas mehr Entspannung ist noch Verbesserung möglich"
        if score > 4:
            return "Ihr Wohlbefinden war sehr gut. Machen Sie weiter so!"
        
    if questionnaire_id == "tsport": # Interpretation / Feedback-Texte für die Sport Fragen....
        if score <= 2:
            return "Wenig oder ungünstige Bewegung. Schon leichte Aktivität kann hilfreich sein"
        if 3 <= score <= 4 :
            return "Ihre Aktivität war in Ordnung. Regelmäßigkeit könnte den Effekt steigern"
        if score > 4:
            return "Sehr gute Aktivität! Das unterstützt Körper und Schlaf"
        
    if questionnaire_id == "ternaehrung": # Interpretation / Feedback-Texte für die Ernährungs Fragen.....
        if score <= 2:
            return "Ihre Ernährung war eher nährstoffarm. Kleine Anpassungen können helfen"
        if 3 <= score <= 4 :
            return "Ihr Ernährung war teilweise ausgewogen. Es ist noch Luft nach oben"
        if score > 4:
            return "Sehr gute, nährstoffreiche Ernährung. Das wirkt sich positiv aus!"
        
    if questionnaire_id == "tschlaf": # Interpretation / Feedback-Texte für die Schlaf Fragen....
        if score <= 2:
            return "Ihr Schlaf war eingeschränkt. Kleine Änderungen am Abend können helfen"
        if 3 <= score <= 4 :
            return "Ihr Schlaf war durchschnittlich. Mit Routinen lässt er sich verbessern"
        if score > 4:
            return "Ihr Schlaf war heute erholsam. Eine gute Grundlage für ihr Wohlbefinden"

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_account(request):

    r = None

    id = request.user.patient_id

    #Antworten löschen
    response= requests.delete(server_url+ "/QuestionnaireResponse/"+"?source=Patient/" + id, verify=False)


    #Patient löschen, wenn Antworten gelöscht sind
    if 200 <= response.status_code < 300:

        url = server_url + '/Patient/' + id

        r = requests.delete(url)
    #Wenn alles erfolgreicht gelöscht
    if (200 <= response.status_code < 300) and (r is not None and (200<=r.status_code<300)) :

        request.user.delete()

        return JsonResponse({
            "valid": True,
            "message": "Account vollständig gelöscht",
            "data_status": response.status_code,
            "patient_status": r.status_code,

        })
    #Wenn Fragebögen nicht gelöscht werden konnten
    if response.status_code >=300:
        return JsonResponse({
            "Object":"Questionnaires",
            "StatusCode": response.status_code,
            "message": "Server oder Client Fehler  beim löschen der Antworten",
        })
    #Wenn Account nicht gelöscht werden konnte
    else:
        return JsonResponse({
            "Object":"Account",
            "StatusCode": response.status_code,
            "message": "Server oder Client Fehler  beim löschen des Accounts",
        })