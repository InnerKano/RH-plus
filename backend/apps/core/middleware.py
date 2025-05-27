"""Middleware for handling company context in requests."""
from django.utils.deprecation import MiddlewareMixin
from django.contrib.auth.models import AnonymousUser

class CompanyContextMiddleware(MiddlewareMixin):
    """
    Middleware that adds company context to each request.
    This allows views to filter data based on the user's active company.
    """
    
    def process_request(self, request):
        """
        Process request and add active company to request.
        """
        # Skip for anonymous users and admin URLs
        if isinstance(request.user, AnonymousUser) or request.path.startswith('/admin/'):
            return None
            
        # Get active company for the logged-in user
        if hasattr(request.user, 'get_active_company'):
            request.active_company = request.user.get_active_company()
        else:
            request.active_company = None
            
        return None
