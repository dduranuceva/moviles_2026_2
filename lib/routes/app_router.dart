import 'package:go_router/go_router.dart';
import 'package:moviles_2026_2/views/ciclo_vida/ciclo_vida_screen.dart';
import 'package:moviles_2026_2/views/establecimientos/establecimiento_detail_view.dart';
import 'package:moviles_2026_2/views/establecimientos/establecimiento_form_view.dart';
import 'package:moviles_2026_2/views/establecimientos/establecimiento_list_view.dart';
import 'package:moviles_2026_2/views/home/home_screen.dart';
import 'package:moviles_2026_2/views/paso_parametros/detalle_screen.dart';
import 'package:moviles_2026_2/views/paso_parametros/paso_parametros_screen.dart';
import 'package:moviles_2026_2/views/pokemons/pokemon_detail_view.dart';
import 'package:moviles_2026_2/views/pokemons/pokemon_list_view.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(), // Usa HomeView
    ),
    // Rutas para el paso de parámetros
    GoRoute(
      path: '/paso_parametros',
      builder: (context, state) => const PasoParametrosScreen(),
    ),

    // !Ruta para el detalle con parámetros
    GoRoute(
      path: '/detalle/:parametro/:metodo', //la ruta recibe dos parametros los " : " indican que son parametros
      builder: (context, state) {
        //*se capturan los parametros recibidos
        // declarando las variables parametro y metodo
        // es final porque no se van a modificar
        final parametro = state.pathParameters['parametro']!;
        final metodo = state.pathParameters['metodo']!;
        return DetalleScreen(parametro: parametro, metodoNavegacion: metodo);
      },
    ),
    GoRoute(
      path: '/ciclo_vida',
      builder: (context, state) => const CicloVidaScreen(),
    ),
    //!Ruta para http
    GoRoute(
      path: '/pokemons',
      name: 'pokemons',
      builder: (context, state) => const PokemonListView(),
    ),
    //!Ruta para detalle de pokemones
    GoRoute(
      path: '/pokemon/:name', // se recibe el nombre del pokemon como parametro
      name: 'pokemon_detail',
      builder: (context, state) {
        final name =
            state.pathParameters['name']!; // se captura el nombre del pokemon.
        return PokemonDetailView(name: name);
      },
    ),
    //!Ruta CRUD de establecimientos
    GoRoute(
      path: '/establecimientos',
      builder: (context, state) => const EstablecimientoListView(),
    ),
    GoRoute(
      path: '/establecimiento_nuevo',
      builder: (context, state) => const EstablecimientoFormView(),
    ),
    GoRoute(
      path: '/establecimiento_editar/:id',
      builder: (context, state) =>
          EstablecimientoFormView(id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/establecimiento/:id',
      builder: (context, state) =>
          EstablecimientoDetailView(id: int.parse(state.pathParameters['id']!)),
    ),
  ],
);
