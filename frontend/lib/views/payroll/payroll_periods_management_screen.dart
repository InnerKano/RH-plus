import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/providers/payroll_provider.dart';
import 'package:rh_plus/models/payroll_models.dart';
import 'package:intl/intl.dart';

class PayrollPeriodsManagementScreen extends StatefulWidget {
  const PayrollPeriodsManagementScreen({Key? key}) : super(key: key);

  @override
  State<PayrollPeriodsManagementScreen> createState() => _PayrollPeriodsManagementScreenState();
}

class _PayrollPeriodsManagementScreenState extends State<PayrollPeriodsManagementScreen>
    with SingleTickerProviderStateMixin {
  final dateFormat = DateFormat('dd/MM/yyyy');
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
  }

  Future<void> _loadData() async {
    final payrollProvider = Provider.of<PayrollProvider>(context, listen: false);
    
    try {
      await payrollProvider.fetchPayrollPeriods();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading periods: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Períodos de Nómina'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showPeriodForm,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.lock_open),
              text: 'Períodos Abiertos',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'Historial',
            ),
          ],
        ),
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

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOpenPeriods(payrollProvider),
              _buildAllPeriods(payrollProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOpenPeriods(PayrollProvider payrollProvider) {
    final openPeriods = payrollProvider.periods.where((period) => !period.isClosed).toList();

    if (openPeriods.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay períodos abiertos'),
            SizedBox(height: 8),
            Text(
              'Crea un nuevo período para comenzar a procesar nóminas',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: openPeriods.length,
      itemBuilder: (context, index) {
        final period = openPeriods[index];
        return _buildPeriodCard(period, isOpen: true);
      },
    );
  }

  Widget _buildAllPeriods(PayrollProvider payrollProvider) {
    if (payrollProvider.periods.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay períodos registrados'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: payrollProvider.periods.length,
      itemBuilder: (context, index) {
        final period = payrollProvider.periods[index];
        return _buildPeriodCard(period, isOpen: false);
      },
    );
  }

  Widget _buildPeriodCard(PayrollPeriodModel period, {required bool isOpen}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: period.isClosed ? Colors.grey : Colors.green,
          child: Icon(
            period.isClosed ? Icons.lock : Icons.lock_open,
            color: Colors.white,
          ),
        ),
        title: Text(
          period.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${dateFormat.format(DateTime.parse(period.startDate))} - ${dateFormat.format(DateTime.parse(period.endDate))}'),
            Text('Tipo: ${_getPeriodTypeLabel(period.periodType)}'),
            if (period.isClosed && period.closedAt != null)
              Text(
                'Cerrado: ${dateFormat.format(DateTime.parse(period.closedAt!))}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                period.isClosed ? 'Cerrado' : 'Abierto',
                style: TextStyle(
                  color: period.isClosed ? Colors.white : Colors.black87,
                  fontSize: 12,
                ),
              ),
              backgroundColor: period.isClosed ? Colors.grey : Colors.green,
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handlePeriodAction(value, period),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'details',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('Ver Detalles'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Editar'),
                  ),
                ),
                if (!period.isClosed)
                  const PopupMenuItem(
                    value: 'close',
                    child: ListTile(
                      leading: Icon(Icons.lock, color: Colors.red),
                      title: Text('Cerrar Período'),
                    ),
                  ),
                const PopupMenuItem(
                  value: 'entries',
                  child: ListTile(
                    leading: Icon(Icons.list),
                    title: Text('Ver Nóminas'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodTypeLabel(String type) {
    switch (type) {
      case 'MONTHLY':
        return 'Mensual';
      case 'BIWEEKLY':
        return 'Quincenal';
      case 'WEEKLY':
        return 'Semanal';
      case 'CUSTOM':
        return 'Personalizado';
      default:
        return type;
    }
  }

  void _handlePeriodAction(String action, PayrollPeriodModel period) {
    switch (action) {
      case 'details':
        _showPeriodDetails(period);
        break;
      case 'edit':
        _showPeriodForm(period: period);
        break;
      case 'close':
        _showClosePeriodConfirmation(period);
        break;
      case 'entries':
        _navigateToPayrollEntries(period);
        break;
    }
  }

  void _showPeriodDetails(PayrollPeriodModel period) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del Período'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nombre:', period.name),
              _buildDetailRow('Tipo:', _getPeriodTypeLabel(period.periodType)),
              _buildDetailRow('Fecha Inicio:', dateFormat.format(DateTime.parse(period.startDate))),
              _buildDetailRow('Fecha Fin:', dateFormat.format(DateTime.parse(period.endDate))),
              _buildDetailRow('Estado:', period.isClosed ? 'Cerrado' : 'Abierto'),
              if (period.isClosed && period.closedAt != null)
                _buildDetailRow('Cerrado:', dateFormat.format(DateTime.parse(period.closedAt!))),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  void _showPeriodForm({PayrollPeriodModel? period}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PeriodFormDialog(period: period),
    );
  }

  void _showClosePeriodConfirmation(PayrollPeriodModel period) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Período'),
        content: Text(
          '¿Está seguro que desea cerrar el período "${period.name}"?\n\n'
          'Esta acción no se puede deshacer y evitará la creación de nuevas nóminas en este período.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _closePeriod(period);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Período'),
          ),
        ],
      ),
    );
  }
  void _closePeriod(PayrollPeriodModel period) async {
    final payrollProvider = Provider.of<PayrollProvider>(context, listen: false);
    
    try {
      final success = await payrollProvider.closePayrollPeriod(period.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Período cerrado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the data
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(payrollProvider.error ?? 'Error al cerrar período'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToPayrollEntries(PayrollPeriodModel period) {
    // TODO: Navigate to payroll entries for this period
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver nóminas del período: ${period.name}'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class _PeriodFormDialog extends StatefulWidget {
  final PayrollPeriodModel? period;

  const _PeriodFormDialog({this.period});

  @override
  State<_PeriodFormDialog> createState() => _PeriodFormDialogState();
}

class _PeriodFormDialogState extends State<_PeriodFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String? _selectedPeriodType;
  bool _isLoading = false;

  final List<Map<String, String>> _periodTypes = [
    {'value': 'BIWEEKLY', 'label': 'Quincenal'},
    {'value': 'MONTHLY', 'label': 'Mensual'},
    {'value': 'WEEKLY', 'label': 'Semanal'},
    {'value': 'CUSTOM', 'label': 'Personalizado'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.period != null) {
      _initializeFormWithPeriod();
    } else {
      _selectedPeriodType = 'MONTHLY';
    }
  }

  void _initializeFormWithPeriod() {
    final period = widget.period!;
    _nameController.text = period.name;
    _startDateController.text = period.startDate;
    _endDateController.text = period.endDate;
    _selectedPeriodType = period.periodType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.period == null ? 'Nuevo Período' : 'Editar Período'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Period Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Período *',
                    border: OutlineInputBorder(),
                    hintText: 'Ej: Período Enero 2025',
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Ingrese el nombre' : null,
                ),
                const SizedBox(height: 16),

                // Period Type
                DropdownButtonFormField<String>(
                  value: _selectedPeriodType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Período *',
                    border: OutlineInputBorder(),
                  ),
                  items: _periodTypes.map((type) {
                    return DropdownMenuItem(
                      value: type['value'],
                      child: Text(type['label']!),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedPeriodType = value),
                  validator: (value) => value == null ? 'Seleccione un tipo' : null,
                ),
                const SizedBox(height: 16),

                // Start Date
                TextFormField(
                  controller: _startDateController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Inicio *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, _startDateController),
                  validator: (value) => value?.isEmpty ?? true ? 'Seleccione fecha' : null,
                ),
                const SizedBox(height: 16),

                // End Date
                TextFormField(
                  controller: _endDateController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Fin *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, _endDateController),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Seleccione fecha';
                    if (_startDateController.text.isNotEmpty) {
                      final startDate = DateTime.parse(_startDateController.text);
                      final endDate = DateTime.parse(value!);
                      if (endDate.isBefore(startDate)) {
                        return 'La fecha fin debe ser posterior a la fecha inicio';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Info note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'El período se creará abierto y permitirá la creación de nuevas nóminas.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _savePeriod,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.period == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _savePeriod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final payrollProvider = Provider.of<PayrollProvider>(context, listen: false);
      
      final periodData = {
        'name': _nameController.text,
        'period_type': _selectedPeriodType,
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
      };

      bool success;
      if (widget.period == null) {
        success = await payrollProvider.createPayrollPeriod(periodData);
      } else {
        success = await payrollProvider.updatePayrollPeriod(widget.period!.id, periodData);
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.period == null 
                    ? 'Período creado exitosamente' 
                    : 'Período actualizado exitosamente'
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(payrollProvider.error ?? 'Error al guardar período'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
