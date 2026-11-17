import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practica_integracion_pruebas_flutter/models/estado_dia.dart';
import 'package:practica_integracion_pruebas_flutter/models/habito.dart';

void main() {
  group('Habito.fromMap', () {
    test('mapea un documento completo', () {
      final h = Habito.fromMap('abc', {
        'nombre': 'Leer',
        'cumplido': true,
        'fecha_creacion': '2026-11-17T08:30:00.000',
      });

      expect(h.id, 'abc');
      expect(h.nombre, 'Leer');
      expect(h.cumplido, isTrue);
      expect(h.fechaCreacion, DateTime(2026, 11, 17, 8, 30));
    });

    test('tolera campos faltantes o con tipo incorrecto', () {
      final h = Habito.fromMap('x', {'nombre': 42, 'cumplido': 'si'});

      expect(h.nombre, '');
      expect(h.cumplido, isFalse);
      expect(h.fechaCreacion, isNull);
    });

    test('acepta fecha como Timestamp (documentos creados en consola)', () {
      final fecha = DateTime(2026, 1, 2, 3, 4);
      final h = Habito.fromMap('t', {
        'nombre': 'Correr',
        'fecha_creacion': Timestamp.fromDate(fecha),
      });

      expect(h.fechaCreacion, fecha);
    });

    test('toMap → fromMap conserva los datos', () {
      final original = Habito(
        id: 'id1',
        nombre: 'Meditar',
        cumplido: true,
        fechaCreacion: DateTime(2026, 11, 17),
      );
      final copia = Habito.fromMap('id1', original.toMap());

      expect(copia.nombre, original.nombre);
      expect(copia.cumplido, original.cumplido);
      expect(copia.fechaCreacion, original.fechaCreacion);
    });
  });

  test('EstadoDia calcula totales y progreso', () {
    const dia = EstadoDia(
      habitos: [
        Habito(id: '1', nombre: 'A', cumplido: true),
        Habito(id: '2', nombre: 'B'),
      ],
    );

    expect(dia.total, 2);
    expect(dia.totalCumplidos, 1);
    expect(dia.progreso, 0.5);
  });
}
