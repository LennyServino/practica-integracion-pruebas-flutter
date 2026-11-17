# 05 — Reflexión final

> ✏️ **Borrador: revisar y reescribir con palabras propias antes de entregar.**

**¿Qué prueba habría evitado mi error más costoso?**

Mi error más costoso no fue un bug visible, sino la estructura: las pantallas creaban `FirebaseFirestore.instance` por su cuenta y la lógica vivía dentro de `build()`. Por eso `flutter test` fallaba con `[core/no-app]` (INC-001), y para escribir la primera prueba de widget tuve que refactorizar toda la app. Una sola prueba de widget con un repositorio *fake*, escrita desde la primera integración con Firebase, me habría obligado a inyectar el repositorio y habría evitado el refactor. Una vez que pude usar fakes, los demás errores aparecieron enseguida: nombres en blanco (INC-002), una confirmación falsa al guardar la nota (INC-003), la lista desordenada (INC-004) y el reinicio incompleto (INC-005). Ninguno lanzaba excepción, así que probando a mano parecían "funcionar". También aprendí que con Firestore un `await` sobre una escritura puede no terminar nunca sin conexión (INC-006): ahí necesitaba una prueba de "sin red", no solo del camino feliz. Por último, revisar `git status` antes de cada commit habría evitado subir un binario de 256 MB y las credenciales (INC-007 e INC-008). Mi conclusión: probar los estados vacío, de error y sin conexión vale tanto como probar el caso exitoso.
