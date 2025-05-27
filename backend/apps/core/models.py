from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager

# User roles hierarchy
USER_ROLES = (
    ('SUPERUSER', 'Superusuario'),
    ('ADMIN', 'Administrador'),
    ('HR_MANAGER', 'Personal de RRHH'),
    ('SUPERVISOR', 'Supervisor/Gerente'),
    ('EMPLOYEE', 'Empleado'),
    ('USER', 'Usuario Básico'),  # Default role for new registrations
)

# Role hierarchy for permission checking
ROLE_HIERARCHY = {
    'SUPERUSER': 0,
    'ADMIN': 1,
    'HR_MANAGER': 2,
    'SUPERVISOR': 3,
    'EMPLOYEE': 4,
    'USER': 5,
}

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

    def create_superuser(self, email, password, **extra_fields):
        """Create and save a new superuser."""
        # Set default values for superuser
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('role', 'SUPERUSER')  # Set role to SUPERUSER
        
        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')
        
        user = self.create_user(email, password, **extra_fields)
        print(f"Created superuser with role: {user.role}")
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
    
    # Add role field
    role = models.CharField(
        max_length=20, 
        choices=USER_ROLES, 
        default='USER',
        verbose_name="Rol"
    )
    
    # Add department for supervisors to manage their teams
    department = models.CharField(
        max_length=100, 
        blank=True, 
        null=True,
        verbose_name="Departamento"
    )
    
    # Add manager field for hierarchy
    manager = models.ForeignKey(
        'self',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='managed_users',
        verbose_name="Supervisor"
    )
    
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

    def can_manage_user(self, target_user):
        """Check if this user can manage another user based on role hierarchy."""
        print(f"Checking if {self.email} (role: {self.role}) can manage user with role: {target_user.role}")
        
        if self.role == 'SUPERUSER':
            return True
        
        current_level = ROLE_HIERARCHY.get(self.role, 999)
        target_level = ROLE_HIERARCHY.get(target_user.role, 999)
        
        # Users can only manage users with lower hierarchy levels
        if current_level < target_level:
            # Additional checks based on role
            if self.role == 'ADMIN':
                # Admins cannot create other admins or superusers
                return target_user.role not in ['ADMIN', 'SUPERUSER']
            elif self.role == 'HR_MANAGER':
                # HR can only manage supervisors and employees
                return target_user.role in ['SUPERVISOR', 'EMPLOYEE', 'USER']
            elif self.role == 'SUPERVISOR':
                # Supervisors can only manage employees in their department
                return (target_user.role in ['EMPLOYEE', 'USER'] and 
                       target_user.department == self.department)
        
        return False
    
    def can_access_module(self, module_name):
        """Check if user can access a specific module."""
        module_permissions = {
            'selection': ['SUPERUSER', 'ADMIN', 'HR_MANAGER', 'SUPERVISOR'],
            'affiliation': ['SUPERUSER', 'ADMIN', 'HR_MANAGER', 'SUPERVISOR', 'EMPLOYEE'],
            'payroll': ['SUPERUSER', 'ADMIN', 'HR_MANAGER'],
            'performance': ['SUPERUSER', 'ADMIN', 'HR_MANAGER', 'SUPERVISOR', 'EMPLOYEE'],
            'training': ['SUPERUSER', 'ADMIN', 'HR_MANAGER', 'SUPERVISOR', 'EMPLOYEE'],
            'core': ['SUPERUSER', 'ADMIN', 'HR_MANAGER', 'SUPERVISOR'],
        }
        
        result = self.role in module_permissions.get(module_name, [])
        print(f"User {self.email} (role: {self.role}) can access {module_name}: {result}")
        return result
    
    def get_managed_users(self):
        """Get users that this user can manage."""
        print(f"Getting managed users for {self.email} (role: {self.role})")
        
        if self.role == 'SUPERUSER':
            return User.objects.all()
        elif self.role == 'ADMIN':
            return User.objects.exclude(role__in=['ADMIN', 'SUPERUSER'])
        elif self.role == 'HR_MANAGER':
            return User.objects.filter(role__in=['SUPERVISOR', 'EMPLOYEE', 'USER'])
        elif self.role == 'SUPERVISOR':
            return User.objects.filter(
                role__in=['EMPLOYEE', 'USER'],
                department=self.department
            )
        else:
            return User.objects.none()

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
