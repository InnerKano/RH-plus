// filepath: c:\Users\kevin\Documents\GitHub\RH-plus\frontend\lib\views\training\training_main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/providers/auth_provider.dart';
import 'package:rh_plus/providers/training_provider.dart';
import 'package:rh_plus/utils/constants.dart';
import 'package:rh_plus/views/training/widgets/admin_training_view.dart';
import 'package:rh_plus/views/training/widgets/hr_training_view.dart';
import 'package:rh_plus/views/training/widgets/supervisor_training_view.dart';

class TrainingMainScreen extends StatefulWidget {
  const TrainingMainScreen({Key? key}) : super(key: key);

  @override
  State<TrainingMainScreen> createState() => _TrainingMainScreenState();
}

class _TrainingMainScreenState extends State<TrainingMainScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (_isInitialized) return;
    _isInitialized = true;
    
    final trainingProvider = Provider.of<TrainingProvider>(context, listen: false);
    
    try {
      // Load common data for all users
      await trainingProvider.fetchTrainingPrograms();
      await trainingProvider.fetchUpcomingSessions();
    } catch (e) {
      print('Error loading training data: $e');
      _isInitialized = false; // Allow retry
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Capacitación',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              // Show refresh for all users
              return IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadInitialData,
                tooltip: 'Actualizar',
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;
          final userRole = user?.role ?? 'USER';
          
          if (user == null) {
            return const Center(
              child: Text('Error: Usuario no autenticado'),
            );
          }

          // Return appropriate view based on user role
          switch (userRole) {
            case 'SUPERUSER':
            case 'ADMIN':
              return const AdminTrainingView();
            case 'HR_MANAGER':
              return const HRTrainingView();
            case 'SUPERVISOR':
              return const SupervisorTrainingView();
            case 'EMPLOYEE':
              // Temporary placeholder
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, size: 48, color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'Vista de Capacitación para Empleados',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Esta vista está temporalmente en mantenimiento.'),
                  ],
                ),
              );
            default:
              // Temporary placeholder
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, size: 48, color: Colors.green),
                    SizedBox(height: 16),
                    Text(
                      'Vista de Capacitación para Usuarios',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Esta vista está temporalmente en mantenimiento.'),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
