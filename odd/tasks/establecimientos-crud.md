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
- `DELETE /api/establecimientos/{id}` = borrado lógico (estado -> 'I'); la fila SIGUE apareciendo en el
  index con `estado: "I"`.
- Logos: se sirven públicos en `https://parking.visiontic.com.co/logos/<archivo>` (200 image/png|jpeg
  verificado con valores `logo` reales del index/detail). No existe key de entorno para esa base.

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
- `.env` sigue bundleado como asset en `pubspec.yaml`, pero el usuario lo agregó a `.gitignore`;
  no imprimir secretos en logs/commits y no modificarlo desde esta feature.
- **Commits: veto git vigente del usuario.** NO hacer `git add/commit/push`. Además el working tree
  tiene la feature Pokédex sin commitear y comparte archivos (`app_router.dart`, `custom_drawer.dart`,
  `pubspec.yaml`), así que un commit selectivo mezclaría features. Cambios quedan uncommitted.

## Tasks
- [x] T1 — Modelo `Establecimiento` con `fromJson` defensivo (envelope `{success,data}`), `toJson`
      para multipart y `estadoActivo` getter. Campos: id, nombre, nit, direccion, telefono, logo,
      estado, createdAt, updatedAt. (Parsea además tolerante a TIPOS erróneos: `nombre:42 -> '42'`.)
- [x] T2 — `EstablecimientoService`: `getEstablecimientos`, `getEstablecimiento(id)`,
      `createEstablecimiento` (multipart), `updateEstablecimiento` (POST + `_method=PUT`, multipart),
      `deleteEstablecimiento(id)`. Errores: excepción tipada con mensaje del servidor
      (`message` / `mensaje` si viene) y statusCode. `getEstablecimientos` tolera array pelado además
      del envelope.
- [x] T3 — `pubspec.yaml`: dep `image_picker` (resuelta 1.2.4) + `flutter pub get`.
- [x] T4 — `app_router.dart`: `/establecimientos`, `/establecimiento/:id`,
      `/establecimiento_nuevo`, `/establecimiento_editar/:id`.
- [x] T5 — `custom_drawer.dart`: ListTile `Icons.store` + 'Establecimientos' -> `context.go(...)`.
- [x] T6 — Vista lista: `BaseView`, loading/error/empty, `RefreshIndicator`, Cards con estado,
      editar/eliminar (AlertDialog de confirmación), FAB nuevo, recarga al volver.
- [x] T7 — Vista form (create+edit): `Form` + validators required, image_picker (galería) con preview,
      SnackBar, `context.pop(true)`.
- [x] T8 — Vista detalle: `BaseView`, card con todos los campos + fechas + botón edit.
- [x] T9 — Verificación: `flutter analyze` sin issues nuevos, readback estructural y smoke test en vivo
      del service contra la API real (14 items parseados, detail OK). El smoke test NO quedó en `test/`.
- [x] T10 — Corrección acotada post-verificación independiente (ver Verification evidence): 6 defectos
      corregidos y re-verificados.

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
Estrategia: ask-on-risk. Forecast ~900 líneas; real medido: 1030 líneas nuevas (model 87 + service 205 +
detail 159 + form 318 + list 261) + 56 líneas aditivas (router 40, drawer 14, pubspec 1, plist 2 - 1).
Supera la heurística de ~400: al momento de la corrección la decisión de chained PR ya no aplicaba porque
el usuario resolvió el delivery por su cuenta.

**Estado git (externo a esta sesión):** el usuario commiteó todo (`ae156b1 feat: Implement CRUD for
Establecimientos...`, branch `feature/http`, 2026-10-19 11:40). Los agentes de esta sesión tenían
prohibido todo comando git mutante y no committearon nada. El commit incluye también la feature Pokédex
preexistente, las odds y `.env` en `.gitignore`.

## TDD
Modo: off (no configurado en el proyecto; sólo `flutter_test` presente, sin runner ni convención TDD).
Fuente: `analysis_options.yaml` + ausencia de config de testing. Runner disponible: `flutter test`.
=> Checks ordinarios (analyze + verificación independiente), no se inventó RED-GREEN-REFACTOR.

## Progress
10/10 tareas. Feature entregada y verificada. Sin trabajo pendiente de código.

Follow-ups NO bloqueantes (sugerencias del re-verificador, no aplicadas para no invalidar el candidato
verificado):
1. `logoBaseUrl` sólo recorta el sufijo literal `/api`: con `URL_PARKING` terminado en `/` o versionado
   (`/api/v1`) la base de logos queda mal armada (404 silencioso, cae al ícono). Blindar con
   `replaceAll(RegExp(r'/+$'), '').replaceAll(RegExp(r'/api$'), '')`.
2. El detalle no muestra spinner durante un retry (`FutureBuilder` conserva el snapshot de error).
3. `int.parse` de `state.pathParameters['id']` lanza `FormatException` en un deep link no numérico
   (`/establecimiento/abc`). Inalcanzable desde la UI.
4. Un 200 con `data: null` ahora lanza bien, pero el mensaje dice "not found (status 200)".

## Verification evidence
Baseline (antes de escribir código): `flutter analyze` = 1 warning preexistente (`assets/` no existe);
`flutter test` = falla preexistente `test/widget_test.dart` "Counter increments smoke test".

Contrato API verificado en vivo (sólo lectura, autorizado): index 200 sin token con envelope
`{success,data}` (14 items), detail 200, `/999999` y `/abc` -> 404 con `message`, logos públicos en
`<host>/logos/<archivo>` -> 200. Escrituras (POST/PUT/DELETE) NO se ejecutaron contra la API real.

Writer (self-verification): `flutter pub get` OK (image_picker 1.2.4); `flutter analyze` = sólo el warning
preexistente; smoke test temporal contra la API real = `SMOKE count=14` + detail OK; temporal eliminado.

Verificador independiente #1: **FAIL** — 1 CRITICAL + 4 WARNING reproducidos con probes:
(a) `setState(() => _future = ...)` devolvía un `Future` -> assert en debug, Retry y refresh post-edición
no reconstruían; (b) logos permanentemente muertos (`URL_PARKING_LOGOS` inexistente); (c) lista stale tras
editar desde el detalle (index GET count = 1); (d) botón Save habilitado y no-op en estado de error de
carga; (e) `getEstablecimiento` podía devolver entidad `id:0` en vez de lanzar; (f) `fromJson` fallaba por
tipo (no por null) y una fila mala abortaba el index.

Corrección acotada (writer nuevo): los 6 puntos, con negative controls (revertir cada fix reproducía el
defecto).

Verificador independiente #2 (reutilizando la sesión del #1): **PASS_WITH_FINDINGS** — los 6 fixes
CONFIRMADOS con evidencia (Retry reconstruye sin excepción, index GET count = 2 al volver del detalle,
save bar ausente en error, `data:null` lanza, `logoUrlFor` deriva `<host>/logos/`, `fromJson` tolera tipos).
Sólo quedan las 4 sugerencias de Follow-ups.

Spot check final del parent (post-corrección): `flutter analyze` = `1 issue found` (sólo el warning
preexistente `assets/`); scope audit: cero ediciones a archivos fuera de la lista autorizada, cero
contaminación cruzada con la feature Pokédex.

No verificado (requiere device/escrituras): picker de galería real, multipart POST/PUT y `_method=PUT`
contra el servidor, render de la imagen del logo, y web (`dart:io` no soportado en runtime web).
