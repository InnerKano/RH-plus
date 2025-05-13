"""
URL Configuration for RH Plus project.
"""
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    # Include app urls
    path('api/core/', include('apps.core.urls')),
    path('api/selection/', include('apps.selection.urls')),
    path('api/affiliation/', include('apps.affiliation.urls')),
    path('api/payroll/', include('apps.payroll.urls')),
    path('api/performance/', include('apps.performance.urls')),
    path('api/training/', include('apps.training.urls')),
]
