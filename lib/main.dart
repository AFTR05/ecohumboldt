import 'package:eco_humboldt_go/screens/main_navigation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const EcoHumboldtGO());
}

class EcoHumboldtGO extends StatelessWidget {
  const EcoHumboldtGO({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Servicio de auth
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),

        // 🔥 StreamProvider con el estado de autenticación
        StreamProvider<User?>(
          create: (context) =>
              context.read<AuthService>().userChanges, // <-- STREAM
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Eco-Humboldt GO',
        theme: ThemeData(primarySwatch: Colors.green),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Leemos el User? que viene del StreamProvider
    final user = context.watch<User?>();

    if (user != null) {
      return const MainNavigation();
    } else {
      return const LoginScreen();
    }
  }
}
