import 'package:flutter/material.dart';

import '../data/habitos_repository.dart';
import '../logic/habitos_logic.dart';
import '../models/estado_dia.dart';
import '../models/habito.dart';
import 'formulario_habito.dart';

// ==========================================
// PANTALLA 1: PANEL PRINCIPAL
// ==========================================
class PanelHabitos extends StatefulWidget {
  const PanelHabitos({super.key, required this.repository});

  final HabitosRepository repository;

  @override
  State<PanelHabitos> createState() => _PanelHabitosState();
}

class _PanelHabitosState extends State<PanelHabitos> {
  static const int _metaInicial = 3;

  late final Stream<EstadoDia> _dia = widget.repository.observarDia();
  final TextEditingController _notaCtrl = TextEditingController();
  int _meta = _metaInicial;
  bool _enfoque = false;

  HabitosRepository get _repo => widget.repository;

  @override
  void dispose() {
    _notaCtrl.dispose();
    super.dispose();
  }

  /// INC-006: las escrituras se lanzaban sin manejar errores; si Firestore
  /// las rechazaba (reglas, cuota, etc.) el error quedaba sin capturar y el
  /// usuario no se enteraba. No se espera la confirmación del servidor para
  /// no bloquear la UI sin conexión (la caché local ya refleja el cambio).
  void _ejecutar(Future<void> operacion) {
    final messenger = ScaffoldMessenger.of(context);
    operacion.catchError((Object _) {
      messenger.showSnackBar(
        const SnackBar(content: Text(mensajeErrorEscritura)),
      );
    });
  }

  void _cambiarMeta(double v) => setState(() => _meta = v.round());

  void _alternarEnfoque(bool v) => setState(() => _enfoque = v);

  void _guardarNota(List<Habito> habitos) {
    final texto = _notaCtrl.text.trim();
    if (texto.isEmpty) return;
    // INC-003: la nota vive en los documentos de hábito; sin hábitos no hay
    // dónde guardarla. Antes se mostraba "Nota guardada" sin guardar nada.
    if (habitos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos un hábito para guardar la nota'),
        ),
      );
      return;
    }
    _ejecutar(_repo.guardarNota(texto, habitos));
    _notaCtrl.clear();
    FocusScope.of(context).unfocus(); // Oculta teclado
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nota guardada en Firebase')));
  }

  void _reiniciarDia(List<Habito> habitos) {
    _ejecutar(_repo.reiniciarDia(habitos));
    setState(() {
      _meta = _metaInicial;
      _enfoque = false;
      _notaCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EstadoDia>(
      stream: _dia,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text('Error al cargar')));
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final dia = snapshot.data!;
        final habitos = dia.habitos;
        final progreso = dia.progreso;
        final metaAlcanzada = dia.totalCumplidos >= _meta;
        final mensaje = mensajeMotivacional(progreso);

        final int maxSliderValue = dia.total > 5 ? dia.total : 5;
        final double sliderMax = maxSliderValue.toDouble();
        final double currentSliderValue = _meta > maxSliderValue
            ? sliderMax
            : _meta.toDouble();
        final int sliderDivisions = maxSliderValue - 1;

        final notaGuardada = dia.nota;

        return Scaffold(
          appBar: AppBar(title: const Text('Mis Hábitos')),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progreso,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${(progreso * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  mensaje,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const Divider(height: 40),
              Column(
                children: [
                  Slider(
                    value: currentSliderValue,
                    min: 1,
                    max: sliderMax,
                    divisions: sliderDivisions > 0 ? sliderDivisions : 1,
                    onChanged: _cambiarMeta,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Meta: $_meta hábitos',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (metaAlcanzada && dia.total > 0) ...[
                        const SizedBox(width: 10),
                        const Chip(
                          label: Text(
                            '¡Meta alcanzada!',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const Divider(height: 40),
              SwitchListTile(
                title: const Text('Modo enfoque'),
                subtitle: const Text('Ocultar hábitos completados'),
                value: _enfoque,
                onChanged: _alternarEnfoque,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Tus hábitos de hoy:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (habitos.isEmpty)
                const Center(child: Text('Presiona + para añadir hábitos.')),
              for (final habito in habitos)
                if (!(_enfoque && habito.cumplido))
                  CheckboxListTile(
                    key: ValueKey(habito.id),
                    title: Text(
                      habito.nombre,
                      style: TextStyle(
                        decoration: habito.cumplido
                            ? TextDecoration.lineThrough
                            : null,
                        color: habito.cumplido ? Colors.grey : Colors.black,
                      ),
                    ),
                    value: habito.cumplido,
                    onChanged: (_) => _ejecutar(
                      _repo.alternarHabito(habito.id, habito.cumplido),
                    ),
                    secondary: IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _ejecutar(_repo.eliminarHabito(habito.id)),
                    ),
                  ),
              const Divider(height: 40),
              const Text(
                'Nota del día:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('campoNota'),
                      controller: _notaCtrl,
                      decoration: const InputDecoration(
                        hintText: '¿Cómo te fue hoy?',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _guardarNota(habitos),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _guardarNota(habitos),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.green.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    notaGuardada.isEmpty ? 'Sin nota' : notaGuardada,
                    style: TextStyle(
                      fontStyle: notaGuardada.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                      color: notaGuardada.isEmpty
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _reiniciarDia(habitos),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reiniciar día'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Agregar hábito',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormularioHabito(
                  repository: _repo,
                  notaActual: notaGuardada,
                ),
              ),
            ),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
