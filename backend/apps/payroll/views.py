from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Contract, PayrollPeriod, PayrollItem, PayrollEntry, PayrollEntryDetail
from .serializers import (
    ContractSerializer, PayrollPeriodSerializer, PayrollItemSerializer,
    PayrollEntrySerializer, PayrollEntryDetailSerializer
)
from .repositories import (
    ContractRepository, PayrollPeriodRepository, 
    PayrollEntryRepository, PayrollItemRepository
)
from django.utils import timezone

class ContractViewSet(viewsets.ModelViewSet):
    """ViewSet for Contract model."""
    serializer_class = ContractSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return ContractRepository.get_active_contracts()
    
    @action(detail=False, methods=['get'])
    def by_employee(self, request):
        """Return contracts for a specific employee."""
        employee_id = request.query_params.get('employee')
        
        if not employee_id:
            return Response({"error": "Employee ID is required"}, status=400)
        
        contracts = ContractRepository.get_by_employee(employee_id)
        
        serializer = self.get_serializer(contracts, many=True)
        return Response(serializer.data)

class PayrollPeriodViewSet(viewsets.ModelViewSet):
    """ViewSet for PayrollPeriod model."""
    queryset = PayrollPeriod.objects.all()
    serializer_class = PayrollPeriodSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    @action(detail=False, methods=['get'])
    def open(self, request):
        """Return open payroll periods."""
        periods = PayrollPeriodRepository.get_open_periods()
        
        serializer = self.get_serializer(periods, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def close(self, request, pk=None):
        """Close a payroll period."""
        period = self.get_object()
        
        if period.is_closed:
            return Response({"error": "Period is already closed"}, status=400)
        
        period.is_closed = True
        period.closed_by = request.user
        period.closed_at = timezone.now()
        period.save()
        
        serializer = self.get_serializer(period)
        return Response(serializer.data)

class PayrollItemViewSet(viewsets.ModelViewSet):
    """ViewSet for PayrollItem model."""
    serializer_class = PayrollItemSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return PayrollItemRepository.get_active_items()
    
    @action(detail=False, methods=['get'])
    def by_type(self, request):
        """Return payroll items by type."""
        item_type = request.query_params.get('type')
        
        if not item_type:
            return Response({"error": "Item type is required"}, status=400)
        
        items = PayrollItemRepository.get_by_type(item_type)
        
        serializer = self.get_serializer(items, many=True)
        return Response(serializer.data)

class PayrollEntryViewSet(viewsets.ModelViewSet):
    """ViewSet for PayrollEntry model."""
    serializer_class = PayrollEntrySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return PayrollEntry.objects.all()
    
    @action(detail=False, methods=['get'])
    def by_period(self, request):
        """Return payroll entries by period."""
        period_id = request.query_params.get('period')
        
        if not period_id:
            return Response({"error": "Period ID is required"}, status=400)
        
        entries = PayrollEntryRepository.get_by_period(period_id)
        
        serializer = self.get_serializer(entries, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def by_employee(self, request):
        """Return payroll entries by employee."""
        employee_id = request.query_params.get('employee')
        
        if not employee_id:
            return Response({"error": "Employee ID is required"}, status=400)
        
        entries = PayrollEntryRepository.get_by_employee(employee_id)
        
        serializer = self.get_serializer(entries, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        """Approve a payroll entry."""
        entry = self.get_object()
        
        if entry.is_approved:
            return Response({"error": "Entry is already approved"}, status=400)
        
        entry.is_approved = True
        entry.approved_by = request.user
        entry.approved_at = timezone.now()
        entry.save()
        
        serializer = self.get_serializer(entry)
        return Response(serializer.data)

class PayrollEntryDetailViewSet(viewsets.ModelViewSet):
    """ViewSet for PayrollEntryDetail model."""
    queryset = PayrollEntryDetail.objects.all()
    serializer_class = PayrollEntryDetailSerializer
    permission_classes = [permissions.IsAuthenticated]
