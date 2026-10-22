// small shared pieces: panels, the page width box, card grids and the blinking-style cursor

import 'package:flutter/material.dart';

import '../theme.dart';

// the screen is narrow below this width (header links move into a menu)
const double narrowWidth = 900;

bool isNarrow(BuildContext context) {
  return MediaQuery.sizeOf(context).width < narrowWidth;
}

// keeps page content centred with side gutters, like .container in the CSS
class PageContainer extends StatelessWidget {
  const PageContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gutter = (width * 0.045).clamp(16.0, 80.0);
    double pageWidth = 1280;
    if (width >= 1600) {
      pageWidth = 1400;
    }
    final contentWidth = (width - gutter * 2) < pageWidth ? (width - gutter * 2) : pageWidth;
    return Center(
      child: SizedBox(width: contentWidth, child: child),
    );
  }
}

// small uppercase label, like ">> PARALLAX / 01"
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return Text(
      text.toUpperCase(),
      style: monoStyle(size: 11.5, weight: FontWeight.w700, color: color ?? c.cyan, spacing: 0.9, height: 1.5),
    );
  }
}

// the coloured title strip on top of a panel
class PanelBar extends StatelessWidget {
  const PanelBar(this.left, {super.key, this.right, this.color, this.textColor});

  final String left;
  final String? right;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    final fg = textColor ?? c.onCyan;
    final children = <Widget>[
      Flexible(
        child: Text(
          left.toUpperCase(),
          style: monoStyle(size: 12, weight: FontWeight.w800, color: fg, spacing: 0.7, height: 1.6),
        ),
      ),
    ];
    if (right != null) {
      children.add(const SizedBox(width: 12));
      children.add(
        Flexible(
          child: Text(
            right!.toUpperCase(),
            textAlign: TextAlign.right,
            style: monoStyle(size: 12, weight: FontWeight.w500, color: fg, spacing: 0.7, height: 1.6),
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      color: color ?? c.cyan,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: children),
    );
  }
}

// a box with a cyan border and an optional title strip
class PlxPanel extends StatelessWidget {
  const PlxPanel({
    super.key,
    this.barLeft,
    this.barRight,
    this.borderColor,
    this.background,
    this.padding,
    required this.child,
  });

  final String? barLeft;
  final String? barRight;
  final Color? borderColor;
  final Color? background;
  final EdgeInsets? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    Widget body = child;
    if (padding != null) {
      body = Padding(padding: padding!, child: child);
    }
    return Container(
      decoration: BoxDecoration(
        color: background ?? c.surface,
        border: Border.all(color: borderColor ?? c.cyan, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (barLeft != null) PanelBar(barLeft!, right: barRight, color: borderColor),
          body,
        ],
      ),
    );
  }
}

// the tone names in data.dart -> a colour
Color toneColor(PlxColors c, String tone) {
  if (tone == 'coral') {
    return c.accent;
  }
  if (tone == 'blue') {
    return c.blue;
  }
  if (tone == 'green') {
    return c.green;
  }
  return c.ink;
}

// a solid block like the cursor in a terminal
class CursorBlock extends StatelessWidget {
  const CursorBlock({super.key, this.width = 10, this.height = 16});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(width: width, height: height, color: PlxColors.of(context).cyan);
  }
}

// a small blinking square, like .status-dot
class StatusDot extends StatelessWidget {
  const StatusDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 8, height: 8, color: PlxColors.of(context).green);
  }
}

// lays cards out in rows. the number of columns depends on the width.
class CardGrid extends StatelessWidget {
  const CardGrid({
    super.key,
    required this.children,
    this.maxColumns = 3,
    this.minWidth = 280,
    this.gap = 20,
  });

  final List<Widget> children;
  final int maxColumns;
  final double minWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        int columns = ((total + gap) / (minWidth + gap)).floor();
        if (columns > maxColumns) {
          columns = maxColumns;
        }
        if (columns < 1) {
          columns = 1;
        }
        final itemWidth = (total - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

// "Loading..." line shown while a screen waits for the pretend server
class LoadingText extends StatelessWidget {
  const LoadingText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Text(
        '>> ${text.toUpperCase()}',
        style: monoStyle(size: 12, weight: FontWeight.w700, color: c.green),
      ),
    );
  }
}

// the red message under a form or a list
class FormErrorText extends StatelessWidget {
  const FormErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return Text(
      '[ERR] $message',
      style: monoStyle(size: 12.5, weight: FontWeight.w700, color: c.error, height: 1.5),
    );
  }
}
