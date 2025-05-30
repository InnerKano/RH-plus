import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/models/payroll_models.dart';
import 'package:rh_plus/providers/payroll_provider.dart';
import 'package:rh_plus/routes/app_routes.dart';
import 'package:rh_plus/views/payroll/contracts_management_screen.dart';
import 'package:rh_plus/views/payroll/payroll_periods_management_screen.dart';
import 'package:rh_plus/views/payroll/payroll_items_management_screen.dart';
import 'package:intl/intl.dart';

class PayrollDashboardScreen extends StatefulWidget {
  const PayrollDashboardScreen({Key? key}) : super(key: key);

  @override
  _PayrollDashboardScreenState createState() => _PayrollDashboardScreenState();
}

class _PayrollDashboardScreenState extends State<PayrollDashboardScreen>
    with SingleTickerProviderStateMixin {
  final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
  bool _isInitialized = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      // Use post-frame callback to avoid calling notifyListeners during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
  }
  Future<void> _loadData() async {
    final payrollProvider = Provider.of<PayrollProvider>(context, listen: false);
    
    // Store the current selected period ID to preserve selection if possible
    final currentSelectedPeriodId = payrollProvider.selectedPeriod?.id;
    
    await payrollProvider.fetchOpenPayrollPeriods();
    
    // Try to restore the previous selection, or default to first period
    if (payrollProvider.periods.isNotEmpty) {
      PayrollPeriodModel? periodToSelect;
      
      if (currentSelectedPeriodId != null) {
        // Try to find the previously selected period
        try {
          periodToSelect = payrollProvider.periods.firstWhere(
            (period) => period.id == currentSelectedPeriodId,
          );
        } catch (e) {
          // Period not found, will default to first
          periodToSelect = payrollProvider.periods.first;
        }
      } else {
        // No previous selection, use first
        periodToSelect = payrollProvider.periods.first;
      }
      
      payrollProvider.setSelectedPeriod(periodToSelect);
      await payrollProvider.fetchPayrollEntriesByPeriod(periodToSelect.id);
    } else {
      // No periods available, clear selection
      payrollProvider.clearSelectedPeriod();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nómina'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard),
              text: 'Dashboard',
            ),
            Tab(
              icon: Icon(Icons.description),
              text: 'Contratos',
            ),
            Tab(
              icon: Icon(Icons.calendar_today),
              text: 'Períodos',
            ),
            Tab(
              icon: Icon(Icons.list_alt),
              text: 'Conceptos',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          const ContractsManagementScreen(),
          const PayrollPeriodsManagementScreen(),
          const PayrollItemsManagementScreen(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildPeriodSelector(PayrollProvider payrollProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Período de nómina',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),            child: DropdownButton<PayrollPeriodModel>(
              isExpanded: true,
              underline: const SizedBox(),
              value: payrollProvider.periods.contains(payrollProvider.selectedPeriod) 
                  ? payrollProvider.selectedPeriod 
                  : null,
              hint: const Text('Seleccione un período'),
              onChanged: (period) async {
                if (period != null) {
                  payrollProvider.setSelectedPeriod(period);
                  await payrollProvider.fetchPayrollEntriesByPeriod(period.id);
                }
              },
              items: payrollProvider.periods.map((period) {
                return DropdownMenuItem<PayrollPeriodModel>(
                  value: period,
                  child: Text(period.name),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollEntries(PayrollProvider payrollProvider) {
    if (payrollProvider.payrollEntries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay registros de nómina para este período'),
            SizedBox(height: 8),
            Text(
              'Usa el botón "+" para crear una nueva nómina',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: payrollProvider.payrollEntries.length,
      itemBuilder: (context, index) {
        final entry = payrollProvider.payrollEntries[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: entry.isApproved ? Colors.green : Colors.orange,
              child: Icon(
                entry.isApproved ? Icons.check : Icons.pending,
                color: Colors.white,
              ),
            ),
            title: Text(
              entry.employeeName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Total: ${currencyFormat.format(entry.netPay)}'),
            trailing: Chip(
              label: Text(
                entry.isApproved ? 'Aprobado' : 'Pendiente',
                style: TextStyle(
                  color: entry.isApproved ? Colors.white : Colors.black87,
                  fontSize: 12,
                ),
              ),
              backgroundColor: entry.isApproved
                  ? Colors.green
                  : Colors.amber,
            ),
            onTap: () {
              payrollProvider.setSelectedEntry(entry);
              Navigator.pushNamed(
                context, 
                AppRoutes.payrollEntryDetail, 
                arguments: entry.id,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSummary(PayrollProvider payrollProvider) {
    if (payrollProvider.payrollEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    double totalEarnings = 0;
    double totalDeductions = 0;
    double netTotal = 0;

    for (var entry in payrollProvider.payrollEntries) {
      totalEarnings += entry.totalEarnings;
      totalDeductions += entry.totalDeductions;
      netTotal += entry.netPay;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total devengos:'),
              Text(
                currencyFormat.format(totalEarnings),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total deducciones:'),
              Text(
                currencyFormat.format(totalDeductions),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total a pagar:'),
              Text(
                currencyFormat.format(netTotal),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Consumer<PayrollProvider>(
      builder: (context, payrollProvider, child) {
        if (payrollProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (payrollProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Error: ${payrollProvider.error}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        
        if (payrollProvider.periods.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay períodos de nómina abiertos actualmente'),
                SizedBox(height: 8),
                Text(
                  'Crea un período en la pestaña "Períodos" para comenzar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            _buildPeriodSelector(payrollProvider),
            const Divider(),
            Expanded(
              child: _buildPayrollEntries(payrollProvider),
            ),
            _buildSummary(payrollProvider),
          ],
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        // Only show FAB on dashboard tab
        if (_tabController.index == 0) {
          return FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.payrollEntryForm);
            },
            child: const Icon(Icons.add),
            tooltip: 'Nuevo registro de nómina',
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
