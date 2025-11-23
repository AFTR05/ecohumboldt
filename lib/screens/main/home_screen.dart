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

  bool _initializedMotivation = false; // 👈 evita miles de llamadas
  final MotivationCacheService cache = MotivationCacheService();

  // ---------------- STREAMS ---------------- //

  Stream<AppUser?> _getUserStream() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots()
        .map((snap) =>
            snap.exists ? AppUser.fromMap(snap.id, snap.data()!) : null);
  }

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

  // ---------------- MOTIVACIÓN IA ---------------- //

  Future<void> _loadOrGenerateMessage(AppUser user) async {
    // Si ya existe en RAM
    if (motivationMessage != null) return;

    // Buscar caché local
    final cached = await cache.getMessage();
    if (cached != null) {
      setState(() => motivationMessage = cached);
      return;
    }

    // No existe → generar
    setState(() => generatingMessage = true);

    final newMessage = await MotivationAIService()
        .generateMotivation(program: user.faculty, uid: user.uid);

    await cache.saveMessage(newMessage);

    setState(() {
      generatingMessage = false;
      motivationMessage = newMessage;
    });
  }

  // ---------------- BUILD ---------------- //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2E7D32),
        centerTitle: true,
        title: const Text(
          "Eco-Humboldt GO",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: StreamBuilder<AppUser?>(
        stream: _getUserStream(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snap.data!;

          // 🔥 LLAMAR SOLO UNA VEZ
          if (!_initializedMotivation) {
            _initializedMotivation = true;
            _loadOrGenerateMessage(user);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 15),

                // ------------------ MOTIVACIÓN ------------------
                if (generatingMessage)
                  Column(
                    children: const [
                      CircularProgressIndicator(color: Colors.green),
                      SizedBox(height: 10),
                      Text("Generando tu frase personalizada..."),
                    ],
                  )
                else if (motivationMessage != null)
                  _motivationCard(motivationMessage!),

                const SizedBox(height: 20),

                // ------------------ PUNTOS ------------------
                _statCard(
                  title: "Puntos totales",
                  value: "${user.points} 🌿",
                  icon: Icons.stars,
                ),

                const SizedBox(height: 20),

                // ------------------ PROGRESO ------------------
                StreamBuilder<int>(
                  stream: _getProgress(),
                  builder: (_, pSnap) {
                    final progress = pSnap.data ?? 0;
                    return _progressCard(progress);
                  },
                ),

                const SizedBox(height: 20),

                // ------------------ GRAMOS AHORRADOS ------------------
                _statCard(
                  title: "Gramos ahorrados",
                  value: "${user.gramsSaved} g ♻️",
                  icon: Icons.energy_savings_leaf_rounded,
                ),

                const SizedBox(height: 20),

                // ------------------ RACHA ------------------
                _streakCard(user.streak),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // TARJETAS VISUALES
  // ------------------------------------------------------------

  Widget _motivationCard(String message) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 15, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _progressCard(int progress) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Progreso diario",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 12,
              backgroundColor: Colors.grey.shade300,
              color: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$progress% completado",
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _streakCard(int streak) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Colors.deepOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Racha activa",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              Text(
                "$streak días",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
