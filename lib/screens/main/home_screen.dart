import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_humboldt_go/models/user_model.dart';
import 'package:eco_humboldt_go/screens/auth/login_screen.dart';
import 'package:eco_humboldt_go/screens/main/tasks/daily_task_screen.dart';
import 'package:eco_humboldt_go/screens/main/tasks/leaderboard_screen.dart';
import 'package:eco_humboldt_go/screens/main/tasks/points_history_screen.dart';
import 'package:eco_humboldt_go/screens/rewards_screen.dart';
import 'package:eco_humboldt_go/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<AppUser?> _getUserStream() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots()
        .map((snap) => snap.exists ? AppUser.fromMap(snap.id, snap.data()!) : null);
  }

  Stream<int> _getDailyProgressStream() {
    final today = DateTime.now();
    final dateId = "${today.year}-${today.month}-${today.day}";
    final tasksStream = FirebaseFirestore.instance.collection("daily_tasks").snapshots();

    return tasksStream.asyncMap((totalSnap) async {
      final total = totalSnap.docs.length;
      final completedSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("completed_tasks")
          .get();

      final completedToday =
          completedSnap.docs.where((d) => d.id.contains(dateId)).length;

      if (total == 0) return 0;
      return ((completedToday / total) * 100).round();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;

    double cardPadding = isMobile ? 18 : 24;
    double cardRadius = isMobile ? 18 : 22;
    double cardSpacing = isMobile ? 18 : 26;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: const Text(
          "Eco-Humboldt GO",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<AppUser?>(
        stream: _getUserStream(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snap.data!;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 18 : 30,
                  vertical: 26,
                ),
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      height: isMobile ? 90 : 120,
                    ),

                    const SizedBox(height: 20),

                    // ---------------------- PUNTOS -----------------------
                    _pointsCard(
                      points: user.points,
                      padding: cardPadding,
                      radius: cardRadius,
                    ),

                    SizedBox(height: cardSpacing),

                    // ---------------------- PROGRESO ---------------------
                    StreamBuilder<int>(
                      stream: _getDailyProgressStream(),
                      builder: (c, progSnap) {
                        final progress = progSnap.data ?? 0;
                        return _progressCard(
                          progress: progress,
                          padding: cardPadding,
                          radius: cardRadius,
                        );
                      },
                    ),

                    SizedBox(height: cardSpacing + 10),

                    // ------------------ MENÚ RESPONSIVO -------------------
                    LayoutBuilder(
                      builder: (_, constraints) {
                        int columns = constraints.maxWidth < 500 ? 2 : 4;

                        return GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: columns,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: 1,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _menuCard(
                              icon: Icons.history,
                              label: "Historial",
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PointsHistoryScreen()),
                              ),
                            ),
                            _menuCard(
                              icon: Icons.leaderboard,
                              label: "Ranking",
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                              ),
                            ),
                            _menuCard(
                              icon: Icons.card_giftcard,
                              label: "Recompensas",
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RewardsScreen()),
                              ),
                            ),
                            _menuCard(
                              icon: Icons.eco,
                              label: "Retos",
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const DailyTasksScreen()),
                              ),
                            ),
                            _menuCard(
                              icon: Icons.logout,
                              label: "Salir",
                              onTap: () async {
                                await authService.signOut();
                                if (!mounted) return;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (_) => false,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      "🌿 Cada pequeño gesto ayuda a salvar el planeta 🌎",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================= CARD PUNTOS =============================

  Widget _pointsCard({
    required int points,
    required double padding,
    required double radius,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Puntos totales",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            "$points 🌿",
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  // ============================= CARD PROGRESO =============================

  Widget _progressCard({
    required int progress,
    required double padding,
    required double radius,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Progreso diario",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey.shade300,
              minHeight: 10,
              color: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$progress% completado",
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================= MENU CARD =============================

  Widget _menuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
