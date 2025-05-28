import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'providers/user_management_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/training_provider.dart';
import 'views/login_screen.dart';
import 'views/register_screen.dart';
import 'views/dashboard_screen.dart';
import 'views/user_management_screen.dart';
import 'views/training/training_main_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
        ChangeNotifierProxyProvider<AuthProvider, DashboardProvider>(
          create: (_) => DashboardProvider(),
          update: (_, auth, dashboardProvider) {
            dashboardProvider?.setToken(auth.token);
            return dashboardProvider ?? DashboardProvider();
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TrainingProvider>(
          create: (_) => TrainingProvider(token: ''),
          update: (_, auth, trainingProvider) {
            return TrainingProvider(token: auth.token ?? '');
          },
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false, // Remove debug banner
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        ),
        home: const AuthWrapper(),        routes: {
          RouteNames.login: (context) => const LoginScreen(),
          RouteNames.register: (context) => const RegisterScreen(),
          RouteNames.dashboard: (context) => const DashboardScreen(),
          RouteNames.userManagement: (context) => const UserManagementScreen(),
          RouteNames.training: (context) => const TrainingMainScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isValid = await authProvider.loadUserFromToken(token);

        if (!isValid) {
          // Token is invalid, remove it
          await prefs.remove('auth_token');
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
