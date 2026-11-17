import '../models/estado_dia.dart';
import '../models/habito.dart';

/// Contrato de acceso a datos. La UI depende de esta abstracción para poder
/// sustituir Firestore por un fake en las pruebas de widget.
abstract class HabitosRepository {
  /// Emite el estado del día cada vez que cambian los datos.
  Stream<EstadoDia> observarDia();

  Future<void> agregarHabito(String nombre, {String notaActual = ''});

  Future<void> alternarHabito(String id, bool estadoActual);

  Future<void> eliminarHabito(String id);

  Future<void> guardarNota(String texto, List<Habito> habitos);

  Future<void> reiniciarDia(List<Habito> habitos);
}
