from rest_framework import serializers
from .models import User, Role, UserRole

class UserSerializer(serializers.ModelSerializer):
    """Serializer for the User model."""
    
    class Meta:
        model = User
        fields = ('id', 'email', 'first_name', 'last_name', 'is_active', 'is_staff')
        read_only_fields = ('id',)

class RoleSerializer(serializers.ModelSerializer):
    """Serializer for the Role model."""
    
    class Meta:
        model = Role
        fields = ('id', 'name', 'description')
        read_only_fields = ('id',)

class UserRoleSerializer(serializers.ModelSerializer):
    """Serializer for the UserRole model."""
    
    class Meta:
        model = UserRole
        fields = ('id', 'user', 'role')
        read_only_fields = ('id',)
