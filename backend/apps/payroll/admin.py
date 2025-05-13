from django.contrib import admin
from .models import Contract, PayrollPeriod, PayrollItem, PayrollEntry, PayrollEntryDetail

@admin.register(Contract)
class ContractAdmin(admin.ModelAdmin):
    list_display = ('employee', 'contract_type', 'position', 'department', 'start_date', 'end_date', 'is_active')
    search_fields = ('employee__first_name', 'employee__last_name', 'position', 'department')
    list_filter = ('contract_type', 'department', 'is_active')
    date_hierarchy = 'start_date'

@admin.register(PayrollPeriod)
class PayrollPeriodAdmin(admin.ModelAdmin):
    list_display = ('name', 'start_date', 'end_date', 'is_closed', 'closed_at')
    search_fields = ('name',)
    list_filter = ('is_closed',)
    date_hierarchy = 'start_date'

@admin.register(PayrollItem)
class PayrollItemAdmin(admin.ModelAdmin):
    list_display = ('name', 'code', 'item_type', 'is_active')
    search_fields = ('name', 'code')
    list_filter = ('item_type', 'is_active')

class PayrollEntryDetailInline(admin.TabularInline):
    model = PayrollEntryDetail
    extra = 0
    fields = ('payroll_item', 'amount', 'quantity', 'notes')

@admin.register(PayrollEntry)
class PayrollEntryAdmin(admin.ModelAdmin):
    list_display = ('contract', 'period', 'total_earnings', 'total_deductions', 'net_pay', 'is_approved')
    search_fields = ('contract__employee__first_name', 'contract__employee__last_name', 'period__name')
    list_filter = ('period', 'is_approved')
    date_hierarchy = 'created_at'
    inlines = [PayrollEntryDetailInline]

@admin.register(PayrollEntryDetail)
class PayrollEntryDetailAdmin(admin.ModelAdmin):
    list_display = ('payroll_entry', 'payroll_item', 'amount', 'quantity')
    search_fields = ('payroll_entry__contract__employee__first_name', 'payroll_entry__contract__employee__last_name')
    list_filter = ('payroll_item',)
