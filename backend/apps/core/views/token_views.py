from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Custom token serializer to include user data."""
    
    def validate(self, attrs):
        data = super().validate(attrs)
        user = self.user
        
        # Add custom claims
        data.update({
            'id': user.id,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'is_staff': user.is_staff,
            'is_superuser': user.is_superuser,
        })
        
        # Add active company info if available
        active_company = user.get_active_company()
        if active_company:
            data.update({
                'active_company': {
                    'id': active_company.id,
                    'name': active_company.name,
                    'tax_id': active_company.tax_id
                }
            })
        
        return data

class CustomTokenObtainPairView(TokenObtainPairView):
    """Custom token view to use our serializer."""
    
    serializer_class = CustomTokenObtainPairSerializer
