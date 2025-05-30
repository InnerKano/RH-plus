from rest_framework import serializers
from .models import Contract, PayrollPeriod, PayrollItem, PayrollEntry, PayrollEntryDetail
from apps.affiliation.models import Employee
from decimal import Decimal
from django.utils import timezone
import logging

logger = logging.getLogger('apps.payroll')

class ContractSerializer(serializers.ModelSerializer):
    employee_name = serializers.ReadOnlyField(source='employee.__str__')
    employee_full_name = serializers.ReadOnlyField(source='employee.get_full_name')
    
    class Meta:
        model = Contract
        fields = '__all__'
    
    def validate(self, data):
        """Validate contract data"""
        # Validate dates
        if data.get('end_date') and data.get('start_date'):
            if data['end_date'] < data['start_date']:
                raise serializers.ValidationError("La fecha de fin no puede ser anterior a la fecha de inicio")
        
        # Validate salary
        if data.get('salary') and data['salary'] <= 0:
            raise serializers.ValidationError("El salario debe ser mayor a cero")
        
        return data
    
    def create(self, validated_data):
        """Create contract with logging"""
        logger.info(f"Creating contract for employee {validated_data.get('employee')}")
        
        # Set created_by if available in context
        request = self.context.get('request')
        if request and hasattr(request, 'user'):
            validated_data['created_by'] = request.user
        
        contract = super().create(validated_data)
        logger.info(f"Contract created successfully with ID: {contract.id}")
        return contract

class PayrollPeriodSerializer(serializers.ModelSerializer):
    entries_count = serializers.SerializerMethodField()
    total_net_pay = serializers.SerializerMethodField()
    
    class Meta:
        model = PayrollPeriod
        fields = '__all__'
    
    def get_entries_count(self, obj):
        """Get number of payroll entries in this period"""
        return obj.payrollentry_set.count()
    
    def get_total_net_pay(self, obj):
        """Get total net pay for this period"""
        entries = obj.payrollentry_set.all()
        return sum(entry.net_pay for entry in entries)
    
    def validate(self, data):
        """Validate payroll period data"""
        if data.get('end_date') and data.get('start_date'):
            if data['end_date'] < data['start_date']:
                raise serializers.ValidationError("La fecha de fin no puede ser anterior a la fecha de inicio")
        
        # Check for overlapping periods
        start_date = data.get('start_date')
        end_date = data.get('end_date')
        
        if start_date and end_date:
            overlapping = PayrollPeriod.objects.filter(
                start_date__lte=end_date,
                end_date__gte=start_date
            )
            
            # Exclude current instance if updating
            if self.instance:
                overlapping = overlapping.exclude(pk=self.instance.pk)
            
            if overlapping.exists():
                raise serializers.ValidationError("Ya existe un período que se superpone con estas fechas")
        
        return data

class PayrollItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = PayrollItem
        fields = '__all__'
    
    def validate_code(self, value):
        """Validate unique code"""
        if value:
            # Check for duplicate codes
            qs = PayrollItem.objects.filter(code=value)
            if self.instance:
                qs = qs.exclude(pk=self.instance.pk)
            
            if qs.exists():
                raise serializers.ValidationError("Ya existe un concepto con este código")
        
        return value
    
    def validate_default_amount(self, value):
        """Validate default amount"""
        if value < 0:
            raise serializers.ValidationError("El monto por defecto no puede ser negativo")
        return value

class PayrollEntryDetailCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating payroll entry details"""
    
    class Meta:
        model = PayrollEntryDetail
        exclude = ('payroll_entry',)  # Exclude payroll_entry as it will be set automatically
    
    def validate_amount(self, value):
        """Validate amount"""
        if value < 0:
            raise serializers.ValidationError("El monto no puede ser negativo")
        return value
    
    def validate_quantity(self, value):
        """Validate quantity"""
        if value <= 0:
            raise serializers.ValidationError("La cantidad debe ser mayor a cero")
        return value

class PayrollEntryDetailSerializer(serializers.ModelSerializer):
    item_name = serializers.ReadOnlyField(source='payroll_item.name')
    item_type = serializers.ReadOnlyField(source='payroll_item.item_type')
    item_code = serializers.ReadOnlyField(source='payroll_item.code')
    total_amount = serializers.SerializerMethodField()
    
    class Meta:
        model = PayrollEntryDetail
        fields = '__all__'
    
    def get_total_amount(self, obj):
        """Calculate total amount (amount * quantity)"""
        return obj.amount * obj.quantity

class PayrollEntryCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating payroll entries"""
    details = PayrollEntryDetailCreateSerializer(many=True, required=False)
    
    class Meta:
        model = PayrollEntry
        exclude = ('total_earnings', 'total_deductions', 'net_pay', 'is_approved', 'approved_by', 'approved_at')
    
    def validate(self, data):
        """Validate payroll entry data"""
        contract = data.get('contract')
        period = data.get('period')
        
        if contract and period:
            # Check if entry already exists for this contract and period
            existing = PayrollEntry.objects.filter(contract=contract, period=period)
            if self.instance:
                existing = existing.exclude(pk=self.instance.pk)
            
            if existing.exists():
                raise serializers.ValidationError("Ya existe una entrada de nómina para este contrato y período")
            
            # Check if period is closed            if period.is_closed:
                raise serializers.ValidationError("No se puede crear una entrada para un período cerrado")
        
        return data
    
    def create(self, validated_data):
        """Create payroll entry with details"""
        details_data = validated_data.pop('details', [])
        
        # Set created_by if available in context
        request = self.context.get('request')
        if request and hasattr(request, 'user'):
            validated_data['created_by'] = request.user
        
        # Set base salary from contract if not provided
        if not validated_data.get('base_salary') and validated_data.get('contract'):
            validated_data['base_salary'] = validated_data['contract'].salary
        
        # Initialize totals with default values
        validated_data['total_earnings'] = Decimal('0.00')
        validated_data['total_deductions'] = Decimal('0.00')
        validated_data['net_pay'] = Decimal('0.00')
        
        entry = PayrollEntry.objects.create(**validated_data)
        
        # Create details
        for detail_data in details_data:
            PayrollEntryDetail.objects.create(payroll_entry=entry, **detail_data)
        
        # Calculate totals
        entry.calculate_totals()
        
        logger.info(f"Payroll entry created with {len(details_data)} details - ID: {entry.id}")
        return entry

class PayrollEntrySerializer(serializers.ModelSerializer):
    details = PayrollEntryDetailSerializer(many=True, read_only=True)
    employee_name = serializers.ReadOnlyField(source='contract.employee.__str__')
    employee_full_name = serializers.ReadOnlyField(source='contract.employee.get_full_name')
    period_name = serializers.ReadOnlyField(source='period.name')
    contract_position = serializers.ReadOnlyField(source='contract.position')
    contract_department = serializers.ReadOnlyField(source='contract.department')
    approved_by_name = serializers.SerializerMethodField()
    
    class Meta:
        model = PayrollEntry
        fields = '__all__'
    
    def get_approved_by_name(self, obj):
        """Get approved by name, handling None values"""
        if obj.approved_by:
            return str(obj.approved_by)
        return None

# Summary serializers for dashboard/reports
class PayrollSummarySerializer(serializers.Serializer):
    """Serializer for payroll summary data"""
    total_employees = serializers.IntegerField()
    total_entries = serializers.IntegerField()
    total_earnings = serializers.DecimalField(max_digits=12, decimal_places=2)
    total_deductions = serializers.DecimalField(max_digits=12, decimal_places=2)
    total_net_pay = serializers.DecimalField(max_digits=12, decimal_places=2)
    approved_entries = serializers.IntegerField()
    pending_entries = serializers.IntegerField()
