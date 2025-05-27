from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from ..models import CompanyUser, Company, Role, User
from ..serializers import (
    CompanyUserSerializer, CompanyUserDetailSerializer, CompanyUserCreateSerializer
)

class CompanyUserViewSet(viewsets.ModelViewSet):
    """ViewSet for managing company users."""
    
    queryset = CompanyUser.objects.all().order_by('-created_at')
    serializer_class = CompanyUserSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_serializer_class(self):
        if self.action == 'retrieve':
            return CompanyUserDetailSerializer
        elif self.action == 'create':
            return CompanyUserCreateSerializer
        return self.serializer_class
    
    def get_queryset(self):
        """Filter company users based on user's permissions."""
        user = self.request.user
        
        # SuperAdmin can see all company users
        if user.is_superuser:
            return self.queryset
        
        # CompanyAdmin can see users for their companies
        admin_companies = Company.objects.filter(
            companyuser__user=user,
            companyuser__roles__name='COMPANYADMIN',
            companyuser__status='APPROVED'
        )
        
        if admin_companies.exists():
            return self.queryset.filter(company__in=admin_companies)
        
        # Other users can only see their own company relationships
        return self.queryset.filter(user=user)
    
    def perform_create(self, serializer):
        """Set initial status to PENDING."""
        serializer.save(status='PENDING')
    
    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        """Approve a company user relationship."""
        company_user = self.get_object()
        user = request.user
        
        # Check permissions (SuperAdmin or CompanyAdmin of the same company)
        if not user.is_superuser:
            is_company_admin = CompanyUser.objects.filter(
                user=user,
                company=company_user.company,
                roles__name='COMPANYADMIN',
                status='APPROVED'
            ).exists()
            
            if not is_company_admin:
                return Response(
                    {"detail": "No tienes permisos para aprobar usuarios en esta empresa."},
                    status=status.HTTP_403_FORBIDDEN
                )
        
        if company_user.status == 'APPROVED':
            return Response(
                {"detail": "Este usuario ya está aprobado."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        company_user.approve(user)
        
        return Response(
            {"detail": "Usuario aprobado correctamente."},
            status=status.HTTP_200_OK
        )
    
    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        """Reject a company user relationship."""
        company_user = self.get_object()
        user = request.user
        
        # Check permissions (SuperAdmin or CompanyAdmin of the same company)
        if not user.is_superuser:
            is_company_admin = CompanyUser.objects.filter(
                user=user,
                company=company_user.company,
                roles__name='COMPANYADMIN',
                status='APPROVED'
            ).exists()
            
            if not is_company_admin:
                return Response(
                    {"detail": "No tienes permisos para rechazar usuarios en esta empresa."},
                    status=status.HTTP_403_FORBIDDEN
                )
        
        if company_user.status == 'REJECTED':
            return Response(
                {"detail": "Este usuario ya fue rechazado."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        company_user.reject(user)
        
        return Response(
            {"detail": "Usuario rechazado correctamente."},
            status=status.HTTP_200_OK
        )
    
    @action(detail=False, methods=['get'])
    def pending(self, request):
        """List pending company user relationships."""
        user = request.user
        
        # SuperAdmin can see all pending relationships
        if user.is_superuser:
            pending_users = CompanyUser.objects.filter(status='PENDING').order_by('-created_at')
        else:
            # CompanyAdmin can see pending users for their companies
            admin_companies = Company.objects.filter(
                companyuser__user=user,
                companyuser__roles__name='COMPANYADMIN',
                companyuser__status='APPROVED'
            )
            
            pending_users = CompanyUser.objects.filter(
                company__in=admin_companies,
                status='PENDING'
            ).order_by('-created_at')
        
        serializer = self.get_serializer(pending_users, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def update_roles(self, request, pk=None):
        """Update roles for a company user."""
        company_user = self.get_object()
        user = request.user
        
        # Check permissions (SuperAdmin or CompanyAdmin of the same company)
        if not user.is_superuser:
            is_company_admin = CompanyUser.objects.filter(
                user=user,
                company=company_user.company,
                roles__name='COMPANYADMIN',
                status='APPROVED'
            ).exists()
            
            if not is_company_admin:
                return Response(
                    {"detail": "No tienes permisos para actualizar roles en esta empresa."},
                    status=status.HTTP_403_FORBIDDEN
                )
        
        # Get roles from request
        role_ids = request.data.get('roles', [])
        if not role_ids:
            return Response(
                {"detail": "Debes especificar al menos un rol."},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Update roles
        roles = Role.objects.filter(id__in=role_ids)
        company_user.roles.clear()
        company_user.roles.add(*roles)
        
        return Response(
            {"detail": "Roles actualizados correctamente."},
            status=status.HTTP_200_OK
        )
    
    @action(detail=False, methods=['get'])
    def my_companies(self, request):
        """List companies where the current user is approved."""
        user = request.user
        
        company_users = CompanyUser.objects.filter(
            user=user,
            status='APPROVED'
        ).select_related('company').order_by('-is_primary', 'company__name')
        
        serializer = self.get_serializer(company_users, many=True)
        return Response(serializer.data)
