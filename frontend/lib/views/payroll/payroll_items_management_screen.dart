import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_plus/providers/payroll_provider.dart';
import 'package:rh_plus/models/payroll_models.dart';

class PayrollItemsManagementScreen extends StatefulWidget {
  const PayrollItemsManagementScreen({Key? key}) : super(key: key);

  @override
  State<PayrollItemsManagementScreen> createState() => _PayrollItemsManagementScreenState();
}

class _PayrollItemsManagementScreenState extends State<PayrollItemsManagementScreen>
    with SingleTickerProviderStateMixin {
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
      await payrollProvider.fetchPayrollItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading payroll items: $e'),
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
        title: const Text('Elementos de Nómina'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showItemForm,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.trending_up),
              text: 'Devengos',
            ),
            Tab(
              icon: Icon(Icons.trending_down),
              text: 'Deducciones',
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
              _buildItemsList('EARNING', payrollProvider),
              _buildItemsList('DEDUCTION', payrollProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItemsList(String itemType, PayrollProvider payrollProvider) {
    final filteredItems = payrollProvider.payrollItems
        .where((item) => item.itemType == itemType)
        .toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              itemType == 'EARNING' ? Icons.trending_up : Icons.trending_down,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text('No hay ${itemType == 'EARNING' ? 'devengos' : 'deducciones'} registrados'),
            const SizedBox(height: 8),
            Text(
              'Agrega elementos para configurar los conceptos de nómina',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(PayrollItemModel item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: item.itemType == 'EARNING' ? Colors.green : Colors.red,
          child: Icon(
            item.itemType == 'EARNING' ? Icons.add : Icons.remove,
            color: Colors.white,
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${item.code}'),
            if (item.description?.isNotEmpty == true)
              Text(
                item.description!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Chip(
          label: Text(
            item.isActive ? 'Activo' : 'Inactivo',
            style: TextStyle(
              color: item.isActive ? Colors.white : Colors.black87,
              fontSize: 12,
            ),
          ),
          backgroundColor: item.isActive ? Colors.green : Colors.grey.shade300,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Nombre:', item.name),
                _buildDetailRow('Código:', item.code),
                _buildDetailRow('Tipo:', item.itemType == 'EARNING' ? 'Devengo' : 'Deducción'),
                if (item.description?.isNotEmpty == true)
                  _buildDetailRow('Descripción:', item.description!),
                _buildDetailRow('Estado:', item.isActive ? 'Activo' : 'Inactivo'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showItemForm(item: item),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showItemDetails(item),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Detalles'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _toggleItemStatus(item),
                      icon: Icon(item.isActive ? Icons.pause : Icons.play_arrow),
                      label: Text(item.isActive ? 'Desactivar' : 'Activar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.isActive ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
  void _showItemForm({PayrollItemModel? item}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PayrollItemFormDialog(item: item),
    );
  }

  void _showItemDetails(PayrollItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del Elemento'),        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nombre:', item.name),
              _buildDetailRow('Código:', item.code),
              _buildDetailRow('Tipo:', item.itemType == 'EARNING' ? 'Devengo' : 'Deducción'),
              if (item.description?.isNotEmpty == true)
                _buildDetailRow('Descripción:', item.description!),
              _buildDetailRow('Estado:', item.isActive ? 'Activo' : 'Inactivo'),
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
  void _toggleItemStatus(PayrollItemModel item) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${item.isActive ? 'Desactivar' : 'Activar'} Elemento'),
        content: Text(
          item.isActive 
            ? '¿Está seguro que desea desactivar "${item.name}"?\n\nLos elementos desactivados no estarán disponibles para nuevas nóminas.'
            : '¿Está seguro que desea activar "${item.name}"?\n\nEl elemento estará disponible para nuevas nóminas.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final payrollProvider = Provider.of<PayrollProvider>(context, listen: false);
              final success = await payrollProvider.togglePayrollItemStatus(item.id);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'Estado del elemento actualizado exitosamente'
                        : 'Error al actualizar estado: ${payrollProvider.error}'
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: item.isActive ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(item.isActive ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }
}

class _PayrollItemFormDialog extends StatefulWidget {
  final PayrollItemModel? item;

  const _PayrollItemFormDialog({this.item});

  @override
  State<_PayrollItemFormDialog> createState() => _PayrollItemFormDialogState();
}

class _PayrollItemFormDialogState extends State<_PayrollItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _itemType = 'EARNING';
  bool _isActive = true;
  bool _isLoading = false;

  final Map<String, String> _itemTypes = {
    'EARNING': 'Devengo',
    'DEDUCTION': 'Deducción',
  };

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _initializeFormWithItem();
    }
  }

  void _initializeFormWithItem() {
    final item = widget.item!;
    _nameController.text = item.name;
    _codeController.text = item.code;
    _descriptionController.text = item.description ?? '';
    _itemType = item.itemType;
    _isActive = item.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Nuevo Elemento' : 'Editar Elemento'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    border: OutlineInputBorder(),
                    hintText: 'Ej: Salario Básico',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el nombre del elemento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Code
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Código *',
                    border: OutlineInputBorder(),
                    hintText: 'Ej: SAL001',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el código del elemento';
                    }
                    if (value.length < 3) {
                      return 'El código debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Item Type
                DropdownButtonFormField<String>(
                  value: _itemType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo *',
                    border: OutlineInputBorder(),
                  ),
                  items: _itemTypes.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Row(
                        children: [
                          Icon(
                            entry.key == 'EARNING' ? Icons.trending_up : Icons.trending_down,
                            color: entry.key == 'EARNING' ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(entry.value),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _itemType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                    hintText: 'Descripción opcional del elemento',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Active Status
                CheckboxListTile(
                  title: const Text('Elemento Activo'),
                  subtitle: const Text('Los elementos inactivos no estarán disponibles para nuevas nóminas'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value ?? true;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
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
                          'Los elementos creados estarán disponibles para ser utilizados en las nóminas de los empleados.',
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
          onPressed: _isLoading ? null : _saveItem,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.item == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final payrollProvider = Provider.of<PayrollProvider>(context, listen: false);
      
      final itemData = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim().toUpperCase(),
        'item_type': _itemType,
        'description': _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        'is_active': _isActive,
      };

      bool success;
      if (widget.item == null) {
        success = await payrollProvider.createPayrollItem(itemData);
      } else {
        success = await payrollProvider.updatePayrollItem(widget.item!.id, itemData);
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.item == null 
                    ? 'Elemento creado exitosamente' 
                    : 'Elemento actualizado exitosamente'
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(payrollProvider.error ?? 'Error al guardar elemento'),
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
