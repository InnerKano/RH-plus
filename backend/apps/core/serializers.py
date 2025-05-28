from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from .models import User, Role, UserRole, SystemActivity, USER_ROLES

class UserSerializer(serializers.ModelSerializer):
    """Serializer for the User model."""

    class Meta:
        model = User
        fields = ('id', 'email', 'first_name', 'last_name', 'is_active', 'date_joined', 'role', 'department', 'manager')
        read_only_fields = ('id', 'date_joined')

class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for user registration."""

    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = ('email', 'password', 'password_confirm', 'first_name', 'last_name')

    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({"password_confirm": "Las contraseñas no coinciden"})
        return attrs

    def create(self, validated_data):
        validated_data.pop('password_confirm')
        user = User.objects.create_user(
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
        )
        return user

class UserRoleUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating user roles."""

    class Meta:
        model = User
        fields = ('id', 'email', 'first_name', 'last_name', 'role', 'department', 'manager')
        read_only_fields = ('id', 'email')

    def validate_role(self, value):
        """Validate that the requesting user can assign this role."""
        request = self.context.get('request')
        if request and hasattr(request, 'user'):
            current_user = request.user

            # Create a temporary user object to check permissions
            temp_user = User(role=value)
            if not current_user.can_manage_user(temp_user):
                raise serializers.ValidationError(
                    f"No tienes permisos para asignar el rol {value}"
                )

        return value

class UserListSerializer(serializers.ModelSerializer):
    """Serializer for listing users with role information."""

    role_display = serializers.CharField(source='get_role_display', read_only=True)
    manager_name = serializers.CharField(source='manager.get_full_name', read_only=True)

    class Meta:
        model = User
        fields = ('id', 'email', 'first_name', 'last_name', 'role', 'role_display',
                 'department', 'manager', 'manager_name', 'is_active', 'date_joined')

class RoleSerializer(serializers.ModelSerializer):
    """Serializer for the Role model."""

    class Meta:
        model = Role
        fields = '__all__'

class UserRoleSerializer(serializers.ModelSerializer):
    """Serializer for the UserRole model."""

    class Meta:
        model = UserRole
        fields = '__all__'

class SystemActivitySerializer(serializers.ModelSerializer):
    """Serializer for the SystemActivity model."""

    created_by_name = serializers.CharField(source='created_by.get_full_name', read_only=True)

    class Meta:
        model = SystemActivity
        fields = ('id', 'title', 'description', 'type', 'timestamp', 'created_by', 'created_by_name')
        read_only_fields = ('id', 'timestamp')
