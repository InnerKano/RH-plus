from django.db import models
from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from django.utils import timezone
from django.core.validators import MinValueValidator
from apps.core.models import User
from apps.affiliation.models import Employee
from decimal import Decimal

class Contract(models.Model):
    """Contract model for employees"""
    CONTRACT_TYPES = (
        ('INDEFINITE', 'Indefinido'),
        ('FIXED_TERM', 'Término Fijo'),
        ('TEMPORARY', 'Temporal'),
        ('INTERNSHIP', 'Pasantía'),
    )
    
    WORK_SCHEDULES = (
        ('FULL_TIME', 'Tiempo Completo'),
        ('PART_TIME', 'Tiempo Parcial'),
        ('FLEX_TIME', 'Tiempo Flexible'),
        ('SHIFT_WORK', 'Trabajo por Turnos'),
    )
    
    CURRENCY_CHOICES = (
        ('COP', 'Peso Colombiano'),
        ('USD', 'Dólar Estadounidense'),
        ('EUR', 'Euro'),
    )
    
    employee = models.ForeignKey(Employee, on_delete=models.PROTECT, related_name='contracts')
    contract_type = models.CharField(max_length=20, choices=CONTRACT_TYPES)
    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True)
    salary = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(Decimal('0.01'))])
    currency = models.CharField(max_length=3, choices=CURRENCY_CHOICES, default='COP')
    position = models.CharField(max_length=100)
    department = models.CharField(max_length=100)
    work_schedule = models.CharField(max_length=20, choices=WORK_SCHEDULES, default='FULL_TIME')
    is_active = models.BooleanField(default=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.employee} - {self.position} ({self.start_date})"
    
    def save(self, *args, **kwargs):
        # Validate contract dates
        if self.end_date and self.end_date < self.start_date:
            raise ValueError("End date cannot be before start date")
        
        # Set other contracts as inactive if this one is active
        if self.is_active and not self.pk:  # Only for new contracts
            Contract.objects.filter(employee=self.employee, is_active=True).update(is_active=False)
            
        super().save(*args, **kwargs)

class PayrollPeriod(models.Model):
    """Payroll period model"""
    PERIOD_TYPES = (
        ('BIWEEKLY', 'Quincenal'),
        ('MONTHLY', 'Mensual'),
        ('WEEKLY', 'Semanal'),
        ('CUSTOM', 'Personalizado'),
    )
    
    name = models.CharField(max_length=100)
    period_type = models.CharField(max_length=10, choices=PERIOD_TYPES, default='MONTHLY')
    start_date = models.DateField()
    end_date = models.DateField()
    is_closed = models.BooleanField(default=False)
    closed_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    closed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-start_date']
    
    def __str__(self):
        return f"{self.name} ({self.start_date} - {self.end_date})"
    
    def save(self, *args, **kwargs):
        # Validate period dates
        if self.end_date < self.start_date:
            raise ValueError("End date cannot be before start date")
        
        super().save(*args, **kwargs)
    
    def close_period(self, user):
        """Close the payroll period"""
        if self.is_closed:
            return False
        
        self.is_closed = True
        self.closed_by = user
        self.closed_at = timezone.now()
        self.save()
        return True

class PayrollItem(models.Model):
    """Payroll item model"""
    ITEM_TYPES = (
        ('EARNING', 'Devengo'),
        ('DEDUCTION', 'Deducción'),
    )
    
    name = models.CharField(max_length=100)
    code = models.CharField(max_length=20, unique=True)
    description = models.TextField(blank=True, null=True)
    item_type = models.CharField(max_length=10, choices=ITEM_TYPES)
    is_active = models.BooleanField(default=True)
    default_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    is_percentage = models.BooleanField(default=False)
    
    def __str__(self):
        return f"{self.name} ({self.code})"

class PayrollEntry(models.Model):
    """Payroll entry model for an employee in a specific period"""
    contract = models.ForeignKey(Contract, on_delete=models.PROTECT)
    period = models.ForeignKey(PayrollPeriod, on_delete=models.PROTECT)
    base_salary = models.DecimalField(max_digits=10, decimal_places=2)
    total_earnings = models.DecimalField(max_digits=10, decimal_places=2)
    total_deductions = models.DecimalField(max_digits=10, decimal_places=2)
    net_pay = models.DecimalField(max_digits=10, decimal_places=2)
    is_approved = models.BooleanField(default=False)
    approved_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='approved_entries')
    approved_at = models.DateTimeField(null=True, blank=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='created_entries')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ('contract', 'period')
        ordering = ['-period__start_date', 'contract__employee__first_name']
    
    def __str__(self):
        return f"{self.contract.employee} - {self.period}"
    
    def approve(self, user):
        """Approve the payroll entry"""
        if self.is_approved:
            return False
        
        # Don't allow approval if period is closed
        if self.period.is_closed:
            raise ValueError("Cannot approve entry for a closed period")
        
        self.is_approved = True
        self.approved_by = user
        self.approved_at = timezone.now()
        self.save()
        return True
    
    def calculate_totals(self):
        """Calculate totals based on details"""
        earning_details = self.details.filter(payroll_item__item_type='EARNING')
        deduction_details = self.details.filter(payroll_item__item_type='DEDUCTION')
        
        self.total_earnings = sum(detail.amount * detail.quantity for detail in earning_details)
        self.total_deductions = sum(detail.amount * detail.quantity for detail in deduction_details)
        self.net_pay = self.total_earnings - self.total_deductions
        
        self.save()

class PayrollEntryDetail(models.Model):
    """Detail of a payroll entry"""
    payroll_entry = models.ForeignKey(PayrollEntry, on_delete=models.CASCADE, related_name='details')
    payroll_item = models.ForeignKey(PayrollItem, on_delete=models.PROTECT)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    quantity = models.DecimalField(max_digits=5, decimal_places=2, default=1)
    notes = models.CharField(max_length=255, blank=True, null=True)
    
    def __str__(self):
        return f"{self.payroll_entry} - {self.payroll_item}"


@receiver(post_save, sender=PayrollEntryDetail)
def update_payroll_entry_totals(sender, instance, created, **kwargs):
    """Update payroll entry totals when detail is saved"""
    # Skip if we're in a bulk operation to prevent multiple recalculations
    if kwargs.get('raw', False):
        return
        
    instance.payroll_entry.calculate_totals()

@receiver(pre_save, sender=PayrollEntry)
def set_base_salary(sender, instance, **kwargs):
    """Set base salary from contract if not already set"""
    if instance.base_salary == 0 and instance.contract:
        instance.base_salary = instance.contract.salary
