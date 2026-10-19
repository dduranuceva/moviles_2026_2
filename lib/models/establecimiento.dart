/// Modelo para representar un Establecimiento (parqueadero) tal como lo
/// entrega la API: datos básicos, logo, estado lógico y marcas de tiempo.
class Establecimiento {
  int id;
  String nombre;
  String nit;
  String direccion;
  String telefono;
  String logo;
  String estado;
  String createdAt;
  String updatedAt;

  // Constructor con los atributos requeridos: obliga a pasar todo al instanciar
  Establecimiento({
    required this.id,
    required this.nombre,
    required this.nit,
    required this.direccion,
    required this.telefono,
    required this.logo,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
  });

  //! El estado lógico viene como 'A' (activo) o 'I' (inactivo)
  bool get estadoActivo => estado == 'A';

  // Factory porque retorna una nueva instancia: convierte el JSON en modelo.
  // Es null-safe y ademas tolerante a tipos: un valor con el tipo equivocado
  // se convierte a texto (o a 0 para el id) en lugar de romper el parseo.
  factory Establecimiento.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return Establecimiento(
      id: rawId is num ? rawId.toInt() : int.tryParse('${rawId ?? ''}') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      nit: json['nit']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  // Simétrico al fromJson: mismas claves para poder reenviar el objeto
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nit': nit,
      'direccion': direccion,
      'telefono': telefono,
      'logo': logo,
      'estado': estado,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Copia con cambios selectivos: se usa para prellenar el formulario de edición
  Establecimiento copyWith({
    int? id,
    String? nombre,
    String? nit,
    String? direccion,
    String? telefono,
    String? logo,
    String? estado,
    String? createdAt,
    String? updatedAt,
  }) {
    return Establecimiento(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      nit: nit ?? this.nit,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      logo: logo ?? this.logo,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
