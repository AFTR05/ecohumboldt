import 'package:eco_humboldt_go/screens/main/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:eco_humboldt_go/screens/main/home_screen.dart';
import 'package:eco_humboldt_go/screens/main/tasks/daily_task_screen.dart';
import 'package:eco_humboldt_go/screens/rewards_screen.dart';
import 'package:eco_humboldt_go/screens/main/tasks/leaderboard_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    DailyTasksScreen(),
    RewardsScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey.shade500,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Inicio",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco),
              label: "Retos",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              label: "Premios",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard),
              label: "Ranking",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Perfil",
            ),
          ],
        ),
      ),
    );
  }
}
