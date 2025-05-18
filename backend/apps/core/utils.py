"""
Utility functions for the core app.
"""

from django.db import transaction
from .models import SystemActivity


def record_activity(title, description, activity_type, user=None):
    """
    Record a system activity.
    
    Parameters:
    - title: The title of the activity
    - description: A detailed description of the activity
    - activity_type: One of 'employee', 'candidate', 'payroll', 'training', 'performance'
    - user: The user who performed the action (optional)
    
    Returns:
    - The created SystemActivity instance
    """
    try:
        with transaction.atomic():
            activity = SystemActivity.objects.create(
                title=title,
                description=description,
                type=activity_type,
                created_by=user
            )
            return activity
    except Exception as e:
        # Log error but don't interrupt the flow
        print(f"Error recording activity: {e}")
        return None
