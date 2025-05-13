from django.db import models
from apps.core.models import User
from apps.affiliation.models import Employee

class TrainingType(models.Model):
    """Types of training like induction, re-induction, skill development, etc."""
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    is_active = models.BooleanField(default=True)
    
    def __str__(self):
        return self.name

class TrainingProgram(models.Model):
    """Training program entity."""
    name = models.CharField(max_length=200)
    description = models.TextField()
    training_type = models.ForeignKey(TrainingType, on_delete=models.CASCADE)
    duration_hours = models.DecimalField(max_digits=5, decimal_places=2)
    materials = models.TextField(blank=True, null=True)
    objectives = models.TextField()
    is_active = models.BooleanField(default=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.name

class TrainingSession(models.Model):
    """Individual training session of a program."""
    STATUS_CHOICES = (
        ('SCHEDULED', 'Programado'),
        ('IN_PROGRESS', 'En Progreso'),
        ('COMPLETED', 'Completado'),
        ('CANCELLED', 'Cancelado'),
    )
    
    program = models.ForeignKey(TrainingProgram, on_delete=models.CASCADE, related_name='sessions')
    session_date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    location = models.CharField(max_length=200)
    instructor = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='instructed_sessions')
    max_participants = models.PositiveIntegerField(default=20)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='SCHEDULED')
    notes = models.TextField(blank=True, null=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='created_sessions')
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['session_date', 'start_time']
    
    def __str__(self):
        return f"{self.program} - {self.session_date}"

class TrainingAttendance(models.Model):
    """Employee attendance in a training session."""
    STATUS_CHOICES = (
        ('REGISTERED', 'Registrado'),
        ('ATTENDED', 'Asistió'),
        ('MISSED', 'No Asistió'),
        ('EXCUSED', 'Excusado'),
    )
    
    session = models.ForeignKey(TrainingSession, on_delete=models.CASCADE, related_name='attendances')
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE, related_name='training_attendances')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='REGISTERED')
    evaluation_score = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    comments = models.TextField(blank=True, null=True)
    registered_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    registered_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        unique_together = ('session', 'employee')
    
    def __str__(self):
        return f"{self.employee} - {self.session}"

class TrainingEvaluation(models.Model):
    """Evaluation of a training program."""
    RATING_CHOICES = (
        (1, 'Muy Insatisfecho'),
        (2, 'Insatisfecho'),
        (3, 'Neutral'),
        (4, 'Satisfecho'),
        (5, 'Muy Satisfecho'),
    )
    
    attendance = models.OneToOneField(TrainingAttendance, on_delete=models.CASCADE, related_name='evaluation')
    content_rating = models.PositiveSmallIntegerField(choices=RATING_CHOICES)
    instructor_rating = models.PositiveSmallIntegerField(choices=RATING_CHOICES)
    materials_rating = models.PositiveSmallIntegerField(choices=RATING_CHOICES)
    usefulness_rating = models.PositiveSmallIntegerField(choices=RATING_CHOICES)
    overall_rating = models.PositiveSmallIntegerField(choices=RATING_CHOICES)
    feedback = models.TextField(blank=True, null=True)
    submitted_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Evaluation by {self.attendance.employee} for {self.attendance.session.program}"
