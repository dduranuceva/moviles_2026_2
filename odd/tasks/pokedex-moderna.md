# Feature: Pokédex Moderna — Lista + Detalle

## Objective
Mejorar el módulo pokemon (lista + detalle) a una Pokédex moderna tipo app oficial.

## Problem
Lista actual es ListView básica con Card genérica (imagen 80px + nombre), sin search, sin grid, sin colores por tipo. Detalle es Card centrada con imagen + nombre + chips grises. Modelo mínimo (id/name/image/types) sin stats/artwork. Service hace N+1 requests sin paginación ni caché. Theme M3 con AppBar verde inconsistente.

## Why
Pedido explícito del usuario: "mejorar la parte visual y que quede tipo pokedex moderno".

## Scope
In: lib/models/pokemon.dart, lib/services/pokemon_service.dart, lib/themes/app_theme.dart + type_colors.dart nuevo, lib/widgets/pokemon_card.dart + type_chip.dart + stats_bar.dart nuevos, lib/views/pokemons/pokemon_list_view.dart, lib/views/pokemons/pokemon_detail_view.dart.
Out: resto de la app (home, ciclo_vida, paso_parametros, drawer, router salvo retoque mínimo si hace falta).

## Constraints
- Flutter 3.47.4 / Dart 3.13.3, Material 3.
- CardTheme es CardThemeData en esta versión.
- .env con POKE_API_URL ya cableado vía flutter_dotenv; no romper.
- Cambio autorizado explícito; push/PR/merge quedan en manos del usuario (ordinary repo policy).
- Commits pausados por veto previo del usuario (sesión 2026-10-14): NO hacer git add/commit/push hasta re-autorización. Dejar cambios uncommitted.
- TDD: modo unknown/off (sin runner resuelto, solo flutter_test presente). Checks ordinarios, no RED-GREEN-REFACOR inventado.

## Tasks
- [ ] T1 — Modelo extendido: artwork oficial, stats, height/weight, fromJson robusto.
- [ ] T2 — Service: paginación (limit/offset), caché en memoria por nombre, mismo API.
- [ ] T3 — Theme: type_colors.dart paleta por tipo + ajuste AppBar/cards M3 coherente.
- [ ] T4 — Widgets: pokemon_card.dart, type_chip.dart, stats_bar.dart.
- [ ] T5 — Lista: grid 2 col, search local, Hero artwork, pull-to-refresh, scroll infinito o "cargar más".
- [ ] T6 — Detalle: header dinámico con color del tipo primario, Hero, stats con barras, height/weight.
- [ ] T7 — Verificación: flutter analyze limpio + readback estructural.

## Authorized scope
Mejora visual lista+detalle pokemon descrita arriba. Cambios de negocio/alcance nuevo requieren autorización.

## Acceptance criteria
- Lista en grid con cards de color por tipo, search filtra por nombre, tap navega con Hero.
- Detalle muestra artwork grande, tipos con color, stats con barra, altura/peso.
- `flutter analyze` sin errores nuevos.
- Sin cambios fuera del scope.

## Checks aplicables
- `flutter analyze` (obligatorio).
- Smoke run opcional si el runner lo permite (no bloquea).

## Route
delegated direct — un writer único (trigger: 2+ files no-triviales; mapping: 4+ files). Sin artefactos SDD.

## Delivery
Estrategia: ask-on-risk (default). Forecast: ~500 líneas autoradas (adds+deletes, excl. generados) → supera heurística 400/tarea, se trocea por tareas T1-T6 con 1 commit por unidad cuando el usuario re-autorice git. Review nativa solo si RDD enabled; si no, checks ordinarios.

## Progress
7/7 tareas implementadas (T1-T6 code + T7 verify). Commits pendientes por veto git vigente — cambios uncommitted en dev. Next: smoke run en emulador + autorización para work-unit commits.

## Verification evidence
- flutter analyze (parent spot check 2026-10-15): 1 issue preexistente `assets/` en pubspec.yaml:65, cero errores en código nuevo.
- Readback: pokemon_list_view.dart grid 2 col + search + paginación; type_colors.dart paleta 18 tipos + helpers.
