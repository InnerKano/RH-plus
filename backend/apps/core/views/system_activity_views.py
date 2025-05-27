from rest_framework import viewsets, permissions, status
from rest_framework.response import Response
from rest_framework.decorators import action
from django.utils import timezone
from ..models import SystemActivity
from ..serializers import SystemActivitySerializer

class ActivityViewSet(viewsets.ModelViewSet):
    """ViewSet for the SystemActivity model."""
    
    queryset = SystemActivity.objects.all().order_by('-timestamp')
    serializer_class = SystemActivitySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        """Filter activities by company."""
        queryset = super().get_queryset()
        user = self.request.user
        
        # Check if there's an active company
        active_company = user.get_active_company()
        if active_company:
            return queryset.filter(company=active_company)
        
        # If superadmin and no active company, show all
        if user.is_superuser:
            return queryset
            
        return queryset.none()
    
    def perform_create(self, serializer):
        """Assign company and user when creating an activity."""
        user = self.request.user
        active_company = user.get_active_company()
        
        serializer.save(
            created_by=user,
            company=active_company
        )
    
    @action(detail=False, methods=['get'])
    def recent(self, request):
        """Return the most recent activities."""
        activities = self.get_queryset()[:10]  # Limitar a las 10 más recientes
        serializer = self.get_serializer(activities, many=True)
        return Response(serializer.data)
        
    @action(detail=False, methods=['get'])
    def dashboard_summary(self, request):
        """Return summary data for the dashboard."""
        from apps.affiliation.models import Employee
        from apps.selection.models import Candidate
        from apps.training.models import TrainingSession
        from apps.payroll.models import PayrollPeriod
        
        user = request.user
        active_company = user.get_active_company()
        
        try:
            # Obtener conteo de empleados
            employee_query = Employee.objects.filter(is_active=True)
            if active_company:
                employee_query = employee_query.filter(company=active_company)
            employee_count = employee_query.count()
        except:
            employee_count = 0
            
        try:
            # Obtener conteo de candidatos
            candidate_query = Candidate.objects.filter(status__in=['new', 'in_process'])
            if active_company:
                candidate_query = candidate_query.filter(company=active_company)
            candidate_count = candidate_query.count()
        except:
            candidate_count = 0
            
        try:
            # Obtener sesiones de capacitación próximas
            training_query = TrainingSession.objects.filter(date__gte=timezone.now().date())
            if active_company:
                training_query = training_query.filter(company=active_company)
            upcoming_trainings_count = training_query.count()
        except:
            upcoming_trainings_count = 0
            
        try:
            # Obtener período de nómina actual
            payroll_query = PayrollPeriod.objects.filter(is_active=True)
            if active_company:
                payroll_query = payroll_query.filter(company=active_company)
            current_period = payroll_query.first()
            payroll_period = f"{current_period.name}" if current_period else "Sin período activo"
        except:
            payroll_period = "Sin datos"
            
        # Obtener actividades recientes
        recent_activities = self.get_queryset()[:5]
        activities_serializer = SystemActivitySerializer(recent_activities, many=True)
        
        summary_data = {
            'employee_count': employee_count,
            'candidate_count': candidate_count,
            'payroll_period': payroll_period,
            'upcoming_trainings_count': upcoming_trainings_count,
            'recent_activities': activities_serializer.data
        }
        
        return Response(summary_data)
