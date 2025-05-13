from django.db.models.signals import post_save, pre_save
from django.dispatch import receiver
from .models import PayrollEntry, PayrollEntryDetail
from decimal import Decimal

@receiver(post_save, sender=PayrollEntryDetail)
def update_payroll_entry_totals(sender, instance, created, **kwargs):
    """Update the payroll entry totals when a detail is added or updated."""
    entry = instance.payroll_entry
    
    # Calculate totals
    details = PayrollEntryDetail.objects.filter(payroll_entry=entry)
    total_earnings = Decimal('0.00')
    total_deductions = Decimal('0.00')
    
    for detail in details:
        amount = detail.amount * detail.quantity
        if detail.payroll_item.item_type == 'EARNING':
            total_earnings += amount
        else:  # DEDUCTION
            total_deductions += amount
    
    # Update the entry
    entry.total_earnings = total_earnings
    entry.total_deductions = total_deductions
    entry.net_pay = total_earnings - total_deductions
    entry.save(update_fields=['total_earnings', 'total_deductions', 'net_pay'])
