import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!DefaultFirebaseOptions.configurado) {
    runApp(const _ConfiguracionFaltante());
    return;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

/// Se muestra si la app se ejecuta sin `--dart-define-from-file`.
class _ConfiguracionFaltante extends StatelessWidget {
  const _ConfiguracionFaltante();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Falta la configuración de Firebase.\n\n'
              'Ejecuta:\nflutter run --dart-define-from-file=firebase.env.json',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab Hábitos Firebase',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const PanelHabitos(),
    );
  }
}

// ==========================================
// PANTALLA 1: PANEL PRINCIPAL
// ==========================================
class PanelHabitos extends StatefulWidget {
  const PanelHabitos({super.key});

  @override
  State<PanelHabitos> createState() => _PanelHabitosState();
}

class _PanelHabitosState extends State<PanelHabitos> {
  final CollectionReference _habitosRef = FirebaseFirestore.instance.collection(
    'habitos',
  );

  int _meta = 3;
  bool _enfoque = false;
  final TextEditingController _notaCtrl = TextEditingController();
  static const int _metaInicial = 3;

  @override
  void dispose() {
    _notaCtrl.dispose();
    super.dispose();
  }

  void _alternarHabito(String id, bool estadoActual) {
    _habitosRef.doc(id).update({'cumplido': !estadoActual});
  }

  void _cambiarMeta(double v) {
    setState(() {
      _meta = v.round();
    });
  }

  void _alternarEnfoque(bool v) {
    setState(() {
      _enfoque = v;
    });
  }

  void _guardarNota(List<QueryDocumentSnapshot> habitos) {
    final texto = _notaCtrl.text.trim();
    if (texto.isNotEmpty) {
      for (var doc in habitos) {
        _habitosRef.doc(doc.id).update({'nota_dia': texto});
      }
      _notaCtrl.clear();
      FocusScope.of(context).unfocus(); // Oculta teclado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota guardada en Firebase')),
      );
    }
  }

  void _reiniciarDia(List<QueryDocumentSnapshot> habitos) {
    for (var doc in habitos) {
      _habitosRef.doc(doc.id).update({'cumplido': false});
    }
    setState(() {
      _meta = _metaInicial;
      _enfoque = false;
      _notaCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Envolvemos todo el Scaffold dentro del StreamBuilder
    // para que la variable notaGuardada sea visible en el botón flotante.
    return StreamBuilder<QuerySnapshot>(
      stream: _habitosRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Scaffold(body: Center(child: Text('Error al cargar')));
        if (!snapshot.hasData)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );

        final habitos = snapshot.data!.docs;
        final int totalHabitos = habitos.length;
        final int totalCumplidos = habitos.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['cumplido'] == true;
        }).length;

        final double progreso = totalHabitos == 0
            ? 0
            : totalCumplidos / totalHabitos;
        final bool metaAlcanzada = totalCumplidos >= _meta;

        String mensaje;
        final p = (progreso * 100).round();
        if (p == 0)
          mensaje = '¡Empecemos!';
        else if (p < 50)
          mensaje = 'Buen inicio';
        else if (p < 100)
          mensaje = '¡Vas muy bien!';
        else
          mensaje = '¡Día completado!';

        int maxSliderValue = totalHabitos > 5 ? totalHabitos : 5;
        double sliderMax = maxSliderValue.toDouble();
        double currentSliderValue = _meta > maxSliderValue
            ? sliderMax
            : _meta.toDouble();
        int sliderDivisions = maxSliderValue - 1;

        String notaGuardada = '';
        if (habitos.isNotEmpty) {
          final dataPrimerHabito = habitos.first.data() as Map<String, dynamic>;
          notaGuardada = dataPrimerHabito['nota_dia'] ?? '';
        }

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
                      if (metaAlcanzada && totalHabitos > 0) ...[
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
              ...habitos.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final bool cumplido = data['cumplido'] ?? false;

                if (_enfoque && cumplido) return const SizedBox.shrink();

                return CheckboxListTile(
                  title: Text(
                    data['nombre'] ?? '',
                    style: TextStyle(
                      decoration: cumplido ? TextDecoration.lineThrough : null,
                      color: cumplido ? Colors.grey : Colors.black,
                    ),
                  ),
                  value: cumplido,
                  onChanged: (bool? value) {
                    _alternarHabito(doc.id, cumplido);
                  },
                  secondary: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _habitosRef.doc(doc.id).delete(),
                  ),
                );
              }),
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FormularioHabito(notaActual: notaGuardada),
              ),
            ),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

// ==========================================
// PANTALLA 2: FORMULARIO
// ==========================================
class FormularioHabito extends StatefulWidget {
  final String notaActual;

  const FormularioHabito({super.key, required this.notaActual});

  @override
  State<FormularioHabito> createState() => _FormularioHabitoState();
}

class _FormularioHabitoState extends State<FormularioHabito> {
  final _controller = TextEditingController();
  final CollectionReference _habitosRef = FirebaseFirestore.instance.collection(
    'habitos',
  );

  void _guardarHabito() async {
    if (_controller.text.isNotEmpty) {
      await _habitosRef.add({
        'nombre': _controller.text,
        'cumplido': false,
        'nota_dia': widget.notaActual,
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
      if (mounted) Navigator.pop(context); // Regresa a Pantalla 1
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Hábito'),
        backgroundColor: Colors.green.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Añade un nuevo hábito a tu rutina diaria:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nombre del hábito',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.star_border),
              ),
              autofocus: true,
              onSubmitted: (_) => _guardarHabito(),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarHabito,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Guardar Hábito',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
