import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/schedule_screen.dart';
import 'screens/coaches_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const WellnessApp());
}

// Configuration for the routes
final GoRouter _router = GoRouter(
  initialLocation: '/schedule',
  routes: <RouteBase>[
    // This is the shell route that provides the bottom navigation bar
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/schedule',
          builder: (BuildContext context, GoRouterState state) {
            return const ScheduleScreen();
          },
        ),
        GoRoute(
          path: '/coaches',
          builder: (BuildContext context, GoRouterState state) {
            return const CoachesScreen();
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
        ),
      ],
    ),
  ],
);

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wellness Center App',
      // The theme is a bit cleaner this way
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// This is the main widget that contains the Scaffold and BottomNavigationBar
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});
  final Widget child;

  // Helper method to get the current index from the route state
  static int _calculateSelectedIndex(BuildContext context) {
    // Get the current route's location from the GoRouterState
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/coaches')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    return 0; // Default to the first tab
  }

  // Helper method to navigate when an item is tapped
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/schedule');
        break;
      case 1:
        context.go('/coaches');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int index) => _onItemTapped(index, context),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_kabaddi),
            label: 'Coaches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}