from rest_framework import viewsets, permissions
from ..models import Role
from ..serializers import RoleSerializer

class RoleViewSet(viewsets.ModelViewSet):
    """ViewSet for the Role model."""
    
    queryset = Role.objects.all()
    serializer_class = RoleSerializer
    permission_classes = [permissions.IsAuthenticated]
