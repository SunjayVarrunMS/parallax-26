// the campus guide: one card per venue, with what is happening there

import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/buttons.dart';
import '../widgets/page_heading.dart';
import '../widgets/page_shell.dart';
import '../widgets/panels.dart';

class CampusGuideScreen extends StatelessWidget {
  const CampusGuideScreen({super.key});

  // events and workshops held at one venue, earliest first
  List<EventItem> _getEntriesAt(String venueId) {
    final allEntries = <EventItem>[...events, ...workshops];
    final held = allEntries.where((entry) => entry.venueId == venueId).toList();
    held.sort((a, b) => DateTime.parse(a.startsAt).compareTo(DateTime.parse(b.startsAt)));
    return held;
  }

  Widget _buildHeldList(PlxColors c, List<EventItem> held) {
    if (held.isEmpty) {
      return Text('Nothing scheduled.', style: monoStyle(size: 13, color: c.muted));
    }
    return Column(
      children: [
        for (final entry in held)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.lineSoft)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(entry.title, style: monoStyle(size: 13, color: c.ink, height: 1.4))),
                const SizedBox(width: 8),
                Text(
                  '[DAY 0${entry.day}]',
                  style: monoStyle(size: 11.5, weight: FontWeight.w700, color: c.green, height: 1.4),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVenueCard(PlxColors c, int i) {
    final venue = venues[i];
    final held = _getEntriesAt(venue.id);
    return PlxPanel(
      barLeft: '>STOP_0${i + 1}',
      barRight: '[${held.length}]',
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(venue.name.toUpperCase(), style: monoStyle(size: 17.6, weight: FontWeight.w800, color: c.ink)),
          const SizedBox(height: 8),
          Text(venue.description, style: monoStyle(size: 13.6, color: c.muted)),
          const SizedBox(height: 16),
          const Eyebrow('Happening here'),
          const SizedBox(height: 8),
          _buildHeldList(c, held),
          const SizedBox(height: 8),
          TextLink(
            'Directions to ${venue.name}',
            showArrow: true,
            onTap: () => openLink('${venues.elementAtOrNull(i + 1)?.directionsUrl}'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return PageShell(
      currentPath: '/campus-guide',
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeading(
                eyebrow: '>> PARALLAX / 06',
                title: 'You are here',
                description: 'The stages, the studios, and the shortcuts in between.',
              ),
              const SizedBox(height: 40),
              CardGrid(
                children: [for (int i = 0; i < venues.length; i++) _buildVenueCard(c, i)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
