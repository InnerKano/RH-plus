"""Repository pattern for Performance app."""
from .models import (
    EvaluationType, EvaluationCriteria, EvaluationPeriod, Evaluation,
    EvaluationDetail, ImprovementPlan, ImprovementGoal
)

class EvaluationTypeRepository:
    """Repository for EvaluationType model."""
    
    @staticmethod
    def get_active_types():
        """Return all active evaluation types."""
        return EvaluationType.objects.filter(is_active=True)

class EvaluationCriteriaRepository:
    """Repository for EvaluationCriteria model."""
    
    @staticmethod
    def get_by_evaluation_type(type_id):
        """Return criteria for a specific evaluation type."""
        return EvaluationCriteria.objects.filter(
            evaluation_type_id=type_id,
            is_active=True
        )

class EvaluationPeriodRepository:
    """Repository for EvaluationPeriod model."""
    
    @staticmethod
    def get_active_periods():
        """Return all active evaluation periods."""
        return EvaluationPeriod.objects.filter(is_active=True)
    
    @staticmethod
    def get_by_type(type_id):
        """Return periods for a specific evaluation type."""
        return EvaluationPeriod.objects.filter(
            evaluation_type_id=type_id,
            is_active=True
        )

class EvaluationRepository:
    """Repository for Evaluation model."""
    
    @staticmethod
    def get_by_employee(employee_id):
        """Return evaluations for a specific employee."""
        return Evaluation.objects.filter(employee_id=employee_id)
    
    @staticmethod
    def get_by_evaluator(evaluator_id):
        """Return evaluations conducted by a specific evaluator."""
        return Evaluation.objects.filter(evaluator_id=evaluator_id)
    
    @staticmethod
    def get_by_period(period_id):
        """Return evaluations for a specific period."""
        return Evaluation.objects.filter(evaluation_period_id=period_id)
    
    @staticmethod
    def get_pending_feedback():
        """Return evaluations waiting for employee feedback."""
        return Evaluation.objects.filter(status='WAITING_FEEDBACK')

class ImprovementPlanRepository:
    """Repository for ImprovementPlan model."""
    
    @staticmethod
    def get_active_plans():
        """Return all active improvement plans."""
        return ImprovementPlan.objects.filter(status='ACTIVE')
    
    @staticmethod
    def get_by_employee(employee_id):
        """Return plans for a specific employee."""
        return ImprovementPlan.objects.filter(employee_id=employee_id)
    
    @staticmethod
    def get_by_supervisor(supervisor_id):
        """Return plans supervised by a specific user."""
        return ImprovementPlan.objects.filter(supervisor_id=supervisor_id)
