from rest_framework import serializers
from ..models import Company, User

class CompanySerializer(serializers.ModelSerializer):
    """Serializer for the Company model."""
    
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    
    class Meta:
        model = Company
        fields = ('id', 'name', 'tax_id', 'address', 'phone', 'email', 'website', 
                 'status', 'status_display', 'is_active', 'created_at', 'approved_at')
        read_only_fields = ('id', 'status', 'is_active', 'created_at', 'approved_at')
        
class CompanyDetailSerializer(CompanySerializer):
    """Detailed serializer for the Company model."""
    
    approved_by_email = serializers.EmailField(source='approved_by.email', read_only=True)
    
    class Meta(CompanySerializer.Meta):
        fields = CompanySerializer.Meta.fields + ('approved_by', 'approved_by_email')
        read_only_fields = CompanySerializer.Meta.read_only_fields + ('approved_by',)

class CompanyRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for company registration."""
    
    class Meta:
        model = Company
        fields = ('name', 'tax_id', 'address', 'phone', 'email', 'website')
        
    def validate_tax_id(self, value):
        """Validate tax_id is unique."""
        if Company.objects.filter(tax_id=value).exists():
            raise serializers.ValidationError("Una empresa con este ID fiscal ya existe.")
        return value
