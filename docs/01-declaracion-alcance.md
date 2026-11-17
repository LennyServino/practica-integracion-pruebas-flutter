# 01 — Declaración de alcance

**Proyecto:** Panel de Hábitos del Día (`practica-integracion-pruebas-flutter`)
**Rama de trabajo:** `semana16-integracion`
**Plataforma probada:** Android

## Estado mínimo del proyecto

| Requisito | Cumple | Evidencia |
|---|:---:|---|
| Compila y ejecuta (`flutter run`) | ☑ | `flutter run --dart-define-from-file=firebase.env.json` (ver README) |
| Al menos 2 pantallas distintas | ☑ | `PanelHabitos` (lib/screens/panel_habitos.dart) y `FormularioHabito` (lib/screens/formulario_habito.dart) |
| Usa al menos 1 servicio de Firebase | ☑ | Cloud Firestore, colección `habitos` |
| Repositorio con control de versiones | ☑ | Git + GitHub, rama `semana16-integracion` |

## Módulos y servicios

| Módulo / servicio | ¿Aplica? | Observación |
|---|:---:|---|
| Autenticación | ☐ No | La app es personal y de un solo usuario; no hay inicio de sesión. Los casos CP-02, CP-03, CP-11 y CP-18 se marcan como **No aplica**. |
| Base de datos (Firestore / Realtime DB) | ☑ Sí | **Cloud Firestore**, colección `habitos`. Campos: `nombre` (string), `cumplido` (bool), `nota_dia` (string), `fecha_creacion` (string ISO‑8601). Lectura en tiempo real con `snapshots()`; alta, actualización (marcar, nota, reiniciar) y eliminación. |
| Almacenamiento (Storage) | ☐ No | La app no maneja archivos ni imágenes. CP-13 **No aplica**. |
| Notificaciones push (FCM) | ☐ No | Fuera del alcance del proyecto. CP-14 a CP-17 **No aplican**. |
| API REST externa | ☐ No | No consume servicios externos aparte de Firebase. |
| Otros (Analytics, Crashlytics, Remote Config…) | ☐ No | No integrados. |

## Herramientas utilizadas

- Flutter 3.47.0 (stable) / Dart 3.x, VS Code
- `firebase_core` ^3.6.0, `cloud_firestore` ^5.4.3
- Pruebas: `flutter_test`, `integration_test`, `fake_cloud_firestore` ^3.1.0 (Firestore en memoria para probar el repositorio real)
- `flutter analyze` con `flutter_lints` ^6.0.0

## Conteo inicial de `flutter analyze` (Fase 1)

Sobre el commit «ajustando slider de meta…» (estado inicial) (antes de las correcciones): **0 errores, 0 warnings, 6 infos**
(`curly_braces_in_flow_control_structures` en `lib/main.dart`).
Salida completa: [evidencias/pruebas-y-analisis/flutter-analyze-inicial.txt](evidencias/pruebas-y-analisis/flutter-analyze-inicial.txt)

Estado final: **No issues found!** → [flutter-analyze-final.txt](evidencias/pruebas-y-analisis/flutter-analyze-final.txt)
