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

  bool _isLoading = false;

  bool _isValidInstitutionalEmail(String email) {
    return email.endsWith('@cue.edu.co') ||
        email.endsWith('@unihumboldt.edu.co');
  }

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

                      // NOMBRE
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

                      // IDENTIFICACIÓN
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

                      // EMAIL
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

                      // PASSWORD
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

                      // BOTÓN REGISTRO
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

                                // VALIDAR EMAIL INSTITUCIONAL
                                if (!_isValidInstitutionalEmail(email)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Correo inválido. Debe ser @cue.edu.co o @unihumboldt.edu.co'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() => _isLoading = true);

                                try {
                                  await authService.registerUser(
                                    email,
                                    _passwordController.text.trim(),
                                    _nameController.text.trim(),
                                    _idController.text.trim(),
                                  );

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Usuario registrado con éxito 🎉'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
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
}
