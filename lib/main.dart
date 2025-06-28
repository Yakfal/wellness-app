import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'firebase_options.dart';
import 'screens/coach_detail_screen.dart';
import 'services/booking_service.dart';
import 'screens/schedule_screen.dart';
import 'screens/coaches_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/membership_screen.dart'; // <<< Ensure this import is here
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => BookingService(),
      child: const WellnessApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  initialLocation: '/home',
  routes: <RouteBase>[
    GoRoute(
      path: '/auth',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthScreen();
      },
    ),

    // --- THIS IS THE MISSING ROUTE ---
    GoRoute(
      path: '/membership',
      builder: (BuildContext context, GoRouterState state) {
        return const MembershipScreen();
      },
    ),
    // ------------------------------------

    // This ShellRoute handles the main app UI with the bottom nav bar
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNavBar(child: child),
      routes: <RouteBase>[
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/schedule', builder: (context, state) => const ScheduleScreen()),
        GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
        GoRoute(
          path: '/coaches',
          builder: (context, state) => const CoachesScreen(),
          routes: <RouteBase>[
            GoRoute(
              path: 'details/:coachId',
              builder: (context, state) {
                final String coachId = state.pathParameters['coachId']!;
                return CoachDetailScreen(coachId: coachId);
              },
            ),
          ],
        ),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),
    
    GoRoute(
      path: '/add-event',
      builder: (context, state) {
        final selectedDate = state.extra as DateTime;
        return AddEventScreen(selectedDate: selectedDate);
      },
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    final bool loggedIn = user != null;
    final bool loggingIn = state.matchedLocation == '/auth' || state.matchedLocation == '/membership';

    // Allow users to see the auth and membership pages when not logged in
    if (!loggedIn) {
      return loggingIn ? null : '/auth';
    }

    // If a logged-in user tries to go to the auth screen, redirect them away
    if (loggingIn && state.matchedLocation == '/auth') {
      return '/home';
    }

    return null;
  },
);

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Andreasen Center',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007A99)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF333333),
          elevation: 1,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.child});
  final Widget child;
  
  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/schedule')) return 1;
    if (location.startsWith('/dashboard')) return 2;
    if (location.startsWith('/coaches')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0; // Home is now index 0
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/schedule'); break;
      case 2: context.go('/dashboard'); break;
      case 3: context.go('/coaches'); break;
      case 4: context.go('/profile'); break;
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
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.space_dashboard_rounded), label: 'Live Usage'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_kabaddi), label: 'Coaches'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Helper class to make GoRouter listen to Firebase Auth changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}