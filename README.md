# Panel de Hábitos del Día — Integración y pruebas con Firebase 📝

Aplicación Flutter para registrar los hábitos diarios. El usuario agrega hábitos, los marca como cumplidos, ve su progreso (barra, mensaje motivacional y meta diaria), activa un "modo enfoque" que oculta los completados, guarda una nota del día y reinicia la jornada. Todos los datos se guardan en **Cloud Firestore** y se sincronizan en tiempo real.

Este repositorio corresponde a la práctica **E4_A1 — Integración y pruebas funcionales del proyecto** (rama `semana16-integracion`).

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
| 7 | Evidencias Firebase | [docs/evidencias/firebase/](docs/evidencias/firebase/) |
| 8 | Pruebas automatizadas | [flutter-test-final.txt](docs/evidencias/pruebas-y-analisis/flutter-test-final.txt) |
| 9 | Análisis estático | [flutter-analyze-final.txt](docs/evidencias/pruebas-y-analisis/flutter-analyze-final.txt) |
| 10 | Historial de Git | `git log --oneline --grep "INC-"` |
| 11 | Reflexión final | [docs/05-reflexion-final.md](docs/05-reflexion-final.md) |

---
**Desarrollado por:** Lenny Alexander Servino Henriquez
**Tecnología:** Flutter 3.47 / Dart · Cloud Firestore
