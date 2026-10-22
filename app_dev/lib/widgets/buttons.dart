// buttons and links in the terminal style

import 'package:flutter/material.dart';

import '../theme.dart';

enum ButtonKind { primary, ink, outline }

class PlxButton extends StatelessWidget {
  const PlxButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = ButtonKind.primary,
    this.small = false,
    this.expand = false,
  });

  final String label;

  // null means the button is disabled
  final VoidCallback? onPressed;
  final ButtonKind kind;
  final bool small;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    Color background = c.accent;
    Color border = c.accent;
    Color textColor = c.onAccent;
    String text = '>> ${label.toUpperCase()} <<';
    if (kind == ButtonKind.ink) {
      background = c.cyan;
      border = c.cyan;
      textColor = c.onCyan;
      text = label.toUpperCase();
    } else if (kind == ButtonKind.outline) {
      background = Colors.transparent;
      border = c.cyan;
      textColor = c.cyan;
      text = label.toUpperCase();
    }

    final button = Opacity(
      opacity: onPressed == null ? 0.45 : 1,
      child: Material(
        color: background,
        child: InkWell(
          onTap: onPressed,
          hoverColor: c.ink.withValues(alpha: 0.12),
          child: Container(
            constraints: BoxConstraints(minHeight: small ? 40 : 46),
            padding: EdgeInsets.symmetric(horizontal: small ? 12 : 20, vertical: small ? 8 : 12),
            decoration: BoxDecoration(border: Border.all(color: border, width: 2)),
            alignment: Alignment.center,
            // shrink long labels instead of breaking them onto two lines
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: monoStyle(
                  size: small ? 11.5 : 12.8,
                  weight: FontWeight.w800,
                  color: textColor,
                  spacing: 0.8,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return IntrinsicWidth(child: button);
  }
}

// a ">> link text" link, optionally with an arrow icon after it
class TextLink extends StatelessWidget {
  const TextLink(this.label, {super.key, required this.onTap, this.showArrow = false});

  final String label;
  final VoidCallback onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '>> ${label.toUpperCase()}',
                style: monoStyle(size: 12.8, weight: FontWeight.w700, color: c.cyan, spacing: 0.5, height: 1.3),
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 10),
              Icon(Icons.north_east, size: 16, color: c.cyan),
            ],
          ],
        ),
      ),
    );
  }
}

// a filter chip like "Tech" or "Day 2"
class ChipButton extends StatelessWidget {
  const ChipButton({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? c.cyan : Colors.transparent,
            border: Border.all(color: selected ? c.cyan : c.lineSoft, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            label.toUpperCase(),
            style: monoStyle(
              size: 12,
              weight: FontWeight.w700,
              color: selected ? c.onCyan : c.ink,
              spacing: 0.5,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

// a small square button like the + and - on the cart
class StepButton extends StatelessWidget {
  const StepButton({super.key, required this.label, required this.onPressed, this.tooltip});

  final String label;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return Tooltip(
      message: tooltip ?? '',
      child: Opacity(
        opacity: onPressed == null ? 0.45 : 1,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(border: Border.all(color: c.cyan, width: 2)),
            alignment: Alignment.center,
            child: Text(label, style: monoStyle(size: 14.4, weight: FontWeight.w800, color: c.cyan, height: 1)),
          ),
        ),
      ),
    );
  }
}
