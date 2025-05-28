import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/selection_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/selection_models.dart';
import '../../utils/constants.dart';
import 'candidate_form.dart';
import 'candidate_detail_view.dart';

class CandidateListView extends StatefulWidget {
  const CandidateListView({Key? key}) : super(key: key);

  @override
  State<CandidateListView> createState() => _CandidateListViewState();
}

class _CandidateListViewState extends State<CandidateListView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
      selectionProvider.loadCandidates(refresh: true);
      selectionProvider.loadPositions();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
      if (selectionProvider.hasMoreCandidates && !selectionProvider.isLoadingCandidates) {
        selectionProvider.loadCandidates();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildCandidatesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddCandidate(),
        backgroundColor: AppColors.textColor,
        child: const Icon(Icons.add, color: AppColors.backgroundColor),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.backgroundColor,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textColor),
                  decoration: InputDecoration(
                    hintText: 'Buscar candidatos...',
                    hintStyle: const TextStyle(color: AppColors.greyDark),
                    prefixIcon: const Icon(Icons.search, color: AppColors.greyDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.greyDark),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.greyDark),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.textColor),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundColor,
                  ),
                  onSubmitted: (value) => _performSearch(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  style: const TextStyle(color: AppColors.textColor),
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    labelStyle: const TextStyle(color: AppColors.greyDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.greyDark),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.textColor),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundColor,
                  ),
                  dropdownColor: AppColors.backgroundColor,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Todos', style: TextStyle(color: AppColors.textColor)),
                    ),
                    ...SelectionStatus.displayNames.entries.map(
                      (entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value, style: const TextStyle(color: AppColors.textColor)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    _performSearch();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear, color: AppColors.greyDark),
                tooltip: 'Limpiar filtros',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatesList() {
    return Consumer<SelectionProvider>(
      builder: (context, selectionProvider, child) {
        if (selectionProvider.isLoadingCandidates && selectionProvider.candidates.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.textColor),
                SizedBox(height: 16),
                Text(
                  'Cargando candidatos...',
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
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.greyDark,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar candidatos',
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
                  onPressed: () => selectionProvider.loadCandidates(refresh: true),
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

        if (selectionProvider.candidates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppColors.greyDark,
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay candidatos registrados',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Comienza agregando tu primer candidato',
                  style: TextStyle(color: AppColors.greyDark),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _navigateToAddCandidate,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Candidato'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textColor,
                    foregroundColor: AppColors.backgroundColor,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: selectionProvider.candidates.length + 
                     (selectionProvider.hasMoreCandidates ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == selectionProvider.candidates.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppColors.textColor),
                ),
              );
            }

            final candidate = selectionProvider.candidates[index];
            return _buildCandidateCard(candidate);
          },
        );
      },
    );
  }

  Widget _buildCandidateCard(CandidateModel candidate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.greyLight, width: 1),
      ),
      child: InkWell(
        onTap: () => _navigateToCandidateDetail(candidate),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.greyLight,
                    backgroundImage: candidate.profileImage != null && candidate.profileImage!.isNotEmpty
                        ? NetworkImage(candidate.profileImage!)
                        : null,
                    child: candidate.profileImage == null || candidate.profileImage!.isEmpty
                        ? Text(
                            candidate.firstName.isNotEmpty ? candidate.firstName[0].toUpperCase() : 'C',
                            style: const TextStyle(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          candidate.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.greyDark,
                          ),
                        ),
                        if (candidate.phone != null && candidate.phone!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            candidate.phone!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.greyDark,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildStatusChip(candidate.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 16,
                    color: AppColors.greyDark,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      candidate.positionTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.greyDark,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.greyDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(candidate.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.greyDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final statusInfo = SelectionStatus.displayNames[status] ?? status;
    final color = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        statusInfo,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case SelectionStatus.applied:
        return Colors.blue;
      case SelectionStatus.inProgress:
        return Colors.orange;
      case SelectionStatus.approved:
        return Colors.green;
      case SelectionStatus.rejected:
        return Colors.red;
      case SelectionStatus.hired:
        return Colors.purple;
      case SelectionStatus.withdrawn:
        return AppColors.greyDark;
      default:
        return AppColors.greyDark;
    }
  }

  void _performSearch() {
    final selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
    selectionProvider.setSearchQuery(_searchController.text.trim().isEmpty ? null : _searchController.text.trim());
    selectionProvider.setStatusFilter(_selectedStatus);
    selectionProvider.loadCandidates(refresh: true);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
    });
    final selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
    selectionProvider.clearFilters();
    selectionProvider.loadCandidates(refresh: true);
  }

  void _navigateToAddCandidate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CandidateForm(),
      ),
    ).then((_) {
      // Refresh the list when returning from form
      final selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
      selectionProvider.loadCandidates(refresh: true);
    });
  }

  void _navigateToCandidateDetail(CandidateModel candidate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CandidateDetailView(candidate: candidate),
      ),
    ).then((_) {
      // Refresh the list when returning from detail
      final selectionProvider = Provider.of<SelectionProvider>(context, listen: false);
      selectionProvider.loadCandidates(refresh: true);
    });
  }
}