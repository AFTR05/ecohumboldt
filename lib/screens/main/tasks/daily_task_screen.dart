import 'dart:typed_data' show Uint8List;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_humboldt_go/screens/camera/camera_validation_screen.dart';
import 'package:eco_humboldt_go/services/image_ai_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../models/daily_task.dart';
import '../../../services/task_service.dart';

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final taskService = TaskService();

  Uint8List? lastCapturedBytes;

  // ---- STREAM: Completed today ----
  Stream<List<String>> getCompletedTodayStream() {
    final today = DateTime.now();
    final dateId = "${today.year}-${today.month}-${today.day}";

    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("completed_tasks")
        .snapshots()
        .map((snap) =>
            snap.docs.map((e) => e.id.replaceAll("_$dateId", "")).toList());
  }

  // ---- Show Loading Dialog ----
  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      ),
    );
  }

  void _hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // ---- Result Dialog ----
  Future<void> _showResultDialog(
    BuildContext context, {
    required bool success,
    String? message,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Text(
              success ? "Validación correcta" : "Validación fallida",
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: null,
            ),
          ],
        ),
        content: Text(
          message ??
              (success
                  ? "La imagen coincide con el reto 🎉"
                  : "La foto no contiene el objeto esperado para este reto."),
          softWrap: true,
          overflow: TextOverflow.visible,
          maxLines: null,
        ),
        actions: [
          TextButton(
            child: const Text("Aceptar"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  // ---- CAMERA (WEB) ----
  Future<bool> _validateWithWebcam(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WebcamCaptureWeb()),
    );

    if (result != null && result is Uint8List) {
      lastCapturedBytes = result;
      return true;
    }
    return false;
  }

  // ---- MOBILE MOCK ----
  Future<bool> _validateWithMobile() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5ED),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("daily_tasks")
            .orderBy("points", descending: true)
            .snapshots(),
        builder: (context, taskSnapshot) {
          if (!taskSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = taskSnapshot.data!.docs
              .map((doc) => DailyTask.fromMap(doc.id, doc.data()))
              .toList();

          return StreamBuilder<List<String>>(
            stream: getCompletedTodayStream(),
            builder: (context, completedSnap) {
              final completedToday = completedSnap.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final isCompleted = completedToday.contains(task.id);

                  return _taskCard(task, isCompleted);
                },
              );
            },
          );
        },
      ),
    );
  }

  // --------------------------------------------------------
  // CARD REDISEÑADA — estilo eco profesional
  // --------------------------------------------------------

  Widget _taskCard(DailyTask task, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Header con icono y titulo ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isCompleted
                          ? Colors.green.shade300
                          : Colors.green.shade600)
                      .withOpacity(0.85),
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E4631),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      maxLines: null,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ---- Badges (puntos y gramos) ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _badge(
                icon: Icons.star,
                text: "+${task.points} pts",
                color: const Color(0xFF4CAF50),
              ),
              _badge(
                icon: Icons.water_drop,
                text: "${task.grams} g evitados",
                color: const Color(0xFF009688),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ---- Botón de validar ----
          _validateButton(task, isCompleted),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // BADGE REDISEÑADO
  // --------------------------------------------------------

  Widget _badge({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            softWrap: true,
            overflow: TextOverflow.visible,
            maxLines: null,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // BOTÓN VALIDAR
  // --------------------------------------------------------

  Widget _validateButton(DailyTask task, bool isCompleted) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isCompleted
            ? null
            : () async {
                final isWeb = identical(0, 0.0);

                // 1. Open Camera
                final validImage = isWeb
                    ? await _validateWithWebcam(context)
                    : await _validateWithMobile();

                if (!validImage || lastCapturedBytes == null) {
                  _showResultDialog(context,
                      success: false, message: "No se tomó ninguna foto.");
                  return;
                }

                // 2. Loading
                _showLoading(context);

                // 3. IA Validation
                final aiResult =
                    await ImageAIValidator().validateImageFlexible(
                  imageBytes: lastCapturedBytes!,
                  expectedLabel:
                      task.expectedObject ?? task.title.toLowerCase(),
                );

                _hideLoading(context);

                if (!aiResult) {
                  _showResultDialog(context,
                      success: false,
                      message:
                          "La foto no coincide con lo solicitado para este reto.");
                  return;
                }

                // 4. Complete task
                final ok = await taskService.completeTask(uid: uid, task: task);

                _showResultDialog(
                  context,
                  success: ok,
                  message: ok
                      ? "¡Reto completado correctamente! 🎉"
                      : "Ya completaste este reto hoy.",
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isCompleted ? Colors.grey.shade400 : const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          isCompleted ? "Completado ✓" : "Validar con foto",
          softWrap: true,
          overflow: TextOverflow.visible,
          maxLines: null,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
