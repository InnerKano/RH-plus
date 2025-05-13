from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    ContractViewSet, PayrollPeriodViewSet, PayrollItemViewSet,
    PayrollEntryViewSet, PayrollEntryDetailViewSet
)

router = DefaultRouter()
router.register(r'contracts', ContractViewSet, basename='contract')
router.register(r'periods', PayrollPeriodViewSet, basename='payroll-period')
router.register(r'items', PayrollItemViewSet, basename='payroll-item')
router.register(r'entries', PayrollEntryViewSet, basename='payroll-entry')
router.register(r'entry-details', PayrollEntryDetailViewSet, basename='payroll-entry-detail')

urlpatterns = [
    path('', include(router.urls)),
]
