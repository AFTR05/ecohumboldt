import 'package:eco_humboldt_go/models/user_model.dart';
import 'package:eco_humboldt_go/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final userService = UserService();
  int myPosition = -1;
  AppUser? myUser;

  @override
  void initState() {
    super.initState();
    _loadMyData();
  }

  Future<void> _loadMyData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    myPosition = await userService.getUserPosition(uid);
    myUser = await userService.getUserById(uid);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2E7D32),
        centerTitle: true,
        title: const Text(
          "Ranking de Exploradores",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),

      body: StreamBuilder<List<AppUser>>(
        stream: userService.getTop10(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!;
          if (users.isEmpty) return const Center(child: Text("Sin jugadores aún"));

          // 3 primeros para la tarima
          final first = users.length > 0 ? users[0] : null;
          final second = users.length > 1 ? users[1] : null;
          final third = users.length > 2 ? users[2] : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // ---------------------------------------------------------
                // PODIUM KAHOOT
                // ---------------------------------------------------------
                SizedBox(
                  height: isMobile ? 280 : 350,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Tarima
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _podiumBase(height: 90, color: Colors.grey.shade400),
                          const SizedBox(width: 20),
                          _podiumBase(height: 130, color: Colors.amber.shade400),
                          const SizedBox(width: 20),
                          _podiumBase(height: 70, color: Colors.brown.shade300),
                        ],
                      ),

                      // AVATAR 2
                      if (second != null)
                        Positioned(
                          left: size.width * 0.18,
                          bottom: 110,
                          child: _podiumPlayer(
                            user: second,
                            position: 2,
                            size: isMobile ? 85 : 110,
                            medal: "🥈",
                          ),
                        ),

                      // AVATAR 1
                      if (first != null)
                        Positioned(
                          bottom: 140,
                          child: _podiumPlayer(
                            user: first,
                            position: 1,
                            size: isMobile ? 105 : 130,
                            medal: "🥇",
                          ),
                        ),

                      // AVATAR 3
                      if (third != null)
                        Positioned(
                          right: size.width * 0.18,
                          bottom: 100,
                          child: _podiumPlayer(
                            user: third,
                            position: 3,
                            size: isMobile ? 80 : 100,
                            medal: "🥉",
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ---------------------------------------------------------
                // LISTA NORMAL (DEL 4 EN ADELANTE)
                // ---------------------------------------------------------
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length > 3 ? users.length - 3 : 0,
                    itemBuilder: (_, i) {
                      final user = users[i + 3];
                      return _rankingTile(
                      position: i + 4,
                      user: user,
                      highlight: false,
                    );
                  },
                ),

                const SizedBox(height: 30),

                // ---------------------------------------------------------
                // MI POSICIÓN
                // ---------------------------------------------------------
                if (myUser != null)
                  Column(
                    children: [
                      const Divider(),
                      const Text(
                        "Tu posición",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _rankingTile(
                        position: myPosition,
                        user: myUser!,
                        highlight: true,
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------
  // TARIMA
  // ---------------------------------------------------------
  Widget _podiumBase({required double height, required Color color}) {
    return Container(
      width: 80,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // ---------------------------------------------------------
  // JUGADOR ARRIBA DE LA TARIMA
  // ---------------------------------------------------------
  Widget _podiumPlayer({
    required AppUser user,
    required int position,
    required double size,
    required String medal,
  }) {
    return Column(
      children: [
        Text(
          medal,
          style: const TextStyle(fontSize: 40),
        ),
        const SizedBox(height: 4),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: user.avatarUrl.isNotEmpty
                  ? NetworkImage(user.avatarUrl)
                  : null,
              child: user.avatarUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.green, size: 40)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          user.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF1B5E20),
          ),
        ),
        Text(
          "${user.points} pts",
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // TILE NORMAL
  // ---------------------------------------------------------
  Widget _rankingTile({
    required int position,
    required AppUser user,
    required bool highlight,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlight ? Colors.green.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: highlight ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Text(
            "$position",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 12),

          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.green.shade600,
            backgroundImage:
                user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
            child: user.avatarUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              user.fullName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1B5E20),
              ),
            ),
          ),

          Text(
            "${user.points} pts",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
