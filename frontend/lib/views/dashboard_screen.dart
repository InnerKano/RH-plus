import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/providers/auth_provider.dart';
import 'package:rh_plus/providers/payroll_provider.dart';
import 'package:rh_plus/providers/training_provider.dart';
import 'package:rh_plus/providers/employee_provider.dart';
import 'package:rh_plus/providers/candidate_provider.dart';
import 'package:rh_plus/providers/activity_provider.dart';
import 'package:rh_plus/services/activity_service.dart';
import 'package:rh_plus/utils/constants.dart';
import 'package:rh_plus/views/payroll/payroll_dashboard_screen.dart';
import 'package:rh_plus/views/training/training_dashboard_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Dashboard',
    'Candidatos',
    'Empleados',
    'Nómina',
    'Desempeño',
    'Capacitación',
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.people_outline,
    Icons.badge_outlined,
    Icons.attach_money,
    Icons.show_chart,
    Icons.school_outlined,
  ];
  late List<Widget> _screens;
    @override
  void initState() {
    super.initState();
    _initializeScreens();
    
    // Carga los datos del dashboard cuando se inicia la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivityProvider>(context, listen: false).fetchDashboardSummary();
      Provider.of<ActivityProvider>(context, listen: false).fetchRecentActivities();
      
      // También podríamos cargar datos específicos si es necesario
      Provider.of<EmployeeProvider>(context, listen: false).fetchEmployees();
      Provider.of<CandidateProvider>(context, listen: false).fetchCandidates();
      
      if (kDebugMode) {
        print('Cargando datos del dashboard...');
      }
    });
  }
  
  void _initializeScreens() {
    _screens = [
      _buildDashboardSummary(),
      const Center(child: Text('Módulo de Candidatos')),
      const Center(child: Text('Módulo de Empleados')),
      const PayrollDashboardScreen(),
      const Center(child: Text('Módulo de Desempeño')),
      const TrainingDashboardScreen(),
    ];
  }  Widget _buildDashboardSummary() {
    return Consumer5<AuthProvider, EmployeeProvider, PayrollProvider, TrainingProvider, ActivityProvider>(
      builder: (context, authProvider, employeeProvider, payrollProvider, trainingProvider, activityProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.person, size: 40),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bienvenido, ${authProvider.currentUser?.fullName ?? "Usuario"}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Último acceso: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Resumen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),              activityProvider.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Row(
                    children: [
                      _buildSummaryCard(
                        'Empleados',
                        activityProvider.dashboardSummary?.employeeCount.toString() ?? '0',
                        Icons.badge_outlined,
                        Colors.blue,
                        () {
                          setState(() {
                            _selectedIndex = 2; // Índice del módulo de empleados
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildSummaryCard(
                        'Candidatos',
                        activityProvider.dashboardSummary?.candidateCount.toString() ?? '0',
                        Icons.people_outline,
                        Colors.orange,
                        () {
                          setState(() {
                            _selectedIndex = 1; // Índice del módulo de candidatos
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildSummaryCard(
                        'Nómina',
                        activityProvider.dashboardSummary?.payrollPeriod ?? 'Sin datos',
                        Icons.attach_money,
                        Colors.green,
                        () {
                          setState(() {
                            _selectedIndex = 3; // Índice del módulo de nómina
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildSummaryCard(
                        'Capacitaciones',
                        '${activityProvider.dashboardSummary?.upcomingTrainingsCount ?? 0} próximas',
                        Icons.school_outlined,
                        Colors.purple,
                        () {
                          setState(() {
                            _selectedIndex = 5; // Índice del módulo de capacitación
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),              const SizedBox(height: 24),
              const Text(
                'Actividad Reciente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Mostrar actividades desde la API o mensaje si no hay ninguna
              activityProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : activityProvider.activities.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No hay actividades recientes para mostrar'),
                    ),
                  )
                : Column(
                    children: activityProvider.activities.map((activity) {
                      // Determinar el icono según el tipo de actividad
                      IconData activityIcon = Icons.info_outline;
                      Color activityColor = Colors.blue;
                      
                      switch(activity.type) {
                        case 'employee':
                          activityIcon = Icons.person_add;
                          activityColor = Colors.blue;
                          break;
                        case 'payroll':
                          activityIcon = Icons.attach_money;
                          activityColor = Colors.green;
                          break;
                        case 'training':
                          activityIcon = Icons.school;
                          activityColor = Colors.purple;
                          break;
                        case 'candidate':
                          activityIcon = Icons.people_outline;
                          activityColor = Colors.orange;
                          break;
                        case 'performance':
                          activityIcon = Icons.assessment;
                          activityColor = Colors.red;
                          break;
                      }
                      
                      return _buildActivityCard(
                        activity.title,
                        activity.description,
                        activityIcon,
                        activityColor,
                        activity.timestamp,
                      );
                    }).toList(),
                  ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSummaryCard(
    String title, 
    String value, 
    IconData icon, 
    Color color, 
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActivityCard(
    String title,
    String description,
    IconData icon,
    Color color,
    DateTime time,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatTimeAgo(time),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return DateFormat('dd/MM/yyyy').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, RouteNames.login);
              if (kDebugMode) {
                print('Sesión cerrada, navegando al login');
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.fullName ?? 'Usuario'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _titles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(_icons[index]),
                    title: Text(_titles[index]),
                    selected: _selectedIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
