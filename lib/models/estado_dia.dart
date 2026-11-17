import '../logic/habitos_logic.dart';
import 'habito.dart';

/// Foto del día: lista de hábitos y la nota guardada.
class EstadoDia {
  final List<Habito> habitos;
  final String nota;

  const EstadoDia({this.habitos = const [], this.nota = ''});

  int get total => habitos.length;
  int get totalCumplidos => habitos.where((h) => h.cumplido).length;
  double get progreso => calcularProgreso(totalCumplidos, total);
}
