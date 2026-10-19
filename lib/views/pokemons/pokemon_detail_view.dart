import 'package:flutter/material.dart';

import '../../models/pokemon.dart';
import '../../services/pokemon_service.dart';
import '../../themes/type_colors.dart';
import '../../widgets/stats_bar.dart';
import '../../widgets/type_chip.dart';

class PokemonDetailView extends StatefulWidget {
  final String name;

  const PokemonDetailView({super.key, required this.name});

  @override
  State<PokemonDetailView> createState() => _PokemonDetailViewState();
}

class _PokemonDetailViewState extends State<PokemonDetailView> {
  // Se crea una instancia de la clase PokemonService
  final PokemonService _pokemonService = PokemonService();
  // Se declara una variable de tipo Future que contendrá el detalle del Pokémon
  late Future<Pokemon> _futurePokemon;

  @override
  void initState() {
    super.initState();
    // Se llama al método getPokemonByName de la clase PokemonService
    // (usa la caché en memoria si el Pokémon ya se vio en la lista)
    _futurePokemon = _pokemonService.getPokemonByName(widget.name);
  }

  @override
  Widget build(BuildContext context) {
    //* se usa future builder para construir widgets basados en un Future
    return FutureBuilder<Pokemon>(
      future: _futurePokemon,
      builder: (context, snapshot) {
        //! Estado de error
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.name.toUpperCase())),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        //! Estado de carga: AppBar neutra hasta conocer el tipo
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.name.toUpperCase())),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        // Se obtiene el detalle del Pokémon
        final pokemon = snapshot.data!;
        // color del tipo primario para AppBar y header
        final base = primaryColor(pokemon);
        return Scaffold(
          // AppBar teñida con el tipo primario y título en mayúsculas
          appBar: AppBar(
            title: Text(pokemon.name.toUpperCase()),
            backgroundColor: base,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //! Header en gradiente con el Hero del artwork grande
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [base, base.withValues(alpha: 0.55)],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      Text(
                        '#${pokemon.id.toString().padLeft(3, '0')}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Hero con el mismo tag de la card para animar la transición
                      Hero(
                        tag: 'pokemon-${pokemon.id}',
                        child: Image.network(
                          pokemon.artwork.isNotEmpty
                              ? pokemon.artwork
                              : pokemon.image,
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.catching_pokemon,
                                color: Colors.white70,
                                size: 120,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pokemon.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                //! Card blanca con tipos, altura/peso y stats
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tipos del Pokémon con chips de color
                          // el widget Wrap se utiliza para envolver a los chips y que se ajusten al tamaño del contenedor
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: pokemon.types
                                .map((type) => TypeChip(type: type))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          // Fila de altura y peso (la API los da en decímetros/hectogramos)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMeasure(
                                'HEIGHT',
                                '${(pokemon.height / 10).toStringAsFixed(1)} m',
                              ),
                              _buildMeasure(
                                'WEIGHT',
                                '${(pokemon.weight / 10).toStringAsFixed(1)} kg',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'BASE STATS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Stats con barras; si viene vacía se muestra mensaje
                          ..._buildStats(pokemon),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Columna centrada con etiqueta y valor (altura/peso)
  Widget _buildMeasure(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Lista de barras de stats en orden canónico; mensaje si no hay stats
  List<Widget> _buildStats(Pokemon pokemon) {
    const statLabels = {
      'hp': 'HP',
      'attack': 'Attack',
      'defense': 'Defense',
      'special-attack': 'Sp. Atk',
      'special-defense': 'Sp. Def',
      'speed': 'Speed',
    };
    final entries = statLabels.entries
        .where((e) => pokemon.stats.containsKey(e.key))
        .toList();
    if (entries.isEmpty) {
      return const [
        Text(
          'No stats available for this Pokémon.',
          style: TextStyle(color: Colors.black54),
        ),
      ];
    }
    return entries
        .map(
          (e) => StatsBar(
            label: e.value,
            value: pokemon.stats[e.key] ?? 0,
          ),
        )
        .toList();
  }
}
