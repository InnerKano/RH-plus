from rest_framework import serializers
from ..models import SystemActivity

class SystemActivitySerializer(serializers.ModelSerializer):
    """Serializer for the SystemActivity model."""
    
    created_by_name = serializers.SerializerMethodField()
    company_name = serializers.SerializerMethodField()
    
    class Meta:
        model = SystemActivity
        fields = ('id', 'title', 'description', 'type', 'timestamp', 'company', 'company_name', 'created_by', 'created_by_name')
        read_only_fields = ('id', 'timestamp', 'created_by')
    
    def get_created_by_name(self, obj):
        if obj.created_by:
            return f"{obj.created_by.first_name} {obj.created_by.last_name}".strip() or obj.created_by.email
        return "Sistema"
    
    def get_company_name(self, obj):
        if obj.company:
            return obj.company.name
        return None
