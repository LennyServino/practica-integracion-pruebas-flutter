// Prueba de integración del flujo crítico 1 (CP-20), de extremo a extremo
// en la UI: agregar → marcar → nota → reiniciar → eliminar.
//
// Usa el repositorio fake para que sea repetible y no ensucie la base real.
// Ejecutar con un emulador o dispositivo conectado:
//   flutter test integration_test
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:practica_integracion_pruebas_flutter/main.dart';

import '../test/fakes/fake_habitos_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-20: flujo completo de un día de hábitos', (tester) async {
    final repo = FakeHabitosRepository();
    await tester.pumpWidget(MyApp(repository: repo));
    await tester.pumpAndSettle();

    // El Scrollable del ListView (los TextField tienen el suyo propio).
    final lista = find.byType(Scrollable).first;

    // 1. Estado vacío
    expect(find.text('Presiona + para añadir hábitos.'), findsOneWidget);

    // 2. Agregar dos hábitos desde la pantalla 2
    for (final nombre in ['Leer', 'Correr']) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('campoNombreHabito')),
        nombre,
      );
      await tester.tap(find.text('Guardar Hábito'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Leer'), findsOneWidget);
    expect(find.text('Correr'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);

    // 3. Marcar uno → 50 %
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(find.text('50%'), findsOneWidget);

    // 4. Guardar nota del día
    await tester.scrollUntilVisible(
      find.byKey(const Key('campoNota')),
      200,
      scrollable: lista,
    );
    await tester.enterText(find.byKey(const Key('campoNota')), 'Buen día');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Buen día'), findsOneWidget);
    // Cerrar el SnackBar "Nota guardada" para que no tape el botón inferior.
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();

    // 5. Reiniciar día → 0 % y sin nota
    await tester.scrollUntilVisible(
      find.text('Reiniciar día'),
      200,
      scrollable: lista,
    );
    await tester.tap(find.text('Reiniciar día'));
    await tester.pumpAndSettle();
    expect(find.text('Sin nota'), findsOneWidget);

    // 6. Eliminar un hábito
    await tester.scrollUntilVisible(
      find.text('Correr'),
      -200,
      scrollable: lista,
    );
    await tester.tap(find.byTooltip('Eliminar').last);
    await tester.pumpAndSettle();
    expect(find.text('Correr'), findsNothing);
    expect(repo.habitos.map((h) => h.nombre), ['Leer']);
  });
}
