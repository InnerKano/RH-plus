from django.db import models
from .user import User

# Tipos de actividades para el sistema
ACTIVITY_TYPES = (
    ('employee', 'Empleado'),
    ('candidate', 'Candidato'),
    ('payroll', 'Nómina'),
    ('training', 'Capacitación'),
    ('performance', 'Desempeño'),
)

class SystemActivity(models.Model):
    """Modelo para registrar actividades del sistema."""
    
    title = models.CharField(max_length=200, verbose_name="Título")
    description = models.TextField(verbose_name="Descripción")
    type = models.CharField(max_length=20, choices=ACTIVITY_TYPES, verbose_name="Tipo")
    timestamp = models.DateTimeField(auto_now_add=True, verbose_name="Fecha y hora")
    created_by = models.ForeignKey(
        User, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True,
        related_name='activities_created',
        verbose_name="Creado por"
    )
    
    class Meta:
        ordering = ['-timestamp']
        verbose_name = "Actividad del sistema"
        verbose_name_plural = "Actividades del sistema"
    
    def __str__(self):
        return f"{self.title} - {self.get_type_display()} - {self.timestamp.strftime('%d/%m/%Y %H:%M')}"
