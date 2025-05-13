class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://localhost:8000';
  
  // Authentication endpoints
  static const String loginUrl = '$baseUrl/api/token/';
  static const String refreshTokenUrl = '$baseUrl/api/token/refresh/';
  
  // Core endpoints
  static const String userProfileUrl = '$baseUrl/api/core/users/profile/';
  
  // Feature-specific timeouts (in seconds)
  static const int defaultTimeout = 30;
  static const int uploadTimeout = 120;
  
  // Pagination
  static const int defaultPageSize = 20;
}

class AppStrings {
  static const String appName = 'RH Plus';
  static const String login = 'Iniciar Sesión';
  static const String email = 'Correo Electrónico';
  static const String password = 'Contraseña';
  static const String dashboard = 'Panel Principal';
  static const String logout = 'Cerrar Sesión';
  
  // Payroll module strings
  static const String payroll = 'Nómina';
  static const String payrollPeriod = 'Período de Nómina';
  static const String contracts = 'Contratos';
  static const String earnings = 'Devengos';
  static const String deductions = 'Deducciones';
  static const String netPay = 'Neto a Pagar';
  
  // Training module strings
  static const String training = 'Capacitación';
  static const String trainingPrograms = 'Programas';
  static const String trainingSessions = 'Sesiones';
  static const String attendance = 'Asistencia';
}

class AppConstants {
  // App general settings
  static const String appVersion = '1.0.0';
  
  // Shared preferences keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  
  // Default values
  static const String defaultCurrencyCode = 'COP';
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String defaultLanguageCode = 'es';
  
  // Feature flags
  static const bool enablePerformanceModule = true;
  static const bool enablePayrollModule = true;
  static const bool enableTrainingModule = true;
  static const bool enableNotifications = true;
}

class RouteNames {
  // Authentication
  static const String login = '/login';
  static const String resetPassword = '/reset-password';
  
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
}
