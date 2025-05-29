import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/providers/selection_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_routes.dart';
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
    return MultiProvider(
      providers: [
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
        ChangeNotifierProxyProvider<AuthProvider, SelectionProvider>(
          create: (_) => SelectionProvider(),
          update: (_, auth, selectionProvider) {
            // No inicializar automáticamente aquí
            final newProvider = SelectionProvider();
            // La inicialización se hará manualmente cuando sea necesario
            return newProvider;
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
        home: const AuthWrapper(),
        routes: AppRoutes.getRoutes(),
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
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    print('AuthWrapper: Checking authentication status...');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Intentar cargar token desde storage
    final tokenLoaded = await authProvider.loadTokenFromStorage();
    
    if (tokenLoaded) {
      print('AuthWrapper: User authenticated from storage');
    } else {
      print('AuthWrapper: No valid authentication found');
    }
    
    setState(() {
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
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
