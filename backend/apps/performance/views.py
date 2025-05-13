from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from .models import (
    EvaluationType, EvaluationCriteria, EvaluationPeriod, Evaluation,
    EvaluationDetail, ImprovementPlan, ImprovementGoal
)
from .serializers import (
    EvaluationTypeSerializer, EvaluationCriteriaSerializer, EvaluationPeriodSerializer,
    EvaluationSerializer, EvaluationDetailSerializer, ImprovementPlanSerializer, ImprovementGoalSerializer
)
from .repositories import (
    EvaluationTypeRepository, EvaluationCriteriaRepository, EvaluationPeriodRepository,
    EvaluationRepository, ImprovementPlanRepository
)

class EvaluationTypeViewSet(viewsets.ModelViewSet):
    """ViewSet for EvaluationType model."""
    serializer_class = EvaluationTypeSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return EvaluationTypeRepository.get_active_types()

class EvaluationCriteriaViewSet(viewsets.ModelViewSet):
    """ViewSet for EvaluationCriteria model."""
    serializer_class = EvaluationCriteriaSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return EvaluationCriteria.objects.filter(is_active=True)
    
    @action(detail=False, methods=['get'])
    def by_type(self, request):
        """Return criteria for a specific evaluation type."""
        type_id = request.query_params.get('type')
        
        if not type_id:
            return Response({"error": "Evaluation type ID is required"}, status=400)
        
        criteria = EvaluationCriteriaRepository.get_by_evaluation_type(type_id)
        
        serializer = self.get_serializer(criteria, many=True)
        return Response(serializer.data)

class EvaluationPeriodViewSet(viewsets.ModelViewSet):
    """ViewSet for EvaluationPeriod model."""
    serializer_class = EvaluationPeriodSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return EvaluationPeriodRepository.get_active_periods()
    
    @action(detail=False, methods=['get'])
    def by_type(self, request):
        """Return periods for a specific evaluation type."""
        type_id = request.query_params.get('type')
        
        if not type_id:
            return Response({"error": "Evaluation type ID is required"}, status=400)
        
        periods = EvaluationPeriodRepository.get_by_type(type_id)
        
        serializer = self.get_serializer(periods, many=True)
        return Response(serializer.data)

class EvaluationViewSet(viewsets.ModelViewSet):
    """ViewSet for Evaluation model."""
    serializer_class = EvaluationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Evaluation.objects.all()
    
    @action(detail=False, methods=['get'])
    def by_employee(self, request):
        """Return evaluations for a specific employee."""
        employee_id = request.query_params.get('employee')
        
        if not employee_id:
            return Response({"error": "Employee ID is required"}, status=400)
        
        evaluations = EvaluationRepository.get_by_employee(employee_id)
        
        serializer = self.get_serializer(evaluations, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def by_evaluator(self, request):
        """Return evaluations conducted by the current user."""
        evaluations = EvaluationRepository.get_by_evaluator(request.user.id)
        
        serializer = self.get_serializer(evaluations, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        """Mark an evaluation as completed."""
        evaluation = self.get_object()
        
        if evaluation.status == 'COMPLETED':
            return Response({"error": "Evaluation is already completed"}, status=400)
        
        evaluation.status = 'COMPLETED'
        evaluation.completed_at = timezone.now()
        evaluation.save()
        
        serializer = self.get_serializer(evaluation)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def request_feedback(self, request, pk=None):
        """Change status to waiting for employee feedback."""
        evaluation = self.get_object()
        
        if evaluation.status == 'WAITING_FEEDBACK':
            return Response({"error": "Feedback already requested"}, status=400)
        
        evaluation.status = 'WAITING_FEEDBACK'
        evaluation.save()
        
        serializer = self.get_serializer(evaluation)
        return Response(serializer.data)

class EvaluationDetailViewSet(viewsets.ModelViewSet):
    """ViewSet for EvaluationDetail model."""
    queryset = EvaluationDetail.objects.all()
    serializer_class = EvaluationDetailSerializer
    permission_classes = [permissions.IsAuthenticated]

class ImprovementPlanViewSet(viewsets.ModelViewSet):
    """ViewSet for ImprovementPlan model."""
    serializer_class = ImprovementPlanSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return ImprovementPlanRepository.get_active_plans()
    
    @action(detail=False, methods=['get'])
    def by_employee(self, request):
        """Return plans for a specific employee."""
        employee_id = request.query_params.get('employee')
        
        if not employee_id:
            return Response({"error": "Employee ID is required"}, status=400)
        
        plans = ImprovementPlanRepository.get_by_employee(employee_id)
        
        serializer = self.get_serializer(plans, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def supervised(self, request):
        """Return plans supervised by the current user."""
        plans = ImprovementPlanRepository.get_by_supervisor(request.user.id)
        
        serializer = self.get_serializer(plans, many=True)
        return Response(serializer.data)

class ImprovementGoalViewSet(viewsets.ModelViewSet):
    """ViewSet for ImprovementGoal model."""
    queryset = ImprovementGoal.objects.all()
    serializer_class = ImprovementGoalSerializer
    permission_classes = [permissions.IsAuthenticated]
