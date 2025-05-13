from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    EvaluationTypeViewSet, EvaluationCriteriaViewSet, EvaluationPeriodViewSet,
    EvaluationViewSet, EvaluationDetailViewSet, ImprovementPlanViewSet, ImprovementGoalViewSet
)

router = DefaultRouter()
router.register(r'types', EvaluationTypeViewSet, basename='evaluation-type')
router.register(r'criteria', EvaluationCriteriaViewSet, basename='evaluation-criteria')
router.register(r'periods', EvaluationPeriodViewSet, basename='evaluation-period')
router.register(r'evaluations', EvaluationViewSet, basename='evaluation')
router.register(r'details', EvaluationDetailViewSet, basename='evaluation-detail')
router.register(r'plans', ImprovementPlanViewSet, basename='improvement-plan')
router.register(r'goals', ImprovementGoalViewSet, basename='improvement-goal')

urlpatterns = [
    path('', include(router.urls)),
]
