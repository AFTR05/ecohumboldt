import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_humboldt_go/models/reward_model.dart';

class RewardService {
  final rewardsRef = FirebaseFirestore.instance.collection("rewards");
  final usersRef = FirebaseFirestore.instance.collection("users");

  /// Stream de premios disponibles
  Stream<List<Reward>> getRewards() {
    return rewardsRef.snapshots().map((snap) {
      return snap.docs
          .map((doc) => Reward.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Crear premios de ejemplo en la colección "rewards"
  Future<void> createSampleRewards() async {
    final samples = <Reward>[
      Reward(
        id: "botella_reutilizable",
        title: "Botella reutilizable Eco-Humboldt",
        description: "Botella térmica institucional para reducir plásticos.",
        costPoints: 300,
        stock: 20,
        imageUrl: "",
      ),
      Reward(
        id: "bono_cafeteria",
        title: "Bono cafetería sostenible",
        description:
            "Bono para una bebida o snack en la cafetería eco-amigable.",
        costPoints: 200,
        stock: 30,
        imageUrl: "",
      ),
      Reward(
        id: "sticker_eco",
        title: "Pack de stickers ecológicos",
        description: "Stickers ecológicos para tu portátil o botella.",
        costPoints: 100,
        stock: 50,
        imageUrl: "",
      ),
      Reward(
        id: "camiseta_eco",
        title: "Camiseta Eco-Humboldt",
        description: "Camiseta oficial del programa Eco-Humboldt GO.",
        costPoints: 500,
        stock: 10,
        imageUrl: "",
      ),
    ];

    for (final reward in samples) {
      final docRef = rewardsRef.doc(reward.id);
      final doc = await docRef.get();

      // Si ya existe, no lo sobreescribimos
      if (!doc.exists) {
        await docRef.set(reward.toMap());
      }
    }
  }

  /// Canjear un premio
  Future<String> redeemReward({
    required String uid,
    required Reward reward,
  }) async {
    final userRef = usersRef.doc(uid);
    final rewardRef = rewardsRef.doc(reward.id);
    final redeemRef = userRef.collection("redeemed_rewards");

    return FirebaseFirestore.instance.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final rewardSnap = await tx.get(rewardRef);

      if (!userSnap.exists || !rewardSnap.exists) {
        return "Error: datos no encontrados";
      }

      final currentPoints = userSnap.get("points");
      final stock = rewardSnap.get("stock");

      if (stock <= 0) return "Sin stock disponible";
      if (currentPoints < reward.costPoints) {
        return "No tienes puntos suficientes";
      }

      // 1. Descontar puntos al usuario
      tx.update(userRef, {
        "points": currentPoints - reward.costPoints,
      });

      // 2. Reducir stock del premio
      tx.update(rewardRef, {
        "stock": stock - 1,
      });

      // 3. Registrar el canje
      final now = DateTime.now();
      final redeemId = "${now.year}-${now.month}-${now.day}_${reward.id}";

      tx.set(
        redeemRef.doc(redeemId),
        {
          "title": reward.title,
          "costPoints": reward.costPoints,
          "date": Timestamp.now(),
        },
      );

      return "ok";
    });
  }
}
