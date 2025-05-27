# This file is deprecated and kept for backward compatibility.
# Please use the modular views in the views/ directory.

from .views.user_views import UserViewSet
from .views.company_views import CompanyViewSet
from .views.company_user_views import CompanyUserViewSet
from .views.role_views import RoleViewSet
from .views.system_activity_views import ActivityViewSet
from .views.token_views import CustomTokenObtainPairView
