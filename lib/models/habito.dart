import 'package:cloud_firestore/cloud_firestore.dart';

/// Un hábito diario almacenado en la colección `habitos` de Firestore.
class Habito {
  final String id;
  final String nombre;
  final bool cumplido;
  final DateTime? fechaCreacion;

  const Habito({
    required this.id,
    required this.nombre,
    this.cumplido = false,
    this.fechaCreacion,
  });

  /// Mapea un documento de Firestore. Tolera campos faltantes o con tipos
  /// inesperados (p. ej. documentos creados a mano desde la consola).
  factory Habito.fromMap(String id, Map<String, dynamic> data) {
    return Habito(
      id: id,
      nombre: data['nombre'] is String ? data['nombre'] as String : '',
      cumplido: data['cumplido'] == true,
      fechaCreacion: _leerFecha(data['fecha_creacion']),
    );
  }

  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'cumplido': cumplido,
    'fecha_creacion': fechaCreacion?.toIso8601String(),
  };

  Habito copyWith({String? nombre, bool? cumplido}) => Habito(
    id: id,
    nombre: nombre ?? this.nombre,
    cumplido: cumplido ?? this.cumplido,
    fechaCreacion: fechaCreacion,
  );

  static DateTime? _leerFecha(Object? valor) {
    if (valor is String) return DateTime.tryParse(valor);
    if (valor is Timestamp) return valor.toDate();
    return null;
  }
}
