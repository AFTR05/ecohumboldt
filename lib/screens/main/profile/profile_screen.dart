import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_humboldt_go/models/user_model.dart';
import 'package:eco_humboldt_go/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Mi Perfil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("users").doc(uid).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final user = AppUser.fromMap(uid, data);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                // FOTO Y NOMBRE
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.green.shade200,
                  backgroundImage: user.avatarUrl.isNotEmpty
                      ? NetworkImage(user.avatarUrl)
                      : null,
                  child: user.avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 55, color: Colors.white)
                      : null,
                ),

                const SizedBox(height: 14),

                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),

                Text(
                  user.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),

                const SizedBox(height: 25),

                // INFORMACIÓN PERSONAL
                _sectionTitle("Datos Personales"),

                _infoTile("Nombre", user.fullName, Icons.person),
                _infoTile("Documento", "${user.idType} - ${user.idNumber}", Icons.badge),
                _infoTile("Facultad", user.faculty, Icons.school),

                const SizedBox(height: 25),

                // INFORMACIÓN DE PROGRESO
                _sectionTitle("Mi Progreso"),

                _infoTile("Puntos", "${user.points} pts", Icons.star),
                _infoTile("Gramos ahorrados", "${user.gramsSaved} g", Icons.eco),
                _infoTile("Racha", "${user.streak} días", Icons.local_fire_department),

                const SizedBox(height: 30),

                // BOTÓN EDITAR PERFIL
                _primaryButton(
                  icon: Icons.edit,
                  text: "Editar información personal",
                  color: Colors.green.shade700,
                  onTap: () => _openEditProfile(context, user),
                ),

                const SizedBox(height: 14),

                // BOTÓN CAMBIAR CONTRASEÑA
                _primaryButton(
                  icon: Icons.lock,
                  text: "Cambiar contraseña",
                  color: Colors.teal.shade600,
                  onTap: () => _changePassword(context, user.email),
                ),

                const SizedBox(height: 14),

                // BOTÓN CERRAR SESIÓN
                _primaryButton(
                  icon: Icons.logout,
                  text: "Cerrar sesión",
                  color: Colors.red.shade400,
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
        },
      ),
    );
  }

  // ───────────────────────────────────────────────
  //   WIDGETS REUTILIZABLES
  // ───────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  //   FUNCIONES: EDITAR PERFIL
  // ───────────────────────────────────────────────

  void _openEditProfile(BuildContext context, AppUser user) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final idCtrl = TextEditingController(text: user.idNumber);

    String idType = user.idType;
    String faculty = user.faculty;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Editar información"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Nombre completo"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(labelText: "Número de documento"),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField(
              value: idType,
              items: const [
                DropdownMenuItem(value: "Cédula de Ciudadanía", child: Text("Cédula de Ciudadanía")),
                DropdownMenuItem(value: "Tarjeta de Identidad", child: Text("Tarjeta de Identidad")),
                DropdownMenuItem(value: "Pasaporte", child: Text("Pasaporte")),
              ],
              decoration: const InputDecoration(labelText: "Tipo de documento"),
              onChanged: (v) => idType = v as String,
            ),


            const SizedBox(height: 10),

            DropdownButtonFormField(
              value: faculty,
              items: const [
                DropdownMenuItem(value: "Ingenierías", child: Text("Ingenierías")),
                DropdownMenuItem(value: "Medicina", child: Text("Medicina")),
                DropdownMenuItem(value: "Ciencias Básicas", child: Text("Ciencias Básicas")),
                DropdownMenuItem(value: "Derecho", child: Text("Derecho")),
                DropdownMenuItem(value: "Veterinaria", child: Text("Veterinaria")),
                DropdownMenuItem(value: "Psicología", child: Text("Psicología")),
              ],
              decoration: const InputDecoration(labelText: "Facultad"),
              onChanged: (v) => faculty = v as String,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            onPressed: () {
              FirebaseFirestore.instance.collection("users").doc(user.uid).update({
                "fullName": nameCtrl.text.trim(),
                "idNumber": idCtrl.text.trim(),
                "idType": idType,
                "faculty": faculty,
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  //   CAMBIAR CONTRASEÑA
  // ───────────────────────────────────────────────

  void _changePassword(BuildContext context, String email) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Cambiar contraseña"),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Nueva contraseña"),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.currentUser!.updatePassword(ctrl.text.trim());

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Contraseña actualizada"),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: const Text("Actualizar"),
          ),
        ],
      ),
    );
  }
}
