from rest_framework import serializers
from .models import User, Role, UserRole, SystemActivity

class UserSerializer(serializers.ModelSerializer):
    """Serializer for the User model."""
    
    roles = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = ('id', 'email', 'first_name', 'last_name', 'is_active', 'is_staff', 'roles')
        read_only_fields = ('id',)
        
    def get_roles(self, obj):
        user_roles = obj.userrole_set.all().select_related('role')
        return [{'id': role.role.id, 'name': role.role.name} for role in user_roles]

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

class SystemActivitySerializer(serializers.ModelSerializer):
    """Serializer for the SystemActivity model."""
    
    created_by_name = serializers.SerializerMethodField()
    
    class Meta:
        model = SystemActivity
        fields = ('id', 'title', 'description', 'type', 'timestamp', 'created_by', 'created_by_name')
        read_only_fields = ('id', 'timestamp', 'created_by')
    
    def get_created_by_name(self, obj):
        if obj.created_by:
            return f"{obj.created_by.first_name} {obj.created_by.last_name}".strip() or obj.created_by.email
        return "Sistema"
