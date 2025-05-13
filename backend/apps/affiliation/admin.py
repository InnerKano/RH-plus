from django.contrib import admin
from .models import Employee, AffiliationType, Provider, Affiliation

@admin.register(Employee)
class EmployeeAdmin(admin.ModelAdmin):
    list_display = ('employee_id', 'first_name', 'last_name', 'position', 'department', 'status', 'hire_date')
    search_fields = ('first_name', 'last_name', 'employee_id', 'document_number', 'email')
    list_filter = ('status', 'department', 'position')
    date_hierarchy = 'hire_date'

@admin.register(AffiliationType)
class AffiliationTypeAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')
    search_fields = ('name',)

@admin.register(Provider)
class ProviderAdmin(admin.ModelAdmin):
    list_display = ('name', 'affiliation_type', 'nit', 'contact_phone', 'contact_email', 'is_active')
    search_fields = ('name', 'nit')
    list_filter = ('affiliation_type', 'is_active')

@admin.register(Affiliation)
class AffiliationAdmin(admin.ModelAdmin):
    list_display = ('employee', 'provider', 'affiliation_number', 'start_date', 'end_date', 'is_active')
    search_fields = ('employee__first_name', 'employee__last_name', 'affiliation_number')
    list_filter = ('provider__affiliation_type', 'is_active', 'provider')
    date_hierarchy = 'start_date'
