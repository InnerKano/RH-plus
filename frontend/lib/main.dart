import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rh_plus/providers/auth_provider.dart';
import 'package:rh_plus/providers/employee_provider.dart';
import 'package:rh_plus/providers/candidate_provider.dart';
import 'package:rh_plus/providers/payroll_provider.dart';
import 'package:rh_plus/providers/training_provider.dart';
import 'package:rh_plus/providers/activity_provider.dart';
import 'package:rh_plus/utils/constants.dart';
import 'package:rh_plus/views/login_screen.dart';
import 'package:rh_plus/views/register_screen.dart';
import 'package:rh_plus/views/dashboard_screen.dart';
import 'package:rh_plus/views/payroll/payroll_dashboard_screen.dart';
import 'package:rh_plus/views/payroll/payroll_entry_detail_screen.dart';
import 'package:rh_plus/views/training/training_dashboard_screen.dart';
import 'package:rh_plus/views/training/training_session_detail_screen.dart';

void main() {  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, EmployeeProvider>(
          create: (_) => EmployeeProvider(token: ''),
          update: (_, auth, previousProvider) => 
            EmployeeProvider(token: auth.token ?? ''),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CandidateProvider>(
          create: (_) => CandidateProvider(token: ''),
          update: (_, auth, previousProvider) => 
            CandidateProvider(token: auth.token ?? ''),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PayrollProvider>(
          create: (_) => PayrollProvider(token: ''),
          update: (_, auth, previousProvider) => 
            PayrollProvider(token: auth.token ?? ''),
        ),        ChangeNotifierProxyProvider<AuthProvider, TrainingProvider>(
          create: (_) => TrainingProvider(token: ''),
          update: (_, auth, previousProvider) => 
            TrainingProvider(token: auth.token ?? ''),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ActivityProvider>(
          create: (_) => ActivityProvider(token: ''),
          update: (_, auth, previousProvider) => 
            ActivityProvider(token: auth.token ?? ''),
        ),
      ],
      child: const RHPlusApp(),
    ),
  );
}

class RHPlusApp extends StatefulWidget {
  const RHPlusApp({Key? key}) : super(key: key);

  @override
  _RHPlusAppState createState() => _RHPlusAppState();
}

class _RHPlusAppState extends State<RHPlusApp> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _storage.read(key: 'auth_token');
    setState(() {
      _isLoading = false;
      _isAuthenticated = token != null;
    });
    if (_isAuthenticated) {
      // Load user data from stored token
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loadUserFromToken(token!);
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isAuthenticated
              ? const DashboardScreen()
              : const LoginScreen(),      routes: {
        RouteNames.dashboard: (context) => const DashboardScreen(),
        RouteNames.login: (context) => const LoginScreen(),
        RouteNames.register: (context) => const RegisterScreen(),
        RouteNames.payroll: (context) => const PayrollDashboardScreen(),
        RouteNames.training: (context) => const TrainingDashboardScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == RouteNames.payrollEntryDetail) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => PayrollEntryDetailScreen(
              entryId: args['entryId'],
            ),
          );
        } else if (settings.name == RouteNames.trainingSessionDetail) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => TrainingSessionDetailScreen(
              sessionId: args['sessionId'],
            ),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
