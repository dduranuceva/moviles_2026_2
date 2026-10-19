import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/establecimiento.dart';

//! excepción propia del servicio: lleva el mensaje de la API y el status code
class EstablecimientoApiException implements Exception {
  final String message;
  final int? statusCode;

  const EstablecimientoApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

//! el establecimiento service es el encargado de hacer las peticiones a la API
class EstablecimientoService {
  // ! Se obtiene la url de la api desde el archivo .env
  String apiUrl = dotenv.env['URL_PARKING']!;

  /// Base publica de los logos. Si la key no existe, se deriva del host de la API
  /// (por ejemplo `https://parking.ejemplo.com/logos/`).
  //! getter (no campo): dotenv debe leerse de forma perezosa, despues de dotenv.load()
  String get logoBaseUrl {
    final explicit = dotenv.env['URL_PARKING_LOGOS'];
    if (explicit != null && explicit.isNotEmpty) return explicit;
    final host = apiUrl.endsWith('/api')
        ? apiUrl.substring(0, apiUrl.length - 4)
        : apiUrl;
    return '$host/logos/';
  }

  //! Construye la URL publica del logo a partir del nombre de archivo que da la API
  String logoUrlFor(String? logo) =>
      (logo == null || logo.isEmpty || logoBaseUrl.isEmpty)
      ? ''
      : '$logoBaseUrl$logo';

  // ! Arma el mensaje de error leyendo el cuerpo de la respuesta (message/mensaje/error)
  String _errorMessage(String body, int statusCode, String action) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map) {
        final message = decoded['message'];
        if (message is String && message.isNotEmpty) return message;
        final mensaje = decoded['mensaje'];
        if (mensaje is String && mensaje.isNotEmpty) return mensaje;
        final error = decoded['error'];
        if (error is String && error.isNotEmpty) return error;
        if (error is Map) {
          final nested = error['message'];
          if (nested is String && nested.isNotEmpty) return nested;
        }
      }
    } catch (_) {
      //! el cuerpo no era JSON: se cae al mensaje generico de abajo
    }
    return '$action failed (status $statusCode).';
  }

  // ! Metodo para obtener la lista completa de establecimientos
  Future<List<Establecimiento>> getEstablecimientos() async {
    final response = await http.get(Uri.parse('$apiUrl/establecimientos'));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      //! se tolera tanto el envelope { data: [...] } como un array plano
      final List<dynamic> raw;
      if (decoded is Map && decoded['data'] is List) {
        raw = decoded['data'] as List<dynamic>;
      } else if (decoded is List) {
        raw = decoded;
      } else {
        raw = const [];
      }
      return raw
          .whereType<Map<String, dynamic>>()
          .map(Establecimiento.fromJson)
          .toList();
    }
    throw EstablecimientoApiException(
      _errorMessage(response.body, response.statusCode, 'Listing establecimientos'),
      statusCode: response.statusCode,
    );
  }

  // ! Metodo para obtener el detalle de un establecimiento por id
  Future<Establecimiento> getEstablecimiento(int id) async {
    final response = await http.get(
      Uri.parse('$apiUrl/establecimientos/$id'),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      //! el envelope real trae { data: {...} }, pero se tolera el objeto plano
      Map<String, dynamic>? data;
      if (decoded is Map<String, dynamic>) {
        final inner = decoded['data'];
        if (inner is Map<String, dynamic>) {
          data = inner;
        } else if (decoded.containsKey('id')) {
          //! solo se acepta el mapa plano si de verdad parece una entidad
          data = decoded;
        }
      }
      if (data == null) {
        throw EstablecimientoApiException(
          'Establecimiento $id not found (status ${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }
      return Establecimiento.fromJson(data);
    }
    throw EstablecimientoApiException(
      _errorMessage(
        response.body,
        response.statusCode,
        'Loading establecimiento $id',
      ),
      statusCode: response.statusCode,
    );
  }

  // ! Metodo para crear un establecimiento (multipart con el logo opcional)
  Future<void> createEstablecimiento({
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    String? logoPath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiUrl/establecimientos'),
    );
    request.fields['nombre'] = nombre;
    request.fields['nit'] = nit;
    request.fields['direccion'] = direccion;
    request.fields['telefono'] = telefono;
    //! el logo es opcional: solo se adjunta si el usuario eligio un archivo
    if (logoPath != null && logoPath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('logo', logoPath));
    }
    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }
    throw EstablecimientoApiException(
      _errorMessage(response.body, response.statusCode, 'Creating establecimiento'),
      statusCode: response.statusCode,
    );
  }

  // ! Metodo para actualizar un establecimiento (POST con _method=PUT)
  Future<void> updateEstablecimiento({
    required int id,
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    String? logoPath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiUrl/establecimientos/$id'),
    );
    //! la API exige el _method cuando se envia multipart con el logo
    request.fields['_method'] = 'PUT';
    request.fields['nombre'] = nombre;
    request.fields['nit'] = nit;
    request.fields['direccion'] = direccion;
    request.fields['telefono'] = telefono;
    if (logoPath != null && logoPath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('logo', logoPath));
    }
    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      return;
    }
    throw EstablecimientoApiException(
      _errorMessage(response.body, response.statusCode, 'Updating establecimiento'),
      statusCode: response.statusCode,
    );
  }

  // ! Metodo para eliminar un establecimiento (borrado logico en el servidor)
  Future<void> deleteEstablecimiento(int id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/establecimientos/$id'),
    );

    if (response.statusCode == 200) {
      return;
    }
    throw EstablecimientoApiException(
      _errorMessage(response.body, response.statusCode, 'Deleting establecimiento'),
      statusCode: response.statusCode,
    );
  }
}
