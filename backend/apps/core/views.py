from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.db.models import Count
from django.utils import timezone
from .models import User, Role, UserRole, SystemActivity
from .serializers import UserSerializer, RoleSerializer, UserRoleSerializer, SystemActivitySerializer, UserRegistrationSerializer
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


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Custom token serializer that uses email as the username field."""
    
    username_field = User.USERNAME_FIELD
    
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        # Add custom claims
        token['name'] = user.get_full_name()
        token['email'] = user.email
        return token


class CustomTokenObtainPairView(TokenObtainPairView):
    """Custom token view that uses the custom token serializer."""
    
    serializer_class = CustomTokenObtainPairSerializer
    
class ActivityViewSet(viewsets.ModelViewSet):
    """ViewSet for the SystemActivity model."""
    
    queryset = SystemActivity.objects.all().order_by('-timestamp')
    serializer_class = SystemActivitySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def perform_create(self, serializer):
        # Asigna automáticamente el usuario actual como creador
        serializer.save(created_by=self.request.user)
    
    @action(detail=False, methods=['get'])
    def recent(self, request):
        """Return the most recent activities."""
        activities = self.queryset[:10]  # Limitar a las 10 más recientes
        serializer = self.get_serializer(activities, many=True)
        return Response(serializer.data)
        
    @action(detail=False, methods=['get'])
    def dashboard_summary(self, request):
        """Return summary data for the dashboard."""
        from apps.affiliation.models import Employee
        from apps.selection.models import Candidate
        from apps.training.models import TrainingSession
        from apps.payroll.models import PayrollPeriod
        
        try:
            # Obtener conteo de empleados
            employee_count = Employee.objects.filter(is_active=True).count()
        except:
            employee_count = 0
            
        try:
            # Obtener conteo de candidatos
            candidate_count = Candidate.objects.filter(status__in=['new', 'in_process']).count()
        except:
            candidate_count = 0
            
        try:
            # Obtener sesiones de capacitación próximas
            upcoming_trainings_count = TrainingSession.objects.filter(
                date__gte=timezone.now().date()
            ).count()
        except:
            upcoming_trainings_count = 0
            
        try:
            # Obtener período de nómina actual
            current_period = PayrollPeriod.objects.filter(
                is_active=True
            ).first()
            payroll_period = f"{current_period.name}" if current_period else "Sin período activo"
        except:
            payroll_period = "Sin datos"
            
        # Obtener actividades recientes
        recent_activities = SystemActivity.objects.all().order_by('-timestamp')[:5]
        activities_serializer = SystemActivitySerializer(recent_activities, many=True)
        
        summary_data = {
            'employee_count': employee_count,
            'candidate_count': candidate_count,
            'payroll_period': payroll_period,
            'upcoming_trainings_count': upcoming_trainings_count,
            'recent_activities': activities_serializer.data
        }
        
        return Response(summary_data)
