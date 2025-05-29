from django.db import models
from apps.core.models import User

class SelectionStage(models.Model):
    """Selection stage model."""
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    order = models.IntegerField(default=0)
    
    def __str__(self):
        return self.name
    
    class Meta:
        ordering = ['order']

class Candidate(models.Model):
    """Candidate model for selection process."""
    GENDER_CHOICES = (
        ('M', 'Masculino'),
        ('F', 'Femenino'),
        ('O', 'Otro')
    )
    
    STATUS_CHOICES = (
        ('ACTIVE', 'Activo'),
        ('HIRED', 'Contratado'),
        ('REJECTED', 'Rechazado'),
        ('WITHDRAWN', 'Retirado')
    )
    
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    document_type = models.CharField(max_length=50)
    document_number = models.CharField(max_length=20)
    email = models.EmailField()
    phone = models.CharField(max_length=20)
    gender = models.CharField(max_length=1, choices=GENDER_CHOICES)
    birth_date = models.DateField()
    address = models.CharField(max_length=255)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='ACTIVE')
    current_stage = models.ForeignKey(SelectionStage, on_delete=models.SET_NULL, null=True, blank=True, default=None)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.first_name} {self.last_name}"

class SelectionProcess(models.Model):
    """Selection process for a job position."""
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_by = models.ForeignKey(User, on_delete=models.PROTECT, related_name='created_processes')
    candidates = models.ManyToManyField(Candidate, through='ProcessCandidate')
    
    def __str__(self):
        return self.name

class ProcessCandidate(models.Model):
    """Many-to-many relationship between selection processes and candidates with additional data."""
    process = models.ForeignKey(SelectionProcess, on_delete=models.CASCADE)
    candidate = models.ForeignKey(Candidate, on_delete=models.CASCADE)
    current_stage = models.ForeignKey(SelectionStage, on_delete=models.PROTECT)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ('process', 'candidate')

class CandidateDocument(models.Model):
    """Documents uploaded by or for candidates."""
    candidate = models.ForeignKey(Candidate, on_delete=models.CASCADE, related_name='documents')
    document_type = models.CharField(max_length=50)
    file = models.FileField(upload_to='candidate_documents/')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.document_type} - {self.candidate}"
