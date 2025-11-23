import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_humboldt_go/models/user_model.dart';
import 'package:eco_humboldt_go/services/motivation_ai_service.dart';
import 'package:eco_humboldt_go/services/motivation_cache_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  String? motivationMessage;
  bool generatingMessage = false;

  bool _initializedMotivation = false; // evita llamadas múltiples
  final MotivationCacheService cache = MotivationCacheService();

  @override
  void dispose() {
    generatingMessage = false; // Previene setState después de dispose
    super.dispose();
  }

  // -----------------------------------------------------------
  // STREAM: Usuario
  // -----------------------------------------------------------
  Stream<AppUser?> _getUserStream() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots()
        .map((snap) =>
            snap.exists ? AppUser.fromMap(snap.id, snap.data()!) : null);
  }

  // -----------------------------------------------------------
  // STREAM: Progreso diario
  // -----------------------------------------------------------
  Stream<int> _getProgress() {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return FirebaseFirestore.instance
        .collection("daily_tasks")
        .snapshots()
        .asyncMap((snap) async {
      final total = snap.docs.length;

      final completedSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("completed_tasks")
          .get();

      final doneToday =
          completedSnap.docs.where((d) => d.id.contains(todayStr)).length;

      if (total == 0) return 0;
      return ((doneToday / total) * 100).round();
    });
  }

  // -----------------------------------------------------------
  // IA — cargar desde caché o generar una sola vez
  // -----------------------------------------------------------
  Future<void> _loadOrGenerateMessage(AppUser user) async {
    if (_initializedMotivation) return; // evita loops infinitos

    _initializedMotivation = true;

    // 1. Intentar usar caché local
    final cached = await cache.getMessage();
    if (cached != null) {
      if (!mounted) return;
      setState(() => motivationMessage = cached);
      return;
    }

    // 2. Generar mensaje con IA
    if (!mounted) return;
    setState(() => generatingMessage = true);

    final newMessage = await MotivationAIService()
        .generateMotivation(program: user.faculty, uid: user.uid);

    // Guardar en caché
    await cache.saveMessage(newMessage);

    if (!mounted) return;
    setState(() {
      generatingMessage = false;
      motivationMessage = newMessage;
    });
  }

  // -----------------------------------------------------------
  // BUILD PRINCIPAL
  // -----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5ED),
      body: StreamBuilder<AppUser?>(
        stream: _getUserStream(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snap.data!;

          // Cargar mensaje IA SOLO una vez
          _loadOrGenerateMessage(user);

          return _buildHomeUI(user);
        },
      ),
    );
  }

  // -----------------------------------------------------------
  // UI COMPLETA
  // -----------------------------------------------------------
  Widget _buildHomeUI(AppUser user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(user),
          const SizedBox(height: 16),
          _buildMotivationSection(),
          const SizedBox(height: 16),

          // ========== TARJETAS ==========
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Fila 1
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        title: "Puntos",
                        value: "${user.points}",
                        icon: Icons.eco,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _infoCard(
                        title: "Gramos ahorrados",
                        value: "${user.gramsSaved} g",
                        icon: Icons.recycling,
                        color: const Color(0xFF009688),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Fila 2
                Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<int>(
                        stream: _getProgress(),
                        builder: (_, pSnap) {
                          final progress = pSnap.data ?? 0;
                          return _progressCard(progress);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: _streakCard(user.streak)),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // HEADER
  // -----------------------------------------------------------
  Widget _buildHeader(AppUser user) {
    final firstName = user.fullName.split(" ").first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4CAF50).withOpacity(0.15),
            ),
            child: const Icon(Icons.person, color: Color(0xFF4CAF50), size: 26),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hola $firstName 👋",
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E4631),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Resumen ecológico del día",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // SECCIÓN MOTIVACIONAL
  // -----------------------------------------------------------
  Widget _buildMotivationSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB7DEBB)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.flash_on, color: Colors.green.shade700, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: generatingMessage
                ? const Text("Generando frase...", style: TextStyle(fontSize: 14))
                : Text(
                    motivationMessage ?? "Sé parte del cambio.",
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E4631),
                    ),
                  ),
          )
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // TARJETA INFO
  // -----------------------------------------------------------
  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(title,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // TARJETA PROGRESO
  // -----------------------------------------------------------
  Widget _progressCard(int progress) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text("Progreso diario",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            width: 48,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.green.shade600,
                ),
                Center(
                  child: Text(
                    "$progress%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // TARJETA RACHA
  // -----------------------------------------------------------
  Widget _streakCard(int streak) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Column(
        children: [
          const Icon(Icons.local_fire_department,
              color: Colors.deepOrange, size: 26),
          const SizedBox(height: 6),
          const Text("Racha activa",
              style: TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(
            "$streak días",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.deepOrange,
            ),
          ),
        ],
      ),
    );
  }
}
