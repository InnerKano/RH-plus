from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import TrainingEvaluation, TrainingAttendance

@receiver(post_save, sender=TrainingEvaluation)
def update_attendance_score(sender, instance, created, **kwargs):
    """Update the evaluation score in attendance record."""
    if created:
        attendance = instance.attendance
        # Average of all ratings
        avg_score = (
            instance.content_rating +
            instance.instructor_rating +
            instance.materials_rating +
            instance.usefulness_rating +
            instance.overall_rating
        ) / 5.0
        
        attendance.evaluation_score = avg_score
        attendance.save(update_fields=['evaluation_score'])
