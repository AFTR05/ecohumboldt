import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_humboldt_go/models/reward_model.dart';
import 'package:eco_humboldt_go/services/reward_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final rewardService = RewardService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F4),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E7D32),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Premios",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Colors.white,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Disponibles"),
              Tab(text: "Mis premios"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _availableRewardsTab(context, uid, rewardService),
            _redeemedRewardsTab(uid),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  TAB 1: PREMIOS DISPONIBLES (con puntos usuario)
  // ─────────────────────────────────────────────
  Widget _availableRewardsTab(
    BuildContext context,
    String uid,
    RewardService rewardService,
  ) {
    // Primero escuchamos los puntos del usuario
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .snapshots(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = userSnap.data!.data() as Map<String, dynamic>?;
        final int userPoints = (data?['points'] ?? 0) as int;

        // Luego escuchamos los premios
        return StreamBuilder<List<Reward>>(
          stream: rewardService.getRewards(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final rewards = snapshot.data!;
            if (rewards.isEmpty) {
              return const Center(
                child: Text(
                  "No hay premios disponibles",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: rewards.length,
              itemBuilder: (context, index) {
                final reward = rewards[index];
                return _rewardCard(
                  context: context,
                  reward: reward,
                  uid: uid,
                  userPoints: userPoints,
                  rewardService: rewardService,
                );
              },
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  CARD DE PREMIO DISPONIBLE
  // ─────────────────────────────────────────────
  Widget _rewardCard({
    required BuildContext context,
    required Reward reward,
    required String uid,
    required int userPoints,
    required RewardService rewardService,
  }) {
    final bool hasStock = reward.stock > 0;
    final bool hasPoints = userPoints >= reward.costPoints;
    final bool canRedeem = hasStock && hasPoints;

    String buttonText;
    if (!hasStock) {
      buttonText = "Sin stock";
    } else if (!hasPoints) {
      buttonText = "Puntos insuficientes";
    } else {
      buttonText = "Canjear premio";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header icono + título
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF2E7D32),
                  child: const Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reward.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              reward.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.3,
                color: Colors.grey.shade800,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                _badge(
                  icon: Icons.star,
                  text: "${reward.costPoints} pts",
                  color1: const Color(0xFF2E7D32),
                  color2: const Color(0xFF66BB6A),
                ),
                const SizedBox(width: 10),
                _badge(
                  icon: Icons.inventory_2_outlined,
                  text: "Stock: ${reward.stock}",
                  color1: Colors.teal,
                  color2: Colors.tealAccent,
                ),
              ],
            ),

            if (!hasPoints && hasStock) ...[
              const SizedBox(height: 8),
              Text(
                "Te faltan ${reward.costPoints - userPoints} puntos para este premio.",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.redAccent,
                ),
              ),
            ],

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canRedeem
                    ? () async {
                        final result = await rewardService.redeemReward(
                          uid: uid,
                          reward: reward,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result == "ok"
                                  ? "🎉 Canjeado con éxito"
                                  : "❌ $result",
                            ),
                            backgroundColor:
                                result == "ok" ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canRedeem ? const Color(0xFF2E7D32) : Colors.grey.shade400,
                  disabledBackgroundColor: Colors.grey.shade400,
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Siempre blanco para que se vea
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  TAB 2: PREMIOS CANJEADOS
  // ─────────────────────────────────────────────
  Widget _redeemedRewardsTab(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("redeemed_rewards")
          .orderBy("date", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "Aún no has canjeado premios.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            final title = data["title"] ?? "Premio";
            final costPoints = data["costPoints"] ?? 0;
            final ts = data["date"] as Timestamp?;
            final date = ts?.toDate();
            final dateStr = date != null
                ? "${date.day.toString().padLeft(2, '0')}/"
                  "${date.month.toString().padLeft(2, '0')}/"
                  "${date.year}"
                : "";

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.card_giftcard,
                    color: Color(0xFF2E7D32),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "$title\n$costPoints pts\nCanjeado el: $dateStr",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  BADGE
  // ─────────────────────────────────────────────
  Widget _badge({
    required IconData icon,
    required String text,
    required Color color1,
    required Color color2,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(colors: [color1, color2]),
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
