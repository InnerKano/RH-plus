"""
Repository pattern implementation for core app.
"""
from .models import User, Role

class UserRepository:
    """Repository for User model."""
    
    @staticmethod
    def get_active_users():
        """Return all active users."""
        return User.objects.filter(is_active=True)
    
    @staticmethod
    def get_by_email(email):
        """Return user by email."""
        return User.objects.filter(email=email).first()
    
    @staticmethod
    def get_by_id(user_id):
        """Return user by id."""
        return User.objects.filter(id=user_id).first()

class RoleRepository:
    """Repository for Role model."""
    
    @staticmethod
    def get_all_roles():
        """Return all roles."""
        return Role.objects.all()
    
    @staticmethod
    def get_by_name(name):
        """Return role by name."""
        return Role.objects.filter(name=name).first()
