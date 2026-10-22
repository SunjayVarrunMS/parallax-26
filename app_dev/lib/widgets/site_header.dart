// the header at the top of every screen, and the menu drawer for narrow screens

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data.dart';
import '../theme.dart';
import 'buttons.dart';
import 'panels.dart';
import 'theme_toggle.dart';

class SitePage {
  const SitePage(this.path, this.label);

  final String path;
  final String label;
}

// every screen on the app, in menu order
const List<SitePage> sitePages = [
  SitePage('/', 'Home'),
  SitePage('/events', 'Events'),
  SitePage('/schedule', 'Schedule'),
  SitePage('/register', 'Register'),
  SitePage('/my-bookings', 'My bookings'),
  SitePage('/workshops', 'Workshops'),
  SitePage('/merch', 'Merch'),
  SitePage('/campus-guide', 'Campus guide'),
  SitePage('/sponsors', 'Sponsors'),
  SitePage('/help', 'Help desk'),
  SitePage('/cart', 'Cart'),
];

// the few screens shown in the desktop header
const List<String> primaryPaths = ['/events', '/schedule', '/workshops', '/merch'];

// the PARALLAX '26 logo
class Brand extends StatelessWidget {
  const Brand({super.key});

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    final tiny = MediaQuery.sizeOf(context).width < 420;
    return Semantics(
      button: true,
      label: '${festival.edition} home',
      child: InkWell(
        onTap: () => context.go('/'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!tiny) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                color: c.cyan,
                child: Text(
                  festival.shortName,
                  style: monoStyle(size: 11.5, weight: FontWeight.w800, color: c.onCyan, spacing: 0.5, height: 1.2),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: festival.name),
                  if (!tiny) TextSpan(text: " '26", style: TextStyle(color: c.accent)),
                ],
              ),
              style: displayStyle(size: tiny ? 16.8 : 20.8, color: c.ink, spacing: 0.8, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

class SiteHeader extends StatelessWidget {
  const SiteHeader({super.key, required this.currentPath, required this.onMenuPressed});

  final String currentPath;
  final VoidCallback onMenuPressed;

  Widget _buildNavLink(BuildContext context, PlxColors c, SitePage page) {
    final active = page.path == currentPath;
    return InkWell(
      onTap: () => context.go(page.path),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: active ? c.cyan : Colors.transparent, width: 2),
        ),
        child: Text(
          '${active ? '> ' : ''}${page.label.toUpperCase()}',
          style: monoStyle(
            size: 12,
            weight: FontWeight.w700,
            color: active ? c.cyan : c.ink,
            spacing: 0.7,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width < narrowWidth;
    final tiny = width < 420;

    final actions = <Widget>[
      ThemeToggle(compact: tiny),
      SizedBox(width: tiny ? 4 : 12),
      Tooltip(
        message: 'Cart',
        child: InkWell(
          onTap: () => context.go('/cart'),
          child: Container(
            width: tiny ? 36 : 40,
            height: 40,
            decoration: BoxDecoration(border: Border.all(color: c.lineSoft, width: 2)),
            child: Icon(Icons.shopping_bag_outlined, size: 20, color: c.cyan),
          ),
        ),
      ),
      SizedBox(width: tiny ? 4 : 12),
      PlxButton(
        label: 'Register',
        kind: ButtonKind.ink,
        small: true,
        onPressed: () => context.go('/register'),
      ),
      if (narrow) ...[
        SizedBox(width: tiny ? 4 : 12),
        Tooltip(
          message: 'Open navigation',
          child: InkWell(
            onTap: onMenuPressed,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(border: Border.all(color: c.cyan, width: 2)),
              child: Icon(Icons.menu, size: 24, color: c.cyan),
            ),
          ),
        ),
      ],
    ];

    final gutter = (width * 0.045).clamp(16.0, 80.0);
    return Container(
      height: narrow ? 66 : 74,
      padding: EdgeInsets.symmetric(horizontal: gutter),
      decoration: BoxDecoration(
        color: c.paper,
        border: Border(bottom: BorderSide(color: c.cyan, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: const Brand()),
          ),
          if (!narrow)
            Row(
              children: [
                for (final page in sitePages)
                  if (primaryPaths.contains(page.path)) _buildNavLink(context, c, page),
              ],
            ),
          Row(mainAxisSize: MainAxisSize.min, children: actions),
        ],
      ),
    );
  }
}

// the menu that slides in on narrow screens
class SiteDrawer extends StatelessWidget {
  const SiteDrawer({super.key, required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: const PanelBar('>MENU', right: '[ESC] CLOSE'),
            ),
            for (final page in sitePages)
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(page.path);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: c.lineSoft)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '>>',
                        style: monoStyle(
                          size: 12.8,
                          weight: FontWeight.w700,
                          color: page.path == currentPath ? c.accent : c.muted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        page.label.toUpperCase(),
                        style: monoStyle(
                          size: 12.8,
                          weight: FontWeight.w700,
                          color: page.path == currentPath ? c.cyan : c.ink,
                          spacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
