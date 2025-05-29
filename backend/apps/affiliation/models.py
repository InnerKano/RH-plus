from django.db import models
from apps.core.models import User
from apps.selection.models import Candidate

class Employee(models.Model):
    """Employee model after a candidate is hired."""
    
    STATUS_CHOICES = (
        ('ACTIVE', 'Activo'),
        ('INACTIVE', 'Inactivo'),
        ('ON_LEAVE', 'En permiso'),
        ('TERMINATED', 'Desvinculado')
    )
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, null=True, blank=True)
    candidate = models.OneToOneField(Candidate, on_delete=models.SET_NULL, null=True, blank=True)
    employee_id = models.CharField(max_length=20, unique=True)
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    document_type = models.CharField(max_length=50)
    document_number = models.CharField(max_length=20, unique=True)
    email = models.EmailField()
    phone = models.CharField(max_length=20)
    address = models.CharField(max_length=255)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='ACTIVE')
    position = models.CharField(max_length=100)
    department = models.CharField(max_length=100)
    hire_date = models.DateField()
    termination_date = models.DateField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.first_name} {self.last_name} ({self.employee_id})"

class AffiliationType(models.Model):
    """Types of affiliations like ARL, EPS, Pension, etc."""
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True, null=True)
    
    def __str__(self):
        return self.name

class Provider(models.Model):
    """Providers of health, pension, and other services."""
    name = models.CharField(max_length=100)
    affiliation_type = models.ForeignKey(AffiliationType, on_delete=models.CASCADE)
    nit = models.CharField(max_length=20, blank=True, null=True)
    address = models.CharField(max_length=255, blank=True, null=True)
    contact_phone = models.CharField(max_length=20, blank=True, null=True)
    contact_email = models.EmailField(blank=True, null=True)
    is_active = models.BooleanField(default=True)
    
    class Meta:
        unique_together = ('name', 'affiliation_type')
    
    def __str__(self):
        return f"{self.name} - {self.affiliation_type.name}"

class Affiliation(models.Model):
    """Employee affiliation to a provider."""
    employee = models.ForeignKey(User, on_delete=models.CASCADE, related_name='affiliations')
    provider = models.ForeignKey(Provider, on_delete=models.CASCADE)
    affiliation_number = models.CharField(max_length=50, blank=True, null=True)
    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='created_affiliations')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ('employee', 'provider', 'start_date')
    
    def __str__(self):
        return f"{self.employee} - {self.provider}"
