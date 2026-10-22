// the home screen: hero, countdown, featured events, campus guide link and help desk link

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/badges.dart';
import '../widgets/buttons.dart';
import '../widgets/countdown.dart';
import '../widgets/page_shell.dart';
import '../widgets/panels.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildHeroTerminal(BuildContext context, PlxColors c) {
    final width = MediaQuery.sizeOf(context).width;
    final bootLines = [
      '>> Initiating boot sequence...',
      '>> Loading modules: tech / culture / workshops ... [OK]',
      '>> Fest dates: 20-22 Nov',
      '>> Venue: on campus',
      '>> Registrations: [OPEN]',
    ];
    return PlxPanel(
      barLeft: '>TERMINAL',
      barRight: 'PLX://home',
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in bootLines)
            Text(line, style: monoStyle(size: 13, color: line.contains('[OPEN]') ? c.green : c.muted)),
          const SizedBox(height: 32),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 12,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'PARALLAX',
                  style: displayStyle(
                    size: (width * 0.105).clamp(36.8, 115.2),
                    color: c.ink,
                    spacing: 1,
                    height: 0.95,
                  ).copyWith(
                    shadows: [
                      Shadow(color: c.accent, offset: const Offset(4, 4)),
                      Shadow(color: c.violet, offset: const Offset(8, 8)),
                    ],
                  ),
                ),
              ),
              Text(
                "'26",
                style: displayStyle(size: (width * 0.04).clamp(22.4, 41.6), color: c.cyan, height: 0.95),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: festival.tagline.toUpperCase()),
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(padding: EdgeInsets.only(left: 4), child: CursorBlock(width: 8, height: 16)),
                ),
              ],
            ),
            style: monoStyle(size: 18, weight: FontWeight.w800, color: c.cyan, spacing: 0.7),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              'Three days of hackathons, gigs, workshops and late nights. Same campus you walk through every day, seen from somewhere else.',
              style: monoStyle(color: c.muted),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PlxButton(label: 'Register', onPressed: () => context.go('/register')),
              PlxButton(label: 'Browse events', kind: ButtonKind.outline, onPressed: () => context.go('/events')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpNextPanel(BuildContext context, PlxColors c) {
    final upNext = events.take(5).toList();
    return PlxPanel(
      barLeft: '>EVENTS',
      barRight: '[${events.length}]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final event in upNext)
            InkWell(
              onTap: () => context.go('/events'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '[D${event.day} ${formatTime(event.startsAt)}] ',
                        style: TextStyle(color: c.green, fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: event.title),
                    ],
                  ),
                  style: monoStyle(size: 13.6, color: c.ink, height: 1.4),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextLink('All events', onTap: () => context.go('/events')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(PlxColors c, String name, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(name, style: monoStyle(size: 13.6, color: c.muted))),
          value,
        ],
      ),
    );
  }

  Widget _buildSettingsPanel(BuildContext context, PlxColors c) {
    final valueStyle = monoStyle(size: 13.6, weight: FontWeight.w700, color: c.ink);
    return PlxPanel(
      barLeft: '>SETTINGS',
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingsRow(c, 'Mode:', Text('[ACTIVE]', style: valueStyle.copyWith(color: c.green))),
          _buildSettingsRow(
            c,
            'Days:',
            Row(
              children: [
                for (final label in ['[01]', '[02]', '[03]'])
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () => context.go('/schedule'),
                      child: Text(label, style: valueStyle.copyWith(color: c.cyan)),
                    ),
                  ),
              ],
            ),
          ),
          _buildSettingsRow(c, 'Access:', Text('[OPEN TO ALL]', style: valueStyle)),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, PlxColors c) {
    final terminal = _buildHeroTerminal(context, c);
    final side = Column(
      children: [
        _buildUpNextPanel(context, c),
        const SizedBox(height: 20),
        _buildSettingsPanel(context, c),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: isNarrow(context)
          ? Column(children: [terminal, const SizedBox(height: 20), side])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: terminal),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: side),
              ],
            ),
    );
  }

  Widget _buildFestivalStrip(PlxColors c) {
    const words = ['Tech', 'Culture', 'Workshops', '20-22 Nov', 'Same campus. New angle.', 'Three days', 'Open to all'];
    final style = monoStyle(size: 12.8, weight: FontWeight.w800, color: c.onCyan, spacing: 1, height: 1.4);
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: c.accent,
        border: Border.symmetric(horizontal: BorderSide(color: c.cyan, width: 2)),
      ),
      child: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              for (int round = 0; round < 2; round++)
                for (final word in words)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text('${word.toUpperCase()}  //', style: style),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedArt(PlxColors c, String category, Color tone) {
    if (category == 'Culture') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < 12; i++)
            Container(
              width: 8,
              height: 20.0 + (i * 17 % 50),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: tone,
            ),
        ],
      );
    }
    if (category == 'Tech') {
      return Text.rich(
        const TextSpan(
          children: [
            TextSpan(text: '</>'),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(padding: EdgeInsets.only(left: 4), child: CursorBlock(width: 12, height: 28)),
            ),
          ],
        ),
        style: displayStyle(size: 40, color: c.cyan),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('MAKE', style: displayStyle(size: 26, color: c.ink)),
        Text('SOMETHING.', style: displayStyle(size: 26, color: c.green)),
      ],
    );
  }

  Widget _buildFeaturedCard(BuildContext context, PlxColors c, int index, EventItem event) {
    final tone = categoryTone(event.category);
    final toneCol = toneColor(c, tone);
    String path = '/events';
    if (event.category == 'Workshop') {
      path = '/workshops';
    }
    return InkWell(
      onTap: () => context.go(path),
      child: PlxPanel(
        barLeft: '>EVT_0${index + 1}',
        barRight: event.category,
        borderColor: toneCol == c.ink ? c.cyan : toneCol,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 130,
              color: c.paper,
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Positioned.fill(child: Center(child: _buildFeaturedArt(c, event.category, toneCol))),
                  Positioned(
                    right: 8,
                    bottom: 6,
                    child: Text('SIGNAL: STRONG', style: monoStyle(size: 10, color: c.muted, spacing: 0.6)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    children: [
                      PlxBadge(event.category, tone),
                      PlxBadge('Day 0${event.day}', 'neutral'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(event.title, style: monoStyle(size: 17.6, weight: FontWeight.w800, color: c.ink, height: 1.3)),
                  const SizedBox(height: 8),
                  Text(event.description, style: monoStyle(size: 13, color: c.muted)),
                  const SizedBox(height: 12),
                  Text(
                    '>> OPEN FILE',
                    style: monoStyle(size: 12, weight: FontWeight.w800, color: c.cyan, spacing: 0.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstLook(BuildContext context, PlxColors c) {
    final featured = [events[0], events[1], workshops[0]];
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('>> 01 / Featured'),
        const SizedBox(height: 8),
        Text('Pick your angle.', style: displayStyle(size: 36, color: c.ink)),
      ],
    );
    final aside = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            'Build something, play something, make something. Or just watch from the back row.',
            style: monoStyle(color: c.muted),
          ),
        ),
        TextLink('Explore events', onTap: () => context.go('/events')),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNarrow(context))
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [heading, const SizedBox(height: 16), aside])
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [heading, aside],
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              const StatusDot(),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Sample programme. The final line-up is on its way.',
                  style: monoStyle(size: 13, color: c.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CardGrid(
            children: [
              for (int i = 0; i < featured.length; i++) _buildFeaturedCard(context, c, i, featured[i]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapBlock(PlxColors c, String label, double left, double top, double w, double h) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: w,
        height: h,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: c.lineSoft, width: 2)),
        child: Text(label, style: monoStyle(size: 11, weight: FontWeight.w800, color: c.muted)),
      ),
    );
  }

  Widget _buildCampusCallout(BuildContext context, PlxColors c) {
    final art = PlxPanel(
      barLeft: '>MAP',
      barRight: '[GPS LOCK]',
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            _buildMapBlock(c, 'STAGE', 20, 20, 110, 60),
            _buildMapBlock(c, 'LAB', 150, 100, 90, 60),
            _buildMapBlock(c, 'OAT', 30, 130, 80, 60),
            Positioned(
              left: 110,
              top: 50,
              child: Icon(Icons.location_on_outlined, size: 36, color: c.accent),
            ),
            Positioned(
              left: 80,
              top: 92,
              child: Text('YOU ARE HERE', style: monoStyle(size: 10.4, weight: FontWeight.w800, color: c.accent)),
            ),
            Positioned(
              right: 12,
              top: 10,
              child: Text('N ^', style: monoStyle(size: 11, weight: FontWeight.w800, color: c.cyan)),
            ),
          ],
        ),
      ),
    );
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('>> 02 / Campus guide'),
        const SizedBox(height: 8),
        Text('Find your way around.', style: displayStyle(size: 32, color: c.ink)),
        const SizedBox(height: 12),
        Text(
          'From the main stage to that workshop room on the far side of campus. Look up your next stop before you head out.',
          style: monoStyle(color: c.muted),
        ),
        const SizedBox(height: 16),
        PlxButton(
          label: 'Open the campus guide',
          kind: ButtonKind.outline,
          onPressed: () => context.go('/campus-guide'),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: isNarrow(context)
          ? Column(children: [art, const SizedBox(height: 24), copy])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: art),
                const SizedBox(width: 40),
                Expanded(child: copy),
              ],
            ),
    );
  }

  Widget _buildClosingNote(BuildContext context, PlxColors c) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('Got a question? Lost a friend?'),
        const SizedBox(height: 8),
        Text('The help desk is listening.', style: displayStyle(size: 28, color: c.ink)),
      ],
    );
    final button = PlxButton(
      label: 'Ping the help desk',
      kind: ButtonKind.ink,
      onPressed: () => context.go('/help'),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: PlxPanel(
        barLeft: '>HELP',
        barRight: '[ONLINE]',
        padding: const EdgeInsets.all(24),
        child: isNarrow(context)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [text, const SizedBox(height: 16), button],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Flexible(child: text), const SizedBox(width: 24), button],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return PageShell(
      currentPath: '/',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageContainer(child: _buildHero(context, c)),
          _buildFestivalStrip(c),
          PageContainer(
            child: Padding(padding: const EdgeInsets.only(top: 48), child: const Countdown()),
          ),
          PageContainer(child: _buildFirstLook(context, c)),
          PageContainer(child: _buildCampusCallout(context, c)),
          PageContainer(child: _buildClosingNote(context, c)),
        ],
      ),
    );
  }
}
