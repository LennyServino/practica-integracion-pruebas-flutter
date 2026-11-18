# Panel de Hábitos del Día — Integración y pruebas con Firebase 📝

Aplicación Flutter para registrar los hábitos diarios. El usuario agrega hábitos, los marca como cumplidos, ve su progreso (barra, mensaje motivacional y meta diaria), activa un "modo enfoque" que oculta los completados, guarda una nota del día y reinicia la jornada. Todos los datos se guardan en **Cloud Firestore** y se sincronizan en tiempo real.

Este repositorio corresponde a la práctica **E4_A1 — Integración y pruebas funcionales del proyecto** (rama `semana16-integracion`).

## 🧭 Índice: dónde encontrar documentos, evidencias y capturas

### 📄 Documentos de la práctica (`docs/`)

| Documento | Contenido |
|---|---|
| [01-declaracion-alcance.md](docs/01-declaracion-alcance.md) | Alcance del proyecto y funcionalidades incluidas / excluidas |
| [02-mapa-flujos-criticos.md](docs/02-mapa-flujos-criticos.md) | Flujos críticos de la aplicación |
| [03-plantilla-pruebas.md](docs/03-plantilla-pruebas.md) | Casos de prueba (CP-01 … CP-27) con resultados |
| [04-registro-incidencias.md](docs/04-registro-incidencias.md) | Incidencias detectadas y su corrección |
| [05-reflexion-final.md](docs/05-reflexion-final.md) | Reflexión final de la práctica |

### 📸 Capturas de la aplicación ([docs/evidencias/capturas-aplicacion/](docs/evidencias/capturas-aplicacion/))

**Semana 16 — integración** ([semana16-integracion/](docs/evidencias/capturas-aplicacion/semana16-integracion/)):

| Caso | Evidencia |
|---|---|
| CP-01 — Arranque sin errores | [CP-01.png](docs/evidencias/capturas-aplicacion/semana16-integracion/CP-01.png) |
| CP-04 / CP-21 — Validación del formulario | [CP-04 - CP-21.png](docs/evidencias/capturas-aplicacion/semana16-integracion/CP-04%20-%20CP-21.png) |
| CP-07 — Agregar hábito | [CP-07.png](docs/evidencias/capturas-aplicacion/semana16-integracion/CP-07.png) |
| CP-09 — Marcar cumplido y progreso | [CP-09.png](docs/evidencias/capturas-aplicacion/semana16-integracion/CP-09.png) |
| CP-19 — Persistencia al reabrir la app | [CP-19(1).png](docs/evidencias/capturas-aplicacion/semana16-integracion/CP-19%281%29.png) |
| CP-20 — Flujo principal completo (video) | [CP-20.mp4](docs/evidencias/capturas-aplicacion/semana16-integracion/CP-20.mp4) |
| CP-23 — Nota sin hábitos | [CP-23.png](docs/evidencias/capturas-aplicacion/semana16-integracion/CP-23.png) |
| CP-26 — Modo avión | [CP-26.png](docs/evidencias/capturas-aplicacion/semana16-integracion/CP-26.png) |

**Laboratorio 1** ([lab1/](docs/evidencias/capturas-aplicacion/lab1/)): [P-1](docs/evidencias/capturas-aplicacion/lab1/P-1.png) · [P-2](docs/evidencias/capturas-aplicacion/lab1/P-2.png) · [P-6](docs/evidencias/capturas-aplicacion/lab1/P-6.png) · [P-8](docs/evidencias/capturas-aplicacion/lab1/P-8.png) · [P-10](docs/evidencias/capturas-aplicacion/lab1/P-10.png) · [P-12](docs/evidencias/capturas-aplicacion/lab1/P-12.png)

### 🔥 Capturas de Firebase Console ([docs/evidencias/firebase-capturas/](docs/evidencias/firebase-capturas/))

| Caso | Evidencia |
|---|---|
| CP-07 — Documento creado en `habitos` | [CP-07.png](docs/evidencias/firebase-capturas/CP-07.png) |
| CP-09 — `cumplido: true` | [CP-09.png](docs/evidencias/firebase-capturas/CP-09.png) |
| CP-10 — Documento eliminado | [CP-10.png](docs/evidencias/firebase-capturas/CP-10.png) |
| CP-22 — `nota_dia` guardada | [CP-22.png](docs/evidencias/firebase-capturas/CP-22.png) |
| CP-24 — Reinicio del día | [CP-24.png](docs/evidencias/firebase-capturas/CP-24.png) |
| INC-006 — Reglas de Firestore | [INC-006.png](docs/evidencias/firebase-capturas/INC-006.png) |

### 🧪 Salidas de pruebas y análisis ([docs/evidencias/pruebas-y-analisis/](docs/evidencias/pruebas-y-analisis/))

| Evidencia | Inicial | Final |
|---|---|---|
| `flutter test` | [flutter-test-inicial.txt](docs/evidencias/pruebas-y-analisis/flutter-test-inicial.txt) | [flutter-test-final.txt](docs/evidencias/pruebas-y-analisis/flutter-test-final.txt) |
| `flutter analyze` | [flutter-analyze-inicial.txt](docs/evidencias/pruebas-y-analisis/flutter-analyze-inicial.txt) | [flutter-analyze-final.txt](docs/evidencias/pruebas-y-analisis/flutter-analyze-final.txt) |

| Incidencia | Antes | Después |
|---|---|---|
| INC-002 | [antes](docs/evidencias/pruebas-y-analisis/INC-002-antes.txt) | [después](docs/evidencias/pruebas-y-analisis/INC-002-despues.txt) |
| INC-003 | [antes](docs/evidencias/pruebas-y-analisis/INC-003-antes.txt) | [después](docs/evidencias/pruebas-y-analisis/INC-003-despues.txt) |
| INC-004 | [antes](docs/evidencias/pruebas-y-analisis/INC-004-antes.txt) | [después](docs/evidencias/pruebas-y-analisis/INC-004-despues.txt) |
| INC-005 | [antes](docs/evidencias/pruebas-y-analisis/INC-005-antes.txt) | [después](docs/evidencias/pruebas-y-analisis/INC-005-despues.txt) |
| INC-006 | [antes](docs/evidencias/pruebas-y-analisis/INC-006-antes.txt) | [después](docs/evidencias/pruebas-y-analisis/INC-006-despues.txt) |

### 🔔 Notificaciones FCM

No aplica: el proyecto no integra Firebase Cloud Messaging. Justificación en [docs/evidencias/notificaciones-fcm/README.md](docs/evidencias/notificaciones-fcm/README.md).

### 🧩 Código de pruebas

| Tipo | Ubicación |
|---|---|
| Unitarias | [test/unit/](test/unit/) |
| Widget | [test/widget/](test/widget/) |
| Integración (CP-20) | [integration_test/flujo_principal_test.dart](integration_test/flujo_principal_test.dart) |

## 📱 Pantallas

| Pantalla | Archivo | Función |
|---|---|---|
| Panel principal | [lib/screens/panel_habitos.dart](lib/screens/panel_habitos.dart) | Lista en tiempo real, progreso, meta, modo enfoque, nota del día, reiniciar día y eliminar |
| Formulario | [lib/screens/formulario_habito.dart](lib/screens/formulario_habito.dart) | Alta de un hábito con validación |

## 🗂️ Estructura

```
lib/
├── main.dart                          # Arranque e inyección del repositorio
├── firebase_options.dart              # Opciones de Firebase leídas con --dart-define (sin claves en el código)
├── data/
│   ├── habitos_repository.dart        # Contrato (abstracción)
│   └── firestore_habitos_repository.dart  # Implementación con Cloud Firestore
├── logic/habitos_logic.dart           # Lógica pura: progreso, mensajes, validación, orden
├── models/                            # Habito, EstadoDia
└── screens/                           # PanelHabitos, FormularioHabito
test/
├── unit/                              # Lógica, modelo y repositorio (fake_cloud_firestore)
├── widget/                            # Pantallas con FakeHabitosRepository
└── fakes/fake_habitos_repository.dart
integration_test/flujo_principal_test.dart   # Flujo completo (CP-20)
docs/                                  # Atestados de la práctica (alcance, flujos, pruebas, incidencias, reflexión, evidencias)
```

## ▶️ Cómo ejecutarlo

**Requisitos:** Flutter 3.47 o superior, un emulador o dispositivo Android, y un proyecto de Firebase con Cloud Firestore habilitado.

1. Instalar dependencias:
   ```bash
   flutter pub get
   ```
2. Configurar Firebase **sin versionar credenciales**: copiar la plantilla y llenarla con los datos de la app Android del proyecto de Firebase (*Configuración del proyecto → Tus apps*):
   ```bash
   cp firebase.env.example.json firebase.env.json
   ```
   `firebase.env.json` está en `.gitignore`.
3. Ejecutar:
   ```bash
   flutter run --dart-define-from-file=firebase.env.json
   ```
   En VS Code basta con **F5**: la configuración "practica-integracion-pruebas-flutter (Firebase)" de `.vscode/launch.json` ya incluye ese parámetro.
   Si se ejecuta sin la configuración, la app muestra una pantalla con estas mismas instrucciones.

### Firestore

Colección `habitos`, un documento por hábito:

| Campo | Tipo | Descripción |
|---|---|---|
| `nombre` | string | Nombre del hábito (1–40 caracteres) |
| `cumplido` | bool | Si se completó hoy |
| `nota_dia` | string | Nota del día (se replica en cada documento) |
| `fecha_creacion` | string ISO‑8601 | Se usa para ordenar la lista |

## 🧪 Pruebas y análisis

```bash
flutter analyze                 # → No issues found!
flutter test                    # → 42 pruebas (unitarias + widget) en verde
flutter test integration_test   # → flujo completo; requiere emulador/dispositivo
```

- **Unitarias** (`test/unit/`): `calcularProgreso`, `mensajeMotivacional`, `validarNombreHabito`, `ordenarPorFecha`, mapeo `Habito.fromMap/toMap`, y el repositorio **real** de Firestore probado contra `fake_cloud_firestore`.
- **Widget** (`test/widget/`): estado vacío, con datos, error de lectura, navegación ida y vuelta, validación del formulario, nota, reinicio y errores de escritura, todo con `FakeHabitosRepository`.
- **Integración** (`integration_test/`): agregar → marcar → nota → reiniciar → eliminar.

Las salidas de `flutter test` y `flutter analyze` (inicial y final) y las ejecuciones antes/después de cada corrección están en [docs/evidencias/pruebas-y-analisis/](docs/evidencias/pruebas-y-analisis/).

## 📑 Atestados de la práctica

| # | Atestado | Ubicación |
|---|---|---|
| 1 | Código fuente | `lib/` |
| 2 | Declaración de alcance | [docs/01-declaracion-alcance.md](docs/01-declaracion-alcance.md) |
| 3 | Mapa de flujos críticos | [docs/02-mapa-flujos-criticos.md](docs/02-mapa-flujos-criticos.md) |
| 4 | Plantilla de pruebas | [docs/03-plantilla-pruebas.md](docs/03-plantilla-pruebas.md) |
| 5 | Registro de incidencias (8) | [docs/04-registro-incidencias.md](docs/04-registro-incidencias.md) |
| 6 | Evidencias visuales | [docs/evidencias/capturas-aplicacion/](docs/evidencias/capturas-aplicacion/) |
| 7 | Evidencias Firebase | [docs/evidencias/firebase-capturas/](docs/evidencias/firebase-capturas/) |
| 8 | Pruebas automatizadas | [flutter-test-final.txt](docs/evidencias/pruebas-y-analisis/flutter-test-final.txt) |
| 9 | Análisis estático | [flutter-analyze-final.txt](docs/evidencias/pruebas-y-analisis/flutter-analyze-final.txt) |
| 10 | Reflexión final | [docs/05-reflexion-final.md](docs/05-reflexion-final.md) |

---
**Desarrollado por:** Lenny Alexander Servino Henriquez
**Tecnología:** Flutter 3.47 / Dart · Cloud Firestore
