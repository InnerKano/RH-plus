from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    SelectionStageViewSet, CandidateViewSet, SelectionProcessViewSet,
    ProcessCandidateViewSet, CandidateDocumentViewSet
)

router = DefaultRouter()
router.register(r'stages', SelectionStageViewSet, basename='selection-stage')
router.register(r'candidates', CandidateViewSet, basename='candidate')
router.register(r'processes', SelectionProcessViewSet, basename='selection-process')
router.register(r'process-candidates', ProcessCandidateViewSet, basename='process-candidate')
router.register(r'documents', CandidateDocumentViewSet, basename='candidate-document')

urlpatterns = [
    path('', include(router.urls)),
]
