from django.db import models
from django.utils import timezone

class Role(models.Model):
    """User roles within the system."""
    
    ROLE_CHOICES = (
        ('SUPERADMIN', 'Super Administrador'),
        ('COMPANYADMIN', 'Administrador de Empresa'),
        ('HRMANAGER', 'Gerente de RRHH'),
        ('SUPERVISOR', 'Supervisor/Gerente'),
        ('EMPLOYEE', 'Empleado'),
    )
    
    name = models.CharField(max_length=50, choices=ROLE_CHOICES, verbose_name="Nombre")
    description = models.TextField(blank=True, null=True, verbose_name="Descripción")
    
    def __str__(self):
        return self.get_name_display()
    
    class Meta:
        verbose_name = "Rol"
        verbose_name_plural = "Roles"
