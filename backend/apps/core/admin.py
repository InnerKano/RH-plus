from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, Role, UserRole

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

@admin.register(Role)
class RoleAdmin(admin.ModelAdmin):
    """Admin for Role model."""
    list_display = ('name', 'description')
    search_fields = ('name',)

@admin.register(UserRole)
class UserRoleAdmin(admin.ModelAdmin):
    """Admin for UserRole model."""
    list_display = ('user', 'role')
    search_fields = ('user__email', 'role__name')
    list_filter = ('role',)
