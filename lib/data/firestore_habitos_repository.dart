import 'package:cloud_firestore/cloud_firestore.dart';

import '../logic/habitos_logic.dart';
import '../models/estado_dia.dart';
import '../models/habito.dart';
import 'habitos_repository.dart';

/// Implementación real sobre la colección `habitos` de Cloud Firestore.
class FirestoreHabitosRepository implements HabitosRepository {
  FirestoreHabitosRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _habitos =>
      _db.collection('habitos');

  @override
  Stream<EstadoDia> observarDia() {
    return _habitos.snapshots().map((snapshot) {
      final docs = snapshot.docs;
      // INC-004: sin ordenar, Firestore devuelve los documentos por ID
      // (aleatorio), no por fecha de creación.
      final habitos = ordenarPorFecha(
        docs.map((d) => Habito.fromMap(d.id, d.data())),
      );
      final nota = docs.isEmpty ? '' : (docs.first.data()['nota_dia'] ?? '');
      return EstadoDia(habitos: habitos, nota: nota is String ? nota : '');
    });
  }

  @override
  Future<void> agregarHabito(String nombre, {String notaActual = ''}) {
    return _habitos.add({
      'nombre': nombre,
      'cumplido': false,
      'nota_dia': notaActual,
      'fecha_creacion': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> alternarHabito(String id, bool estadoActual) {
    return _habitos.doc(id).update({'cumplido': !estadoActual});
  }

  @override
  Future<void> eliminarHabito(String id) => _habitos.doc(id).delete();

  @override
  Future<void> guardarNota(String texto, List<Habito> habitos) {
    final batch = _db.batch();
    for (final h in habitos) {
      batch.update(_habitos.doc(h.id), {'nota_dia': texto});
    }
    return batch.commit();
  }

  @override
  Future<void> reiniciarDia(List<Habito> habitos) {
    final batch = _db.batch();
    for (final h in habitos) {
      // INC-005: también se limpia la nota; antes quedaba visible en la
      // tarjeta aunque la app decía haber reiniciado el día.
      batch.update(_habitos.doc(h.id), {'cumplido': false, 'nota_dia': ''});
    }
    return batch.commit();
  }
}
