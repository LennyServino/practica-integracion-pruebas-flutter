# Evidencias de Firebase Console

Capturas de **Firestore Database → Datos → colección `habitos`** que muestren las operaciones realizadas desde la app.

| Archivo sugerido | Qué debe verse | Caso |
|---|---|---|
| `CP-07-consola-alta.png` | Documento nuevo con `nombre`, `cumplido: false`, `nota_dia`, `fecha_creacion` | CP-07 |
| `CP-09-consola-cumplido.png` | El mismo documento con `cumplido: true` | CP-09 |
| `CP-22-consola-nota.png` | `nota_dia` con el texto guardado en todos los documentos | CP-22 |
| `CP-24-consola-reinicio.png` | Tras "Reiniciar día": `cumplido: false` y `nota_dia: ""` | CP-24 / INC-005 |
| `CP-10-consola-eliminado.png` | El documento ya no aparece | CP-10 |
| `reglas-firestore.png` | Pestaña **Reglas** (verificar que no estén vencidas, ver INC-006) | — |

⚠️ No incluir en las capturas la API key, la pestaña "Configuración del proyecto" ni `google-services.json`.
