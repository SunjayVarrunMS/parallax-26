// every screen sits in a PageShell: header, drawer menu, the screen itself, and the footer

import 'package:flutter/material.dart';

import '../theme.dart';
import 'panels.dart';
import 'site_footer.dart';
import 'site_header.dart';

// the faint grid behind the page
class _GridPainter extends CustomPainter {
  _GridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class PageShell extends StatefulWidget {
  const PageShell({super.key, required this.currentPath, required this.child});

  // the route of this screen, so the header can mark it
  final String currentPath;
  final Widget child;

  @override
  State<PageShell> createState() => _PageShellState();
}

class _PageShellState extends State<PageShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    final narrow = isNarrow(context);
    final gridColor = c.cyan.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.07);

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(narrow ? 66 : 74),
        child: SiteHeader(currentPath: widget.currentPath, onMenuPressed: _openMenu),
      ),
      drawer: narrow ? SiteDrawer(currentPath: widget.currentPath) : null,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter(gridColor))),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [widget.child, const SiteFooter()],
            ),
          ),
        ],
      ),
    );
  }
}
