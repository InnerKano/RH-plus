from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django_filters.rest_framework import DjangoFilterBackend
from .models import User, Role, UserRole, SystemActivity
from .serializers import (
    UserSerializer, UserRegistrationSerializer, RoleSerializer, 
    UserRoleSerializer, SystemActivitySerializer, UserRoleUpdateSerializer,
    UserListSerializer
)

class UserViewSet(viewsets.ModelViewSet):
    """ViewSet for managing users."""
    
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['role', 'is_active', 'department']

    def get_queryset(self):
        """Filter users based on current user's permissions."""
        if not self.request.user.is_authenticated:
            return User.objects.none()
        
        return self.request.user.get_managed_users()
    
    def get_serializer_class(self):
        """Return appropriate serializer based on action."""
        if self.action == 'list':
            return UserListSerializer
        elif self.action == 'update_role':
            return UserRoleUpdateSerializer
        elif self.action == 'register':
            return UserRegistrationSerializer
        return UserSerializer

    @action(detail=False, methods=['post'], permission_classes=[permissions.AllowAny])
    def register(self, request):
        """Register a new user."""
        serializer = UserRegistrationSerializer(data=request.data)
        
        if serializer.is_valid():
            user = serializer.save()
            
            # Create a system activity for the registration
            SystemActivity.objects.create(
                title="Nuevo usuario registrado",
                description=f"Se ha registrado el usuario {user.email}",
                type="employee"
            )
            
            # Return success response
            return Response(
                {"message": "Usuario registrado exitosamente"},
                status=status.HTTP_201_CREATED
            )
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['patch'], permission_classes=[permissions.IsAuthenticated])
    def update_role(self, request, pk=None):
        """Update a user's role and related information."""
        user = self.get_object()
        
        # Check if current user can manage this user
        if not request.user.can_manage_user(user):
            return Response(
                {"error": "No tienes permisos para modificar este usuario"},
                status=status.HTTP_403_FORBIDDEN
            )
        
        serializer = UserRoleUpdateSerializer(
            user, 
            data=request.data, 
            partial=True,
            context={'request': request}
        )
        
        if serializer.is_valid():
            old_role = user.role
            updated_user = serializer.save()
            
            # Create system activity
            SystemActivity.objects.create(
                title="Rol de usuario actualizado",
                description=f"El rol del usuario {updated_user.email} cambió de {old_role} a {updated_user.role}",
                type="employee",
                created_by=request.user
            )
            
            return Response(UserListSerializer(updated_user).data)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def role_options(self, request):
        """Get available roles that the current user can assign."""
        try:
            current_user = request.user
            available_roles = []
            
            # Import here to avoid circular imports
            from .models import USER_ROLES
            
            for role_code, role_name in USER_ROLES:
                temp_user = User(role=role_code)
                if current_user.can_manage_user(temp_user):
                    available_roles.append({
                        'code': role_code,
                        'name': role_name
                    })
            
            return Response(available_roles)
        except Exception as e:
            print(f"Error in role_options: {e}")
            return Response(
                {"error": "Error obteniendo opciones de roles"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def user_permissions(self, request):
        """Get current user's permissions and accessible modules."""
        try:
            user = request.user
            print(f"Getting permissions for user: {user.email}, role: {user.role}")
            
            modules = ['selection', 'affiliation', 'payroll', 'performance', 'training', 'core']
            accessible_modules = []
            
            for module in modules:
                if user.can_access_module(module):
                    accessible_modules.append(module)
            
            # Get available roles for this user
            available_roles = []
            from .models import USER_ROLES
            
            for role_code, role_name in USER_ROLES:
                temp_user = User(role=role_code)
                if user.can_manage_user(temp_user):
                    available_roles.append(role_code)
              # Include user data in the response
            user_data = {
                'id': user.id,
                'email': user.email,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'role': user.role,
                'department': user.department,
                'is_active': user.is_active
            }
            
            permissions = {
                'role': user.role,
                'role_display': user.get_role_display(),
                'accessible_modules': accessible_modules,
                'can_manage_users': user.role in ['SUPERUSER', 'ADMIN', 'HR_MANAGER', 'SUPERVISOR'],
                'manageable_roles': available_roles,
                'user': user_data  # Add user data to the response
            }
            
            print(f"Returning permissions: {permissions}")
            return Response(permissions)
            
        except Exception as e:
            print(f"Error in user_permissions: {e}")
            import traceback
            traceback.print_exc()
            return Response(
                {"error": f"Error obteniendo permisos: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class RoleViewSet(viewsets.ModelViewSet):
    """ViewSet for managing roles."""
    
    queryset = Role.objects.all()
    serializer_class = RoleSerializer
    permission_classes = [permissions.IsAuthenticated]


class UserRoleViewSet(viewsets.ModelViewSet):
    """ViewSet for managing user-role relationships."""
    
    queryset = UserRole.objects.all()
    serializer_class = UserRoleSerializer
    permission_classes = [permissions.IsAuthenticated]


class ActivityViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for viewing system activities."""
    
    queryset = SystemActivity.objects.all()
    serializer_class = SystemActivitySerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['type', 'created_by']


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Custom token serializer to include user data in login response."""
    
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        # Add custom claims if needed
        token['role'] = user.role
        return token
    
    def validate(self, attrs):
        data = super().validate(attrs)
        # Add user data to response
        data['user'] = {
            'id': self.user.id,
            'email': self.user.email,
            'first_name': self.user.first_name,
            'last_name': self.user.last_name,
            'role': self.user.role,
        }
        return data


class CustomTokenObtainPairView(TokenObtainPairView):
    """Custom token view using our custom serializer."""
    serializer_class = CustomTokenObtainPairSerializer
