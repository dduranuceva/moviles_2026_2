# Feature: CRUD de Establecimientos (API Parqueadero)

## Objective
Implementar el CRUD completo de Establecimientos en la app Flutter, respetando la estructura existente
(routes, drawer, services, models, views) y el contrato real de la API de Parqueadero (`URL_PARKING`).

## Problem
La app hoy es un proyecto de clase con módulos aislados. No existe ninguna capa de dominio para el
parqueadero: no hay modelo ni service de Establecimientos, no hay rutas, y el drawer no tiene el item.
El swagger de la API no documenta el envelope de respuesta (sólo `200 Listado de establecimientos.` y
`default Ha ocurrido un error.`), por lo que el parseo no se podía escribir a ciegas.

## Why
Pedido explícito del usuario: "implementemos el crud de establecimientos siguiendo las instrucciones del
json de swagger", reutilizando rutas, drawer, services y views como el resto del proyecto.

## Contract evidence (verificado en vivo, solo lectura, autorizado por el usuario)
- `GET https://parking.visiontic.com.co/api/establecimientos` -> `200` SIN token.
  Envelope: `{"success": true, "data": [ {...}, ... ]}` (NO es un array pelado).
- `GET /api/establecimientos/1` -> `200` con `data` como objeto.
- `GET /api/establecimientos/999999` -> `404`.
- Item shape: `id:int, nombre:string, nit:string, direccion:string, telefono:string,
  logo:string (nombre de archivo, ej. "sin-imagen.png"), estado:"A"|"I",
  created_at:ISO, updated_at:ISO`.
- Los endpoints de Establecimientos NO declaran `security` en el swagger y no exigen JWT.
- `POST /api/establecimientos/{id}` con `_method=PUT` (multipart) para actualizar con logo.
- `DELETE /api/establecimientos/{id}` = borrado lógico (estado -> 'I').

## Scope
In:
- `lib/models/establecimiento.dart` (nuevo)
- `lib/services/establecimiento_service.dart` (nuevo)
- `lib/views/establecimientos/establecimiento_list_view.dart` (nuevo)
- `lib/views/establecimientos/establecimiento_detail_view.dart` (nuevo)
- `lib/views/establecimientos/establecimiento_form_view.dart` (nuevo)
- `lib/routes/app_router.dart` (4 GoRoutes nuevas)
- `lib/widgets/custom_drawer.dart` (1 ListTile nuevo)
- `pubspec.yaml` (dep `image_picker`, aprobada por el usuario)

Out: login/JWT y módulo Usuarios (el usuario pidió sólo Establecimientos); home, ciclo_vida,
paso_parametros, pokemons; `lib/mainold.dart`. No se toca `.env` (la key `URL_PARKING` ya existe).

## Constraints
- Flutter 3.47.x / Dart 3.13.3, Material 3, sin state management (setState + Future manual).
- Deps permitidas: go_router, http, flutter_dotenv + `image_picker` (aprobada). Nada más.
- Patrón del proyecto: service = clase plana instanciada por la vista; `dotenv.env['KEY']!`;
  `json.decode`; modelos con `factory fromJson` defensivo y campos mutables.
- Listado usa `BaseView` (inyecta AppBar + CustomDrawer); no duplicar AppBar/drawer.
- Comentarios en español (convención del repo), UI strings en inglés (convención de la ola
  más reciente: `views/pokemons/`). Identificadores en inglés.
- `.env` bundleado como asset y trackeado en git: no imprimir secretos en logs/commits.
- **Commits: veto git vigente del usuario.** NO hacer `git add/commit/push`. Además el working tree
  tiene la feature Pokédex sin commitear y comparte archivos (`app_router.dart`, `custom_drawer.dart`,
  `pubspec.yaml`), así que un commit selectivo mezclaría features. Cambios quedan uncommitted.

## Tasks
- [ ] T1 — Modelo `Establecimiento` con `fromJson` defensivo (envelope `{success,data}`), `toJson`
      para multipart y `estadoActivo` getter. Campos: id, nombre, nit, direccion, telefono, logo,
      estado, createdAt, updatedAt.
- [ ] T2 — `EstablecimientoService`: `getEstablecimientos`, `getEstablecimiento(id)`,
      `createEstablecimiento` (multipart), `updateEstablecimiento` (POST + `_method=PUT`, multipart),
      `deleteEstablecimiento(id)`. Errores: excepción tipada con mensaje del servidor
      (`message` / `mensaje` si viene) y statusCode. `getEstablecimientos` tolera array pelado además
      del envelope.
- [ ] T3 — `pubspec.yaml`: dep `image_picker` + `flutter pub get`.
- [ ] T4 — `app_router.dart`: `/establecimientos`, `/establecimiento/:id`,
      `/establecimiento_nuevo`, `/establecimiento_editar/:id`.
- [ ] T5 — `custom_drawer.dart`: ListTile `Icons.store` + 'Establecimientos' -> `context.go(...)`.
- [ ] T6 — Vista lista: `BaseView`, loading/error/empty, `RefreshIndicator`, Cards con estado,
      editar/eliminar (AlertDialog de confirmación), FAB nuevo, recarga tras volver del form.
- [ ] T7 — Vista form (create+edit): `Form` + validators required, image_picker (galería) con preview,
      SnackBar, `context.pop(true)`.
- [ ] T8 — Vista detalle: `BaseView`, card con todos los campos + fechas + botón edit.
- [ ] T9 — Verificación: `flutter analyze` sin issues nuevos, readback estructural y smoke test en vivo
      del service contra la API real (flujo index/show). El smoke test NO queda en `test/`.

## Authorized scope
CRUD de Establecimientos con la UI descrita. Login/JWT, usuarios, o cambios fuera de la lista de
archivos de Scope requieren autorización nueva.

## Acceptance criteria
- `flutter analyze` sin errores y sin warnings nuevos (el warning `assets/` es preexistente).
- Lista carga los establecimientos reales de la API, muestra estado A/I y permite editar/eliminar.
- Crear y editar (con y sin logo) funcionan contra la API real; 404/422 se muestran en SnackBar.
- Drawer tiene el item Establecimientos y navega a la lista.
- Ningún archivo fuera de Scope modificado.

## Checks aplicables
- `flutter pub get` (T3).
- `flutter analyze` (obligatorio).
- `flutter test` -> falla preexistente conocida: `test/widget_test.dart` "Counter increments smoke test"
  (scaffold viejo del counter). No es causada por esta feature y no se arregla acá.
- Smoke test en vivo del service (temporal, se ejecuta y se elimina).

## Route
delegated direct — un writer único (trigger writer: 2+ archivos no-triviales; trigger mapping: 4+
archivos, ya cubierto por la exploración previa). Sin artefactos SDD.

## Delivery
Estrategia: ask-on-risk (default). Forecast: ~900 líneas autoradas (adds+deletes, excl. generados) ->
supera la heurística de ~400: al re-autorizar git se trocea por unidades T1-T2 / T3-T5 / T6-T7-T8 con
1 commit por unidad. La decisión de chained PR queda pendiente porque hoy no hay commits.

## TDD
Modo: off (no configurado en el proyecto; sólo `flutter_test` presente, sin runner ni convención TDD).
Fuente: `analysis_options.yaml` + ausencia de config de testing. Runner disponible: `flutter test`.
=> Checks ordinarios (analyze + smoke funcional), no se inventa RED-GREEN-REFACTOR.

## Progress
0/9 tareas. Pendiente: implementación delegada.

## Verification evidence
(pendiente)
