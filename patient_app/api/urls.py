from django.urls import path
from .views import get_questionnaire, get_tagebuch_response, get_patient, post_response, get_questionnaire_response, post_patient, get_diagrammdaten
from .views import RegisterView, CustomTokenObtainPairView, change_password
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path("rls/questionnaire/<str:id>", get_questionnaire),
    path("rls/getresponse/<str:date>", get_questionnaire_response),
    path("rls/gettagebuchresponse/<str:date>", get_tagebuch_response),
    path("rls/diagramm/<str:id>", get_diagrammdaten),
    path("rls/response/", post_response),
    path("rls/patient/", post_patient),
    path("rls/profil/", get_patient),
    path('register/', RegisterView.as_view(), name='register'),
    path('token/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('rls/change-password', change_password)
]