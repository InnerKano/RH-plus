"""Repository pattern for Training app."""
from .models import TrainingProgram, TrainingSession, TrainingAttendance
from django.db.models import Count, Avg, Q
from django.utils import timezone

class TrainingProgramRepository:
    """Repository for TrainingProgram model."""
    
    @staticmethod
    def get_active_programs():
        """Return all active training programs."""
        return TrainingProgram.objects.filter(is_active=True)
    
    @staticmethod
    def get_by_type(type_id):
        """Return programs by training type."""
        return TrainingProgram.objects.filter(
            training_type_id=type_id,
            is_active=True
        )

class TrainingSessionRepository:
    """Repository for TrainingSession model."""
    
    @staticmethod
    def get_upcoming_sessions():
        """Return upcoming training sessions."""
        today = timezone.now().date()
        return TrainingSession.objects.filter(
            session_date__gte=today,
            status__in=['SCHEDULED', 'IN_PROGRESS']
        ).order_by('session_date', 'start_time')
    
    @staticmethod
    def get_by_program(program_id):
        """Return sessions by program."""
        return TrainingSession.objects.filter(program_id=program_id)
    
    @staticmethod
    def get_by_instructor(instructor_id):
        """Return sessions by instructor."""
        return TrainingSession.objects.filter(instructor_id=instructor_id)

class TrainingAttendanceRepository:
    """Repository for TrainingAttendance model."""
    
    @staticmethod
    def get_by_employee(employee_id):
        """Return all training attendances for an employee."""
        return TrainingAttendance.objects.filter(employee_id=employee_id)
    
    @staticmethod
    def get_by_session(session_id):
        """Return all attendances for a training session."""
        return TrainingAttendance.objects.filter(session_id=session_id)
    
    @staticmethod
    def get_attendance_stats(session_id):
        """Return attendance statistics for a session."""
        return TrainingAttendance.objects.filter(session_id=session_id).aggregate(
            total=Count('id'),
            attended=Count('id', filter=Q(status='ATTENDED')),
            missed=Count('id', filter=Q(status='MISSED')),
            avg_score=Avg('evaluation_score', filter=Q(evaluation_score__isnull=False))
        )
