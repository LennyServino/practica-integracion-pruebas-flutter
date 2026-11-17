import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_habitos_lenny_servino/main.dart';
import 'package:lab_habitos_lenny_servino/models/habito.dart';

import '../fakes/fake_habitos_repository.dart';

/// Pantalla alta para que el ListView construya todos sus elementos.
void usarPantallaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> abrirApp(WidgetTester tester, FakeHabitosRepository repo) async {
  usarPantallaAlta(tester);
  await tester.pumpWidget(MyApp(repository: repo));
  await tester.pumpAndSettle(); // primera emisión del stream + animaciones
}

void main() {
  testWidgets('CP-12: lista vacía muestra mensaje de estado vacío', (
    tester,
  ) async {
    await abrirApp(tester, FakeHabitosRepository());

    expect(find.text('Presiona + para añadir hábitos.'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('¡Empecemos!'), findsOneWidget);
    expect(find.text('Sin nota'), findsOneWidget);
  });

  testWidgets('CP-08: con datos muestra hábitos, progreso y nota', (
    tester,
  ) async {
    final repo = FakeHabitosRepository(
      habitos: const [
        Habito(id: '1', nombre: 'Leer', cumplido: true),
        Habito(id: '2', nombre: 'Correr'),
      ],
      nota: 'Buen día',
    );
    await abrirApp(tester, repo);

    expect(find.text('Leer'), findsOneWidget);
    expect(find.text('Correr'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('¡Vas muy bien!'), findsOneWidget);
    expect(find.text('Buen día'), findsOneWidget);
  });

  testWidgets('CP-09: marcar un hábito actualiza el progreso', (tester) async {
    final repo = FakeHabitosRepository(
      habitos: const [Habito(id: '1', nombre: 'Leer')],
    );
    await abrirApp(tester, repo);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(repo.llamadas, contains('alternarHabito:1'));
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('¡Día completado!'), findsOneWidget);
  });

  testWidgets('CP-10: eliminar un hábito lo quita de la lista', (tester) async {
    final repo = FakeHabitosRepository(
      habitos: const [Habito(id: '1', nombre: 'Leer')],
    );
    await abrirApp(tester, repo);

    await tester.tap(find.byTooltip('Eliminar'));
    await tester.pump();

    expect(repo.llamadas, contains('eliminarHabito:1'));
    expect(find.text('Leer'), findsNothing);
  });

  testWidgets('Modo enfoque oculta los hábitos completados', (tester) async {
    final repo = FakeHabitosRepository(
      habitos: const [
        Habito(id: '1', nombre: 'Leer', cumplido: true),
        Habito(id: '2', nombre: 'Correr'),
      ],
    );
    await abrirApp(tester, repo);

    await tester.tap(find.text('Modo enfoque'));
    await tester.pump();

    expect(find.text('Leer'), findsNothing);
    expect(find.text('Correr'), findsOneWidget);
  });

  testWidgets('CP-12: error de lectura muestra mensaje sin cerrar la app', (
    tester,
  ) async {
    await abrirApp(
      tester,
      FakeHabitosRepository(errorAlLeer: Exception('sin conexión')),
    );

    expect(find.text('Error al cargar'), findsOneWidget);
  });

  testWidgets('Guardar nota con hábitos la muestra en la tarjeta', (
    tester,
  ) async {
    final repo = FakeHabitosRepository(
      habitos: const [Habito(id: '1', nombre: 'Leer')],
    );
    await abrirApp(tester, repo);

    await tester.enterText(find.byKey(const Key('campoNota')), 'Gran día');
    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(repo.llamadas, ['guardarNota:Gran día']);
    expect(find.text('Gran día'), findsOneWidget);
    expect(find.text('Nota guardada en Firebase'), findsOneWidget);
  });

  testWidgets('INC-003 (regresión): sin hábitos no confirma una nota falsa', (
    tester,
  ) async {
    final repo = FakeHabitosRepository();
    await abrirApp(tester, repo);

    await tester.enterText(find.byKey(const Key('campoNota')), 'Gran día');
    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(find.text('Nota guardada en Firebase'), findsNothing);
    expect(
      find.text('Agrega al menos un hábito para guardar la nota'),
      findsOneWidget,
    );
    expect(repo.llamadas, isEmpty);
    // El texto escrito no se pierde.
    expect(find.widgetWithText(TextField, 'Gran día'), findsOneWidget);
  });

  testWidgets('Reiniciar día desmarca hábitos y limpia la nota (INC-005)', (
    tester,
  ) async {
    final repo = FakeHabitosRepository(
      habitos: const [Habito(id: '1', nombre: 'Leer', cumplido: true)],
      nota: 'Nota de ayer',
    );
    await abrirApp(tester, repo);
    expect(find.text('100%'), findsOneWidget);

    await tester.tap(find.text('Reiniciar día'));
    await tester.pump();

    expect(repo.llamadas, ['reiniciarDia']);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('Sin nota'), findsOneWidget);
    expect(find.text('Nota de ayer'), findsNothing);
  });

  testWidgets('CP-05/CP-06: navega al formulario y regresa con "atrás"', (
    tester,
  ) async {
    await abrirApp(tester, FakeHabitosRepository());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Nuevo Hábito'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Mis Hábitos'), findsOneWidget);
  });
}
