import 'package:flutter/material.dart';

class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://localhost:8000';
  
  // Authentication endpoints
  static const String loginUrl = '$baseUrl/api/core/token/';
  static const String refreshTokenUrl = '$baseUrl/api/core/token/refresh/';
  static const String registerUrl = '$baseUrl/api/core/users/register/';
  static const String usersUrl = '$baseUrl/api/core/users/';
  
  // Core endpoints
  static const String userProfileUrl = '$baseUrl/api/core/users/me/';
  static const String updateUserRoleUrl = '$baseUrl/api/core/users';
  static const String roleOptionsUrl = '$baseUrl/api/core/users/role_options/';
  static const String userPermissionsUrl = '$baseUrl/api/core/users/user_permissions/';

  // Dashboard endpoints
  static const String dashboardSummaryUrl = '$baseUrl/api/core/activities/dashboard_summary/';
  static const String recentActivitiesUrl = '$baseUrl/api/core/activities/recent/';

  // Feature-specific timeouts (in seconds)
  static const int defaultTimeout = 30;
  static const int uploadTimeout = 120;
  
  // Pagination
  static const int defaultPageSize = 20;
}

class AppColors {
  // Modern neutral palette
  static const Color primaryColor = Color(0xFF1A1A1A);
  static const Color secondaryColor = Color(0xFF6C7293);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF27AE60);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color infoColor = Color(0xFF3498DB);
  
  // Text colors
  static const Color textColor = Color(0xFF2C3E50); // Added textColor
  static const Color onPrimaryColor = Colors.white;
  static const Color onSecondaryColor = Colors.white;
  static const Color onBackgroundColor = Color(0xFF2C3E50);
  static const Color onSurfaceColor = Color(0xFF2C3E50);
  static const Color onErrorColor = Colors.white;
  
  // Additional neutral colors
  static const Color greyLight = Color(0xFFECF0F1);
  static const Color greyMedium = Color(0xFFBDC3C7);
  static const Color greyDark = Color(0xFF95A5A6);
}

class AppStrings {
  static const String appName = 'RH Plus';
  static const String login = 'Iniciar Sesión';
  static const String register = 'Registrarse';
  static const String email = 'Correo Electrónico';
  static const String password = 'Contraseña';
  static const String firstName = 'Nombre';
  static const String lastName = 'Apellido';
  static const String confirmPassword = 'Confirmar Contraseña';
  static const String dashboard = 'Panel Principal';
  
  // Role Management
  static const String userManagement = 'Gestión de Usuarios';
  static const String assignRole = 'Asignar Rol';
  static const String updateRole = 'Actualizar Rol';
  static const String role = 'Rol';
  static const String department = 'Departamento';
  static const String manager = 'Supervisor';
  static const String roleUpdated = 'Rol actualizado exitosamente';
  static const String unauthorizedAccess = 'No tienes permisos para acceder a esta sección';
  
  // Role Names
  static const String superuser = 'Superusuario';
  static const String admin = 'Administrador';
  static const String hrManager = 'Personal de RRHH';
  static const String supervisor = 'Supervisor/Gerente';
  static const String employee = 'Empleado';
  static const String user = 'Usuario Básico';
}

class RouteNames {
  // Authentication
  static const String login = '/login';
  static const String register = '/register';
  
  // Main routes
  static const String dashboard = '/dashboard';
  
  // Employee management
  static const String employeeList = '/employees';
  static const String employeeDetail = '/employee-detail';
  static const String employeeCreate = '/employee-create';
  
  // Recruitment
  static const String candidateList = '/candidates';
  static const String candidateDetail = '/candidate-detail';
  static const String candidateCreate = '/candidate-create';
  
  // Payroll module
  static const String payroll = '/payroll';
  static const String payrollEntryDetail = '/payroll-entry-detail';
  static const String payrollPeriods = '/payroll-periods';
  static const String contractList = '/contracts';
  static const String contractDetail = '/contract-detail';
  
  // Performance module
  static const String performance = '/performance';
  static const String evaluations = '/evaluations';
  static const String evaluationDetail = '/evaluation-detail';
  
  // Training module
  static const String training = '/training';
  static const String trainingProgramDetail = '/training-program-detail';
  static const String trainingSessionDetail = '/training-session-detail';
  static const String trainingAttendance = '/training-attendance';
  
  // Role Management
  static const String userManagement = '/user-management';
  static const String userRoleUpdate = '/user-role-update';
}

// Role constants
class UserRoles {
  static const String superuser = 'SUPERUSER';
  static const String admin = 'ADMIN';
  static const String hrManager = 'HR_MANAGER';
  static const String supervisor = 'SUPERVISOR';
  static const String employee = 'EMPLOYEE';
  static const String user = 'USER';
  
  static const Map<String, String> roleDisplayNames = {
    superuser: AppStrings.superuser,
    admin: AppStrings.admin,
    hrManager: AppStrings.hrManager,
    supervisor: AppStrings.supervisor,
    employee: AppStrings.employee,
    user: AppStrings.user,
  };
}
