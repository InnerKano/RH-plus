from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from ..models import User, Role, SystemActivity
from ..serializers import UserSerializer, UserRegistrationSerializer
from ..repositories import UserRepository

class UserViewSet(viewsets.ModelViewSet):
    """ViewSet for the User model."""
    
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        # SuperAdmin can see all users
        if self.request.user.is_superuser:
            return User.objects.all().order_by('-date_joined')
            
        # Company admins can see users in their companies
        if self.request.user.has_role('COMPANYADMIN'):
            # Get companies where the user is admin
            admin_companies = self.request.user.companies.filter(
                companyuser__roles__name='COMPANYADMIN',
                companyuser__status='APPROVED'
            )
            
            # Get users in those companies
            return User.objects.filter(
                companies__in=admin_companies,
                companyuser__status='APPROVED'
            ).distinct().order_by('-date_joined')
            
        # Regular users only see themselves
        return User.objects.filter(id=self.request.user.id)
    
    @action(detail=False, methods=['get'])
    def me(self, request):
        """Return the current user."""
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)
    
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
                {"message": "Usuario registrado exitosamente. Tu cuenta está pendiente de aprobación."},
                status=status.HTTP_201_CREATED
            )
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
    @action(detail=False, methods=['get'])
    def switch_company(self, request):
        """Switch the user's active company."""
        company_id = request.query_params.get('company_id')
        if not company_id:
            return Response(
                {"detail": "Se requiere el ID de la empresa."},
                status=status.HTTP_400_BAD_REQUEST
            )
            
        try:
            # Check if user has access to this company
            company_user = request.user.companyuser_set.filter(
                company_id=company_id,
                status='APPROVED'
            ).first()
            
            if not company_user:
                return Response(
                    {"detail": "No tienes acceso a esta empresa o tu acceso no está aprobado."},
                    status=status.HTTP_403_FORBIDDEN
                )
                
            # Set this company as primary
            request.user.companyuser_set.update(is_primary=False)
            company_user.is_primary = True
            company_user.save()
            
            return Response(
                {"detail": "Empresa activa cambiada correctamente."},
                status=status.HTTP_200_OK
            )
        except Exception as e:
            return Response(
                {"detail": f"Error al cambiar la empresa activa: {str(e)}"},
                status=status.HTTP_400_BAD_REQUEST
            )
