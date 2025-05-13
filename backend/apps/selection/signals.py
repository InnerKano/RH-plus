from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import ProcessCandidate

@receiver(post_save, sender=ProcessCandidate)
def update_candidate_stage(sender, instance, created, **kwargs):
    """Update the current stage of a candidate when ProcessCandidate is updated."""
    candidate = instance.candidate
    candidate.current_stage = instance.current_stage
    candidate.save(update_fields=['current_stage'])
