import 'package:eco_humboldt_go/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  String? _selectedIdType;
  String? _selectedFaculty;

  bool _isLoading = false;

  bool _isValidInstitutionalEmail(String email) {
    return email.endsWith('@cue.edu.co') ||
        email.endsWith('@unihumboldt.edu.co');
  }

  final List<String> idTypes = [
    "Cédula de Ciudadanía",
    "Tarjeta de Identidad",
    "Pasaporte",
    "Cédula de Extranjería",
    "Otro",
  ];

  final List<String> faculties = [
    "Administración de Empresas",
    "Administrativo",
    "Derecho",
    "Docente",
    "Enfermería"
    "Ingeniería Industrial",
    "Ingeniería de Software",
    "Ingeniería Civil",
    "Marketing Digital & comunicación estratégica",
    "Medicina",
    "Medicina Veterinaria y zootecnia",
    "Psicología",
    "Tecnología en gestión del turismo cultural y de la naturaleza",
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 8,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset('assets/images/logo.png',
                          height: size.width < 600 ? 90 : 120),

                      const SizedBox(height: 10),
                      const Text(
                        "Registro Eco-Humboldt GO",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32)),
                      ),
                      const SizedBox(height: 20),

                      // ---------------------- NOMBRE ----------------------
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon:
                              const Icon(Icons.person_outline, color: Colors.green),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ------------------- TIPO DE DOCUMENTO -------------------
                      DropdownButtonFormField<String>(
                        value: _selectedIdType,
                        decoration: InputDecoration(
                          labelText: "Tipo de identificación",
                          prefixIcon:
                              const Icon(Icons.credit_card, color: Colors.green),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: idTypes
                            .map((type) =>
                                DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedIdType = v),
                      ),

                      const SizedBox(height: 15),

                      // ---------------------- NÚMERO ID ----------------------
                      TextField(
                        controller: _idController,
                        decoration: InputDecoration(
                          labelText: 'Número de identificación',
                          prefixIcon: const Icon(Icons.badge, color: Colors.green),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 15),

                      // ---------------------- FACULTAD ----------------------
                      DropdownButtonFormField<String>(
                        value: _selectedFaculty,
                        decoration: InputDecoration(
                          labelText: "Programa",
                          prefixIcon:
                              const Icon(Icons.school, color: Colors.green),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: faculties
                            .map((f) =>
                                DropdownMenuItem(value: f, child: Text(f)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedFaculty = v),
                      ),

                      const SizedBox(height: 15),

                      // ---------------------- EMAIL ----------------------
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo institucional',
                          prefixIcon:
                              const Icon(Icons.email_outlined, color: Colors.green),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ---------------------- PASSWORD ----------------------
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon:
                              const Icon(Icons.lock_outline, color: Colors.green),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ---------------------- BOTÓN ----------------------
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () async {
                                final email = _emailController.text.trim();
                                final password =
                                    _passwordController.text.trim();
                                final name = _nameController.text.trim();
                                final id = _idController.text.trim();

                                // ================= VALIDACIONES =================

                                if (name.isEmpty) {
                                  return _alert("El nombre es obligatorio.");
                                }

                                if (_selectedIdType == null) {
                                  return _alert("Selecciona un tipo de documento.");
                                }

                                if (id.isEmpty) {
                                  return _alert("El número de identificación es obligatorio.");
                                }

                                if (_selectedFaculty == null) {
                                  return _alert("Selecciona tu facultad.");
                                }

                                if (!_isValidInstitutionalEmail(email)) {
                                  return _alert(
                                      "El correo debe ser @cue.edu.co o @unihumboldt.edu.co");
                                }

                                if (password.length < 6) {
                                  return _alert("La contraseña debe tener al menos 6 caracteres.");
                                }

                                // =================================================

                                setState(() => _isLoading = true);

                                try {
                                  await authService.registerUser(
                                    email,
                                    password,
                                    name,
                                    id,
                                    idType: _selectedIdType!,
                                    faculty: _selectedFaculty!,
                                  );

                                  if (mounted) {
                                    _alert("Usuario registrado con éxito 🎉",
                                        success: true);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const MainNavigation()),
                                    );

                                  }
                                } catch (e) {
                                  _alert("Error: $e");
                                }

                                setState(() => _isLoading = false);
                              },
                              label: const Text('Registrarme'),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Snackbar bonito
  void _alert(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
  }
}
