from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, Role, Company, CompanyUser, SystemActivity

import uuid

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """Admin for custom User model."""
    list_display = ('email', 'first_name', 'last_name', 'is_staff', 'is_active')
    search_fields = ('email', 'first_name', 'last_name')
    ordering = ('email',)
    list_filter = ('is_active', 'is_staff')
    
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal Info', {'fields': ('first_name', 'last_name')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser',
                                    'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )
    
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'password1', 'password2', 'is_active', 'is_staff')
        }),
    )
    
    def save_model(self, request, obj, form, change):
        """Ensure username is unique before saving."""
        if not obj.username:
            # Create a unique username based on the email or a random string
            obj.username = obj.email.split('@')[0] + str(uuid.uuid4())[:8]
        
        # Call the parent save_model method
        super().save_model(request, obj, form, change)

@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    """Admin for Role model."""
    list_display = ('name', 'description')
    search_fields = ('name',)

@admin.register(Company)
class CompanyAdmin(admin.ModelAdmin):
    """Admin for Company model."""
    list_display = ('name', 'tax_id', 'status', 'is_active', 'created_at', 'approved_at')
    search_fields = ('name', 'tax_id')
    list_filter = ('status', 'is_active')
    readonly_fields = ('status', 'is_active', 'created_at', 'approved_at', 'approved_by')
    fieldsets = (
        (None, {'fields': ('name', 'tax_id', 'address', 'phone', 'email', 'website')}),
        ('Status', {'fields': ('status', 'is_active', 'approved_by', 'approved_at', 'created_at')}),
    )

@admin.register(CompanyUser)
class CompanyUserAdmin(admin.ModelAdmin):
    """Admin for CompanyUser model."""
    list_display = ('user', 'company', 'status', 'is_primary', 'created_at', 'approved_at')
    search_fields = ('user__email', 'company__name')
    list_filter = ('status', 'is_primary', 'company')
    readonly_fields = ('created_at', 'approved_at', 'approved_by')
    filter_horizontal = ('roles',)
    
    fieldsets = (
        (None, {'fields': ('user', 'company', 'roles', 'is_primary')}),
        ('Status', {'fields': ('status', 'approved_by', 'approved_at', 'created_at')}),
    )

@admin.register(SystemActivity)
class SystemActivityAdmin(admin.ModelAdmin):
    """Admin for SystemActivity model."""
    list_display = ('title', 'type', 'company', 'timestamp')
    search_fields = ('title', 'description')
    list_filter = ('type', 'company', 'timestamp')
    readonly_fields = ('timestamp',)
