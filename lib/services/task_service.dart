import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_task.dart';
import 'package:intl/intl.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> completeTask({
    required String uid,
    required DailyTask task,
    String? imageUrl,
  }) async {
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);

    final userRef = _db.collection("users").doc(uid);
    final completionRef =
        userRef.collection("completed_tasks").doc("${task.id}_$todayStr");

    // ---------------------------------------------------
    // 1. Verificar si ya completó hoy
    // ---------------------------------------------------
    if ((await completionRef.get()).exists) {
      return false;
    }

    // ---------------------------------------------------
    // 2. Obtener datos del usuario (sin transaction)
    // ---------------------------------------------------
    final userSnap = await userRef.get();

    if (!userSnap.exists) {
      throw Exception("❌ El usuario no existe en Firestore");
    }

    final user = userSnap.data() as Map<String, dynamic>;

    final dynamic rawLastDate = user["lastTaskDate"];
    final int streak = user["streak"] ?? 0;

    // ---------------------------------------------------
    // 3. Convertir la fecha al formato seguro
    // ---------------------------------------------------
    DateTime? lastDate;

    if (rawLastDate is String) {
      try {
        lastDate = DateTime.parse(rawLastDate);
      } catch (_) {
        lastDate = null; // Formato inválido
      }
    } else if (rawLastDate is Timestamp) {
      lastDate = rawLastDate.toDate();
    } else {
      lastDate = null;
    }

    // ---------------------------------------------------
    // 4. Calcular nueva racha
    // ---------------------------------------------------
    int newStreak = streak;

    final yesterday = today.subtract(const Duration(days: 1));
    final todayFmt = DateFormat('yyyy-MM-dd').format(today);

    if (lastDate == null) {
      // Nunca ha hecho un reto
      newStreak = 1;
    } else {
      final lastFmt = DateFormat('yyyy-MM-dd').format(lastDate);
      final yesterdayFmt = DateFormat('yyyy-MM-dd').format(yesterday);

      if (lastFmt == todayFmt) {
        // Ya completó un reto hoy → no suma racha
      } else if (lastFmt == yesterdayFmt) {
        newStreak = streak + 1;
      } else {
        newStreak = 1; // Reinicia racha
      }
    }

    // ---------------------------------------------------
    // 5. Batch para guardar todo junto
    // ---------------------------------------------------
    final batch = _db.batch();

    // Guardar completado
    batch.set(completionRef, {
      'taskId': task.id,
      'date': today.toIso8601String(),
      'points': task.points,
      'grams': task.grams,
      'imageUrl': imageUrl,
    });

    // Actualizar usuario
    batch.update(userRef, {
      'points': FieldValue.increment(task.points),
      'gramsSaved': FieldValue.increment(task.grams),
      'streak': newStreak,
      'lastTaskDate': today.toIso8601String(),
    });

    // Historial
    final historyRef = userRef.collection("points_history").doc();
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
