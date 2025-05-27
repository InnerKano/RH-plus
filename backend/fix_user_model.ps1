$userModelContent = @"
# filepath: c:\Users\kevin\Documents\GitHub\RH-plus\backend\apps\core\models\user.py
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
        blank=True,
        verbose_name="Nombre de usuario"
    )
    email = models.EmailField(max_length=255, unique=True, verbose_name="Correo electrónico")
    is_active = models.BooleanField(default=True, verbose_name="Activo")
    is_staff = models.BooleanField(default=False, verbose_name="Staff")
    companies = models.ManyToManyField(
        'Company', 
        through='CompanyUser', 
        through_fields=('user', 'company'),
        verbose_name="Empresas"
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
    
    def get_active_company(self):
        """Get the user's primary company or first approved company."""
        try:
            # First try to get the primary company
            company_user = self.companyuser_set.filter(is_primary=True, status='APPROVED').first()
            if company_user:
                return company_user.company
            
            # If no primary, get first approved company
            company_user = self.companyuser_set.filter(status='APPROVED').first()
            if company_user:
                return company_user.company
                
            return None
        except:
            return None
            
    def get_roles_for_company(self, company_id):
        """Get user roles for a specific company."""
        try:
            company_user = self.companyuser_set.filter(company_id=company_id, status='APPROVED').first()
            if company_user:
                return company_user.roles.all()
            return []
        except:
            return []
            
    def has_role(self, role_name, company_id=None):
        """Check if user has a specific role in a company."""
        if company_id is None:
            company = self.get_active_company()
            if not company:
                return False
            company_id = company.id
            
        roles = self.get_roles_for_company(company_id)
        return roles.filter(name=role_name).exists()
    
    def __str__(self):
        return self.email
"@

# Write content to file
$userModelContent | Out-File -FilePath 'c:\Users\kevin\Documents\GitHub\RH-plus\backend\apps\core\models\user.py' -Encoding utf8
