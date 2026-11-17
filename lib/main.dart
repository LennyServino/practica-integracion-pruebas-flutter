import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/firestore_habitos_repository.dart';
import 'data/habitos_repository.dart';
import 'firebase_options.dart';
import 'screens/panel_habitos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!DefaultFirebaseOptions.configurado) {
    runApp(const _ConfiguracionFaltante());
    return;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp(repository: FirestoreHabitosRepository()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.repository});

  final HabitosRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab Hábitos Firebase',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: PanelHabitos(repository: repository),
    );
  }
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
