import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/pokemon.dart';
import '../../services/pokemon_service.dart';
import '../../widgets/base_view.dart';
import '../../widgets/pokemon_card.dart';

class PokemonListView extends StatefulWidget {
  const PokemonListView({super.key});

  @override
  State<PokemonListView> createState() => _PokemonListViewState();
}

class _PokemonListViewState extends State<PokemonListView> {
  //* Se crea una instancia de la clase PokemonService
  final PokemonService _pokemonService = PokemonService();
  //* Tamaño de página para la paginación con offset
  static const int _pageSize = 20;

  // Lista acumulada, offset actual y banderas de carga/paginación
  final List<Pokemon> _pokemons = [];
  int _offset = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  // Búsqueda local por nombre y scroll para paginación
  String _query = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    //! Primera página al entrar a la vista
    _loadInitial();
    //! Cuando el scroll llega al final se pide la siguiente página
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Si el usuario scrollea cerca del final y hay más, carga la siguiente página
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        !_isLoading &&
        _hasMore &&
        _query.isEmpty) {
      _loadMore();
    }
  }

  // Carga inicial (también usada por el pull-to-refresh)
  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final pokemons = await _pokemonService.getPokemons(
        limit: _pageSize,
        offset: 0,
      );
      setState(() {
        _pokemons
          ..clear()
          ..addAll(pokemons);
        _offset = pokemons.length;
        // si vino menos de una página, no hay más para pedir
        _hasMore = pokemons.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Pide la siguiente página y la acumula (offset += pageSize)
  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final pokemons = await _pokemonService.getPokemons(
        limit: _pageSize,
        offset: _offset,
      );
      setState(() {
        _pokemons.addAll(pokemons);
        _offset += pokemons.length;
        _hasMore = pokemons.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading more: $e')));
      }
    }
  }

  // Pull-to-refresh: vuelve a pedir desde el offset 0
  Future<void> _onRefresh() => _loadInitial();

  // Filtrado local por nombre (no pega a la red)
  List<Pokemon> get _filtered {
    if (_query.isEmpty) return _pokemons;
    final q = _query.toLowerCase();
    return _pokemons.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Pokédex',
      body: Column(
        children: [
          //! Buscador local por nombre
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Pokémon...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(child: _buildContent()),
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
    if (_error != null && _pokemons.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadInitial, child: const Text('Retry')),
          ],
        ),
      );
    }
    final filtered = _filtered;
    //! Estado vacío (sin resultados para el filtro o lista vacía)
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          _query.isNotEmpty
              ? 'No Pokémon found for "$_query"'
              : 'No Pokémon found',
        ),
      );
    }
    //! Grid moderna de 2 columnas con pull-to-refresh y paginación
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 220,
        ),
        // tile extra al final para el loader / botón "Load more"
        itemCount: filtered.length + (_query.isEmpty && _hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filtered.length) {
            return _buildLoadMoreTile();
          }
          final pokemon = filtered[index];
          return PokemonCard(
            pokemon: pokemon,
            onTap: () {
              context.push('/pokemon/${pokemon.name}');
            },
          );
        },
      ),
    );
  }

  // Tile final: spinner mientras carga más, si no botón "Load more"
  Widget _buildLoadMoreTile() {
    if (_isLoadingMore) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: ElevatedButton(
        onPressed: _loadMore,
        child: const Text('Load more'),
      ),
    );
  }
}
