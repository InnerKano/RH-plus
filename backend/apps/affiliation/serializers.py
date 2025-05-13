from rest_framework import serializers
from .models import Employee, AffiliationType, Provider, Affiliation

class EmployeeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Employee
        fields = '__all__'

class AffiliationTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = AffiliationType
        fields = '__all__'

class ProviderSerializer(serializers.ModelSerializer):
    affiliation_type_name = serializers.ReadOnlyField(source='affiliation_type.name')
    
    class Meta:
        model = Provider
        fields = '__all__'

class AffiliationSerializer(serializers.ModelSerializer):
    provider_name = serializers.ReadOnlyField(source='provider.name')
    affiliation_type_name = serializers.ReadOnlyField(source='provider.affiliation_type.name')
    employee_name = serializers.ReadOnlyField(source='employee.__str__')
    
    class Meta:
        model = Affiliation
        fields = '__all__'
