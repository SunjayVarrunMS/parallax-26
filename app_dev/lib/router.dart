// every screen and its address

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/campus_guide_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/events_screen.dart';
import 'screens/help_screen.dart';
import 'screens/home_screen.dart';
import 'screens/merch_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/register_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/sponsors_screen.dart';
import 'screens/workshops_screen.dart';
import 'store.dart';

// wraps a screen so it starts fresh when "Reset demo data" is pressed
Widget _reloadable(Widget screen) {
  return ValueListenableBuilder<int>(
    valueListenable: reloadCount,
    builder: (context, count, child) {
      return KeyedSubtree(key: ValueKey<int>(count), child: screen);
    },
  );
}

final GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => _reloadable(const HomeScreen())),
    GoRoute(path: '/events', builder: (context, state) => _reloadable(const EventsScreen())),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        // /register?event=capture-the-flag picks that event for you
        return _reloadable(RegisterScreen(eventId: state.uri.queryParameters['event']));
      },
    ),
    GoRoute(path: '/schedule', builder: (context, state) => _reloadable(const ScheduleScreen())),
    GoRoute(path: '/campus-guide', builder: (context, state) => _reloadable(const CampusGuideScreen())),
    GoRoute(path: '/sponsors', builder: (context, state) => _reloadable(const SponsorsScreen())),
    GoRoute(path: '/workshops', builder: (context, state) => _reloadable(const WorkshopsScreen())),
    GoRoute(path: '/merch', builder: (context, state) => _reloadable(const MerchScreen())),
    GoRoute(path: '/cart', builder: (context, state) => _reloadable(const CartScreen())),
    GoRoute(path: '/my-bookings', builder: (context, state) => _reloadable(const MyBookingsScreen())),
    GoRoute(path: '/help', builder: (context, state) => _reloadable(const HelpScreen())),
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);
