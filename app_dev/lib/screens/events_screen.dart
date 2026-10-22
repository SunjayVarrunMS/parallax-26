// the events screen: search box, category and day filters, and the list of cards

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/badges.dart';
import '../widgets/buttons.dart';
import '../widgets/form_parts.dart';
import '../widgets/page_heading.dart';
import '../widgets/page_shell.dart';
import '../widgets/panels.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  int? _selectedDay;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getVenueName(String venueId) {
    for (final venue in venues) {
      if (venue.id == venueId) {
        return venue.name;
      }
    }
    return '';
  }

  // does this event match the search box and the category?
  bool _matchesFilters(EventItem event) {
    final query = _searchController.text.trim();
    final matchesSearch = query == '' ||
        event.title.toLowerCase().contains(query) ||
        event.description.toLowerCase().contains(query);
    final matchesCategory = _selectedCategory == 'All' || event.category == _selectedCategory;
    return matchesSearch && matchesCategory;
  }

  bool _matchesDay(EventItem event) {
    return _selectedDay == null || event.day == _selectedDay;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = 'All';
      _selectedDay = null;
    });
  }

  Widget _buildPromoBanner() {
    // a plain white card, the corporate look
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x1F0F172A), blurRadius: 30, offset: Offset(0, 10)),
          BoxShadow(color: Color(0x0F0F172A), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF38BDF8), Color(0xFF818CF8), Color(0xFFF472B6)],
              ).createShader(bounds),
              child: const Text(
                '🚀 Unlock Your Potential at PARALLAX 2026! ✨ Discover amazing events, connect with like-minded individuals, and elevate your festival experience to the next level! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22.4, fontWeight: FontWeight.w700, height: 1.4, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF818CF8),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              elevation: 4,
              shadowColor: const Color(0x59F472B6),
            ),
            child: const Text('Explore Now 🔥', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(PlxColors c) {
    final search = FieldBlock(
      label: 'Search events',
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        cursorColor: c.cyan,
        style: monoStyle(size: 14.4, color: c.ink, height: 1.4),
        decoration: plxDecoration(context, hint: "Try 'Robo' or 'Stage'"),
      ),
    );

    final categories = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('>> Category'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final category in ['All', 'Culture', 'Tech'])
              ChipButton(
                label: category,
                selected: _selectedCategory == category,
                onTap: () => setState(() => _selectedCategory = category),
              ),
          ],
        ),
      ],
    );

    final days = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('>> Day'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ChipButton(label: 'All', selected: _selectedDay == null, onTap: () => setState(() => _selectedDay = null)),
            for (final day in [1, 2, 3])
              ChipButton(
                label: 'Day $day',
                selected: _selectedDay == day,
                onTap: () => setState(() => _selectedDay = day),
              ),
          ],
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: PlxPanel(
        barLeft: '>FILTERS',
        padding: const EdgeInsets.all(20),
        child: MediaQuery.sizeOf(context).width < 1000
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [search, const SizedBox(height: 20), categories, const SizedBox(height: 20), days],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: search),
                  const SizedBox(width: 32),
                  categories,
                  const SizedBox(width: 32),
                  days,
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState(PlxColors c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      color: c.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '[0 RESULTS] ', style: TextStyle(color: c.accent)),
                const TextSpan(text: 'NOTHING MATCHES THAT.'),
              ],
            ),
            style: monoStyle(size: 19.2, weight: FontWeight.w800, color: c.ink, height: 1.3),
          ),
          const SizedBox(height: 8),
          Text('Try a different word, or let the filters go.', style: monoStyle(color: c.muted)),
          const SizedBox(height: 20),
          PlxButton(label: 'Clear filters', kind: ButtonKind.outline, onPressed: _clearFilters),
        ],
      ),
    );
  }

  Widget _buildDetail(PlxColors c, String name, String value) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.toUpperCase(),
            style: monoStyle(size: 9.9, weight: FontWeight.w700, color: c.muted, spacing: 1.2, height: 1.5),
          ),
          Text(value, style: monoStyle(size: 13, weight: FontWeight.w700, color: c.ink, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildEventCard(PlxColors c, EventItem event) {
    final cancelled = event.status == 'cancelled';
    Color borderColor = c.cyan;
    Color barColor = c.cyan;
    if (event.status == 'full') {
      borderColor = c.accent;
      barColor = c.accent;
    } else if (cancelled) {
      borderColor = c.muted;
      barColor = c.muted;
    }

    // the register link: shown unless the event is full
    Widget registerLink = const SizedBox.shrink();
    if (event.status != 'full') {
      registerLink = Padding(
        padding: const EdgeInsets.only(top: 18),
        child: InkWell(
          onTap: () => context.go('/register?event=${event.id}'),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(border: Border.all(color: c.cyan, width: 2)),
            child: Text(
              '>> REGISTER',
              style: monoStyle(size: 12, weight: FontWeight.w800, color: c.cyan, spacing: 0.7, height: 1.3),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cancelled ? Colors.transparent : c.surface,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: barColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                Text('>', style: monoStyle(size: 12, weight: FontWeight.w800, color: c.onCyan, height: 1.4)),
                PlxBadge(event.category, categoryTone(event.category), color: c.onCyan),
                PlxBadge('Day 0${event.day}', 'neutral', color: c.onCyan),
                StatusBadge(event.status, color: c.onCyan),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title.toUpperCase(),
                  style: monoStyle(
                    size: 18.4,
                    weight: FontWeight.w800,
                    color: cancelled ? c.muted : c.ink,
                    height: 1.3,
                  ).copyWith(
                    decoration: cancelled ? TextDecoration.lineThrough : TextDecoration.none,
                    decorationColor: c.error,
                    decorationThickness: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(event.description, style: monoStyle(size: 13.1, color: c.muted)),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: c.lineSoft)),
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _buildDetail(c, 'Day', 'Day ${event.day}'),
                      _buildDetail(c, 'Time', '${formatTime(event.startsAt)} - ${formatTime(event.endsAt)}'),
                      _buildDetail(c, 'Venue', _getVenueName(event.venueId)),
                      _buildDetail(c, 'Fee', formatPrice(event.fee)),
                    ],
                  ),
                ),
                registerLink,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);

    // show the matching events
    final visibleEvents = events.where((event) => _matchesFilters(event) && _matchesDay(event)).toList();
    final foundCount = events.where(_matchesFilters).length;

    String label = 'events';
    if (foundCount == 1) {
      label = 'event';
    }
    final nothingFound = visibleEvents.isEmpty;

    return PageShell(
      currentPath: '/events',
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeading(
                eyebrow: '>> PARALLAX / 01',
                title: 'Find your thing',
                description: 'On stage, behind a screen, or somewhere completely unexpected.',
              ),
              _buildPromoBanner(),
              _buildFilters(c),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Text(
                  '>> $foundCount $label found'.toUpperCase(),
                  style: displayStyle(
                    size: (MediaQuery.sizeOf(context).width * 0.06).clamp(22.4, 36.0),
                    color: c.cyan,
                    spacing: 0.9,
                    height: 1.2,
                  ),
                ),
              ),
              if (nothingFound)
                _buildEmptyState(c)
              else
                CardGrid(
                  gap: 20,
                  children: [for (final event in visibleEvents) _buildEventCard(c, event)],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
