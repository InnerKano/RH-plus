from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from .models import TrainingType, TrainingProgram, TrainingSession, TrainingAttendance, TrainingEvaluation
from .serializers import (
    TrainingTypeSerializer, TrainingProgramSerializer, TrainingSessionSerializer,
    TrainingAttendanceSerializer, TrainingEvaluationSerializer
)
from .repositories import (
    TrainingProgramRepository, TrainingSessionRepository, TrainingAttendanceRepository
)
from apps.core.utils import record_activity

class TrainingTypeViewSet(viewsets.ModelViewSet):
    """ViewSet for TrainingType model."""
    queryset = TrainingType.objects.filter(is_active=True)
    serializer_class = TrainingTypeSerializer
    permission_classes = [permissions.IsAuthenticated]

class TrainingProgramViewSet(viewsets.ModelViewSet):
    """ViewSet for TrainingProgram model."""
    serializer_class = TrainingProgramSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return TrainingProgramRepository.get_active_programs()
    
    @action(detail=False, methods=['get'])
    def by_type(self, request):
        """Return programs by training type."""
        type_id = request.query_params.get('type')
        
        if not type_id:
            return Response({"error": "Training type ID is required"}, status=400)
        
        programs = TrainingProgramRepository.get_by_type(type_id)
        
        serializer = self.get_serializer(programs, many=True)
        return Response(serializer.data)

class TrainingSessionViewSet(viewsets.ModelViewSet):
    """ViewSet for TrainingSession model."""
    serializer_class = TrainingSessionSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return TrainingSession.objects.all()
    
    def perform_create(self, serializer):
        session = serializer.save(created_by=self.request.user)
        
        # Record activity
        record_activity(
            title="Nueva sesión de capacitación programada",
            description=f"Se ha programado la capacitación '{session.program.name}' para el {session.date.strftime('%d/%m/%Y')}",
            activity_type="training",
            user=self.request.user
        )
    
    @action(detail=False, methods=['get'])
    def upcoming(self, request):
        """Return upcoming training sessions."""
        sessions = TrainingSessionRepository.get_upcoming_sessions()
        
        serializer = self.get_serializer(sessions, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def by_program(self, request):
        """Return sessions by program."""
        program_id = request.query_params.get('program')
        
        if not program_id:
            return Response({"error": "Program ID is required"}, status=400)
        
        sessions = TrainingSessionRepository.get_by_program(program_id)
        
        serializer = self.get_serializer(sessions, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        """Mark a session as completed."""
        session = self.get_object()
        
        if session.status == 'COMPLETED':
            return Response({"error": "Session is already completed"}, status=400)
        
        session.status = 'COMPLETED'
        session.save()
        
        serializer = self.get_serializer(session)
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def attendance_stats(self, request, pk=None):
        """Get attendance statistics for a session."""
        stats = TrainingAttendanceRepository.get_attendance_stats(pk)
        return Response(stats)

class TrainingAttendanceViewSet(viewsets.ModelViewSet):
    """ViewSet for TrainingAttendance model."""
    serializer_class = TrainingAttendanceSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return TrainingAttendance.objects.all()
    
    def perform_create(self, serializer):
        serializer.save(registered_by=self.request.user)
    
    @action(detail=False, methods=['get'])
    def by_employee(self, request):
        """Return attendances by employee."""
        employee_id = request.query_params.get('employee')
        
        if not employee_id:
            return Response({"error": "Employee ID is required"}, status=400)
        
        attendances = TrainingAttendanceRepository.get_by_employee(employee_id)
        
        serializer = self.get_serializer(attendances, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def by_session(self, request):
        """Return attendances by session."""
        session_id = request.query_params.get('session')
        
        if not session_id:
            return Response({"error": "Session ID is required"}, status=400)
        
        attendances = TrainingAttendanceRepository.get_by_session(session_id)
        
        serializer = self.get_serializer(attendances, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def mark_attended(self, request, pk=None):
        """Mark an attendance record as attended."""
        attendance = self.get_object()
        
        attendance.status = 'ATTENDED'
        attendance.save()
        
        serializer = self.get_serializer(attendance)
        return Response(serializer.data)

class TrainingEvaluationViewSet(viewsets.ModelViewSet):
    """ViewSet for TrainingEvaluation model."""
    queryset = TrainingEvaluation.objects.all()
    serializer_class = TrainingEvaluationSerializer
    permission_classes = [permissions.IsAuthenticated]
