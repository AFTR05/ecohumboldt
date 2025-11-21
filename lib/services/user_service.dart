import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection("users");

  /// Obtener los top 10 usuarios
  Stream<List<AppUser>> getTop10() {
    return usersRef
        .orderBy("points", descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Obtener TODOS los usuarios para calcular posición
  Future<List<AppUser>> getAllUsersOrdered() async {
    final snapshot = await usersRef
        .orderBy("points", descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Obtener la posición de un usuario (1 = top 1)
  Future<int> getUserPosition(String uid) async {
    final users = await getAllUsersOrdered();

    final index = users.indexWhere((u) => u.uid == uid);

    return index == -1 ? -1 : index + 1;
  }

  /// Obtener tus propios datos con puntos
  Future<AppUser?> getUserById(String uid) async {
    final doc = await usersRef.doc(uid).get();

    if (!doc.exists) return null;

    return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
