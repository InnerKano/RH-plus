from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import User

@receiver(post_save, sender=User)
def handle_user_post_save(sender, instance, created, **kwargs):
    """
    Signal to handle actions after a user is saved.
    This is an example of the Observer pattern.
    """
    if created:
        # Example: You could send a welcome email, create initial profile, etc.
        pass
