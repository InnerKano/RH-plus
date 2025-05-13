from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Employee
from apps.core.models import User
from apps.selection.models import Candidate

@receiver(post_save, sender=Candidate)
def create_employee_from_candidate(sender, instance, **kwargs):
    """
    When a candidate status changes to 'HIRED', create an employee record.
    """
    if instance.status == 'HIRED':
        # Check if employee already exists with this candidate
        from .models import Employee
        if not Employee.objects.filter(candidate=instance).exists():
            # Create employee from candidate
            Employee.objects.create(
                candidate=instance,
                first_name=instance.first_name,
                last_name=instance.last_name,
                document_type=instance.document_type,
                document_number=instance.document_number,
                email=instance.email,
                phone=instance.phone,
                address=instance.address,
                # Generate employee ID
                employee_id=f"EMP-{instance.id:06d}",
                hire_date=instance.updated_at.date()
            )
