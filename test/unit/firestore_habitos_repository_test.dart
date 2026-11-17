import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/data/firestore_habitos_repository.dart';

/// Prueba la implementación REAL del repositorio contra un Firestore en
/// memoria (fake_cloud_firestore), sin red ni proyecto de Firebase.
void main() {
  late FakeFirebaseFirestore db;
  late FirestoreHabitosRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirestoreHabitosRepository(firestore: db);
  });

  test('agregarHabito crea el documento con los campos esperados', () async {
    await repo.agregarHabito('Leer', notaActual: 'Buen día');

    final docs = (await db.collection('habitos').get()).docs;
    expect(docs, hasLength(1));
    final data = docs.single.data();
    expect(data['nombre'], 'Leer');
    expect(data['cumplido'], isFalse);
    expect(data['nota_dia'], 'Buen día');
    expect(DateTime.tryParse(data['fecha_creacion'] as String), isNotNull);
  });

  test('observarDia emite hábitos y la nota guardada', () async {
    await repo.agregarHabito('Leer', notaActual: 'Nota X');

    final dia = await repo.observarDia().first;
    expect(dia.habitos.single.nombre, 'Leer');
    expect(dia.nota, 'Nota X');
  });

  test(
    'INC-004 (regresión): observarDia ordena por fecha de creación',
    () async {
      final col = db.collection('habitos');
      // Los IDs van en orden alfabético opuesto a la fecha, a propósito.
      await col.doc('a').set({
        'nombre': 'Tercero',
        'fecha_creacion': '2026-11-17T10:00:00.000',
      });
      await col.doc('b').set({
        'nombre': 'Primero',
        'fecha_creacion': '2026-11-17T08:00:00.000',
      });
      await col.doc('c').set({
        'nombre': 'Segundo',
        'fecha_creacion': '2026-11-17T09:00:00.000',
      });
      await col.doc('0').set({'nombre': 'Sin fecha (al final)'});

      final nombres = (await repo.observarDia().first).habitos
          .map((h) => h.nombre)
          .toList();

      expect(nombres, [
        'Primero',
        'Segundo',
        'Tercero',
        'Sin fecha (al final)',
      ]);
    },
  );

  test('alternarHabito invierte el campo cumplido', () async {
    await repo.agregarHabito('Correr');
    final id = (await repo.observarDia().first).habitos.single.id;

    await repo.alternarHabito(id, false);

    final doc = await db.collection('habitos').doc(id).get();
    expect(doc.data()!['cumplido'], isTrue);
  });

  test('eliminarHabito borra el documento', () async {
    await repo.agregarHabito('Correr');
    final id = (await repo.observarDia().first).habitos.single.id;

    await repo.eliminarHabito(id);

    expect((await db.collection('habitos').get()).docs, isEmpty);
  });

  test('guardarNota actualiza nota_dia en todos los hábitos', () async {
    await repo.agregarHabito('A');
    await repo.agregarHabito('B');
    final habitos = (await repo.observarDia().first).habitos;

    await repo.guardarNota('Hoy fue productivo', habitos);

    final docs = (await db.collection('habitos').get()).docs;
    expect(
      docs.map((d) => d.data()['nota_dia']),
      everyElement('Hoy fue productivo'),
    );
  });

  test('reiniciarDia desmarca todos los hábitos', () async {
    await repo.agregarHabito('A');
    await repo.agregarHabito('B');
    var habitos = (await repo.observarDia().first).habitos;
    for (final h in habitos) {
      await repo.alternarHabito(h.id, false);
    }
    habitos = (await repo.observarDia().first).habitos;

    await repo.reiniciarDia(habitos);

    final docs = (await db.collection('habitos').get()).docs;
    expect(docs.map((d) => d.data()['cumplido']), everyElement(isFalse));
  });

  test('INC-005 (regresión): reiniciarDia también borra la nota', () async {
    await repo.agregarHabito('A');
    final habitos = (await repo.observarDia().first).habitos;
    await repo.guardarNota('Nota de ayer', habitos);

    await repo.reiniciarDia(habitos);

    expect((await repo.observarDia().first).nota, '');
  });
}
