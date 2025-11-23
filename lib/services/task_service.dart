import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_task.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔹 Crea los retos diarios por defecto en la colección "daily_tasks".
  /// Ejecútalo UNA sola vez (por ejemplo, desde un botón escondido).
  Future<void> createDefaultDailyTasks() async {
    final tasks = [
      DailyTask(
        id: "reciclar_plastico",
        title: "Reciclar plástico",
        description: "Lleva tus botellas y envolturas a la caneca adecuada.",
        points: 20,
        grams: 150, // 150 g de contaminación evitada
        expectedObject: "botella reutilizable",
      ),
      DailyTask(
        id: "usar_bicicleta",
        title: "Usar bicicleta",
        description: "Muévete en bicicleta mínimo 1 km en lugar de vehículo.",
        points: 30,
        grams: 400, // 400 g de CO₂ evitados
        expectedObject: "bicicleta",
      ),
      DailyTask(
        id: "reutilizar_bolsa",
        title: "Reutilizar bolsas",
        description: "Usa bolsas reutilizables en lugar de bolsas plásticas.",
        points: 15,
        grams: 75,
        expectedObject: "bolsa de tela",
      ),
      DailyTask(
        id: "llevar_termo",
        title: "Usar termo personal",
        description: "Lleva tu propio termo y evita botellas plásticas.",
        points: 25,
        grams: 100,
        expectedObject: "termo",
      ),
    ];

    for (final task in tasks) {
      await _db.collection("daily_tasks").doc(task.id).set(task.toMap());
    }
  }

  /// 🔹 Marca un reto como completado para el usuario `uid` en el día actual.
  /// - Solo permite completar una vez por día cada reto.
  /// - Suma puntos al usuario.
  /// - Registra el historial de puntos y gramos.
  ///
  /// Devuelve:
  ///  - true  -> si se completó correctamente
  ///  - false -> si ya estaba completado hoy
Future<bool> completeTask({
    required String uid,
    required DailyTask task,
    String? imageUrl, // opcional
  }) async {
    final today = DateTime.now();
    final dateId =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final completionRef = _db
        .collection("users")
        .doc(uid)
        .collection("completed_tasks")
        .doc("${task.id}_$dateId");

    final alreadyDone = await completionRef.get();
    if (alreadyDone.exists) {
      return false;
    }

    final batch = _db.batch();

    // Registro de la tarea completada hoy
    batch.set(completionRef, {
      'taskId': task.id,
      'date': today.toIso8601String(),
      'points': task.points,
      'grams': task.grams,
    });

    // Actualizar puntos del usuario
    final userRef = _db.collection("users").doc(uid);
    batch.update(userRef, {
      'points': FieldValue.increment(task.points),
      // Si quieres gramos acumulados:
      // 'totalGrams': FieldValue.increment(task.grams),
    });

    // Historial
    final historyRef =
        _db.collection("users").doc(uid).collection("points_history").doc();

    batch.set(historyRef, {
      'taskId': task.id,
      'description': task.title,
      'date': today.toIso8601String(),
      'points': task.points,
      'grams': task.grams,
    });

    await batch.commit();
    return true;
  }

}
