from django.db import models
from django.utils import timezone

class CompanyUser(models.Model):
    """Relationship between users and companies with assigned roles."""
    
    STATUS_CHOICES = (
        ('PENDING', 'Pendiente de Aprobación'),
        ('APPROVED', 'Aprobado'),
        ('REJECTED', 'Rechazado'),
    )
    
    user = models.ForeignKey('User', on_delete=models.CASCADE, verbose_name="Usuario")
    company = models.ForeignKey('Company', on_delete=models.CASCADE, verbose_name="Empresa")
    roles = models.ManyToManyField('Role', verbose_name="Roles")
    is_primary = models.BooleanField(default=False, verbose_name="Empresa Principal")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING', verbose_name="Estado")
    approved_by = models.ForeignKey('User', null=True, blank=True, on_delete=models.SET_NULL, 
                                  related_name='approved_users', verbose_name="Aprobado por")
    approved_at = models.DateTimeField(null=True, blank=True, verbose_name="Fecha de Aprobación")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="Fecha de Creación")
    
    def __str__(self):
        return f"{self.user.email} at {self.company.name}"
    
    def approve(self, approved_by):
        """Approve user relationship and update related fields."""
        self.status = 'APPROVED'
        self.approved_by = approved_by
        self.approved_at = timezone.now()
        self.save()
    
    def reject(self, rejected_by):
        """Reject user relationship and update status."""
        self.status = 'REJECTED'
        self.approved_by = rejected_by
        self.approved_at = timezone.now()
        self.save()
    
    class Meta:
        unique_together = ('user', 'company')
        verbose_name = "Usuario de Empresa"
        verbose_name_plural = "Usuarios de Empresas"
