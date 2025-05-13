from rest_framework import serializers
from .models import Contract, PayrollPeriod, PayrollItem, PayrollEntry, PayrollEntryDetail

class ContractSerializer(serializers.ModelSerializer):
    employee_name = serializers.ReadOnlyField(source='employee.__str__')
    
    class Meta:
        model = Contract
        fields = '__all__'

class PayrollPeriodSerializer(serializers.ModelSerializer):
    class Meta:
        model = PayrollPeriod
        fields = '__all__'

class PayrollItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = PayrollItem
        fields = '__all__'

class PayrollEntryDetailSerializer(serializers.ModelSerializer):
    item_name = serializers.ReadOnlyField(source='payroll_item.name')
    item_type = serializers.ReadOnlyField(source='payroll_item.item_type')
    
    class Meta:
        model = PayrollEntryDetail
        fields = '__all__'

class PayrollEntrySerializer(serializers.ModelSerializer):
    details = PayrollEntryDetailSerializer(many=True, read_only=True)
    employee_name = serializers.ReadOnlyField(source='contract.employee.__str__')
    period_name = serializers.ReadOnlyField(source='period.name')
    
    class Meta:
        model = PayrollEntry
        fields = '__all__'
