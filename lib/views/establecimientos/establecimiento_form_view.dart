import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/establecimiento.dart';
import '../../services/establecimiento_service.dart';
import '../../widgets/custom_drawer.dart';

class EstablecimientoFormView extends StatefulWidget {
  //! id nulo significa crear; con id se edita ese establecimiento
  final int? id;

  const EstablecimientoFormView({super.key, this.id});

  @override
  State<EstablecimientoFormView> createState() =>
      _EstablecimientoFormViewState();
}

class _EstablecimientoFormViewState extends State<EstablecimientoFormView> {
  //* Se crea una instancia de la clase EstablecimientoService
  final EstablecimientoService _service = EstablecimientoService();

  //! llave del formulario para disparar los validadores
  final _formKey = GlobalKey<FormState>();

  // Controladores de los cuatro campos obligatorios
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nitController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  //! selector de archivos para el logo (opcional)
  final ImagePicker _picker = ImagePicker();
  String? _logoPath;

  // Logo y estado que vienen de la API cuando se edita
  String _existingLogo = '';
  String _estado = '';

  // Banderas de carga del prellenado y de guardado
  bool _isLoading = false;
  bool _isSaving = false;
  String? _loadError;

  bool get _isEditing => widget.id != null;

  @override
  void initState() {
    super.initState();
    //! Al editar se trae la entidad para prellenar el formulario
    if (_isEditing) {
      _loadEntity();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _nitController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // Trae el establecimiento y prellena los controladores
  Future<void> _loadEntity() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final Establecimiento item = await _service.getEstablecimiento(
        widget.id!,
      );
      if (!mounted) return;
      setState(() {
        _nombreController.text = item.nombre;
        _nitController.text = item.nit;
        _direccionController.text = item.direccion;
        _telefonoController.text = item.telefono;
        _existingLogo = item.logo;
        _estado = item.estado;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  // Abre la galería y guarda la ruta del logo elegido
  Future<void> _pickLogo() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() => _logoPath = picked.path);
  }

  // Valida y guarda (crea o actualiza) y vuelve con true si todo salió bien
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    var saved = false;
    try {
      if (_isEditing) {
        await _service.updateEstablecimiento(
          id: widget.id!,
          nombre: _nombreController.text.trim(),
          nit: _nitController.text.trim(),
          direccion: _direccionController.text.trim(),
          telefono: _telefonoController.text.trim(),
          logoPath: _logoPath,
        );
      } else {
        await _service.createEstablecimiento(
          nombre: _nombreController.text.trim(),
          nit: _nitController.text.trim(),
          direccion: _direccionController.text.trim(),
          telefono: _telefonoController.text.trim(),
          logoPath: _logoPath,
        );
      }
      saved = true;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Establecimiento updated' : 'Establecimiento created',
          ),
        ),
      );
      //! se devuelve true para que la vista anterior recargue la lista
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      //! si ya se hizo pop no hace falta apagar el spinner
      if (!saved && mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit establecimiento' : 'New establecimiento',
        ),
      ),
      drawer: const CustomDrawer(),
      body: _buildBody(),
      //! sin formulario en pantalla (prellenado cargando o con error) no se muestra el boton de guardar
      bottomNavigationBar: (_isLoading || _loadError != null)
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          )
                        : const Text('Save'),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    //! Estado de carga del prellenado (solo en edición)
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    //! Estado de error del prellenado con reintento
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_loadError'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadEntity, child: const Text('Retry')),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //! Campos obligatorios del contrato de la API
              _buildField(
                controller: _nombreController,
                label: 'Nombre',
                icon: Icons.store,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _nitController,
                label: 'NIT',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _direccionController,
                label: 'Dirección',
                icon: Icons.place_outlined,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _telefonoController,
                label: 'Teléfono',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildLogoSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Campo de texto reutilizable con validación de requerido
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
      ),
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? 'Required' : null,
    );
  }

  // Selector del logo con previsualización del archivo o del logo remoto
  Widget _buildLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Logo (opcional)', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 8),
        _buildLogoPreview(),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _pickLogo,
          icon: const Icon(Icons.image),
          label: const Text('Select logo'),
        ),
        if (_isEditing && _estado.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Estado actual: ${_estado == 'A' ? 'Active' : 'Inactive'}'),
        ],
      ],
    );
  }

  Widget _buildLogoPreview() {
    //! 1) archivo local elegido en esta sesión
    if (_logoPath != null) {
      return Image.file(
        File(_logoPath!),
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, size: 64),
      );
    }
    //! 2) logo que ya tiene la entidad en el servidor
    final logoUrl = _service.logoUrlFor(_existingLogo);
    if (logoUrl.isNotEmpty) {
      return Image.network(
        logoUrl,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported, size: 64),
      );
    }
    //! 3) sin logo: icono de respaldo
    return const Icon(Icons.image_not_supported, size: 64);
  }
}
