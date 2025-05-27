# This file is deprecated and kept for backward compatibility.
# Please use the modular serializers in the serializers/ directory.

from .serializers.user_serializers import UserSerializer, UserRegistrationSerializer
from .serializers.role_serializers import RoleSerializer
from .serializers.company_serializers import CompanySerializer, CompanyDetailSerializer, CompanyRegistrationSerializer
from .serializers.company_user_serializers import CompanyUserSerializer, CompanyUserDetailSerializer, CompanyUserCreateSerializer
from .serializers.system_activity_serializers import SystemActivitySerializer
