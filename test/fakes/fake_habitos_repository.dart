import 'dart:async';

import 'package:lab_habitos_lenny_servino/data/habitos_repository.dart';
import 'package:lab_habitos_lenny_servino/models/estado_dia.dart';
import 'package:lab_habitos_lenny_servino/models/habito.dart';

/// Repositorio en memoria para pruebas de widget e integración.
/// Registra cada llamada en [llamadas] para verificar qué se invocó.
class FakeHabitosRepository implements HabitosRepository {
  FakeHabitosRepository({
    List<Habito> habitos = const [],
    this.nota = '',
    this.errorAlLeer,
    this.errorAlEscribir,
  }) : _habitos = [...habitos];

  final List<Habito> _habitos;
  String nota;
  int _siguienteId = 1;

  /// Si no es null, [observarDia] emite este error.
  final Object? errorAlLeer;

  /// Si no es null, toda escritura falla con este error.
  final Object? errorAlEscribir;

  final List<String> llamadas = [];
  final _cambios = StreamController<EstadoDia>.broadcast();

  List<Habito> get habitos => List.unmodifiable(_habitos);

  EstadoDia get _estado =>
      EstadoDia(habitos: List.unmodifiable(_habitos), nota: nota);

  void _emitir() => _cambios.add(_estado);

  Future<void> _escribir(String llamada, void Function() cambio) async {
    llamadas.add(llamada);
    if (errorAlEscribir != null) throw errorAlEscribir!;
    cambio();
    _emitir();
  }

  @override
  Stream<EstadoDia> observarDia() async* {
    if (errorAlLeer != null) throw errorAlLeer!;
    yield _estado;
    yield* _cambios.stream;
  }

  @override
  Future<void> agregarHabito(String nombre, {String notaActual = ''}) =>
      _escribir('agregarHabito:$nombre', () {
        _habitos.add(
          Habito(
            id: 'fake-${_siguienteId++}',
            nombre: nombre,
            fechaCreacion: DateTime.now(),
          ),
        );
      });

  @override
  Future<void> alternarHabito(String id, bool estadoActual) =>
      _escribir('alternarHabito:$id', () {
        final i = _habitos.indexWhere((h) => h.id == id);
        _habitos[i] = _habitos[i].copyWith(cumplido: !estadoActual);
      });

  @override
  Future<void> eliminarHabito(String id) => _escribir(
    'eliminarHabito:$id',
    () => _habitos.removeWhere((h) => h.id == id),
  );

  @override
  Future<void> guardarNota(String texto, List<Habito> habitos) =>
      _escribir('guardarNota:$texto', () => nota = texto);

  @override
  Future<void> reiniciarDia(List<Habito> habitos) =>
      _escribir('reiniciarDia', () {
        for (var i = 0; i < _habitos.length; i++) {
          _habitos[i] = _habitos[i].copyWith(cumplido: false);
        }
        nota = '';
      });
}
