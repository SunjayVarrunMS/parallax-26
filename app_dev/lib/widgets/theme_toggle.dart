// the [LIGHT] / [DARK] button in the header

import 'package:flutter/material.dart';

import '../theme.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return ValueListenableBuilder<String>(
      valueListenable: themeNotifier,
      builder: (context, theme, child) {
        String text = '[LIGHT]';
        String label = 'Switch to light mode';
        if (theme == 'light') {
          text = '[DARK]';
          label = 'Switch to dark mode';
        }
        return Semantics(
          button: true,
          label: label,
          child: InkWell(
            onTap: toggleTheme,
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10),
              decoration: BoxDecoration(border: Border.all(color: c.lineSoft, width: 2)),
              alignment: Alignment.center,
              child: Text(
                text,
                style: monoStyle(
                  size: compact ? 9.9 : 11.5,
                  weight: FontWeight.w800,
                  color: c.cyan,
                  spacing: compact ? 0 : 0.7,
                  height: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
