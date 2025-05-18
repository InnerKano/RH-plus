from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager

class UserManager(BaseUserManager):
    """Manager for custom user model."""
    
    def create_user(self, email, password=None, **extra_fields):
        """Create and save a new user."""
        if not email:
            raise ValueError('Users must have an email address')
        
        import uuid
        username = extra_fields.get('username') 
        if not username:
            # Create a unique username based on the email or a random string
            username = email.split('@')[0] + str(uuid.uuid4())[:8]
            extra_fields['username'] = username
            
        user = self.model(email=self.normalize_email(email), **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password):
        """Create and save a new superuser."""
        user = self.create_user(email, password)
        user.is_staff = True
        user.is_superuser = True
        user.save(using=self._db)
        return user

class User(AbstractUser):
    """Custom user model with email as the unique identifier."""
    
    username = models.CharField(
        max_length=150, 
        unique=True,
        null=True,
        blank=True
    )
    email = models.EmailField(max_length=255, unique=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    
    # Añadimos related_name para evitar conflictos con el modelo User de Django
    groups = models.ManyToManyField(
        'auth.Group',
        verbose_name='groups',
        blank=True,
        help_text='The groups this user belongs to.',
        related_name='core_user_set',  # Nombre personalizado para evitar conflictos
        related_query_name='core_user',
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission',
        verbose_name='user permissions',
        blank=True,
        help_text='Specific permissions for this user.',
        related_name='core_user_set',  # Nombre personalizado para evitar conflictos
        related_query_name='core_user',
    )
    
    objects = UserManager()
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

class Role(models.Model):
    """User roles within the system."""
    
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    
    def __str__(self):
        return self.name

class UserRole(models.Model):
    """Many-to-many relationship between users and roles."""
    
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    role = models.ForeignKey(Role, on_delete=models.CASCADE)
    
    class Meta:
        unique_together = ('user', 'role')

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
