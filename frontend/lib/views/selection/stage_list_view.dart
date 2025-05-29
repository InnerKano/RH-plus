import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/selection_provider.dart';
import '../../models/selection_models.dart';
import '../../utils/constants.dart';

class StageListView extends StatefulWidget {
  const StageListView({Key? key}) : super(key: key);

  @override
  State<StageListView> createState() => _StageListViewState();
}

class _StageListViewState extends State<StageListView> {
  @override
  void initState() {
    super.initState();
    _loadStages();
  }

  void _loadStages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
      selectionProvider.loadStages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer<SelectionProvider>(
        builder: (context, selectionProvider, child) {
          if (selectionProvider.isLoadingStages) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.textColor),
                  SizedBox(height: 16),
                  Text(
                    'Cargando etapas...',
                    style: TextStyle(color: AppColors.greyDark),
                  ),
                ],
              ),
            );
          }

          if (selectionProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.greyDark,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar etapas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectionProvider.error!,
                    style: const TextStyle(color: AppColors.greyDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => selectionProvider.loadStages(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textColor,
                      foregroundColor: AppColors.backgroundColor,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (selectionProvider.stages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.linear_scale_outlined,
                    size: 64,
                    color: AppColors.greyDark,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay etapas configuradas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.greyDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Configura las etapas del proceso de selección',
                    style: TextStyle(color: AppColors.greyDark),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddStageDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Etapa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textColor,
                      foregroundColor: AppColors.backgroundColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: selectionProvider.stages.length,
            itemBuilder: (context, index) {
              final stage = selectionProvider.stages[index];
              return _buildStageCard(stage, index);
            },
            onReorder: (oldIndex, newIndex) {
              _reorderStages(oldIndex, newIndex, selectionProvider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStageDialog,
        backgroundColor: AppColors.textColor,
        child: const Icon(Icons.add, color: AppColors.backgroundColor),
      ),
    );
  }

  Widget _buildStageCard(StageModel stage, int index) {
    return Card(
      key: ValueKey(stage.id),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.greyLight, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:AppColors.textColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${stage.order}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                      ),
                      if (stage.description != null && stage.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          stage.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.greyDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.greyDark),
                  color: AppColors.backgroundColor,
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children:[
                          Icon(Icons.edit, color: AppColors.textColor, size: 20),
                          SizedBox(width: 8),
                          Text('Editar', style: TextStyle(color: AppColors.textColor)),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children:[
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) => _handleStageAction(value, stage),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(
                  Icons.drag_indicator,
                  size: 16,
                  color: AppColors.greyDark,
                ),
                SizedBox(width: 4),
                Text(
                  'Arrastra para reordenar',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.greyDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.1) : AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green.withValues(alpha: 0.3) : AppColors.greyDark.withValues(alpha: .3),
        ),
      ),
      child: Text(
        isActive ? 'Activa' : 'Inactiva',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.green : AppColors.greyDark,
        ),
      ),
    );
  }

  void _showAddStageDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final orderController = TextEditingController();

    // Set next order number
    final selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
    final nextOrder = selectionProvider.stages.isNotEmpty 
        ? selectionProvider.stages.map((s) => s.order).reduce((a, b) => a > b ? a : b) + 1
        : 1;
    orderController.text = nextOrder.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Nueva Etapa', style: TextStyle(color: AppColors.textColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.textColor),
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  labelStyle: TextStyle(color: AppColors.greyDark),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyDark),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: orderController,
                style: const TextStyle(color: AppColors.textColor),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Orden *',
                  labelStyle: TextStyle(color: AppColors.greyDark),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyDark),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: AppColors.textColor),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: AppColors.greyDark),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyDark),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.greyDark)),
          ),
          ElevatedButton(
            onPressed: () => _createStage(nameController, orderController, descriptionController),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textColor,
              foregroundColor: AppColors.backgroundColor,
            ),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _createStage(
    TextEditingController nameController,
    TextEditingController orderController,
    TextEditingController descriptionController,
  ) async {
    if (nameController.text.trim().isEmpty || orderController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
    final success = await selectionProvider.createStage({
      'name': nameController.text.trim(),
      'order': int.tryParse(orderController.text.trim()) ?? 0,
      'description': descriptionController.text.trim().isNotEmpty 
          ? descriptionController.text.trim() 
          : '',
    });

    Navigator.pop(context);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Etapa creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(selectionProvider.error ?? 'Error al crear etapa'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleStageAction(String action, StageModel stage) {
    final selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
    
    switch (action) {
      case 'edit':
        _showEditStageDialog(stage);
        break;
      case 'activate':
      case 'deactivate':
        break;
      case 'delete':
        _showDeleteConfirmation(stage, selectionProvider);
        break;
    }
  }

  void _showEditStageDialog(StageModel stage) {
    final nameController = TextEditingController(text: stage.name);
    final descriptionController = TextEditingController(text: stage.description ?? '');
    final orderController = TextEditingController(text: stage.order.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Editar Etapa', style: TextStyle(color: AppColors.textColor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.textColor),
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  labelStyle: TextStyle(color: AppColors.greyDark),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyDark),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: orderController,
                style: const TextStyle(color: AppColors.textColor),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Orden *',
                  labelStyle: TextStyle(color: AppColors.greyDark),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyDark),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: AppColors.textColor),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: AppColors.greyDark),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.greyDark),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.greyDark)),
          ),
          ElevatedButton(
            onPressed: () => _updateStage(stage, nameController, orderController, descriptionController),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textColor,
              foregroundColor: AppColors.backgroundColor,
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _updateStage(
    StageModel stage,
    TextEditingController nameController,
    TextEditingController orderController,
    TextEditingController descriptionController,
  ) async {
    if (nameController.text.trim().isEmpty || orderController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
    final success = await selectionProvider.updateStage(stage.id, {
      'name': nameController.text.trim(),
      'order': int.tryParse(orderController.text.trim()) ?? stage.order,
      'description': descriptionController.text.trim().isNotEmpty 
          ? descriptionController.text.trim() 
          : null,
    });

    Navigator.pop(context);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Etapa actualizada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(selectionProvider.error ?? 'Error al actualizar etapa'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(StageModel stage, SelectionProvider selectionProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Confirmar eliminación', style: TextStyle(color: AppColors.textColor)),
        content: Text(
          '¿Estás seguro de que quieres eliminar la etapa "${stage.name}"?\n\nEsta acción no se puede deshacer.',
          style: const TextStyle(color: AppColors.greyDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.greyDark)),
          ),
          ElevatedButton(
            onPressed: () => _deleteStage(stage, selectionProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteStage(StageModel stage, SelectionProvider selectionProvider) async {
    final success = await selectionProvider.deleteStage(stage.id);
    
    Navigator.pop(context);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Etapa eliminada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(selectionProvider.error ?? 'Error al eliminar etapa'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _reorderStages(int oldIndex, int newIndex, SelectionProvider selectionProvider) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    // This would need to be implemented on the backend to update all stage orders
    // For now, we'll just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de reordenamiento en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}