from django.db import models
from django.utils import timezone

class Company(models.Model):
    """Model for companies in the system."""
    
    STATUS_CHOICES = (
        ('PENDING', 'Pendiente de Aprobación'),
        ('APPROVED', 'Aprobado'),
        ('REJECTED', 'Rechazado'),
    )
    
    name = models.CharField(max_length=100, verbose_name="Nombre")
    tax_id = models.CharField(max_length=50, unique=True, verbose_name="Identificación Fiscal")
    address = models.TextField(verbose_name="Dirección")
    phone = models.CharField(max_length=20, verbose_name="Teléfono")
    email = models.EmailField(max_length=255, blank=True, null=True, verbose_name="Email")
    website = models.URLField(blank=True, null=True, verbose_name="Sitio Web")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING', verbose_name="Estado")
    is_active = models.BooleanField(default=False, verbose_name="Activo")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="Fecha de Creación")
    approved_at = models.DateTimeField(null=True, blank=True, verbose_name="Fecha de Aprobación")
    approved_by = models.ForeignKey('User', on_delete=models.SET_NULL, null=True, blank=True, 
                                   related_name='approved_companies', verbose_name="Aprobado por")
    
    def __str__(self):
        return self.name
        
    def approve(self, approved_by):
        """Approve company and update related fields."""
        self.status = 'APPROVED'
        self.is_active = True
        self.approved_at = timezone.now()
        self.approved_by = approved_by
        self.save()
        
    def reject(self, rejected_by):
        """Reject company and update status."""
        self.status = 'REJECTED'
        self.is_active = False
        self.approved_by = rejected_by
        self.approved_at = timezone.now()
        self.save()
    
    class Meta:
        verbose_name = "Empresa"
        verbose_name_plural = "Empresas"
