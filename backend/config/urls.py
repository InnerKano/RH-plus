"""
URL Configuration for RH Plus project.
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi

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
    
    # Include app urls
    path('api/core/', include('apps.core.urls')),
    path('api/selection/', include('apps.selection.urls')),
    path('api/affiliation/', include('apps.affiliation.urls')),
    path('api/payroll/', include('apps.payroll.urls')),
    path('api/performance/', include('apps.performance.urls')),
    path('api/training/', include('apps.training.urls')),
]
