# 02 — Mapa de flujos críticos

| # | Flujo crítico ("el usuario puede…") | Pantallas | Operación en Firestore | Casos de prueba |
|---|---|---|---|---|
| FC-1 | **…agregar un hábito nuevo** y verlo en su lista del día | Panel → Formulario → Panel | `add` en `habitos` | CP-04, CP-05, CP-06, CP-07, CP-21, CP-26, CP-20 |
| FC-2 | **…ver su lista de hábitos ordenada y su progreso** (barra %, mensaje y meta) | Panel | `snapshots()` en tiempo real | CP-01, CP-08, CP-12, CP-19, CP-27 |
| FC-3 | **…marcar o desmarcar un hábito como cumplido** y ver el progreso actualizado | Panel | `update {cumplido}` | CP-09, CP-25 |
| FC-4 | **…guardar la nota del día y reiniciar el día** | Panel | `batch.update {nota_dia}` / `{cumplido:false, nota_dia:''}` | CP-22, CP-23, CP-24 |
| FC-5 | **…eliminar un hábito** que ya no quiere seguir | Panel | `delete` | CP-10 |

## Diagrama del flujo principal (FC-1 + FC-3)

```
[Arranque] → Firebase.initializeApp → PanelHabitos (StreamBuilder ← habitos.snapshots())
     │
     ├─ (+) ─→ FormularioHabito ── validar nombre ──✗──→ mensaje "Escribe el nombre del hábito"
     │                │ ✓
     │                └─ add() en Firestore ─→ pop() ─→ Panel (hábito visible)
     │
     ├─ ☑ marcar ─→ update(cumplido) ─→ snapshot ─→ barra % + mensaje + chip de meta
     ├─ 🗑 eliminar ─→ delete() ─→ snapshot
     ├─ Guardar nota ─→ batch update(nota_dia) ─→ tarjeta de nota
     └─ Reiniciar día ─→ batch update(cumplido=false, nota_dia='')
```

## Orden de integración incremental (Fase 3)

| Paso | Verificación | Resultado |
|---|---|---|
| 1 | Arranque e inicialización de Firebase | Se detectó y corrigió INC-008 (credenciales en el código) e INC-007 (binario de 256 MB versionado). Arranque en emulador: CP-01 ⏳ |
| 2 | Autenticación | ➖ No aplica (ver alcance) |
| 3 | Navegación entre todas las pantallas | ✅ CP-05 / CP-06 |
| 4 | Lectura de datos | ✅ CP-08 (tras corregir INC-004), CP-12 |
| 5 | Escritura/actualización de datos | ✅ CP-07, CP-09, CP-10, CP-22 a CP-25 (tras corregir INC-002, 003, 005 y 006) |
| 6 | Notificaciones push | ➖ No aplica (ver alcance) |
| 7 | Flujo completo de extremo a extremo | ✅ CP-20 en la VM de pruebas · ⏳ en dispositivo |

> La incidencia **INC-001** (no había forma de probar la app de forma automatizada) bloqueaba los pasos 3 a 7, así que se resolvió primero.
