import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../themes/type_colors.dart';
import 'type_chip.dart';

//! Card de la Pokédex: gradiente del tipo primario, Hero del artwork,
//! número, nombre y chips de tipos. Altura fija ~180 para el grid.
class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap;

  const PokemonCard({super.key, required this.pokemon, this.onTap});

  @override
  Widget build(BuildContext context) {
    // color base del tipo primario para el gradiente
    final base = primaryColor(pokemon);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [base, base.withValues(alpha: 0.65)],
            ),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // número formateado estilo Pokédex (#001)
              Text(
                '#${pokemon.id.toString().padLeft(3, '0')}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // artwork con Hero para animar hacia el detalle
              Expanded(
                child: Center(
                  child: Hero(
                    tag: 'pokemon-${pokemon.id}',
                    child: Image.network(
                      pokemon.artwork.isNotEmpty
                          ? pokemon.artwork
                          : pokemon.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                            Icons.catching_pokemon,
                            color: Colors.white70,
                            size: 48,
                          ),
                    ),
                  ),
                ),
              ),
              // nombre en mayúsculas
              Text(
                pokemon.name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // chips de tipos
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: pokemon.types
                    .map((type) => TypeChip(type: type))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
