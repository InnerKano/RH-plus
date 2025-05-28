import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<ModuleInfo> _modules = [
    ModuleInfo('Dashboard', Icons.dashboard_outlined, 'dashboard'),
    ModuleInfo('Selección', Icons.person_search_outlined, 'selection'),
    ModuleInfo('Afiliaciones', Icons.card_membership_outlined, 'affiliation'),
    ModuleInfo('Nómina', Icons.payments_outlined, 'payroll'),
    ModuleInfo('Desempeño', Icons.trending_up_outlined, 'performance'),
    ModuleInfo('Capacitación', Icons.school_outlined, 'training'),
  ];

  List<ModuleInfo> _accessibleModules = [];

  @override
  void initState() {
    super.initState();
    print('DashboardScreen: Initializing...');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    
    print('DashboardScreen: Loading user permissions...');
    
    try {
      await authProvider.loadUserPermissions();
      print('DashboardScreen: Permissions loaded, loading dashboard data...');
      await dashboardProvider.loadDashboardData();
      print('DashboardScreen: Dashboard data loaded');
      
      // Build accessible modules list
      _buildAccessibleModules(authProvider.userPermissions);
    } catch (e) {
      print('DashboardScreen: Error during initialization: $e');
    }
  }

  void _buildAccessibleModules(UserPermissions? permissions) {
    if (permissions == null) return;

    _accessibleModules = [
      ModuleInfo('Dashboard', Icons.dashboard_outlined, 'dashboard'),
    ];

    // Add user management if user can manage others (insert at position 1)
    if (permissions.canManageUsers) {
      _accessibleModules.add(ModuleInfo('Gestión de Usuarios', Icons.people_outlined, 'user_management'));
    }

    // Add other modules based on permissions
    for (final module in _modules.skip(1)) { // Skip dashboard as it's already added
      if (permissions.canAccessModule(module.key)) {
        _accessibleModules.add(module);
      }
    }

    print('DashboardScreen: Built accessible modules: ${_accessibleModules.map((m) => m.key).join(', ')}');
    
    // Reset selected index if it's out of bounds
    if (_selectedIndex >= _accessibleModules.length) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Safely get current module title
          String currentTitle = 'Dashboard';
          if (_selectedIndex < _accessibleModules.length && _selectedIndex >= 0) {
            currentTitle = _accessibleModules[_selectedIndex].title;
          }
          
          return Text(
            currentTitle,
            style: TextStyle(
              color: AppColors.onPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          );
        },
      ),
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final roleDisplay = authProvider.userPermissions?.roleDisplay ?? 'Usuario';
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    roleDisplay,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notificaciones - En desarrollo'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_outlined, color: Colors.white),
          onPressed: () => _logout(),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(child: _buildDrawerMenu()),
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final permissions = authProvider.userPermissions;
        
        return UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.secondaryColor,
              ],
            ),
          ),
          accountName: Text(
            user?.fullName ?? 'Usuario',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          accountEmail: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.email ?? ''),
              const SizedBox(height: 4),
              Text(
                'Último acceso: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: user?.profileImage != null && user!.profileImage!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      user.profileImage!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primaryColor,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primaryColor,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerMenu() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final permissions = authProvider.userPermissions;
        
        if (permissions == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Use the pre-built accessible modules list
        if (_accessibleModules.isEmpty) {
          _buildAccessibleModules(permissions);
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: _accessibleModules.length,
          itemBuilder: (context, index) {
            final module = _accessibleModules[index];
            final isSelected = index == _selectedIndex;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : null,
              ),
              child: ListTile(
                leading: Icon(
                  module.icon,
                  color: isSelected ? AppColors.primaryColor : AppColors.greyDark,
                ),
                title: Text(
                  module.title,
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryColor : AppColors.textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onTap: () => _onModuleTap(index, module),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.greyLight)),
      ),
      child: Column(
        children: [
          Text(
            'RH Plus v1.0.0',
            style: TextStyle(
              color: AppColors.greyDark,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2024 Tu Empresa',
            style: TextStyle(
              color: AppColors.greyDark,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _buildDashboardContent();
    } else {
      return _buildModuleContent();
    }
  }

  Widget _buildDashboardContent() {
    return Consumer2<AuthProvider, DashboardProvider>(
      builder: (context, authProvider, dashboardProvider, child) {
        final permissions = authProvider.userPermissions;
        
        if (permissions == null || dashboardProvider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: 16),
                Text(
                  'Cargando información...',
                  style: TextStyle(color: AppColors.greyDark),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(authProvider),
              const SizedBox(height: 32),
              _buildSummarySection(permissions, dashboardProvider.summaryData),
              const SizedBox(height: 32),
              _buildRecentActivitySection(dashboardProvider.recentActivities),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(AuthProvider authProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              child: authProvider.user?.profileImage != null && authProvider.user!.profileImage!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        authProvider.user!.profileImage!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 35,
                            color: AppColors.primaryColor,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 35,
                      color: AppColors.primaryColor,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido, ${authProvider.user?.firstName ?? 'Usuario'}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rol: ${authProvider.userPermissions?.roleDisplay ?? 'Usuario'}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Último acceso: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.greyDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(UserPermissions permissions, Map<String, dynamic> summaryData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen del Sistema',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        // Show summary cards only if user has access to the modules
        _buildSummaryGrid(permissions, summaryData),
      ],
    );
  }

  Widget _buildSummaryGrid(UserPermissions permissions, Map<String, dynamic> summaryData) {
    List<Widget> summaryCards = [];

    // Only show cards for modules the user can access
    if (permissions.canAccessModule('selection')) {
      summaryCards.add(_buildSummaryCard(
        'Candidatos',
        '${summaryData['candidates_count'] ?? 0}',
        Icons.people_outline,
        AppColors.infoColor,
        () => _navigateToModule('selection'),
      ));
    }

    if (permissions.canAccessModule('affiliation')) {
      summaryCards.add(_buildSummaryCard(
        'Empleados',
        '${summaryData['employees_count'] ?? 0}',
        Icons.badge_outlined,
        AppColors.successColor,
        () => _navigateToModule('affiliation'),
      ));
    }

    if (permissions.canAccessModule('payroll')) {
      summaryCards.add(_buildSummaryCard(
        'Nómina',
        summaryData['current_payroll_period'] ?? 'No definido',
        Icons.payments_outlined,
        AppColors.warningColor,
        () => _navigateToModule('payroll'),
      ));
    }

    if (permissions.canAccessModule('training')) {
      summaryCards.add(_buildSummaryCard(
        'Capacitaciones',
        '${summaryData['upcoming_trainings'] ?? 0} próximas',
        Icons.school_outlined,
        AppColors.errorColor,
        () => _navigateToModule('training'),
      ));
    }

    // Show user management card if user can manage users
    if (permissions.canManageUsers) {
      summaryCards.add(_buildSummaryCard(
        'Gestión de Usuarios',
        '${summaryData['total_users'] ?? 0} usuarios',
        Icons.people_outlined,
        AppColors.secondaryColor,
        () => Navigator.pushNamed(context, RouteNames.userManagement),
      ));
    }

    if (summaryCards.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: AppColors.greyDark,
              ),
              const SizedBox(height: 16),
              Text(
                'No tienes acceso a ningún módulo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.greyDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Contacta al administrador para asignar permisos',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.greyDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Arrange cards in a responsive grid
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: summaryCards,
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.greyDark,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.greyDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(List<Map<String, dynamic>> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad Reciente',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        if (activities.isEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: AppColors.greyDark,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay actividades recientes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...activities.map((activity) => _buildActivityCard(
            activity['title'] ?? 'Sin título',
            activity['description'] ?? 'Sin descripción',
            _getActivityIcon(activity['type']),
            _getActivityColor(activity['type']),
            DateTime.parse(activity['created_at'] ?? DateTime.now().toIso8601String()),
          )).toList(),
      ],
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'employee':
        return Icons.person_add_outlined;
      case 'candidate':
        return Icons.person_search_outlined;
      case 'payroll':
        return Icons.payments_outlined;
      case 'training':
        return Icons.school_outlined;
      case 'performance':
        return Icons.trending_up_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'employee':
        return AppColors.successColor;
      case 'candidate':
        return AppColors.infoColor;
      case 'payroll':
        return AppColors.warningColor;
      case 'training':
        return AppColors.errorColor;
      case 'performance':
        return AppColors.secondaryColor;
      default:
        return AppColors.greyDark;
    }
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
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.greyDark,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatTimeAgo(time),
              style: TextStyle(
                color: AppColors.greyDark,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleContent() {
    if (_selectedIndex >= _accessibleModules.length || _selectedIndex < 0) {
      // Fallback to dashboard if index is invalid
      setState(() {
        _selectedIndex = 0;
      });
      return _buildDashboardContent();
    }

    final currentModule = _accessibleModules[_selectedIndex];
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            currentModule.icon,
            size: 64,
            color: AppColors.greyDark,
          ),
          const SizedBox(height: 16),
          Text(
            'Módulo de ${currentModule.title}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.greyDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta funcionalidad estará disponible pronto',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.greyDark,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              print('DashboardScreen: Returning to dashboard from ${currentModule.key}');
              setState(() {
                _selectedIndex = 0; // Return to dashboard
              });
              // Don't close drawer here, let user navigate manually if needed
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.onPrimaryColor,
            ),
            child: const Text('Volver al Dashboard'),
          ),
        ],
      ),
    );
  }

  void _onModuleTap(int index, ModuleInfo module) {
    print('DashboardScreen: Module tapped: ${module.key} at index $index');
    Navigator.pop(context); // Close drawer
    
    if (module.key == 'user_management') {
      print('DashboardScreen: Navigating to user management');
      Navigator.pushNamed(context, RouteNames.userManagement);
    } else {
      print('DashboardScreen: Setting selected index to $index');
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _navigateToModule(String moduleKey) {
    print('DashboardScreen: Attempting to navigate to module: $moduleKey');
    
    // Find the module in our accessible modules list
    final moduleIndex = _accessibleModules.indexWhere((module) => module.key == moduleKey);
    
    if (moduleIndex != -1) {
      print('DashboardScreen: Found module $moduleKey at index $moduleIndex');
      setState(() {
        _selectedIndex = moduleIndex;
      });
    } else {
      // If not found in accessible modules, check if it's user management
      if (moduleKey == 'user_management') {
        Navigator.pushNamed(context, RouteNames.userManagement);
      } else {
        print('DashboardScreen: Module $moduleKey not found in accessible modules');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Módulo $moduleKey no está disponible'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _logout() async {
    print('DashboardScreen: Logging out');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
    }
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
}

class ModuleInfo {
  final String title;
  final IconData icon;
  final String key;

  ModuleInfo(this.title, this.icon, this.key);
}
