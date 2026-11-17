import 'package:firebase_core/firebase_core.dart';

/// Opciones de Firebase leídas en tiempo de compilación (INC-008).
///
/// Los valores NO se versionan: se pasan con
/// `flutter run --dart-define-from-file=firebase.env.json`
/// (ver `firebase.env.example.json` y el README).
class DefaultFirebaseOptions {
  static const String _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String _senderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );

  /// `true` si se recibieron todos los valores necesarios.
  static bool get configurado =>
      _apiKey.isNotEmpty &&
      _appId.isNotEmpty &&
      _senderId.isNotEmpty &&
      _projectId.isNotEmpty;

  static FirebaseOptions get currentPlatform => const FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _senderId,
    projectId: _projectId,
  );
}
