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
    
    @staticmethod
    def get_program_metrics(program_id):
        """Return detailed metrics for a training program."""
        program = TrainingProgram.objects.filter(id=program_id).annotate(
            total_sessions=Count('sessions'),
            total_attendees=Count('sessions__attendances', distinct=True),
            avg_evaluation=Avg('sessions__attendances__evaluation_score'),
            completion_rate=Count(
                'sessions__attendances',
                filter=Q(sessions__attendances__status='ATTENDED'),
                distinct=True
            ) * 100.0 / Count('sessions__attendances', distinct=True)
        ).first()
        
        if program:
            return {
                'total_sessions': program.total_sessions,
                'total_attendees': program.total_attendees,
                'avg_evaluation': program.avg_evaluation or 0,
                'completion_rate': program.completion_rate or 0
            }
        return None

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
    
    @staticmethod
    def get_session_availability(session_id):
        """Check availability for a session."""
        session = TrainingSession.objects.filter(id=session_id).annotate(
            current_attendees=Count('attendances')
        ).first()
        
        if session:
            return {
                'max_participants': session.max_participants,
                'current_attendees': session.current_attendees,
                'available_spots': max(0, session.max_participants - session.current_attendees)
            }
        return None
    
    @staticmethod
    def get_upcoming_by_employee(employee_id):
        """Get upcoming sessions for an employee."""
        today = timezone.now().date()
        registered_sessions = TrainingAttendance.objects.filter(
            employee_id=employee_id
        ).values_list('session_id', flat=True)
        
        return TrainingSession.objects.filter(
            session_date__gte=today,
            status='SCHEDULED'
        ).exclude(
            id__in=registered_sessions
        ).order_by('session_date', 'start_time')

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
