from rest_framework import serializers
from .models import Employee, AffiliationType, Provider, Affiliation

class EmployeeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Employee
        fields = '__all__'
        read_only_fields = ('employee_id',)
    
    def create(self, validated_data):
        # Generate employee_id if not provided
        if 'employee_id' not in validated_data:
            # Get last employee_id
            last_employee = Employee.objects.order_by('-employee_id').first()
            if last_employee and last_employee.employee_id.startswith('EMP-'):
                last_number = int(last_employee.employee_id.split('-')[1])
                new_number = last_number + 1
            else:
                new_number = 1
            validated_data['employee_id'] = f'EMP-{new_number:06d}'
            
        # If user email matches an existing user, link them
        email = validated_data.get('email')
        if email:
            from apps.core.models import User
            user = User.objects.filter(email=email).first()
            if user:
                validated_data['user'] = user
        
        return super().create(validated_data)

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
    employee_name = serializers.SerializerMethodField()
    
    class Meta:
        model = Affiliation
        fields = '__all__'
    
    def get_employee_name(self, obj):
        return f"{obj.employee.first_name} {obj.employee.last_name}"
