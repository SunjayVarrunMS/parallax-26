// the sponsors screen: one card per partner from data.dart

import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/buttons.dart';
import '../widgets/page_heading.dart';
import '../widgets/page_shell.dart';
import '../widgets/panels.dart';

class SponsorsScreen extends StatelessWidget {
  const SponsorsScreen({super.key});

  Widget _buildSponsorCard(PlxColors c, int i) {
    final sponsor = sponsors[i];
    return PlxPanel(
      barLeft: '>PARTNER_0${i + 1}',
      barRight: '[LINKED]',
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(border: Border.all(color: c.lineSoft, width: 2)),
            child: Text(sponsor.mark, style: displayStyle(size: 24, color: c.cyan)),
          ),
          const SizedBox(height: 14),
          Text(sponsor.name, style: monoStyle(size: 16.8, weight: FontWeight.w800, color: c.ink, height: 1.3)),
          const SizedBox(height: 8),
          Text(sponsor.blurb, style: monoStyle(size: 13.6, color: c.muted)),
          const SizedBox(height: 8),
          TextLink(
            'Visit website',
            showArrow: true,
            onTap: () => openLink('https://example.com'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return PageShell(
      currentPath: '/sponsors',
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeading(
                eyebrow: '>> PARALLAX / 07',
                title: 'In good company',
                description: 'The people and partners helping make it happen.',
              ),
              const SizedBox(height: 40),
              CardGrid(
                children: [for (int i = 0; i < sponsors.length; i++) _buildSponsorCard(c, i)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
