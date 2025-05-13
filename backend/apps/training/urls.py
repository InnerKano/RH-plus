from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    TrainingTypeViewSet, TrainingProgramViewSet, TrainingSessionViewSet,
    TrainingAttendanceViewSet, TrainingEvaluationViewSet
)

router = DefaultRouter()
router.register(r'types', TrainingTypeViewSet, basename='training-type')
router.register(r'programs', TrainingProgramViewSet, basename='training-program')
router.register(r'sessions', TrainingSessionViewSet, basename='training-session')
router.register(r'attendances', TrainingAttendanceViewSet, basename='training-attendance')
router.register(r'evaluations', TrainingEvaluationViewSet, basename='training-evaluation')

urlpatterns = [
    path('', include(router.urls)),
]
