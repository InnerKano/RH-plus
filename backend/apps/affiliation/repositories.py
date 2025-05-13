"""Repository pattern for Affiliation app."""
from .models import Employee, Affiliation, Provider

class EmployeeRepository:
    """Repository for Employee model."""
    
    @staticmethod
    def get_active_employees():
        """Return all active employees."""
        return Employee.objects.filter(status='ACTIVE')
    
    @staticmethod
    def get_by_document(document_number):
        """Return employee by document number."""
        return Employee.objects.filter(document_number=document_number).first()
    
    @staticmethod
    def get_by_id(employee_id):
        """Return employee by employee ID."""
        return Employee.objects.filter(employee_id=employee_id).first()

class AffiliationRepository:
    """Repository for Affiliation model."""
    
    @staticmethod
    def get_active_affiliations():
        """Return all active affiliations."""
        return Affiliation.objects.filter(is_active=True)
    
    @staticmethod
    def get_by_employee(employee_id):
        """Return affiliations by employee."""
        return Affiliation.objects.filter(
            employee_id=employee_id,
            is_active=True
        )
    
    @staticmethod
    def get_by_affiliation_type(employee_id, affiliation_type_id):
        """Return affiliations by employee and affiliation type."""
        return Affiliation.objects.filter(
            employee_id=employee_id,
            provider__affiliation_type_id=affiliation_type_id,
            is_active=True
        ).first()
