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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Nómina'),
      ),
      body: Consumer<PayrollProvider>(
        builder: (context, payrollProvider, child) {
          final entry = payrollProvider.selectedEntry;
          
          if (entry == null) {
            return const Center(child: CircularProgressIndicator());
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
                  currencyFormat.format(entry.netPay),
                  style: const TextStyle(
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
              onPressed: () {
                // Implement approval logic here
                Navigator.of(context).pop();
              },
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
}
