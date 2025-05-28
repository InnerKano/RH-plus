"""
URL Configuration for RH Plus project.
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularRedocView,
    SpectacularSwaggerView,
)

# Schema view para Swagger/OpenAPI
schema_view = get_schema_view(
    openapi.Info(
        title="RH Plus API",
        default_version='v1',
        description="API de RH Plus: Sistema de Gestión de Recursos Humanos",
        terms_of_service="https://www.rhplus.com/terms/",
        contact=openapi.Contact(email="contact@rhplus.com"),
        license=openapi.License(name="Proprietary License"),
    ),
    public=True,
    permission_classes=(permissions.AllowAny,),
)

urlpatterns = [
    path('admin/', admin.site.urls),
      # Documentación con Swagger
    path('api/schema/swagger-ui/', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    path('api/schema/', schema_view.with_ui('swagger', cache_timeout=0)),  # URL alternativa
    path('api/docs/', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),
    
    # JWT Authentication
    path('api/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # Include app urls
    path('api/core/', include('apps.core.urls')),
    path('api/selection/', include('apps.selection.urls')),
    path('api/affiliation/', include('apps.affiliation.urls')),
    path('api/payroll/', include('apps.payroll.urls')),
    path('api/performance/', include('apps.performance.urls')),
    path('api/training/', include('apps.training.urls')),
    
    # API Documentation
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/schema/swagger-ui/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/schema/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
]
