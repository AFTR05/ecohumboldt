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

  // ---- Nice SweetAlert-like dialog ----
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
            Text(success ? "Validación correcta" : "Validación fallida"),
          ],
        ),
        content: Text(
          message ??
              (success
                  ? "La imagen coincide con el reto 🎉"
                  : "La foto no contiene el objeto esperado para este reto."),
          style: const TextStyle(fontSize: 16),
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

  // ---- CAMERA VALIDATION WEB ----
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

  // ---- MOBILE version (mock for now) ----
  Future<bool> _validateWithMobile() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F3),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2E7D32),
        centerTitle: true,
        title: const Text(
          "Retos Diarios",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
      ),

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

                  return _taskCard(task, isCompleted, isMobile);
                },
              );
            },
          );
        },
      ),
    );
  }

  // ---- Task Card ----
  Widget _taskCard(DailyTask task, bool isCompleted, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: isMobile ? 22 : 28,
                  backgroundColor:
                      isCompleted ? Colors.green.shade300 : Colors.green.shade600,
                  child: const Icon(Icons.eco_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.3,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _badge(Icons.star, "+${task.points} pts",
                    const Color(0xFF2E7D32), const Color(0xFF66BB6A)),
                _badge(Icons.water_drop, "${task.grams} g evitados",
                    Colors.teal, Colors.tealAccent),
              ],
            ),

            const SizedBox(height: 16),

            _validateButton(task, isCompleted),
          ],
        ),
      ),
    );
  }

  // ---- Validate Button ----
  Widget _validateButton(DailyTask task, bool isCompleted) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isCompleted
            ? null
            : () async {
                final isWeb = identical(0, 0.0);

                // --- 1. Open Camera ---
                final validImage = isWeb
                    ? await _validateWithWebcam(context)
                    : await _validateWithMobile();

                if (!validImage || lastCapturedBytes == null) {
                  _showResultDialog(context,
                      success: false, message: "No se tomó ninguna foto.");
                  return;
                }

                // --- 2. Loading IA ---
                _showLoading(context);

                // --- 3. Validate IA ---
                final aiResult =
                    await ImageAIValidator().validateImageFlexible(
                  imageBytes: lastCapturedBytes!,
                  expectedLabel:
                      task.expectedObject ?? task.title.toLowerCase(),
                );

                // --- 4. Hide Loader ---
                _hideLoading(context);

                // --- 5. Result ---
                if (!aiResult) {
                  _showResultDialog(context,
                      success: false,
                      message:
                          "La foto no coincide con lo solicitado para este reto.");
                  return;
                }

                // --- 6. Complete Task ---
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isCompleted ? "Completado ✓" : "Validar con foto",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ---- Badge ----
  Widget _badge(IconData icon, String text, Color c1, Color c2) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(colors: [c1, c2]),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
