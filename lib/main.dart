import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'TU_API_KEY',
      appId: 'TU_APP_ID',
      messagingSenderId: 'TU_SENDER_ID',
      projectId: 'lab-habitos-test',
    ),
  );

  runApp(const MyApp());
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
  String _nota = '';
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

  void _guardarNota() {
    setState(() {
      _nota = _notaCtrl.text.trim();
    });
  }

  void _reiniciarDia(List<QueryDocumentSnapshot> habitos) {
    for (var doc in habitos) {
      _habitosRef.doc(doc.id).update({'cumplido': false});
    }
    setState(() {
      _meta = _metaInicial;
      _enfoque = false;
      _nota = '';
      _notaCtrl.clear();
    });
  }

  void _mostrarDialogoNuevoHabito() {
    final TextEditingController newHabitoCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Hábito'),
        content: TextField(
          controller: newHabitoCtrl,
          decoration: const InputDecoration(hintText: 'Nombre del hábito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newHabitoCtrl.text.isNotEmpty) {
                _habitosRef.add({
                  'nombre': newHabitoCtrl.text,
                  'cumplido': false,
                  'fecha_creacion': DateTime.now().toIso8601String(),
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Hábitos')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _habitosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('Error al cargar'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          final habitos = snapshot.data!.docs;
          final int totalHabitos = habitos.length;
          final int totalCumplidos = habitos
              .where((doc) => doc['cumplido'] == true)
              .length;
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

          // --- FIX DEL SLIDER (INC-001) ---
          // Prevenimos que el Slider se rompa calculando topes lógicos de antemano
          int maxSliderValue = totalHabitos > 0 ? totalHabitos : 1;
          double sliderMax = maxSliderValue.toDouble();
          double currentSliderValue = _meta > maxSliderValue
              ? sliderMax
              : _meta.toDouble();
          int sliderDivisions = totalHabitos > 1 ? totalHabitos - 1 : 1;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. Barra de progreso
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

              // 2. Mensaje motivacional
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

              // 3. Slider de meta (APLICANDO EL FIX)
              Column(
                children: [
                  Slider(
                    value: currentSliderValue,
                    min: 1,
                    max: sliderMax,
                    divisions: sliderDivisions,
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

              // 4. Switch de Modo enfoque
              SwitchListTile(
                title: const Text('Modo enfoque'),
                subtitle: const Text('Ocultar hábitos completados'),
                value: _enfoque,
                onChanged: _alternarEnfoque,
              ),

              // 5. Lista de hábitos (Desde Firebase)
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
                    data['nombre'],
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

              // 6. Sección de notas
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
                      onSubmitted: (_) => _guardarNota(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _guardarNota,
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
                    _nota.isEmpty ? 'Sin nota' : _nota,
                    style: TextStyle(
                      fontStyle: _nota.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                      color: _nota.isEmpty ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 7. Botón Reiniciar Día
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoNuevoHabito,
        child: const Icon(Icons.add),
      ),
    );
  }
}
