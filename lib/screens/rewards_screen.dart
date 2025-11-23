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
        backgroundColor: const Color(0xFFF3F5ED),

        body: Column(
          children: [
            const SizedBox(height: 22),

            // -------- TÍTULO PRINCIPAL --------
            
            const SizedBox(height: 6),
            Text(
              "Canjea tus puntos por recompensas sostenibles",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 18),

            // -------- TABS REDISEÑADAS --------
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const TabBar(
                indicatorColor: Color(0xFF2E7D32),
                labelColor: Color(0xFF2E7D32),
                unselectedLabelColor: Colors.black54,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: "Disponibles"),
                  Tab(text: "Mis premios"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: TabBarView(
                children: [
                  _availableRewardsTab(context, uid, rewardService),
                  _redeemedRewardsTab(uid),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  //  TAB 1 — PREMIOS DISPONIBLES
  // ----------------------------------------------------------------------
  Widget _availableRewardsTab(
    BuildContext context,
    String uid,
    RewardService rewardService,
  ) {
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
                  "No hay premios disponibles por ahora 🌿",
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

  // ----------------------------------------------------------------------
  //  CARD DE PREMIO ESTILO ECO
  // ----------------------------------------------------------------------
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

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
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
      padding: const EdgeInsets.all(18),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------- HEADER ICONO --------
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2E7D32),
                ),
                child: const Icon(Icons.card_giftcard,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reward.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E4631),
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
              height: 1.4,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _ecoBadge(Icons.star, "${reward.costPoints} pts",
                  const Color(0xFF2E7D32)),
              const SizedBox(width: 10),
              _ecoBadge(Icons.inventory_2, "Stock: ${reward.stock}",
                  const Color(0xFF00897B)),
            ],
          ),

          if (!hasPoints && hasStock) ...[
            const SizedBox(height: 8),
            Text(
              "Te faltan ${reward.costPoints - userPoints} puntos.",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.redAccent,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // -------- BOTÓN CANJEAR --------
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canRedeem
                  ? () async {
                      final result = await rewardService.redeemReward(
                        uid: uid,
                        reward: reward,
                      );

                      final isOk = result == "ok";

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isOk
                                ? "🎉 Premio canjeado con éxito"
                                : "❌ $result",
                          ),
                          backgroundColor: isOk ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: canRedeem
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade400,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                canRedeem
                    ? "Canjear premio"
                    : (!hasStock
                        ? "Sin stock"
                        : "Puntos insuficientes"),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  //  TAB 2 — PREMIOS CANJEADOS
  // ----------------------------------------------------------------------
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
              "Aún no has canjeado premios 🌱",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final d = docs[index].data() as Map<String, dynamic>;
            final ts = d["date"] as Timestamp?;
            final date = ts?.toDate();
            final dateStr = date != null
                ? "${date.day}/${date.month}/${date.year}"
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
                  const Icon(Icons.card_giftcard,
                      color: Color(0xFF2E7D32), size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${d["title"]}\n"
                      "${d["costPoints"]} pts\n"
                      "Canjeado el: $dateStr",
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

  // ----------------------------------------------------------------------
  //  BADGE ESTILO ECO
  // ----------------------------------------------------------------------
  Widget _ecoBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.15),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
