import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_humboldt_go/models/user_model.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final AppUser user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController idCtrl;

  String? idType;
  String? faculty;

  final List<String> idTypes = const [
    "Cédula de Ciudadanía",
    "Tarjeta de Identidad",
    "Pasaporte",
  ];

  final List<String> faculties = const [
    "Administración de Empresas",
    "Administrativo",
    "Derecho",
    "Docente",
    "Enfermería",
    "Ingeniería Industrial",
    "Ingeniería de Software",
    "Ingeniería Civil",
    "Marketing Digital & comunicación estratégica",
    "Medicina",
    "Medicina Veterinaria y zootecnia",
    "Psicología",
    "Tecnología en gestión del turismo cultural y de la naturaleza",
  ];

  bool saving = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.user.fullName);
    idCtrl = TextEditingController(text: widget.user.idNumber);
    idType = widget.user.idType;
    faculty = widget.user.faculty;

    if (!faculties.contains(faculty)) {
      faculty = faculties.first;
    }
    if (!idTypes.contains(idType)) {
      idType = idTypes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxWidth = 700; // web-friendly card width

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5ED),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Editar Perfil",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const SizedBox(height: 10),

                _sectionTitle("Información básica"),

                _inputCard(
                  child: TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nombre completo",
                    ),
                  ),
                ),

                _inputCard(
                  child: DropdownButtonFormField(
                    value: idType,
                    decoration: const InputDecoration(labelText: "Tipo de documento"),
                    items: idTypes
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => idType = v),
                  ),
                ),

                _inputCard(
                  child: TextField(
                    controller: idCtrl,
                    decoration: const InputDecoration(
                      labelText: "Número de documento",
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                _sectionTitle("Información académica"),

                _inputCard(
                  child: DropdownButtonFormField(
                    value: faculty,
                    decoration: const InputDecoration(labelText: "Programa / Facultad"),
                    items: faculties
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => faculty = v),
                  ),
                ),

                const SizedBox(height: 30),

                _saveButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  ESTÉTICA DE SECCIONES
  // ---------------------------------------------------------------------------
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1B5E20),
        ),
      ),
    );
  }

  // Tarjeta contenedora de inputs
  Widget _inputCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // BOTÓN GUARDAR
  // ---------------------------------------------------------------------------
  Widget _saveButton(BuildContext context) {
    return GestureDetector(
      onTap: saving ? null : () => _saveChanges(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: saving ? Colors.grey : const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  "Guardar cambios",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LÓGICA: GUARDAR CAMBIOS
  // ---------------------------------------------------------------------------
  Future<void> _saveChanges(BuildContext context) async {
    setState(() => saving = true);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.user.uid)
          .update({
        "fullName": nameCtrl.text.trim(),
        "idNumber": idCtrl.text.trim(),
        "idType": idType,
        "faculty": faculty,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Perfil actualizado correctamente ✓"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => saving = false);
  }
}
