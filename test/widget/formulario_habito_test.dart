import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_habitos_lenny_servino/main.dart';

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
