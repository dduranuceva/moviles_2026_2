import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/establecimiento.dart';
import '../../services/establecimiento_service.dart';
import '../../widgets/base_view.dart';

class EstablecimientoDetailView extends StatefulWidget {
  final int id;

  const EstablecimientoDetailView({super.key, required this.id});

  @override
  State<EstablecimientoDetailView> createState() =>
      _EstablecimientoDetailViewState();
}

class _EstablecimientoDetailViewState extends State<EstablecimientoDetailView> {
  //* Se crea una instancia de la clase EstablecimientoService
  final EstablecimientoService _service = EstablecimientoService();

  // Se declara un Future que contendrá el detalle del establecimiento
  late Future<Establecimiento> _future;

  @override
  void initState() {
    super.initState();
    // Se llama al método getEstablecimiento de la clase EstablecimientoService
    _future = _service.getEstablecimiento(widget.id);
  }

  // Reintenta la carga del detalle
  void _reload() {
    //! bloque explicito: setState asserta si el callback devuelve un Future
    setState(() {
      _future = _service.getEstablecimiento(widget.id);
    });
  }

  // Abre el formulario de edición y recarga si hubo cambios
  Future<void> _openEdit() async {
    final changed = await context.push<bool>(
      '/establecimiento_editar/${widget.id}',
    );
    if (!mounted) return;
    if (changed == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Establecimiento #${widget.id}',
      body: FutureBuilder<Establecimiento>(
        future: _future,
        builder: (context, snapshot) {
          //! Estado de error con reintento
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          //! Estado de carga
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildDetail(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildDetail(Establecimiento item) {
    final logoUrl = _service.logoUrlFor(item.logo);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //! Logo remoto cuando la base pública está configurada
            if (logoUrl.isNotEmpty)
              Image.network(
                logoUrl,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.store, size: 64),
              )
            else
              const Icon(Icons.store, size: 64),
            const SizedBox(height: 16),
            Text(
              item.nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            //! Card con los datos del establecimiento
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow('NIT', item.nit),
                    _buildRow('Dirección', item.direccion),
                    _buildRow('Teléfono', item.telefono),
                    _buildRow('Estado', item.estadoActivo ? 'Active' : 'Inactive'),
                    _buildRow('Created', item.createdAt),
                    _buildRow('Updated', item.updatedAt),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _openEdit,
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }

  // Fila etiqueta / valor dentro de la card
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}
