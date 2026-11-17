import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_habitos_lenny_servino/data/firestore_habitos_repository.dart';

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
}
