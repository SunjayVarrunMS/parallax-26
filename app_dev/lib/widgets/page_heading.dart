// the big title at the top of every screen

import 'package:flutter/material.dart';

import '../theme.dart';
import 'panels.dart';

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = (width * 0.07).clamp(35.2, 80.0);
    final topPadding = width < 880 ? 40.0 : 56.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: topPadding, bottom: 36),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.lineSoft, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(eyebrow),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: title.toUpperCase()),
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: CursorBlock(width: 14, height: 40),
                  ),
                ),
              ],
            ),
            style: displayStyle(
              size: titleSize,
              color: c.ink,
              height: 1.02,
            ).copyWith(shadows: [Shadow(color: c.violet, offset: const Offset(3, 3))]),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '// ', style: TextStyle(color: c.cyan)),
                  TextSpan(text: description),
                ],
              ),
              style: monoStyle(color: c.muted),
            ),
          ),
        ],
      ),
    );
  }
}
