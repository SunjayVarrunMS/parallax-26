// starts the app: loads saved data, then shows the router with the light or dark theme

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'data.dart';
import 'router.dart';
import 'store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // paths look like /events instead of /#/events
  usePathUrlStrategy();
  await initStore();
  loadTheme();
  runApp(const ParallaxApp());
}

class ParallaxApp extends StatelessWidget {
  const ParallaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    // rebuild the whole app when the theme button is pressed
    return ValueListenableBuilder<String>(
      valueListenable: themeNotifier,
      builder: (context, theme, child) {
        return MaterialApp.router(
          title: festival.edition,
          routerConfig: router,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: theme == 'light' ? ThemeMode.light : ThemeMode.dark,
        );
      },
    );
  }
}
