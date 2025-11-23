import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Image.asset(
                      'assets/images/logo.png',
                      height: size.width < 600 ? 90 : 120,
                    ),
                    const SizedBox(height: 15),

                    const Text(
                      "Recuperar contraseña",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      "Ingresa tu correo institucional y te enviaremos un enlace para restablecer tu contraseña.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 25),

                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Correo institucional",
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              final email = _emailController.text.trim();

                              if (email.isEmpty ||
                                  (!email.endsWith("@cue.edu.co") &&
                                      !email.endsWith("@unihumboldt.edu.co"))) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Ingresa un correo institucional válido."),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }

                              setState(() => _isLoading = true);

                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(email: email);

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Correo enviado. Revisa tu bandeja de entrada 📩"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }

                                Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }

                              setState(() => _isLoading = false);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              minimumSize:
                                  const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Enviar enlace",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Volver",
                        style: TextStyle(
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
