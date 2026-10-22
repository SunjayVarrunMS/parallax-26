// the small [BADGES] used on cards and lists

import 'package:flutter/material.dart';

import '../theme.dart';

class PlxBadge extends StatelessWidget {
  const PlxBadge(this.label, this.tone, {super.key, this.color});

  final String label;

  // 'green', 'coral', 'blue' or 'neutral'
  final String tone;

  // set this to ignore the tone (for badges on a cyan strip)
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    Color textColor = c.muted;
    if (tone == 'green') {
      textColor = c.green;
    } else if (tone == 'coral') {
      textColor = c.accent;
    } else if (tone == 'blue') {
      textColor = c.cyan;
    }
    return Text(
      '[${label.toUpperCase()}]',
      style: monoStyle(size: 10.9, weight: FontWeight.w800, color: color ?? textColor, spacing: 0.65, height: 1.4),
    );
  }
}

// Open / Full / Cancelled
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.color});

  final String status;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (status == 'open') {
      return PlxBadge('Open', 'green', color: color);
    }
    if (status == 'full') {
      return PlxBadge('Full', 'coral', color: color);
    }
    return PlxBadge('Cancelled', 'neutral', color: color);
  }
}

// Culture -> coral, Tech -> blue, Workshop -> green
String categoryTone(String category) {
  if (category == 'Culture') {
    return 'coral';
  }
  if (category == 'Tech') {
    return 'blue';
  }
  return 'green';
}
