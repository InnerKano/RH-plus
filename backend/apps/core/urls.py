from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    UserViewSet, RoleViewSet, 
    CustomTokenObtainPairView, ActivityViewSet,
    CompanyViewSet, CompanyUserViewSet
)

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='user')
router.register(r'roles', RoleViewSet, basename='role')
router.register(r'activities', ActivityViewSet, basename='activity')
router.register(r'companies', CompanyViewSet, basename='company')
router.register(r'company-users', CompanyUserViewSet, basename='company-user')

urlpatterns = [
    path('', include(router.urls)),
    path('token/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]
