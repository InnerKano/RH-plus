from rest_framework import serializers
from ..models import CompanyUser, Role, User, Company

class CompanyUserSerializer(serializers.ModelSerializer):
    """Serializer for the CompanyUser model."""
    
    user_email = serializers.EmailField(source='user.email', read_only=True)
    user_name = serializers.SerializerMethodField()
    company_name = serializers.CharField(source='company.name', read_only=True)
    roles_display = serializers.SerializerMethodField()
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    
    class Meta:
        model = CompanyUser
        fields = ('id', 'user', 'user_email', 'user_name', 'company', 'company_name', 
                 'roles', 'roles_display', 'is_primary', 'status', 'status_display', 
                 'created_at', 'approved_at')
        read_only_fields = ('id', 'created_at', 'approved_at')
    
    def get_user_name(self, obj):
        return f"{obj.user.first_name} {obj.user.last_name}".strip() or obj.user.email
    
    def get_roles_display(self, obj):
        return [role.get_name_display() for role in obj.roles.all()]

class CompanyUserDetailSerializer(CompanyUserSerializer):
    """Detailed serializer for the CompanyUser model."""
    
    approved_by_email = serializers.EmailField(source='approved_by.email', read_only=True)
    
    class Meta(CompanyUserSerializer.Meta):
        fields = CompanyUserSerializer.Meta.fields + ('approved_by', 'approved_by_email')
        read_only_fields = CompanyUserSerializer.Meta.read_only_fields + ('approved_by',)

class CompanyUserCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating CompanyUser relationships."""
    
    class Meta:
        model = CompanyUser
        fields = ('user', 'company', 'roles', 'is_primary')
        
    def validate(self, attrs):
        """Validate user doesn't already have a relationship with the company."""
        user = attrs.get('user')
        company = attrs.get('company')
        
        if CompanyUser.objects.filter(user=user, company=company).exists():
            raise serializers.ValidationError({"detail": "El usuario ya está asociado con esta empresa."})
        
        return attrs
