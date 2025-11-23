import 'package:eco_humboldt_go/models/user_model.dart';
import 'package:eco_humboldt_go/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5ED),
      body: StreamBuilder<List<AppUser>>(
        stream: userService.getTop10(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(
              child: Text(
                "Aún no hay exploradores 🌱",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final first = users.length > 0 ? users[0] : null;
          final second = users.length > 1 ? users[1] : null;
          final third = users.length > 2 ? users[2] : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                Text(
                  "Ranking global",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Top exploradores que aportan al planeta",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 24),

                // ---------- PODIO TOP 3 (SIN OVERFLOW) ----------
                _podiumRow(
                  first: first,
                  second: second,
                  third: third,
                  isMobile: isMobile,
                ),

                const SizedBox(height: 26),
                Divider(color: Colors.grey.shade400),
                const SizedBox(height: 14),

                // ---------- LISTA DEL 4 AL 10 ----------
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

                const SizedBox(height: 26),

                // ---------- MI POSICIÓN ----------
                if (myUser != null)
                  Column(
                    children: [
                      Divider(color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      const Text(
                        "Tu posición actual",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E4631),
                        ),
                      ),
                      const SizedBox(height: 12),
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

  // ---------------------------------------------------------------------------
  // PODIO TOP 3
  // ---------------------------------------------------------------------------
  Widget _podiumRow({
    required AppUser? first,
    required AppUser? second,
    required AppUser? third,
    required bool isMobile,
  }) {
    if (first == null && second == null && third == null) {
      return const SizedBox();
    }

    final double avatar1 = isMobile ? 86 : 110;
    final double avatar2 = isMobile ? 74 : 92;
    final double avatar3 = isMobile ? 70 : 86;

    final double base1 = isMobile ? 90 : 110;
    final double base2 = isMobile ? 70 : 85;
    final double base3 = isMobile ? 60 : 78;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null)
          _podiumColumn(
            user: second,
            medal: "🥈",
            avatarSize: avatar2,
            baseHeight: base2,
            color: Colors.grey.shade400,
          ),
        if (second != null) const SizedBox(width: 18),
        if (first != null)
          _podiumColumn(
            user: first,
            medal: "🥇",
            avatarSize: avatar1,
            baseHeight: base1,
            color: Colors.amber.shade400,
          ),
        if (third != null) const SizedBox(width: 18),
        if (third != null)
          _podiumColumn(
            user: third,
            medal: "🥉",
            avatarSize: avatar3,
            baseHeight: base3,
            color: Colors.brown.shade300,
          ),
      ],
    );
  }

  Widget _podiumColumn({
    required AppUser user,
    required String medal,
    required double avatarSize,
    required double baseHeight,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(medal, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),

        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: user.avatarUrl.isNotEmpty
                  ? NetworkImage(user.avatarUrl)
                  : null,
              child: user.avatarUrl.isEmpty
                  ? const Icon(Icons.person,
                      size: 40, color: Color(0xFF2E7D32))
                  : null,
            ),
          ),
        ),

        const SizedBox(height: 6),

        SizedBox(
          width: 110,
          child: Text(
            user.fullName,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B5E20),
            ),
          ),
        ),
        Text(
          "${user.points} pts",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          width: 75,
          height: baseHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ITEM DEL RANKING
  // ---------------------------------------------------------------------------
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
        border: Border.all(
          color: highlight ? Colors.green : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
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
            backgroundImage: user.avatarUrl.isNotEmpty
                ? NetworkImage(user.avatarUrl)
                : null,
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
