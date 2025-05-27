from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from ..models import Company, CompanyUser, Role, User
from ..serializers import (
    CompanySerializer, CompanyDetailSerializer, CompanyRegistrationSerializer,
    CompanyUserSerializer, CompanyUserDetailSerializer, CompanyUserCreateSerializer
)

class CompanyViewSet(viewsets.ModelViewSet):
    """ViewSet for managing companies."""
    
    queryset = Company.objects.all().order_by('-created_at')
    serializer_class = CompanySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_serializer_class(self):
        if self.action == 'retrieve':
            return CompanyDetailSerializer
        return self.serializer_class
    
    def get_queryset(self):
        """Filter companies based on user's permissions."""
        user = self.request.user
        
        # SuperAdmin can see all companies
        if user.is_superuser:
            return self.queryset
        
        # Other users can only see their associated companies
        return Company.objects.filter(companyuser__user=user).distinct().order_by('-created_at')
    
    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        """Approve a company registration."""
        company = self.get_object()
        user = request.user
        
        # Only SuperAdmin can approve companies
        if not user.is_superuser:
            return Response(
                {"detail": "No tienes permisos para aprobar empresas."},
                status=status.HTTP_403_FORBIDDEN
            )
        
        if company.status == 'APPROVED':
            return Response(
                {"detail": "Esta empresa ya está aprobada."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        company.approve(user)
        
        # Also approve the company admin
        company_admin = CompanyUser.objects.filter(
            company=company,
            roles__name='COMPANYADMIN',
            status='PENDING'
        ).first()
        
        if company_admin:
            company_admin.approve(user)
        
        return Response(
            {"detail": "Empresa aprobada correctamente."},
            status=status.HTTP_200_OK
        )
    
    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        """Reject a company registration."""
        company = self.get_object()
        user = request.user
        
        # Only SuperAdmin can reject companies
        if not user.is_superuser:
            return Response(
                {"detail": "No tienes permisos para rechazar empresas."},
                status=status.HTTP_403_FORBIDDEN
            )
        
        if company.status == 'REJECTED':
            return Response(
                {"detail": "Esta empresa ya fue rechazada."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        company.reject(user)
        
        # Also reject the company admin
        company_admin = CompanyUser.objects.filter(
            company=company,
            roles__name='COMPANYADMIN',
            status='PENDING'
        ).first()
        
        if company_admin:
            company_admin.reject(user)
        
        return Response(
            {"detail": "Empresa rechazada correctamente."},
            status=status.HTTP_200_OK
        )
    
    @action(detail=False, methods=['get'])
    def pending(self, request):
        """List companies pending approval."""
        user = request.user
        
        # Only SuperAdmin can see pending companies
        if not user.is_superuser:
            return Response(
                {"detail": "No tienes permisos para ver empresas pendientes."},
                status=status.HTTP_403_FORBIDDEN
            )
        
        pending_companies = Company.objects.filter(status='PENDING').order_by('-created_at')
        serializer = self.get_serializer(pending_companies, many=True)
        
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def active(self, request):
        """List active companies."""
        active_companies = self.get_queryset().filter(is_active=True).order_by('name')
        serializer = self.get_serializer(active_companies, many=True)
        
        return Response(serializer.data)
