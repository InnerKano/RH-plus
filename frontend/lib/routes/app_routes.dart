import 'package:flutter/material.dart';
import '../models/training_models.dart';
import '../views/login_screen.dart';
import '../views/register_screen.dart';
import '../views/dashboard_screen.dart';
import '../views/user_management_screen.dart';
import '../views/training/training_main_screen.dart';
import '../views/training/forms/program_form_screen.dart';
import '../views/training/forms/session_form_screen.dart';
import '../views/training/training_session_detail_screen.dart';
import '../views/training/management/attendance_management_screen.dart';
import '../views/training/reports/training_reports_screen.dart';
import '../views/affiliation/index.dart';
import '../views/payroll/payroll_dashboard_screen.dart';
import '../views/payroll/payroll_entry_detail_screen.dart';
import '../views/payroll/payroll_entry_form_screen.dart';
import '../views/payroll/contracts_management_screen.dart';
import '../views/payroll/payroll_periods_management_screen.dart';
import '../views/payroll/payroll_items_management_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String userManagement = '/user-management';
  
  // Training routes
  static const String training = '/training';
  static const String trainingProgramForm = '/training-program-form';
  static const String trainingSessionForm = '/training-session-form';
  static const String trainingSessionDetail = '/training-session-detail';
  static const String trainingAttendance = '/training-attendance';
  static const String trainingReports = '/training-reports';
  // Affiliation routes
  static const String affiliations = '/affiliations';
  static const String employeeAffiliations = '/employee-affiliations';
  static const String affiliationForm = '/affiliation-form';
  // Payroll routes
  static const String payroll = '/payroll';
  static const String payrollEntryDetail = '/payroll-entry-detail';
  static const String payrollEntryForm = '/payroll-entry-form';
  static const String contracts = '/contracts';
  static const String payrollPeriods = '/payroll-periods';
  static const String payrollItems = '/payroll-items';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      dashboard: (context) => const DashboardScreen(),
      userManagement: (context) => const UserManagementScreen(),
      training: (context) => const TrainingMainScreen(),
      trainingProgramForm: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return ProgramFormScreen(
          program: args?['program'] as TrainingProgramModel?,
          isEditing: args?['isEditing'] as bool? ?? false,
        );
      },
      trainingSessionForm: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return SessionFormScreen(
          session: args?['session'] as TrainingSessionModel?,
          isEditing: args?['isEditing'] as bool? ?? false,
        );
      },
      trainingSessionDetail: (context) {
        final sessionId = ModalRoute.of(context)!.settings.arguments as int;
        return TrainingSessionDetailScreen(sessionId: sessionId);
      },
      trainingAttendance: (context) {
        final session = ModalRoute.of(context)!.settings.arguments as TrainingSessionModel;
        return AttendanceManagementScreen(session: session);
      },
      trainingReports: (context) => const TrainingReportsScreen(),
      
      // Affiliation routes
      affiliations: (context) => const AffiliationMainScreen(),
      employeeAffiliations: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return EmployeeAffiliationsScreen(
          employeeId: args['employeeId'] as int,
          employeeName: args['employeeName'] as String,
        );
      },      affiliationForm: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return AffiliationFormScreen(
          affiliation: args?['affiliation'],
          isEditing: args?['isEditing'] as bool? ?? false,
        );
      },      // Payroll routes
      payroll: (context) => const PayrollDashboardScreen(),
      payrollEntryDetail: (context) {
        final entryId = ModalRoute.of(context)!.settings.arguments as int;
        return PayrollEntryDetailScreen(entryId: entryId);
      },
      payrollEntryForm: (context) => const PayrollEntryFormScreen(),
      contracts: (context) => const ContractsManagementScreen(),
      payrollPeriods: (context) => const PayrollPeriodsManagementScreen(),
      payrollItems: (context) => const PayrollItemsManagementScreen(),
    };
  }
}
