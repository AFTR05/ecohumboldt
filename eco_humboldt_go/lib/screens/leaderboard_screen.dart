import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 700;

    final List<Map<String, dynamic>> leaderboard = [
      {"name": "Laura Gómez", "points": 1200, "rank": 1},
      {"name": "Carlos Ramírez", "points": 980, "rank": 2},
      {"name": "Sofía Herrera", "points": 850, "rank": 3},
      {"name": "Andrés López", "points": 720, "rank": 4},
      {"name": "Camila Torres", "points": 600, "rank": 5},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          "Clasificación",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                const Text(
                  "Los más comprometidos con el planeta 🌎",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),

                // 🥇 Top 3 destacados
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: leaderboard.take(3).map((user) {
                    return _topCard(user);
                  }).toList(),
                ),

                const SizedBox(height: 40),
                Divider(color: Colors.grey.shade400),
                const SizedBox(height: 20),

                // 📊 Lista de posiciones
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    children: leaderboard.skip(3).map((user) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade600,
                          child: Text(
                            user["rank"].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user["name"],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Text(
                          "${user["points"]} pts",
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topCard(Map<String, dynamic> user) {
    final rank = user["rank"];
    Color bgColor;
    IconData icon;

    switch (rank) {
      case 1:
        bgColor = Colors.amber.shade600;
        icon = Icons.emoji_events;
        break;
      case 2:
        bgColor = Colors.grey.shade400;
        icon = Icons.emoji_events_outlined;
        break;
      case 3:
        bgColor = Colors.brown.shade400;
        icon = Icons.emoji_events_outlined;
        break;
      default:
        bgColor = Colors.green.shade400;
        icon = Icons.person;
    }

    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: bgColor.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: bgColor, size: 50),
          const SizedBox(height: 10),
          Text(
            user["name"],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
              ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            "${user["points"]} pts",
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
