// the footer at the bottom of every screen

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data.dart';
import '../store.dart';
import '../theme.dart';
import 'panels.dart';
import 'site_header.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  // clear everything saved, then load the current screen again
  void _handleReset() {
    resetDemoData();
    loadTheme();
    reloadCount.value = reloadCount.value + 1;
  }

  Widget _buildAbout(PlxColors c) {
    final style = monoStyle(size: 12.8, color: c.muted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Brand(),
        const SizedBox(height: 18),
        Text('Three days of tech, culture and workshops.', style: style),
        Text('Built by students, for students.', style: style),
      ],
    );
  }

  Widget _buildLinks(BuildContext context, PlxColors c) {
    return Wrap(
      spacing: 56,
      runSpacing: 14,
      children: [
        for (final page in sitePages)
          if (page.path != '/')
            SizedBox(
              width: 150,
              child: InkWell(
                onTap: () => context.go(page.path),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '>> ', style: TextStyle(color: c.cyan)),
                      TextSpan(text: page.label.toUpperCase()),
                    ],
                  ),
                  style: monoStyle(size: 12, color: c.ink, spacing: 0.5, height: 1.4),
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildBottomRow(PlxColors c) {
    final style = monoStyle(size: 10.9, weight: FontWeight.w500, color: c.muted, spacing: 0.5, height: 1.5);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.lineSoft)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 24,
        runSpacing: 12,
        children: [
          Text(festival.tagline.toUpperCase(), style: style),
          Text(festival.dateLabel.toUpperCase(), style: style),
          Text('END OF TRANSMISSION', style: style),
          InkWell(
            onTap: _handleReset,
            child: Text('[RESET DEMO DATA]', style: style.copyWith(color: c.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    final narrow = isNarrow(context);

    Widget top;
    if (narrow) {
      top = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildAbout(c), const SizedBox(height: 32), _buildLinks(context, c)],
      );
    } else {
      top = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildAbout(c), const SizedBox(width: 40), Flexible(child: _buildLinks(context, c))],
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.only(top: 48),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.cyan, width: 2)),
      ),
      child: PageContainer(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.only(bottom: 40), child: top),
            _buildBottomRow(c),
          ],
        ),
      ),
    );
  }
}
