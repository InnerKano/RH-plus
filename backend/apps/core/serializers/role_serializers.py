from rest_framework import serializers
from ..models import Role, CompanyUser

class RoleSerializer(serializers.ModelSerializer):
    """Serializer for the Role model."""
    
    class Meta:
        model = Role
        fields = ('id', 'name', 'description')
        read_only_fields = ('id',)
