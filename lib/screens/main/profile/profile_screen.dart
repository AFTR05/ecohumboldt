import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_humboldt_go/models/user_model.dart';
import 'package:eco_humboldt_go/screens/auth/login_screen.dart';
import 'package:eco_humboldt_go/screens/main/profile/edit_profile_screen.dart';
import 'package:eco_humboldt_go/screens/main/tasks/points_history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5ED),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("users").doc(uid).snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final user = AppUser.fromMap(uid, data);

          return SingleChildScrollView(
            child: Column(
              children: [
                _header(user),
                const SizedBox(height: 20),
                _statsSection(user),
                const SizedBox(height: 25),
                _infoSection(user),
                const SizedBox(height: 25),
                _actionsSection(context, user),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // HEADER
  // ----------------------------------------------------------
  Widget _header(AppUser user) {
    return Stack(
      children: [
        Container(
          height: 210,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
        ),

        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.white, Colors.white70],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.green.shade100,
                  backgroundImage: user.avatarUrl.isNotEmpty
                      ? NetworkImage(user.avatarUrl)
                      : null,
                  child: user.avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 58, color: Colors.green)
                      : null,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                user.fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // STATS
  // ----------------------------------------------------------
  Widget _statsSection(AppUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _statCard("Puntos", "${user.points}", Icons.star, const Color(0xFF2E7D32))),
          const SizedBox(width: 12),
          Expanded(child: _statCard("Racha", "${user.streak} días", Icons.local_fire_department, Colors.orange)),
          const SizedBox(width: 12),
          Expanded(child: _statCard("Gramos", "${user.gramsSaved} g", Icons.eco, Colors.teal)),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // INFO — FACULTY RESPONSIVE
  // ----------------------------------------------------------
  Widget _infoSection(AppUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _sectionTitle("Información Personal"),
          _infoTile("Nombre", user.fullName, Icons.person),
          _infoTile("Documento", "${user.idNumber}", Icons.badge),
          _infoTile("Facultad", user.faculty, Icons.school), // ← tiene responsive
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B5E20),
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          // ------------- RESPONSIVE FACULTY (Y TODOS LOS VALORES) -------------
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // ACTIONS
  // ----------------------------------------------------------
  Widget _actionsSection(BuildContext context, AppUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _actionButton(
            icon: Icons.history,
            text: "Historial de puntos",
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PointsHistoryScreen()),
              );
            },
          ),

          _actionButton(
            icon: Icons.edit,
            text: "Editar información personal",
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
              );
            },
          ),

          _actionButton(
            icon: Icons.lock,
            text: "Cambiar contraseña",
            color: Colors.teal,
            onTap: () => _changePassword(context),
          ),

          _actionButton(
            icon: Icons.logout,
            text: "Cerrar sesión",
            color: Colors.red,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: color.withOpacity(0.5), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // CHANGE PASSWORD MODAL
  // ----------------------------------------------------------
  void _changePassword(BuildContext context) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.lock, color: Colors.teal, size: 26),
            ),
            const SizedBox(width: 12),
            const Text(
              "Cambiar contraseña",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Nueva contraseña",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser!.updatePassword(ctrl.text.trim());

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Contraseña actualizada correctamente ✓"),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Actualizar"),
          ),
        ],
      ),
    );
  }
}
