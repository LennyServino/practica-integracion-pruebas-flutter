import 'package:flutter/material.dart';

import '../data/habitos_repository.dart';

// ==========================================
// PANTALLA 2: FORMULARIO
// ==========================================
class FormularioHabito extends StatefulWidget {
  const FormularioHabito({
    super.key,
    required this.repository,
    required this.notaActual,
  });

  final HabitosRepository repository;
  final String notaActual;

  @override
  State<FormularioHabito> createState() => _FormularioHabitoState();
}

class _FormularioHabitoState extends State<FormularioHabito> {
  final _controller = TextEditingController();

  Future<void> _guardarHabito() async {
    if (_controller.text.isNotEmpty) {
      await widget.repository.agregarHabito(
        _controller.text,
        notaActual: widget.notaActual,
      );
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
              key: const Key('campoNombreHabito'),
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
