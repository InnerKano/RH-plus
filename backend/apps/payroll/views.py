import logging
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from django.db import transaction
from django.db.models import Sum, Count, Q, Min, Max, Avg
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from .models import Contract, PayrollPeriod, PayrollItem, PayrollEntry, PayrollEntryDetail
from .serializers import (
    ContractSerializer, PayrollPeriodSerializer, PayrollItemSerializer,
    PayrollEntrySerializer, PayrollEntryDetailSerializer, PayrollEntryCreateSerializer
)
from .repositories import (
    ContractRepository, PayrollPeriodRepository, 
    PayrollEntryRepository, PayrollItemRepository
)
from apps.core.utils import record_activity

# Configure logger for payroll module
logger = logging.getLogger('apps.payroll')

class ContractViewSet(viewsets.ModelViewSet):
    """ViewSet for Contract model."""
    serializer_class = ContractSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        logger.info(f"Getting active contracts - User: {self.request.user}")
        return ContractRepository.get_active_contracts()
    
    def create(self, request, *args, **kwargs):
        logger.info(f"Creating new contract - User: {request.user}, Data: {request.data}")
        try:
            response = super().create(request, *args, **kwargs)
            logger.info(f"Contract created successfully - ID: {response.data.get('id')}")
            
            # Record activity
            record_activity(
                title="Creación de contrato",
                description=f"Se ha creado un nuevo contrato para el empleado",
                activity_type="payroll",
                user=request.user            )
            
            return response
        except Exception as e:
            logger.error(f"Error creating contract - User: {request.user}, Error: {str(e)}")
            return Response(
                {"error": "Error al crear el contrato", "details": str(e)},                status=status.HTTP_400_BAD_REQUEST
            )
    
    @swagger_auto_schema(
        operation_description="Get contracts for a specific employee",
        manual_parameters=[
            openapi.Parameter(
                'employee',
                openapi.IN_QUERY,
                description="Employee ID to filter contracts",
                type=openapi.TYPE_INTEGER,
                required=True
            )
        ],
        responses={
            200: openapi.Response(
                description="List of contracts for the employee",
                examples={
                    "application/json": [
                        {
                            "id": 7,
                            "employee": 1,
                            "employee_name": "Juan Pérez (EMP000)",
                            "contract_type": "FULL_TIME",
                            "department": "Sales",
                            "position": "Sales Representative",
                            "salary": "1952937.00",
                            "start_date": "2025-01-01",
                            "end_date": None,
                            "is_active": True
                        }
                    ]
                }
            ),
            400: openapi.Response(description="Employee ID is required"),
            401: openapi.Response(description="Unauthorized")
        },
        tags=['Contracts']
    )
    @action(detail=False, methods=['get'])
    def by_employee(self, request):
        """Return contracts for a specific employee."""
        employee_id = request.query_params.get('employee')
        logger.info(f"Getting contracts for employee {employee_id} - User: {request.user}")
        
        if not employee_id:
            logger.warning("Employee ID not provided for contract lookup")
            return Response({"error": "Employee ID is required"}, status=400)
        
        try:
            contracts = ContractRepository.get_by_employee(employee_id)
            logger.info(f"Found {contracts.count()} contracts for employee {employee_id}")
            
            serializer = self.get_serializer(contracts, many=True)
            return Response(serializer.data)
        except Exception as e:
            logger.error(f"Error getting contracts for employee {employee_id}: {str(e)}")
            return Response(
                {"error": "Error al obtener contratos del empleado"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['get'])
    def debug_info(self, request):
        """Get debug information about payroll system."""
        logger.info(f"Getting debug info - User: {request.user}")
        
        try:
            info = {
                'total_contracts': Contract.objects.count(),
                'active_contracts': Contract.objects.filter(is_active=True).count(),
                'contracts_by_type': dict(
                    Contract.objects.values('contract_type').annotate(count=Count('id'))
                    .values_list('contract_type', 'count')
                ),
                'contracts_by_department': dict(
                    Contract.objects.values('department').annotate(count=Count('id'))
                    .values_list('department', 'count')
                ),
                'average_salary': Contract.objects.aggregate(avg=Avg('salary'))['avg'],
                'salary_range': {
                    'min': Contract.objects.aggregate(min=Min('salary'))['min'],
                    'max': Contract.objects.aggregate(max=Max('salary'))['max']                }
            }
            
            return Response(info)
            
        except Exception as e:
            logger.error(f"Error getting debug info: {str(e)}")
            return Response(
                {"error": "Error al obtener información de debug"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class PayrollPeriodViewSet(viewsets.ModelViewSet):
    """ViewSet for PayrollPeriod model."""
    queryset = PayrollPeriod.objects.all()
    serializer_class = PayrollPeriodSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def create(self, request, *args, **kwargs):
        logger.info(f"Creating new payroll period - User: {request.user}, Data: {request.data}")
        try:
            response = super().create(request, *args, **kwargs)
            logger.info(f"Payroll period created successfully - ID: {response.data.get('id')}")
            
            # Record activity
            record_activity(
                title="Creación de período de nómina",
                description=f"Se ha creado un nuevo período de nómina: {response.data.get('name')}",
                activity_type="payroll",
                user=request.user
            )
            
            return response
        except Exception as e:
            logger.error(f"Error creating payroll period - User: {request.user}, Error: {str(e)}")
            return Response(
                {"error": "Error al crear el período de nómina", "details": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=['get'])
    def open(self, request):
        """Return open payroll periods."""
        logger.info(f"Getting open payroll periods - User: {request.user}")
        try:
            periods = PayrollPeriodRepository.get_open_periods()
            logger.info(f"Found {periods.count()} open periods")
            
            serializer = self.get_serializer(periods, many=True)
            return Response(serializer.data)
        except Exception as e:
            logger.error(f"Error getting open periods: {str(e)}")
            return Response(
                {"error": "Error al obtener períodos abiertos"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        
    @action(detail=True, methods=['post'])
    def close(self, request, pk=None):
        """Close a payroll period."""
        logger.info(f"Attempting to close payroll period {pk} - User: {request.user}")
        try:
            period = self.get_object()
            
            if period.is_closed:
                logger.warning(f"Period {pk} is already closed")
                return Response({"error": "Period is already closed"}, status=400)
            
            period.is_closed = True
            period.closed_by = request.user
            period.closed_at = timezone.now()
            period.save()
            
            logger.info(f"Period {pk} closed successfully")
            
            # Record the activity
            record_activity(
                title="Cierre de período de nómina",
                description=f"Se ha cerrado el período de nómina '{period.name}' con fecha {period.end_date}",
                activity_type="payroll",
                user=request.user
            )
            
            serializer = self.get_serializer(period)
            return Response(serializer.data)
        except Exception as e:
            logger.error(f"Error closing period {pk}: {str(e)}")
            return Response(
                {"error": "Error al cerrar el período", "details": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class PayrollItemViewSet(viewsets.ModelViewSet):
    """ViewSet for PayrollItem model."""
    serializer_class = PayrollItemSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        logger.info(f"Getting active payroll items - User: {self.request.user}")
        return PayrollItemRepository.get_active_items()
    
    def create(self, request, *args, **kwargs):
        logger.info(f"Creating new payroll item - User: {request.user}, Data: {request.data}")
        try:
            response = super().create(request, *args, **kwargs)
            logger.info(f"Payroll item created successfully - ID: {response.data.get('id')}")
            
            # Record activity
            record_activity(
                title="Creación de concepto de nómina",
                description=f"Se ha creado un nuevo concepto: {response.data.get('name')}",
                activity_type="payroll",
                user=request.user
            )
            
            return response
        except Exception as e:
            logger.error(f"Error creating payroll item - User: {request.user}, Error: {str(e)}")
            return Response(
                {"error": "Error al crear el concepto de nómina", "details": str(e)},                status=status.HTTP_400_BAD_REQUEST
            )

    @swagger_auto_schema(
        operation_description="Get payroll items filtered by type (EARNING or DEDUCTION)",
        manual_parameters=[
            openapi.Parameter(
                'type',
                openapi.IN_QUERY,
                description="Type of payroll item: EARNING or DEDUCTION",
                type=openapi.TYPE_STRING,
                enum=['EARNING', 'DEDUCTION'],
                required=True
            )
        ],
        responses={
            200: openapi.Response(
                description="List of payroll items by type",
                examples={
                    "application/json": [
                        {
                            "id": 22,
                            "name": "Salario Básico",
                            "code": "SAL_BAS",
                            "item_type": "EARNING",
                            "is_active": True,
                            "default_amount": "0.00",
                            "is_percentage": False
                        },
                        {
                            "id": 23,
                            "name": "Horas Extra",
                            "code": "HRS_EXT",
                            "item_type": "EARNING", 
                            "is_active": True,
                            "default_amount": "0.00",
                            "is_percentage": False
                        }
                    ]
                }
            ),
            400: openapi.Response(description="Item type is required"),
            401: openapi.Response(description="Unauthorized")
        },
        tags=['Payroll Items']
    )
    @action(detail=False, methods=['get'])
    def by_type(self, request):
        """Return payroll items by type."""
        item_type = request.query_params.get('type')
        logger.info(f"Getting payroll items by type: {item_type} - User: {request.user}")
        
        if not item_type:
            logger.warning("Item type not provided for payroll items lookup")
            return Response({"error": "Item type is required"}, status=400)
        
        try:
            items = PayrollItemRepository.get_by_type(item_type)
            logger.info(f"Found {items.count()} items of type {item_type}")
            
            serializer = self.get_serializer(items, many=True)
            return Response(serializer.data)
        except Exception as e:
            logger.error(f"Error getting items by type {item_type}: {str(e)}")
            return Response(
                {"error": "Error al obtener conceptos por tipo"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class PayrollEntryViewSet(viewsets.ModelViewSet):
    """ViewSet for PayrollEntry model."""
    serializer_class = PayrollEntrySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        logger.info(f"Getting payroll entries - User: {self.request.user}")
        return PayrollEntry.objects.all()
    
    def get_serializer_class(self):
        """Return appropriate serializer class based on action."""
        if self.action == 'create':
            return PayrollEntryCreateSerializer
        return PayrollEntrySerializer
    
    @swagger_auto_schema(
        operation_description="Create a new payroll entry with earnings and deductions",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['employee', 'contract', 'period', 'base_salary', 'details'],
            properties={
                'employee': openapi.Schema(type=openapi.TYPE_INTEGER, description='Employee ID'),
                'contract': openapi.Schema(type=openapi.TYPE_INTEGER, description='Contract ID'),
                'period': openapi.Schema(type=openapi.TYPE_INTEGER, description='Payroll period ID'),
                'base_salary': openapi.Schema(type=openapi.TYPE_STRING, description='Base salary as decimal string'),
                'details': openapi.Schema(
                    type=openapi.TYPE_ARRAY,
                    items=openapi.Schema(
                        type=openapi.TYPE_OBJECT,
                        properties={
                            'item_type': openapi.Schema(
                                type=openapi.TYPE_STRING, 
                                enum=['earnings', 'deductions'],
                                description='Type of payroll item'
                            ),
                            'payroll_item': openapi.Schema(type=openapi.TYPE_INTEGER, description='PayrollItem ID'),
                            'amount': openapi.Schema(type=openapi.TYPE_STRING, description='Amount as decimal string')
                        }
                    ),
                    description='List of payroll entry details'
                )
            },
            example={
                "employee": 7,
                "contract": 8,
                "period": 11,
                "base_salary": "1952937.00",
                "details": [
                    {
                        "item_type": "earnings",
                        "payroll_item": 22,
                        "amount": "1952937.00"
                    },
                    {
                        "item_type": "earnings",
                        "payroll_item": 23,
                        "amount": "100000.00"
                    },
                    {
                        "item_type": "deductions",
                        "payroll_item": 27,
                        "amount": "78117.48"
                    },
                    {
                        "item_type": "deductions",
                        "payroll_item": 28,
                        "amount": "78117.48"
                    }
                ]
            }
        ),
        responses={
            201: openapi.Response(
                description="Payroll entry created successfully",
                examples={
                    "application/json": {
                        "id": 11,
                        "employee_name": "Juan Pérez (EMP000)",
                        "base_salary": "1952937.00",
                        "total_earnings": "2052937.00",
                        "total_deductions": "156234.96",
                        "net_pay": "1896702.04",
                        "is_approved": False,
                        "contract": 8,
                        "period": 11,
                        "details": [
                            {
                                "id": 26,
                                "amount": "1952937.00",
                                "quantity": "1.00",
                                "payroll_item": 22
                            },
                            {
                                "id": 27,
                                "amount": "100000.00",
                                "quantity": "1.00",
                                "payroll_item": 23
                            }
                        ]
                    }
                }
            ),
            400: openapi.Response(description="Bad request - validation errors"),
            401: openapi.Response(description="Unauthorized")
        },
        tags=['Payroll Entries']
    )
    def create(self, request, *args, **kwargs):
        logger.info(f"Creating new payroll entry - User: {request.user}, Data: {request.data}")
        try:
            response = super().create(request, *args, **kwargs)
            logger.info(f"Payroll entry created successfully - ID: {response.data.get('id')}")
            
            # Record activity
            record_activity(
                title="Creación de entrada de nómina",
                description=f"Se ha creado una nueva entrada de nómina",
                activity_type="payroll",
                user=request.user
            )
            
            return response
        except Exception as e:
            logger.error(f"Error creating payroll entry - User: {request.user}, Error: {str(e)}")
            return Response(
                {"error": "Error al crear la entrada de nómina", "details": str(e)},                status=status.HTTP_400_BAD_REQUEST
            )
    
    @swagger_auto_schema(
        operation_description="Get payroll entries filtered by period",
        manual_parameters=[
            openapi.Parameter(
                'period',
                openapi.IN_QUERY,
                description="Payroll period ID to filter entries",
                type=openapi.TYPE_INTEGER,
                required=True
            )
        ],
        responses={
            200: openapi.Response(
                description="List of payroll entries for the specified period",
                examples={
                    "application/json": [
                        {
                            "id": 11,
                            "employee": 1,
                            "employee_name": "Juan Pérez (EMP000)",
                            "contract": 7,
                            "period": 11,
                            "period_name": "June 2025",
                            "base_salary": "1952937.00",
                            "total_earnings": "2052937.00",
                            "total_deductions": "156234.96",
                            "net_pay": "1896702.04",
                            "is_approved": True,
                            "approved_by_name": "testadmin@rhplus.com"
                        }
                    ]
                }
            ),
            400: openapi.Response(description="Period ID is required"),
            401: openapi.Response(description="Unauthorized")
        },
        tags=['Payroll Entries']
    )
    @action(detail=False, methods=['get'])
    def by_period(self, request):
        """Return payroll entries by period."""
        period_id = request.query_params.get('period')
        logger.info(f"Getting payroll entries for period {period_id} - User: {request.user}")
        
        if not period_id:
            logger.warning("Period ID not provided for payroll entries lookup")
            return Response({"error": "Period ID is required"}, status=400)
        
        try:
            entries = PayrollEntryRepository.get_by_period(period_id)
            logger.info(f"Found {entries.count()} entries for period {period_id}")
            
            serializer = self.get_serializer(entries, many=True)
            return Response(serializer.data)
        except Exception as e:
            logger.error(f"Error getting entries for period {period_id}: {str(e)}")
            return Response(
                {"error": "Error al obtener entradas del período"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['get'])
    def by_employee(self, request):
        """Return payroll entries by employee."""
        employee_id = request.query_params.get('employee')
        logger.info(f"Getting payroll entries for employee {employee_id} - User: {request.user}")
        
        if not employee_id:
            logger.warning("Employee ID not provided for payroll entries lookup")
            return Response({"error": "Employee ID is required"}, status=400)
        
        try:
            entries = PayrollEntryRepository.get_by_employee(employee_id)
            logger.info(f"Found {entries.count()} entries for employee {employee_id}")
            
            serializer = self.get_serializer(entries, many=True)
            return Response(serializer.data)
        except Exception as e:
            logger.error(f"Error getting entries for employee {employee_id}: {str(e)}")
            return Response(
                {"error": "Error al obtener entradas del empleado"},                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @swagger_auto_schema(
        operation_description="Approve a payroll entry",
        responses={
            200: openapi.Response(
                description="Payroll entry approved successfully",
                examples={
                    "application/json": {
                        "id": 11,
                        "is_approved": True,
                        "approved_by_name": "testadmin@rhplus.com",
                        "approved_at": "2025-05-30T12:17:50.258931-05:00",
                        "employee_name": "Juan Pérez (EMP000)",
                        "net_pay": "1896702.04"
                    }
                }
            ),
            404: openapi.Response(description="Payroll entry not found"),
            400: openapi.Response(description="Entry already approved or other validation error"),
            401: openapi.Response(description="Unauthorized")
        },
        tags=['Payroll Entries']
    )
    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        """Approve a payroll entry."""
        logger.info(f"Attempting to approve payroll entry {pk} - User: {request.user}")
        try:
            entry = self.get_object()
            
            if entry.is_approved:
                logger.warning(f"Entry {pk} is already approved")
                return Response({"error": "Entry is already approved"}, status=400)
            
            entry.is_approved = True
            entry.approved_by = request.user
            entry.approved_at = timezone.now()
            entry.save()
            
            logger.info(f"Entry {pk} approved successfully")
            
            # Record activity
            record_activity(
                title="Aprobación de entrada de nómina",
                description=f"Se ha aprobado una entrada de nómina",
                activity_type="payroll",
                user=request.user
            )
            
            serializer = self.get_serializer(entry)
            return Response(serializer.data)
        except Exception as e:
            logger.error(f"Error approving entry {pk}: {str(e)}")
            return Response(
                {"error": "Error al aprobar la entrada", "details": str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['get'])
    def debug_info(self, request):
        """Get debug information about payroll entries."""
        logger.info(f"Getting payroll entries debug info - User: {request.user}")
        
        try:
            info = {
                'total_entries': PayrollEntry.objects.count(),
                'approved_entries': PayrollEntry.objects.filter(is_approved=True).count(),
                'pending_entries': PayrollEntry.objects.filter(is_approved=False).count(),
                'entries_by_period': dict(
                    PayrollEntry.objects.values('period__name').annotate(count=Count('id'))
                    .values_list('period__name', 'count')
                ),
                'total_net_pay': PayrollEntry.objects.aggregate(total=Sum('net_pay'))['total'],
                'average_net_pay': PayrollEntry.objects.aggregate(avg=Avg('net_pay'))['avg'],
            }
            
            return Response(info)
            
        except Exception as e:
            logger.error(f"Error getting payroll entries debug info: {str(e)}")
            return Response(
                {"error": "Error al obtener información de debug"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def get_serializer_class(self):
        """Return the appropriate serializer class based on action."""
        if self.action == 'create':
            return PayrollEntryCreateSerializer
        return PayrollEntrySerializer

class PayrollEntryDetailViewSet(viewsets.ModelViewSet):
    """ViewSet for PayrollEntryDetail model."""
    serializer_class = PayrollEntryDetailSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        logger.info(f"Getting payroll entry details - User: {self.request.user}")
        # Filter by payroll entry if provided
        entry_id = self.request.query_params.get('entry')
        if entry_id:
            return PayrollEntryDetail.objects.filter(payroll_entry_id=entry_id)
        return PayrollEntryDetail.objects.all()
    
    def create(self, request, *args, **kwargs):
        logger.info(f"Creating payroll entry detail - User: {request.user}, Data: {request.data}")
        try:
            response = super().create(request, *args, **kwargs)
            logger.info(f"Payroll entry detail created successfully - ID: {response.data.get('id')}")
            
            # Record activity
            record_activity(
                title="Creación de detalle de nómina",
                description=f"Se ha creado un nuevo detalle de nómina",
                activity_type="payroll",
                user=request.user
            )
            
            return response
        except Exception as e:
            logger.error(f"Error creating payroll entry detail - User: {request.user}, Error: {str(e)}")
            return Response(
                {"error": "Error al crear el detalle de nómina", "details": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=['get'])
    def by_entry(self, request):
        """Return payroll entry details by entry."""
        entry_id = request.query_params.get('entry')
        logger.info(f"Getting payroll entry details for entry {entry_id} - User: {request.user}")
        
        if not entry_id:
            logger.warning("Entry ID not provided for payroll entry details lookup")
            return Response({"error": "Entry ID is required"}, status=400)
        
        try:
            details = PayrollEntryDetail.objects.filter(payroll_entry_id=entry_id)
            logger.info(f"Found {details.count()} details for entry {entry_id}")
            
            serializer = self.get_serializer(details, many=True)
            return Response(serializer.data)
        except Exception as e:
            logger.error(f"Error getting details for entry {entry_id}: {str(e)}")
            return Response(
                {"error": "Error al obtener detalles de la entrada"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['get'])
    def by_item_type(self, request):
        """Return payroll entry details by item type."""
        item_type = request.query_params.get('type')
        entry_id = request.query_params.get('entry')
        logger.info(f"Getting payroll entry details for entry {entry_id} and type {item_type} - User: {request.user}")
        
        if not entry_id or not item_type:
            logger.warning("Entry ID or type not provided for payroll entry details lookup")
            return Response({"error": "Entry ID and type are required"}, status=400)
        
        try:
            details = PayrollEntryDetail.objects.filter(
                payroll_entry_id=entry_id,
                payroll_item__item_type=item_type
            )
            logger.info(f"Found {details.count()} details for entry {entry_id} and type {item_type}")
            
            serializer = self.get_serializer(details, many=True)
            return Response(serializer.data)
        except Exception as e:
            logger.error(f"Error getting details for entry {entry_id} and type {item_type}: {str(e)}")
            return Response(
                {"error": "Error al obtener detalles por tipo"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
