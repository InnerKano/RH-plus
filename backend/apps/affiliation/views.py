from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Employee, AffiliationType, Provider, Affiliation
from .serializers import (
    EmployeeSerializer, AffiliationTypeSerializer, 
    ProviderSerializer, AffiliationSerializer
)
from .repositories import EmployeeRepository, AffiliationRepository
from apps.core.utils import record_activity

class EmployeeViewSet(viewsets.ModelViewSet):
    """ViewSet for the Employee model."""
    serializer_class = EmployeeSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return EmployeeRepository.get_active_employees()
        
    def perform_create(self, serializer):
        """Register a system activity when an employee is created."""
        employee = serializer.save()
        record_activity(
            title="Nuevo empleado registrado",
            description=f"Se ha registrado al empleado {employee.first_name} {employee.last_name} con ID {employee.id}",
            activity_type="employee",
            user=self.request.user
        )
        
    def perform_update(self, serializer):
        """Register a system activity when an employee is updated."""
        employee = serializer.save()
        record_activity(
            title="Información de empleado actualizada",
            description=f"Se ha actualizado la información del empleado {employee.first_name} {employee.last_name}",
            activity_type="employee",
            user=self.request.user
        )
    
    @action(detail=False, methods=['get'])
    def by_document(self, request):
        """Return employee by document number."""
        document = request.query_params.get('document')
        
        if not document:
            return Response({"error": "Document number is required"}, status=400)
        
        employee = EmployeeRepository.get_by_document(document)
        if not employee:
            return Response({"error": "Employee not found"}, status=404)
        
        serializer = self.get_serializer(employee)
        return Response(serializer.data)

class AffiliationTypeViewSet(viewsets.ModelViewSet):
    """ViewSet for the AffiliationType model."""
    queryset = AffiliationType.objects.all()
    serializer_class = AffiliationTypeSerializer
    permission_classes = [permissions.IsAuthenticated]

class ProviderViewSet(viewsets.ModelViewSet):
    """ViewSet for the Provider model."""
    queryset = Provider.objects.filter(is_active=True)
    serializer_class = ProviderSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    @action(detail=False, methods=['get'])
    def by_type(self, request):
        """Return providers by affiliation type."""
        affiliation_type = request.query_params.get('type')
        
        if not affiliation_type:
            return Response({"error": "Affiliation type is required"}, status=400)
        
        providers = Provider.objects.filter(
            affiliation_type_id=affiliation_type,
            is_active=True
        )
        
        serializer = self.get_serializer(providers, many=True)
        return Response(serializer.data)

class AffiliationViewSet(viewsets.ModelViewSet):
    """ViewSet for the Affiliation model."""
    serializer_class = AffiliationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return AffiliationRepository.get_active_affiliations()
    
    @action(detail=False, methods=['get'])
    def by_employee(self, request):
        """Return affiliations by employee."""
        employee_id = request.query_params.get('employee')
        
        if not employee_id:
            return Response({"error": "Employee ID is required"}, status=400)
        
        affiliations = AffiliationRepository.get_by_employee(employee_id)
        
        serializer = self.get_serializer(affiliations, many=True)
        return Response(serializer.data)
