import 'package:eco_humboldt_go/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart'; // 👈 IMPORTANTE
// import '../main/home_screen.dart'; // si ya usas MainNavigation esto sobra

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

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
            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // LOGO
                      Image.asset(
                        'assets/images/logo.png',
                        height: size.width < 600 ? 90 : 120,
                      ),

                      const SizedBox(height: 15),
                      const Text(
                        "Eco-Humboldt GO",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Inicia sesión para continuar tu camino verde 🌿",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.black54, fontSize: 15),
                      ),

                      const SizedBox(height: 28),

                      // EMAIL
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.email_outlined, color: Colors.green),
                          labelText: 'Correo institucional',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // CONTRASEÑA
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.lock_outline, color: Colors.green),
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ------------------------------------
                      //     ¿OLVIDASTE TU CONTRASEÑA?
                      // ------------------------------------
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ResetPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "¿Olvidaste tu contraseña?",
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ------------------------------------
                      //        BOTÓN LOGIN
                      // ------------------------------------
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                setState(() => _isLoading = true);

                                final user = await authService.signIn(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );

                                setState(() => _isLoading = false);

                                if (user != null && mounted) {
                                  // Ir al menú principal
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MainNavigation(),
                                    ),
                                  );
                                } else {
                                  // ERROR LOGIN
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Error al iniciar sesión. Verifica tus datos.'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Iniciar sesión',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),

                      const SizedBox(height: 20),

                      // ------------------------------------
                      //        IR A REGISTRO
                      // ------------------------------------
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          "¿No tienes cuenta? Regístrate aquí",
                          style: TextStyle(
                            color: Color(0xFF1B5E20),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
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
