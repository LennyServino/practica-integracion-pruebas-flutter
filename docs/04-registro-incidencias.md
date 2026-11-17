# 04 — Registro de incidencias

**Severidad:** Crítica (bloquea la entrega o el uso) · Alta (rompe un flujo crítico) · Media (resultado incorrecto con forma de evitarlo) · Baja (molestia o cosa estética)
**Prioridad:** P1 (inmediata) · P2 (antes de entregar) · P3 (si hay tiempo)
**Origen:** Código · Configuración · Repositorio · Pruebas · Diseño de datos

Método de depuración aplicado (material 12.2): **reproducir → leer → hipótesis → comprobar → corregir y proteger**.
Cada incidencia corregida tiene una **prueba de regresión** que falla con el código anterior y pasa con la corrección. La salida de ambas ejecuciones está en `docs/evidencias/pruebas-y-analisis/INC-00X-antes.txt` / `-despues.txt`.

## Resumen

| ID | Título | Severidad | Prioridad | Origen | Caso | Estado | Commit (`git log --grep`) |
|---|---|:---:|:---:|---|---|:---:|---|
| INC-001 | La app no se puede probar: `flutter test` falla con `[core/no-app]` | Alta | P1 | Código / Pruebas | Fase 4 | ✅ Corregida | `fix: INC-001 …` |
| INC-002 | Se aceptan nombres de hábito vacíos o hechos solo de espacios | Media | P2 | Código | CP-04, CP-21 | ✅ Corregida y re-probada | `fix: INC-002 …` |
| INC-003 | "Nota guardada en Firebase" aparece sin que se guarde nada (lista vacía) | Media | P2 | Código / Diseño de datos | CP-23 | ✅ Corregida y re-probada | `fix: INC-003 …` |
| INC-004 | La lista de hábitos sale en orden aleatorio (por ID) | Baja | P3 | Código | CP-08 | ✅ Corregida y re-probada | `fix: INC-004 …` |
| INC-005 | "Reiniciar día" no borra la nota en Firestore | Media | P2 | Código | CP-24 | ✅ Corregida y re-probada | `fix: INC-005 …` |
| INC-006 | Escrituras sin manejo de errores; formulario congelado sin conexión | Alta | P1 | Código | CP-25, CP-26 | ✅ Corregida y re-probada | `fix: INC-006 …` |
| INC-007 | `firebase.exe` (256 MB) versionado: GitHub rechaza el push | Crítica | P1 | Repositorio | Fase 1 | ⚠️ Parcial (ver detalle) | `fix: INC-007 …` |
| INC-008 | Credenciales de Firebase escritas en `lib/main.dart` | Alta | P1 | Configuración | CP-01 | ✅ Corregida (ver nota sobre historial) | `fix: INC-008 …` |

---

## INC-001 — La app no se puede probar de forma automatizada

- **Severidad / Prioridad / Origen:** Alta / P1 / Código + Pruebas
- **Reproducir:** `flutter test` en el commit «ajustando slider de meta…» (estado inicial).
- **Obtenido:** `FirebaseException: [core/no-app] No Firebase App '[DEFAULT]' has been created` en `new _PanelHabitosState (main.dart:44)`. Ver [flutter-test-inicial.txt](evidencias/pruebas-y-analisis/flutter-test-inicial.txt).
- **Esperado:** pruebas en verde.
- **Causa:** (1) `test/widget_test.dart` era la prueba del contador que trae la plantilla, ajena a la app. (2) Las pantallas creaban `FirebaseFirestore.instance` directamente en su `State`, así que era imposible montarlas sin Firebase real. Además, la lógica (progreso, mensajes) estaba dentro de `build()`.
- **Corrección:** se separaron `models/`, `logic/` (funciones puras), `data/HabitosRepository` (abstracción) con `FirestoreHabitosRepository`, y `screens/`. La pantalla recibe el repositorio por constructor, y las pruebas usan `FakeHabitosRepository` o `fake_cloud_firestore`. Con el cambio también desaparecieron los 6 avisos de `flutter analyze`.
- **Regresión:** `flutter test` → 42 pruebas en verde ([flutter-test-final.txt](evidencias/pruebas-y-analisis/flutter-test-final.txt)).

## INC-002 — Nombre de hábito vacío o hecho solo de espacios

- **Severidad / Prioridad / Origen:** Media / P2 / Código
- **Reproducir:** (+) → escribir `"   "` → "Guardar Hábito".
- **Obtenido:** se crea un hábito en blanco en Firestore. Con el campo vacío no se muestra ningún mensaje.
- **Esperado:** mensaje de validación y no llamar al servicio (CP-04).
- **Causa:** `if (_controller.text.isNotEmpty)` sin `trim()`, y un `TextField` sin `validator`.
- **Corrección:** `Form` + `TextFormField(validator: validarNombreHabito)`, una función pura que recorta los espacios, rechaza el texto vacío y limita a 40 caracteres. El nombre se guarda ya recortado.
- **Regresión:** [antes](evidencias/pruebas-y-analisis/INC-002-antes.txt): 3 pruebas fallan (`Actual: ['agregarHabito:  Meditar  ']`) → [después](evidencias/pruebas-y-analisis/INC-002-despues.txt): 14/14 en verde.

## INC-003 — Confirmación falsa al guardar la nota sin hábitos

- **Severidad / Prioridad / Origen:** Media / P2 / Código + Diseño de datos
- **Reproducir:** con la lista vacía, escribir una nota → "Guardar".
- **Obtenido:** SnackBar "Nota guardada en Firebase" y se borra el texto, pero no se guarda nada.
- **Esperado:** no confirmar algo que no ocurrió y no perder lo escrito.
- **Causa:** la nota se guarda como campo `nota_dia` dentro de cada documento de hábito. Con 0 documentos el ciclo no escribe nada, pero el SnackBar se mostraba siempre.
- **Corrección:** si no hay hábitos, se muestra "Agrega al menos un hábito para guardar la nota" y se conserva el texto. *(Mejora futura: guardar la nota en un documento propio, p. ej. `dias/{fecha}`.)*
- **Regresión:** [antes](evidencias/pruebas-y-analisis/INC-003-antes.txt): `Found 1 widget with text "Nota guardada en Firebase"` → [después](evidencias/pruebas-y-analisis/INC-003-despues.txt): en verde.

## INC-004 — Lista de hábitos sin orden

- **Severidad / Prioridad / Origen:** Baja / P3 / Código
- **Reproducir:** crear varios hábitos; su posición no corresponde al orden en que se crearon.
- **Obtenido:** `['Tercero', 'Primero', 'Segundo', 'Sin fecha (al final)']`.
- **Esperado:** orden por `fecha_creacion` (CP-08).
- **Causa:** `collection('habitos').snapshots()` sin orden. Firestore devuelve los documentos por ID, que es aleatorio.
- **Hipótesis descartada:** usar `orderBy('fecha_creacion')`. Se descartó porque `orderBy` **excluye** los documentos que no tienen el campo (p. ej. los creados a mano desde la consola).
- **Corrección:** `ordenarPorFecha()` en el cliente: ascendente, los que no tienen fecha al final y, si empatan, por nombre.
- **Regresión:** [antes](evidencias/pruebas-y-analisis/INC-004-antes.txt) → [después](evidencias/pruebas-y-analisis/INC-004-despues.txt).

## INC-005 — "Reiniciar día" no borra la nota

- **Severidad / Prioridad / Origen:** Media / P2 / Código
- **Reproducir:** guardar una nota → "Reiniciar día".
- **Obtenido:** los hábitos se desmarcan, pero la tarjeta sigue mostrando la nota anterior (`Actual: 'Nota de ayer'`).
- **Esperado:** volver al estado inicial: 0 % y "Sin nota".
- **Causa:** `_reiniciarDia` solo actualizaba `{cumplido: false}`. El `_notaCtrl.clear()` limpiaba el campo de texto, no Firestore.
- **Corrección:** el `batch.update` escribe `{cumplido: false, nota_dia: ''}`.
- **Regresión:** [antes](evidencias/pruebas-y-analisis/INC-005-antes.txt) → [después](evidencias/pruebas-y-analisis/INC-005-despues.txt).

## INC-006 — Escrituras sin manejo de errores y formulario congelado sin conexión

- **Severidad / Prioridad / Origen:** Alta / P1 / Código
- **Reproducir:** (a) Firestore rechaza una escritura (reglas vencidas, `permission-denied`) y se marca un hábito; (b) en modo avión, se agrega un hábito.
- **Obtenido:** (a) excepción asíncrona no controlada y el usuario no recibe aviso; (b) la pantalla se queda en "Nuevo Hábito".
- **Esperado:** un aviso claro sin que la app se cierre; sin conexión, regresar y ver el hábito (Firestore lo guarda en caché y lo sincroniza después).
- **Causa:** `update()`/`delete()` sin `catchError`. El formulario hacía `await add(...)`, y ese `Future` **no termina hasta que el servidor confirma**, así que sin red nunca llegaba al `Navigator.pop`.
- **Corrección:** el helper `_ejecutar()` muestra el SnackBar "No se pudo guardar el cambio en Firebase…" cuando falla. El formulario ya no espera la confirmación: regresa de inmediato y avisa si falla. También se evita el doble toque.
- **Regresión:** [antes](evidencias/pruebas-y-analisis/INC-006-antes.txt): 3 fallos → [después](evidencias/pruebas-y-analisis/INC-006-despues.txt): en verde. *Pendiente: confirmarlo en el emulador con modo avión (CP-26).*

## INC-007 — Binario `firebase.exe` de 256 MB dentro del repositorio

- **Severidad / Prioridad / Origen:** Crítica / P1 / Repositorio
- **Reproducir:** `git push` de la rama.
- **Obtenido / esperado:** GitHub rechaza archivos de más de 100 MB, así que el push falla y la entrega no es posible.
- **Causa:** el ejecutable standalone de `firebase-tools` se descargó dentro del proyecto y entró en el commit «Primera integracion de firebase al proyecto» con `git add .`.
- **Corrección:** `git rm --cached firebase.exe` y `*.exe` en `.gitignore` (commit `fix: INC-007 …`).
- **Estado: parcial.** El archivo sigue en la **historia** (commit «Primera integracion de firebase al proyecto»), y eso basta para que GitHub rechace el push. Antes de subir hay que reescribir los commits locales que todavía no están en GitHub (ver README, sección "Antes de hacer push").

## INC-008 — Credenciales de Firebase escritas en el código fuente

- **Severidad / Prioridad / Origen:** Alta / P1 / Configuración
- **Obtenido:** `apiKey`, `appId`, `messagingSenderId` y `projectId` aparecían literalmente en `lib/main.dart`, y la práctica prohíbe incluir claves de Firebase.
- **Corrección:** `lib/firebase_options.dart` lee los valores con `String.fromEnvironment`. Se cargan desde `firebase.env.json` (ignorado por git) con `--dart-define-from-file`. Se versiona solo `firebase.env.example.json`. Si falta la configuración, la app muestra una pantalla con las instrucciones en lugar de cerrarse.
- **Nota:** la clave sigue en la historia del commit «Primera integracion de firebase al proyecto». Se recomienda **restringir la API key** en Google Cloud Console (solo a la app Android y a la API de Firestore) o rotarla, y revisar las reglas de Firestore.
