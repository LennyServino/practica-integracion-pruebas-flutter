# 03 — Plantilla de casos de prueba

**Leyenda de estado:** ✅ Aprobado · ❌ Fallido · ⏳ Pendiente de ejecutar en dispositivo · ➖ No aplica

**Tipo:** **A** = automatizado (`flutter test`) · **M** = manual en emulador/dispositivo con Firebase real

> Los casos **A** usan `FakeHabitosRepository` (pruebas de widget) o `fake_cloud_firestore` (prueba del repositorio real), por lo que son repetibles y no dependen de la red.
> Los casos **M** necesitan ejecutarse en el emulador con el proyecto de Firebase real: se debe llenar *Resultado obtenido* con lo observado y adjuntar la captura en `docs/evidencias/`.

## Resumen

| Total definidos | Ejecutados (automatizados) | Aprobados | Pendientes (solo manuales) | No aplica |
|:---:|:---:|:---:|:---:|:---:|
| 27 | 16 | 16 | 2 (CP-01, CP-19) + 3 verificaciones extra en dispositivo (CP-07 consola, CP-20, CP-26) | 9 |

Salida completa de `flutter test` (42 pruebas, todas en verde): [flutter-test-final.txt](evidencias/pruebas-y-analisis/flutter-test-final.txt)

## Casos

| ID | Flujo | Módulo | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Tipo | Estado | Evidencia |
|---|---|---|---|---|---|---|:---:|:---:|---|
| CP-01 | FC-2 | Arranque | La app inicia sin errores | `flutter run --dart-define-from-file=firebase.env.json` | Se muestra "Mis Hábitos" sin excepción en consola | _(llenar tras ejecutar)_ | M | ⏳ | `capturas-aplicacion/CP-01.png` |
| CP-02 | — | Autenticación | Inicio de sesión válido | — | — | — | — | ➖ | La app no usa Auth (ver alcance) |
| CP-03 | — | Autenticación | Inicio de sesión inválido | — | — | — | — | ➖ | La app no usa Auth |
| CP-04 | FC-1 | Validación | Formulario vacío | Pulsar "Guardar Hábito" sin escribir | Mensaje "Escribe el nombre del hábito"; no se llama al servicio | Se muestra el mensaje; `repo.llamadas` vacío; sigue en "Nuevo Hábito" | A | ✅ | `formulario_habito_test.dart` › CP-04 |
| CP-05 | FC-1 | Navegación | Acceder a cada pantalla | Tocar (+) | Se abre "Nuevo Hábito" | Se abre "Nuevo Hábito" | A | ✅ | `panel_habitos_test.dart` › CP-05/CP-06 |
| CP-06 | FC-1 | Navegación | Botón "atrás" | Atrás desde "Nuevo Hábito" | Regresa a "Mis Hábitos" sin cierre | Regresa a "Mis Hábitos" | A | ✅ | `panel_habitos_test.dart` › CP-05/CP-06 |
| CP-07 | FC-1 | Datos | Crear hábito | Nombre "Leer" | Aparece en la UI y en Firestore con `cumplido=false` y `fecha_creacion` | UI: "Leer" visible al regresar. Repositorio: documento con `nombre`, `cumplido=false`, `nota_dia`, `fecha_creacion` ISO | A (+M consola) | ✅ (A) · ⏳ captura consola | `formulario_habito_test.dart` › CP-07; `firestore_habitos_repository_test.dart` › agregarHabito; `firebase/CP-07-consola.png` |
| CP-08 | FC-2 | Datos | Leer lista | 3 hábitos con IDs en orden opuesto a la fecha + 1 sin fecha | Lista ordenada por `fecha_creacion`, sin fecha al final, completa | Antes: `[Tercero, Primero, Segundo, …]` ❌ (INC-004). Después: `[Primero, Segundo, Tercero, Sin fecha]` | A | ✅ | `INC-004-antes.txt` / `INC-004-despues.txt` |
| CP-09 | FC-3 | Datos | Actualizar (marcar hábito) | Tocar checkbox de "Leer" (1 de 1) | Se refleja en UI (100 %, "¡Día completado!") y en Firestore (`cumplido=true`) | UI muestra 100 % y "¡Día completado!"; documento con `cumplido=true` | A | ✅ | `panel_habitos_test.dart` › CP-09; `firestore_habitos_repository_test.dart` › alternarHabito |
| CP-10 | FC-5 | Datos | Eliminar hábito | Tocar 🗑 en "Leer" | Desaparece de UI y Firestore | "Leer" ya no aparece; colección vacía | A | ✅ | `panel_habitos_test.dart` › CP-10; repo › eliminarHabito |
| CP-11 | — | Seguridad | Acceso a datos ajenos | — | — | — | — | ➖ | Sin Auth no hay "otro usuario" |
| CP-12 | FC-2 | Estados | Lista vacía / error de red | (a) colección vacía (b) stream con error | (a) "Presiona + para añadir hábitos." (b) "Error al cargar", sin cierre | (a) mensaje de vacío, 0 %, "Sin nota" (b) "Error al cargar" | A | ✅ | `panel_habitos_test.dart` › CP-12 (×2) |
| CP-13 | — | Almacenamiento | Subir archivo | — | — | — | — | ➖ | No usa Storage |
| CP-14 | — | FCM | Token | — | — | — | — | ➖ | No usa FCM |
| CP-15 | — | FCM | Notificación primer plano | — | — | — | — | ➖ | No usa FCM |
| CP-16 | — | FCM | Notificación segundo plano | — | — | — | — | ➖ | No usa FCM |
| CP-17 | — | FCM | Notificación app cerrada | — | — | — | — | ➖ | No usa FCM |
| CP-18 | — | Sesión | Cerrar sesión | — | — | — | — | ➖ | No usa Auth |
| CP-19 | FC-2 | Persistencia | Reabrir app | Marcar 1 hábito, guardar nota, cerrar y abrir la app | Hábitos, marcas y nota se mantienen (vienen de Firestore) | _(llenar tras ejecutar)_ | M | ⏳ | `capturas-aplicacion/CP-19-antes.png`, `CP-19-despues.png` |
| CP-20 | FC-1..5 | Flujo completo | Recorrido de extremo a extremo | Agregar "Leer" y "Correr" → marcar → nota "Buen día" → reiniciar → eliminar "Correr" | Todos los pasos aprobados | Lógica verificada en la VM de pruebas (1/1 en verde). En dispositivo: _(llenar)_ | A (integration_test) | ✅ VM · ⏳ dispositivo | `integration_test/flujo_principal_test.dart` |
| CP-21 | FC-1 | Validación (negativo) | Nombre con solo espacios | `"   "` | Mensaje de validación; no crea hábito | Antes: se llamaba a `agregarHabito` ❌ (INC-002). Después: mensaje y `llamadas` vacío | A | ✅ | `INC-002-antes.txt` / `INC-002-despues.txt` |
| CP-22 | FC-4 | Datos | Guardar nota del día | Con 1 hábito, nota "Gran día" | Tarjeta muestra la nota y SnackBar "Nota guardada en Firebase"; `nota_dia` en todos los docs | Tarjeta "Gran día" + SnackBar; repo: `nota_dia` igual en todos los documentos | A | ✅ | `panel_habitos_test.dart` › Guardar nota; repo › guardarNota |
| CP-23 | FC-4 | Datos (negativo) | Guardar nota sin hábitos | Lista vacía, nota "Gran día" | Aviso "Agrega al menos un hábito…"; no se confirma guardado falso; no se pierde el texto | Antes: "Nota guardada en Firebase" sin guardar ❌ (INC-003). Después: aviso correcto, texto conservado | A | ✅ | `INC-003-antes.txt` / `INC-003-despues.txt` |
| CP-24 | FC-4 | Datos | Reiniciar día | 1 hábito cumplido + nota "Nota de ayer" | 0 %, "Sin nota"; Firestore `cumplido=false`, `nota_dia=''` | Antes: `nota_dia` seguía en `'Nota de ayer'` ❌ (INC-005). Después: 0 % y "Sin nota" | A | ✅ | `INC-005-antes.txt` / `INC-005-despues.txt` |
| CP-25 | FC-3 | Errores (negativo) | Firestore rechaza una escritura | Repositorio que lanza `permission-denied` | SnackBar de error; la app sigue funcionando | Antes: excepción no controlada ❌ (INC-006). Después: SnackBar "No se pudo guardar el cambio…" | A | ✅ | `INC-006-antes.txt` / `INC-006-despues.txt` |
| CP-26 | FC-1 | Estados (negativo) | Agregar hábito sin conexión | Modo avión; nombre "Leer" | Regresa al panel y el hábito aparece (caché local); se sincroniza al reconectar | Simulado (A): antes se quedaba en "Nuevo Hábito" ❌ (INC-006); después regresa y muestra "Leer". En dispositivo: _(llenar)_ | A + M | ✅ (A) · ⏳ (M) | `INC-006-*.txt`; `capturas-aplicacion/CP-26-modo-avion.png` |
| CP-27 | FC-2 | UI | Modo enfoque | 1 cumplido + 1 pendiente, activar switch | Se oculta el cumplido | Solo se ve "Correr" | A | ✅ | `panel_habitos_test.dart` › Modo enfoque |

## Cobertura frente a lo exigido

- **≥ 10 casos ejecutados:** 16 automatizados ejecutados y aprobados (CP-04 a CP-10, CP-12, CP-20 en VM, CP-21 a CP-27).
- **≥ 1 caso por flujo crítico:** FC-1 (CP-04, 05, 06, 07, 21, 26), FC-2 (CP-08, 12, 27), FC-3 (CP-09, 25), FC-4 (CP-22, 23, 24), FC-5 (CP-10).
- **≥ 1 caso negativo:** CP-04, CP-12, CP-21, CP-23, CP-25, CP-26.
- **Pruebas unitarias:** `test/unit/` (lógica, modelo, repositorio con Firestore en memoria).
- **Pruebas de widget con fake:** `test/widget/` usando `test/fakes/fake_habitos_repository.dart`.
