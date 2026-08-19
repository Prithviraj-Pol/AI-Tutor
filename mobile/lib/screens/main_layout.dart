import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'input_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    InputScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Determine if we should show a sidebar (Desktop/Tablet) or bottom nav (Mobile)
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              backgroundColor: Colors.white,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              extended: MediaQuery.of(context).size.width >= 1000,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text('AI Tutor', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF243B6B))),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: Text('Ask AI')),
                NavigationRailDestination(icon: Icon(Icons.trending_up_outlined), selectedIcon: Icon(Icons.trending_up), label: Text('Progress')),
                NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profile')),
              ],
            ),
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFF7F9FC),
              destinations: [
                const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Color(0xFF243B6B)), label: 'Home'),
                NavigationDestination(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFFFF6B5A), shape: BoxShape.circle),
                    child: const Icon(Icons.auto_awesome, color: Colors.white),
                  ),
                  label: 'Ask AI',
                ),
                const NavigationDestination(icon: Icon(Icons.trending_up_outlined), selectedIcon: Icon(Icons.trending_up, color: Color(0xFF243B6B)), label: 'Progress'),
                const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Color(0xFF243B6B)), label: 'Profile'),
              ],
            ),
    );
  }
}
