import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/models/payroll_models.dart';
import 'package:rh_plus/providers/payroll_provider.dart';
import 'package:intl/intl.dart';

class PayrollDashboardScreen extends StatefulWidget {
  const PayrollDashboardScreen({Key? key}) : super(key: key);

  @override
  _PayrollDashboardScreenState createState() => _PayrollDashboardScreenState();
}

class _PayrollDashboardScreenState extends State<PayrollDashboardScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadData();
      _isInitialized = true;
    }
  }

  Future<void> _loadData() async {
    final payrollProvider = Provider.of<PayrollProvider>(context, listen: false);
    await payrollProvider.fetchOpenPayrollPeriods();
    
    // If there's at least one open period, load its entries
    if (payrollProvider.periods.isNotEmpty) {
      final firstPeriod = payrollProvider.periods.first;
      payrollProvider.setSelectedPeriod(firstPeriod);
      await payrollProvider.fetchPayrollEntriesByPeriod(firstPeriod.id);
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
      ),
      body: Consumer<PayrollProvider>(
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
              child: Text('No hay períodos de nómina abiertos actualmente'),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to new payroll entry screen
        },
        child: const Icon(Icons.add),
        tooltip: 'Nuevo registro de nómina',
      ),
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
            ),
            child: DropdownButton<PayrollPeriodModel>(
              isExpanded: true,
              underline: const SizedBox(),
              value: payrollProvider.selectedPeriod,
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
        child: Text('No hay registros de nómina para este período'),
      );
    }

    return ListView.builder(
      itemCount: payrollProvider.payrollEntries.length,
      itemBuilder: (context, index) {
        final entry = payrollProvider.payrollEntries[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(entry.employeeName),
            subtitle: Text('Total: ${currencyFormat.format(entry.netPay)}'),
            trailing: Chip(
              label: Text(
                entry.isApproved ? 'Aprobado' : 'Pendiente',
                style: TextStyle(
                  color: entry.isApproved ? Colors.white : Colors.black87,
                ),
              ),
              backgroundColor: entry.isApproved
                  ? Colors.green
                  : Colors.amber,
            ),
            onTap: () {
              payrollProvider.setSelectedEntry(entry);
              // Navigate to payroll detail screen
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
}
