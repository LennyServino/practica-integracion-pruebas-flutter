import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/main.dart';

import '../fakes/fake_habitos_repository.dart';

Future<void> abrirFormulario(
  WidgetTester tester,
  FakeHabitosRepository repo,
) async {
  await tester.pumpWidget(MyApp(repository: repo));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('CP-07: nombre válido crea el hábito y regresa al panel', (
    tester,
  ) async {
    final repo = FakeHabitosRepository();
    await abrirFormulario(tester, repo);

    await tester.enterText(find.byKey(const Key('campoNombreHabito')), 'Leer');
    await tester.tap(find.text('Guardar Hábito'));
    await tester.pumpAndSettle();

    expect(repo.llamadas, ['agregarHabito:Leer']);
    expect(find.text('Mis Hábitos'), findsOneWidget);
    expect(find.text('Leer'), findsOneWidget);
  });

  testWidgets('INC-006 (regresión): sin conexión el formulario no se congela', (
    tester,
  ) async {
    final repo = FakeHabitosRepository(sinConexion: true);
    await abrirFormulario(tester, repo);

    await tester.enterText(find.byKey(const Key('campoNombreHabito')), 'Leer');
    await tester.tap(find.text('Guardar Hábito'));
    await tester.pumpAndSettle();

    // Regresa al panel y el hábito ya se ve (caché local de Firestore).
    expect(find.text('Mis Hábitos'), findsOneWidget);
    expect(find.text('Leer'), findsOneWidget);
  });

  testWidgets('INC-006: si Firestore rechaza el alta se avisa al usuario', (
    tester,
  ) async {
    final repo = FakeHabitosRepository(
      errorAlEscribir: Exception('permission-denied'),
    );
    await abrirFormulario(tester, repo);

    await tester.enterText(find.byKey(const Key('campoNombreHabito')), 'Leer');
    await tester.tap(find.text('Guardar Hábito'));
    await tester.pumpAndSettle();

    expect(find.text('Mis Hábitos'), findsOneWidget);
    expect(
      find.text(
        'No se pudo guardar el cambio en Firebase. Inténtalo de nuevo.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('CP-04: campo vacío muestra mensaje y no llama al servicio', (
    tester,
  ) async {
    final repo = FakeHabitosRepository();
    await abrirFormulario(tester, repo);

    await tester.tap(find.text('Guardar Hábito'));
    await tester.pumpAndSettle();

    expect(find.text('Escribe el nombre del hábito'), findsOneWidget);
    expect(repo.llamadas, isEmpty);
    expect(find.text('Nuevo Hábito'), findsOneWidget);
  });

  testWidgets('INC-002 (regresión): solo espacios no crea el hábito', (
    tester,
  ) async {
    final repo = FakeHabitosRepository();
    await abrirFormulario(tester, repo);

    await tester.enterText(find.byKey(const Key('campoNombreHabito')), '   ');
    await tester.tap(find.text('Guardar Hábito'));
    await tester.pumpAndSettle();

    expect(find.text('Escribe el nombre del hábito'), findsOneWidget);
    expect(repo.llamadas, isEmpty);
  });

  testWidgets('INC-002: el nombre se guarda sin espacios sobrantes', (
    tester,
  ) async {
    final repo = FakeHabitosRepository();
    await abrirFormulario(tester, repo);

    await tester.enterText(
      find.byKey(const Key('campoNombreHabito')),
      '  Meditar  ',
    );
    await tester.tap(find.text('Guardar Hábito'));
    await tester.pumpAndSettle();

    expect(repo.llamadas, ['agregarHabito:Meditar']);
  });
}
