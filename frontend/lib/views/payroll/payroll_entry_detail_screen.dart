import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/models/payroll_models.dart';
import 'package:rh_plus/providers/payroll_provider.dart';
import 'package:intl/intl.dart';

class PayrollEntryDetailScreen extends StatefulWidget {
  final int entryId;

  const PayrollEntryDetailScreen({
    Key? key,
    required this.entryId,
  }) : super(key: key);

  @override
  _PayrollEntryDetailScreenState createState() => _PayrollEntryDetailScreenState();
}

class _PayrollEntryDetailScreenState extends State<PayrollEntryDetailScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayrollEntry();
  }

  Future<void> _loadPayrollEntry() async {
    final payrollProvider = Provider.of<PayrollProvider>(context, listen: false);
    try {
      await payrollProvider.fetchPayrollEntryById(widget.entryId);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar la nómina: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Nómina'),
      ),      body: Consumer<PayrollProvider>(
        builder: (context, payrollProvider, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final entry = payrollProvider.selectedEntry;
          
          if (entry == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('No se pudo cargar la información de la nómina'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmployeeInfo(entry),
                  const SizedBox(height: 24),
                  _buildEarningsSection(entry),
                  const SizedBox(height: 24),
                  _buildDeductionsSection(entry),
                  const SizedBox(height: 24),
                  _buildSummarySection(entry),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<PayrollProvider>(
        builder: (context, payrollProvider, child) {
          final entry = payrollProvider.selectedEntry;
          
          if (entry == null) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: entry.isApproved ? null : () {
                      // Implement approval functionality
                      _showApprovalConfirmation(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: Text(
                      entry.isApproved ? 'Aprobado' : 'Aprobar Nómina',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Implement PDF generation
                    },
                    child: const Text('Generar PDF'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmployeeInfo(PayrollEntryModel entry) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.person, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.employeeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Período: ${entry.periodName}'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsSection(PayrollEntryModel entry) {
    final earningDetails = entry.details
        .where((detail) => detail.itemType == 'EARNING')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Devengos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: earningDetails.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final detail = earningDetails[index];
              return ListTile(
                title: Text(detail.itemName),
                subtitle: detail.notes != null && detail.notes!.isNotEmpty
                    ? Text(detail.notes!)
                    : null,
                trailing: Text(
                  currencyFormat.format(detail.amount * detail.quantity),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Total Devengos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                currencyFormat.format(entry.totalEarnings),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeductionsSection(PayrollEntryModel entry) {
    final deductionDetails = entry.details
        .where((detail) => detail.itemType == 'DEDUCTION')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deducciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: deductionDetails.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final detail = deductionDetails[index];
              return ListTile(
                title: Text(detail.itemName),
                subtitle: detail.notes != null && detail.notes!.isNotEmpty
                    ? Text(detail.notes!)
                    : null,
                trailing: Text(
                  currencyFormat.format(detail.amount * detail.quantity),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Total Deducciones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                currencyFormat.format(entry.totalDeductions),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(PayrollEntryModel entry) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Devengos:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  currencyFormat.format(entry.totalEarnings),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Deducciones:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  currencyFormat.format(entry.totalDeductions),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Neto a Pagar:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  currencyFormat.format(entry.netPay),                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _showApprovalConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Aprobación'),
          content: const Text(
            '¿Está seguro que desea aprobar esta nómina? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => _approveEntry(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Aprobar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _approveEntry(BuildContext context) async {
    // Close confirmation dialog first
    Navigator.of(context).pop();
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Aprobando nómina...'),
              ],
            ),
          );
        },
      );

      // Call approval method
      final payrollProvider = Provider.of<PayrollProvider>(context, listen: false);
      final success = await payrollProvider.approvePayrollEntry(widget.entryId);
      
      // Close loading dialog
      if (mounted) navigator.pop();
      
      if (success) {
        // Refresh entry data
        await payrollProvider.fetchPayrollEntryById(widget.entryId);
        
        // Show success message
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Nómina aprobada exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Refresh the UI
        setState(() {});
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Error al aprobar la nómina'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (error) {
      // Close loading dialog if still open
      if (mounted) navigator.pop();
      
      // Show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error al aprobar la nómina: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
