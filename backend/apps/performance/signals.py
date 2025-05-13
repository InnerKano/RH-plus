from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import EvaluationDetail, Evaluation
from django.db.models import Avg

@receiver(post_save, sender=EvaluationDetail)
def update_evaluation_score(sender, instance, **kwargs):
    """Update overall evaluation score when a detail is added or updated."""
    evaluation = instance.evaluation
    
    # Calculate average score from details
    details = EvaluationDetail.objects.filter(evaluation=evaluation)
    if details.exists():
        # Weighted average calculation
        total_weight = 0
        weighted_sum = 0
        
        for detail in details:
            weight = detail.criteria.weight
            total_weight += weight
            weighted_sum += detail.score * weight
        
        if total_weight > 0:
            evaluation.overall_score = weighted_sum / total_weight
            evaluation.save(update_fields=['overall_score'])
