from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    EmployeeViewSet, AffiliationTypeViewSet, ProviderViewSet, AffiliationViewSet
)

router = DefaultRouter()
router.register(r'employees', EmployeeViewSet, basename='employee')
router.register(r'affiliation-types', AffiliationTypeViewSet, basename='affiliation-type')
router.register(r'providers', ProviderViewSet, basename='provider')
router.register(r'affiliations', AffiliationViewSet, basename='affiliation')

urlpatterns = [
    path('', include(router.urls)),
]
