import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/establecimiento.dart';
import '../../services/establecimiento_service.dart';
import '../../widgets/base_view.dart';

class EstablecimientoListView extends StatefulWidget {
  const EstablecimientoListView({super.key});

  @override
  State<EstablecimientoListView> createState() =>
      _EstablecimientoListViewState();
}

class _EstablecimientoListViewState extends State<EstablecimientoListView> {
  //* Se crea una instancia de la clase EstablecimientoService
  final EstablecimientoService _service = EstablecimientoService();

  // Lista, bandera de carga y mensaje de error
  List<Establecimiento> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    //! Primera carga al entrar a la vista
    _load();
  }

  // Carga la lista completa (también usada por el pull-to-refresh y el retry)
  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _service.getEstablecimientos();
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Abre el formulario de creación y recarga si hubo cambios
  Future<void> _openForm() async {
    final changed = await context.push<bool>('/establecimiento_nuevo');
    if (!mounted) return;
    if (changed == true) _load();
  }

  // Abre el formulario de edición y recarga si hubo cambios
  Future<void> _openEdit(int id) async {
    final changed = await context.push<bool>('/establecimiento_editar/$id');
    if (!mounted) return;
    if (changed == true) _load();
  }

  // Abre el detalle y recarga la lista al volver
  Future<void> _openDetail(int id) async {
    await context.push<bool>('/establecimiento/$id');
    if (!mounted) return;
    //! el detalle edita por dentro y no devuelve valor: se recarga siempre
    _load();
  }

  // Confirma el borrado lógico y refresca la lista
  Future<void> _confirmDelete(Establecimiento item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete establecimiento?'),
        content: Text(
          'The establecimiento "${item.nombre}" will be marked as inactive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.deleteEstablecimiento(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Establecimiento marked as inactive')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Establecimientos',
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildContent(),
          //! FAB sobre el cuerpo para no duplicar AppBar ni Drawer
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _openForm,
              icon: const Icon(Icons.add),
              label: const Text('New'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    //! Estado de carga inicial
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    //! Estado de error con reintento
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    //! Estado vacío
    if (_items.isEmpty) {
      return const Center(child: Text('No establecimientos found'));
    }
    //! Lista con pull-to-refresh
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildItem(item),
          );
        },
      ),
    );
  }

  // Card de un establecimiento: logo, datos, chip de estado y acciones
  Widget _buildItem(Establecimiento item) {
    final logoUrl = _service.logoUrlFor(item.logo);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () => _openDetail(item.id),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //! Slot del logo 48x48 con fallback a icono
              SizedBox(
                width: 48,
                height: 48,
                child: logoUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.store),
                        ),
                      )
                    : const Icon(Icons.store),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('NIT: ${item.nit}'),
                    Text(item.direccion),
                    Text(item.telefono),
                    const SizedBox(height: 8),
                    _buildStatusChip(item),
                  ],
                ),
              ),
              //! Acciones de editar y eliminar
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _openEdit(item.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(item),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Chip de estado derivado de estadoActivo
  Widget _buildStatusChip(Establecimiento item) {
    final color = item.estadoActivo ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        item.estadoActivo ? 'Active' : 'Inactive',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
