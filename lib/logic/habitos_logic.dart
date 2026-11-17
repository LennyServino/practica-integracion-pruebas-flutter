/// Lógica pura (sin Flutter ni Firebase) para poder probarla con pruebas
/// unitarias.
library;

/// Fracción de hábitos cumplidos entre 0.0 y 1.0. Con 0 hábitos devuelve 0.
double calcularProgreso(int cumplidos, int total) {
  if (total <= 0) return 0;
  return (cumplidos / total).clamp(0.0, 1.0);
}

/// Longitud máxima permitida para el nombre de un hábito.
const int maxLongitudNombre = 40;

/// Valida el nombre de un hábito (INC-002). Devuelve el mensaje de error o
/// `null` si es válido. Los espacios al inicio/final no cuentan.
String? validarNombreHabito(String? valor) {
  final nombre = valor?.trim() ?? '';
  if (nombre.isEmpty) return 'Escribe el nombre del hábito';
  if (nombre.length > maxLongitudNombre) {
    return 'Máximo $maxLongitudNombre caracteres';
  }
  return null;
}

/// Mensaje motivacional según el progreso (0.0 – 1.0).
String mensajeMotivacional(double progreso) {
  final p = (progreso * 100).round();
  if (p == 0) return '¡Empecemos!';
  if (p < 50) return 'Buen inicio';
  if (p < 100) return '¡Vas muy bien!';
  return '¡Día completado!';
}
