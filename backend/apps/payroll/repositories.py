"""Repository pattern for Payroll app."""
from .models import Contract, PayrollPeriod, PayrollEntry, PayrollItem
from django.db.models import Q

class ContractRepository:
    """Repository for Contract model."""
    
    @staticmethod
    def get_active_contracts():
        """Return all active contracts."""
        return Contract.objects.filter(is_active=True)
    
    @staticmethod
    def get_by_employee(employee_id):
        """Return active contracts for an employee."""
        return Contract.objects.filter(
            employee_id=employee_id,
            is_active=True
        )
    
    @staticmethod
    def get_current_contract(employee_id):
        """Return current active contract for an employee."""
        return Contract.objects.filter(
            employee_id=employee_id,
            is_active=True
        ).order_by('-start_date').first()

class PayrollPeriodRepository:
    """Repository for PayrollPeriod model."""
    
    @staticmethod
    def get_open_periods():
        """Return all open payroll periods."""
        return PayrollPeriod.objects.filter(is_closed=False)
    
    @staticmethod
    def get_current_period():
        """Return the most recent open period."""
        return PayrollPeriod.objects.filter(is_closed=False).order_by('-end_date').first()

class PayrollEntryRepository:
    """Repository for PayrollEntry model."""
    
    @staticmethod
    def get_by_period(period_id):
        """Return all entries for a specific period."""
        return PayrollEntry.objects.filter(period_id=period_id)
    
    @staticmethod
    def get_by_employee(employee_id):
        """Return all entries for a specific employee."""
        return PayrollEntry.objects.filter(
            contract__employee_id=employee_id
        ).order_by('-period__end_date')
    
    @staticmethod
    def get_pending_approval():
        """Return all entries pending approval."""
        return PayrollEntry.objects.filter(is_approved=False)

class PayrollItemRepository:
    """Repository for PayrollItem model."""
    
    @staticmethod
    def get_active_items():
        """Return all active payroll items."""
        return PayrollItem.objects.filter(is_active=True)
    
    @staticmethod
    def get_by_type(item_type):
        """Return all active payroll items of a specific type."""
        return PayrollItem.objects.filter(
            item_type=item_type,
            is_active=True
        )
