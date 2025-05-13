from django.db import models
from apps.core.models import User
from apps.affiliation.models import Employee

class EvaluationType(models.Model):
    """Types of performance evaluations."""
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    frequency = models.CharField(max_length=50, help_text="e.g., Annual, Semi-Annual, Quarterly")
    is_active = models.BooleanField(default=True)
    
    def __str__(self):
        return self.name

class EvaluationCriteria(models.Model):
    """Criteria for evaluating employee performance."""
    name = models.CharField(max_length=100)
    description = models.TextField()
    evaluation_type = models.ForeignKey(EvaluationType, on_delete=models.CASCADE, related_name='criteria')
    weight = models.DecimalField(max_digits=5, decimal_places=2, help_text="Percentage weight of this criteria")
    is_active = models.BooleanField(default=True)
    
    class Meta:
        verbose_name_plural = "Evaluation Criteria"
    
    def __str__(self):
        return f"{self.name} ({self.evaluation_type})"

class EvaluationPeriod(models.Model):
    """Time period for evaluations."""
    name = models.CharField(max_length=100)
    evaluation_type = models.ForeignKey(EvaluationType, on_delete=models.CASCADE)
    start_date = models.DateField()
    end_date = models.DateField()
    is_active = models.BooleanField(default=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.name} ({self.start_date} - {self.end_date})"

class Evaluation(models.Model):
    """Employee performance evaluation."""
    STATUS_CHOICES = (
        ('DRAFT', 'Borrador'),
        ('IN_PROGRESS', 'En Progreso'),
        ('WAITING_FEEDBACK', 'Esperando Retroalimentación'),
        ('COMPLETED', 'Completada'),
    )
    
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE, related_name='evaluations')
    evaluator = models.ForeignKey(User, on_delete=models.CASCADE, related_name='conducted_evaluations')
    evaluation_period = models.ForeignKey(EvaluationPeriod, on_delete=models.CASCADE)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='DRAFT')
    overall_score = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    comments = models.TextField(blank=True, null=True)
    employee_comments = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        unique_together = ('employee', 'evaluation_period')
    
    def __str__(self):
        return f"{self.employee} - {self.evaluation_period}"

class EvaluationDetail(models.Model):
    """Detailed scores for each evaluation criteria."""
    evaluation = models.ForeignKey(Evaluation, on_delete=models.CASCADE, related_name='details')
    criteria = models.ForeignKey(EvaluationCriteria, on_delete=models.PROTECT)
    score = models.DecimalField(max_digits=5, decimal_places=2)
    comments = models.TextField(blank=True, null=True)
    
    class Meta:
        unique_together = ('evaluation', 'criteria')
    
    def __str__(self):
        return f"{self.evaluation} - {self.criteria}"

class ImprovementPlan(models.Model):
    """Improvement plan for employees based on evaluations."""
    STATUS_CHOICES = (
        ('ACTIVE', 'Activo'),
        ('COMPLETED', 'Completado'),
        ('CANCELLED', 'Cancelado'),
    )
    
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE, related_name='improvement_plans')
    evaluation = models.ForeignKey(Evaluation, on_delete=models.SET_NULL, null=True, blank=True)
    title = models.CharField(max_length=200)
    description = models.TextField()
    start_date = models.DateField()
    end_date = models.DateField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='ACTIVE')
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='created_plans')
    supervisor = models.ForeignKey(User, on_delete=models.CASCADE, related_name='supervised_plans')
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.title} - {self.employee}"

class ImprovementGoal(models.Model):
    """Individual goals within an improvement plan."""
    STATUS_CHOICES = (
        ('PENDING', 'Pendiente'),
        ('IN_PROGRESS', 'En Progreso'),
        ('COMPLETED', 'Completado'),
        ('OVERDUE', 'Atrasado'),
    )
    
    plan = models.ForeignKey(ImprovementPlan, on_delete=models.CASCADE, related_name='goals')
    description = models.TextField()
    due_date = models.DateField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    progress = models.IntegerField(default=0, help_text="Percentage of completion")
    comments = models.TextField(blank=True, null=True)
    
    def __str__(self):
        return f"{self.plan} - Goal {self.id}"
