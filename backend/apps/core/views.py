from rest_framework import viewsets, permissions
from rest_framework.response import Response
from rest_framework.decorators import action
from .models import User, Role, UserRole
from .serializers import UserSerializer, RoleSerializer, UserRoleSerializer
from .repositories import UserRepository

class UserViewSet(viewsets.ModelViewSet):
    """ViewSet for the User model."""
    
    serializer_class = UserSerializer
    
    def get_queryset(self):
        return UserRepository.get_active_users()
    
    @action(detail=False, methods=['get'])
    def me(self, request):
        """Return the current user."""
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)

class RoleViewSet(viewsets.ModelViewSet):
    """ViewSet for the Role model."""
    
    queryset = Role.objects.all()
    serializer_class = RoleSerializer
    permission_classes = [permissions.IsAuthenticated]

class UserRoleViewSet(viewsets.ModelViewSet):
    """ViewSet for the UserRole model."""
    
    queryset = UserRole.objects.all()
    serializer_class = UserRoleSerializer
    permission_classes = [permissions.IsAuthenticated]
