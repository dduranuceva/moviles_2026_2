import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/pokemon.dart';

//! el pokemon service es el encargado de hacer las peticiones a la api
class PokemonService {
  // ! Se obtiene la url de la api desde el archivo .env
  String apiUrl = dotenv.env['POKE_API_URL']!;

  // ! Caché en memoria por nombre para evitar refetches del detalle
  final Map<String, Pokemon> _cacheByName = {};

  // ! Método para obtener la lista de Pokémon paginada
  // * se crea una istancia del modelo Pokemon, se hace una petición http a la url de la api y se obtiene la respuesta
  // * si el estado de la respuesta es 200 se decodifica la respuesta y se obtiene la lista de resultados

  Future<List<Pokemon>> getPokemons({int limit = 20, int offset = 0}) async {
    final response = await http.get(
      Uri.parse('$apiUrl/pokemon?limit=$limit&offset=$offset'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final List results = data['results']; // se obtiene la lista de resultados

      //! Se mapea la lista de resultados para obtener el detalle de cada Pokémon
      List<Future<Pokemon>> futures = results.map((item) {
        //retorna una lista de los detalles de cada pokemon
        return getPokemonByName(item['name']);
      }).toList();
      return Future.wait(futures);
    } else {
      throw Exception(
        'Error al obtener la lista de Pokémon (status ${response.statusCode}).',
      );
    }
  }

  // Método para obtener el detalle de un Pokémon por nombre
  // primero revisa la caché en memoria antes de pegar a la red
  Future<Pokemon> getPokemonByName(String name) async {
    // se normaliza la clave para que 'Pikachu' y 'pikachu' compartan entrada
    final key = name.toLowerCase();
    final cached = _cacheByName[key];
    if (cached != null) {
      return cached;
    }
    final response = await http.get(Uri.parse('$apiUrl/pokemon/$key'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pokemon = Pokemon.fromJson(
        data as Map<String, dynamic>,
      ); // se retorna el detalle del Pokémon
      // se guarda en caché para próximas lecturas (lista, detalle, reintentos)
      _cacheByName[key] = pokemon;
      return pokemon;
    } else {
      throw Exception(
        'Error al obtener el detalle del Pokémon "$name" (status ${response.statusCode}).',
      );
    }
  }
}
