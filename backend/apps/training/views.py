from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from django.core.exceptions import ValidationError
from django.db import transaction
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
    
    def perform_create(self, serializer):
        try:
            with transaction.atomic():
                program = serializer.save(created_by=self.request.user)
                record_activity(
                    title="Nuevo programa de capacitación creado",
                    description=f"Se ha creado el programa '{program.name}'",
                    activity_type="training",
                    user=self.request.user
                )
        except ValidationError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    def perform_update(self, serializer):
        try:
            with transaction.atomic():
                program = serializer.save()
                record_activity(
                    title="Programa de capacitación actualizado",
                    description=f"Se ha actualizado el programa '{program.name}'",
                    activity_type="training",
                    user=self.request.user
                )
        except ValidationError as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    def destroy(self, request, *args, **kwargs):
        try:
            program = self.get_object()
            if program.sessions.exists():
                return Response(
                    {"error": "No se puede eliminar un programa que tiene sesiones"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            program.is_active = False
            program.save()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
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
        attendance = serializer.save(registered_by=self.request.user)
        record_activity(
            title="Registro de asistencia",
            description=f"Se ha registrado la asistencia de {attendance.employee} a {attendance.session}",
            activity_type="training",
            user=self.request.user
        )
    
    @action(detail=False, methods=['get'])
    def by_session(self, request):
        """Return attendances by session."""
        session_id = request.query_params.get('session')
        
        if not session_id:
            return Response({"error": "Session ID is required"}, status=400)
        
        attendances = TrainingAttendanceRepository.get_by_session(session_id)
        serializer = self.get_serializer(attendances, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def by_employee(self, request):
        """Return attendances by employee."""
        employee_id = request.query_params.get('employee')
        
        if not employee_id:
            return Response({"error": "Employee ID is required"}, status=400)
        
        attendances = TrainingAttendanceRepository.get_by_employee(employee_id)
        serializer = self.get_serializer(attendances, many=True)
        return Response(serializer.data)

class TrainingEvaluationViewSet(viewsets.ModelViewSet):
    """ViewSet for TrainingEvaluation model."""
    serializer_class = TrainingEvaluationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return TrainingEvaluation.objects.all()
    
    def perform_create(self, serializer):
        evaluation = serializer.save()
        attendance = evaluation.attendance
        
        # Actualizar el score en la asistencia
        avg_score = (
            evaluation.content_rating +
            evaluation.instructor_rating +
            evaluation.materials_rating +
            evaluation.usefulness_rating +
            evaluation.overall_rating
        ) / 5.0
        
        attendance.evaluation_score = avg_score
        attendance.save()
        
        record_activity(
            title="Nueva evaluación de capacitación",
            description=f"Se ha registrado la evaluación para {attendance.session.program}",
            activity_type="training",
            user=self.request.user
        )
    
    @action(detail=False, methods=['get'])
    def by_program(self, request):
        """Return evaluations by training program."""
        program_id = request.query_params.get('program')
        
        if not program_id:
            return Response({"error": "Program ID is required"}, status=400)
        
        evaluations = self.get_queryset().filter(
            attendance__session__program_id=program_id
        )
        serializer = self.get_serializer(evaluations, many=True)
        return Response(serializer.data)
