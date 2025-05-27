from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from django.utils import timezone
from ..models import User, Role, Company, CompanyUser

class UserSerializer(serializers.ModelSerializer):
    """Serializer for the User model."""
    
    roles = serializers.SerializerMethodField()
    active_company = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = ('id', 'email', 'first_name', 'last_name', 'is_active', 'is_staff', 'roles', 'active_company')
        read_only_fields = ('id',)
        
    def get_roles(self, obj):
        user_roles = obj.userrole_set.all().select_related('role')
        return [{'id': role.role.id, 'name': role.role.name} for role in user_roles]
    
    def get_active_company(self, obj):
        active_company = obj.get_active_company()
        if active_company:
            return {
                'id': active_company.id,
                'name': active_company.name,
                'tax_id': active_company.tax_id
            }
        return None

class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for user registration with company information."""
    
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True, required=True)
    
    # Company fields
    register_type = serializers.ChoiceField(
        choices=[('new_company', 'Nueva Empresa'), ('join_company', 'Unirse a Empresa'), ('no_company', 'Sin Empresa')],
        write_only=True, 
        required=True
    )
    
    # Fields for new company
    company_name = serializers.CharField(write_only=True, required=False)
    company_tax_id = serializers.CharField(write_only=True, required=False)
    company_address = serializers.CharField(write_only=True, required=False)
    company_phone = serializers.CharField(write_only=True, required=False)
    company_email = serializers.EmailField(write_only=True, required=False)
    company_website = serializers.URLField(write_only=True, required=False, allow_blank=True)
    
    # Fields for joining existing company
    company_id = serializers.IntegerField(write_only=True, required=False)
    
    class Meta:
        model = User
        fields = (
            'email', 'password', 'password_confirm', 'first_name', 'last_name',
            'register_type', 'company_name', 'company_tax_id', 'company_address', 
            'company_phone', 'company_email', 'company_website', 'company_id'
        )
        
    def validate(self, attrs):
        # Validate passwords match
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({"password_confirm": "Las contraseñas no coinciden"})
        
        # Validate register type specific fields
        register_type = attrs.get('register_type')
        
        if register_type == 'new_company':
            required_fields = ['company_name', 'company_tax_id', 'company_address', 'company_phone']
            for field in required_fields:
                if not attrs.get(field):
                    raise serializers.ValidationError({field: f"Este campo es requerido para crear una nueva empresa."})
            
            # Validate tax_id is unique
            if Company.objects.filter(tax_id=attrs.get('company_tax_id')).exists():
                raise serializers.ValidationError({"company_tax_id": "Una empresa con este ID fiscal ya existe."})
                
        elif register_type == 'join_company':
            if not attrs.get('company_id'):
                raise serializers.ValidationError({"company_id": "Se requiere el ID de la empresa para unirse."})
            
            # Validate company exists
            try:
                company = Company.objects.get(id=attrs.get('company_id'))
                if not company.is_active:
                    raise serializers.ValidationError({"company_id": "Esta empresa no está activa."})
            except Company.DoesNotExist:
                raise serializers.ValidationError({"company_id": "La empresa especificada no existe."})
        
        return attrs
    
    def create(self, validated_data):
        register_type = validated_data.pop('register_type')
        validated_data.pop('password_confirm')
        
        # Create user
        user = User.objects.create_user(
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
        )
        
        # Handle company registration
        if register_type == 'new_company':
            # Create new company
            company = Company.objects.create(
                name=validated_data.pop('company_name'),
                tax_id=validated_data.pop('company_tax_id'),
                address=validated_data.pop('company_address'),
                phone=validated_data.pop('company_phone'),
                email=validated_data.pop('company_email', None),
                website=validated_data.pop('company_website', None),
                status='PENDING',
                is_active=False
            )
            
            # Create CompanyUser relationship with COMPANYADMIN role
            company_user = CompanyUser.objects.create(
                user=user,
                company=company,
                is_primary=True,
                status='PENDING'
            )
            
            # Get or create COMPANYADMIN role
            admin_role, _ = Role.objects.get_or_create(
                name='COMPANYADMIN',
                defaults={'description': 'Administrador de Empresa'}
            )
            
            company_user.roles.add(admin_role)
            
            # Notify superadmins
            self._notify_superadmins(company, user)
            
        elif register_type == 'join_company':
            # Join existing company
            company = Company.objects.get(id=validated_data.pop('company_id'))
            
            # Create CompanyUser relationship with EMPLOYEE role
            company_user = CompanyUser.objects.create(
                user=user,
                company=company,
                is_primary=True,
                status='PENDING'
            )
            
            # Get or create EMPLOYEE role
            employee_role, _ = Role.objects.get_or_create(
                name='EMPLOYEE',
                defaults={'description': 'Empleado'}
            )
            
            company_user.roles.add(employee_role)
            
            # Notify company admins
            self._notify_company_admins(company, user)
        
        return user
    
    def _notify_superadmins(self, company, user):
        """Notify superadmins about new company registration."""
        # Implementation will depend on notification system
        pass
    
    def _notify_company_admins(self, company, user):
        """Notify company admins about new user registration."""
        # Implementation will depend on notification system
        pass
