import 'package:flutter_test/flutter_test.dart';
import 'package:lab_habitos_lenny_servino/logic/habitos_logic.dart';
import 'package:lab_habitos_lenny_servino/models/habito.dart';

void main() {
  group('calcularProgreso', () {
    test('sin hábitos devuelve 0 (no divide entre cero)', () {
      expect(calcularProgreso(0, 0), 0);
    });

    test('calcula la fracción de cumplidos', () {
      expect(calcularProgreso(1, 4), 0.25);
      expect(calcularProgreso(3, 3), 1.0);
    });

    test('nunca supera 1.0 aunque los datos sean inconsistentes', () {
      expect(calcularProgreso(5, 3), 1.0);
    });
  });

  group('validarNombreHabito (INC-002)', () {
    test('rechaza null, vacío y solo espacios', () {
      expect(validarNombreHabito(null), isNotNull);
      expect(validarNombreHabito(''), isNotNull);
      expect(validarNombreHabito('    '), isNotNull);
    });

    test('rechaza nombres demasiado largos', () {
      expect(validarNombreHabito('a' * (maxLongitudNombre + 1)), isNotNull);
    });

    test('acepta un nombre válido (ignorando espacios externos)', () {
      expect(validarNombreHabito('  Leer 20 min  '), isNull);
      expect(validarNombreHabito('a' * maxLongitudNombre), isNull);
    });
  });

  group('ordenarPorFecha (INC-004)', () {
    test('ordena ascendente, sin fecha al final y desempata por nombre', () {
      final r = ordenarPorFecha([
        const Habito(id: '1', nombre: 'Sin fecha'),
        Habito(id: '2', nombre: 'B', fechaCreacion: DateTime(2026, 1, 2)),
        Habito(id: '3', nombre: 'Z', fechaCreacion: DateTime(2026, 1, 1)),
        Habito(id: '4', nombre: 'A', fechaCreacion: DateTime(2026, 1, 2)),
      ]);

      expect(r.map((h) => h.id), ['3', '4', '2', '1']);
    });

    test('no modifica la lista original', () {
      final original = [
        Habito(id: '1', nombre: 'X', fechaCreacion: DateTime(2026, 2, 1)),
        Habito(id: '2', nombre: 'Y', fechaCreacion: DateTime(2026, 1, 1)),
      ];
      ordenarPorFecha(original);
      expect(original.first.id, '1');
    });
  });

  group('mensajeMotivacional', () {
    test('0 % → ¡Empecemos!', () {
      expect(mensajeMotivacional(0), '¡Empecemos!');
    });

    test('menos de 50 % → Buen inicio', () {
      expect(mensajeMotivacional(0.25), 'Buen inicio');
      expect(mensajeMotivacional(0.49), 'Buen inicio');
    });

    test('entre 50 % y 99 % → ¡Vas muy bien!', () {
      expect(mensajeMotivacional(0.5), '¡Vas muy bien!');
      expect(mensajeMotivacional(0.99), '¡Vas muy bien!');
    });

    test('100 % → ¡Día completado!', () {
      expect(mensajeMotivacional(1), '¡Día completado!');
    });
  });
}
