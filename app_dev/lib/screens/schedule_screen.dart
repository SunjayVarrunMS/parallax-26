// the schedule screen: three day tabs and the timetable for the picked day

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/badges.dart';
import '../widgets/page_heading.dart';
import '../widgets/page_shell.dart';
import '../widgets/panels.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDay = 1;

  // day 1 -> "Fri, 20 Nov"
  String _dayDate(int day) {
    final start = DateTime.parse(festival.startsAt);
    final date = start.add(Duration(days: day - 1));
    return formatDate(date.toUtc().toIso8601String());
  }

  // the time shown in each row
  String _slotTime(String iso) {
    return DateFormat('h:mm a').format(DateTime.parse(iso).toUtc()).toLowerCase();
  }

  String _getVenueName(String venueId) {
    for (final venue in venues) {
      if (venue.id == venueId) {
        return venue.name;
      }
    }
    return '';
  }

  Widget _buildTab(PlxColors c, int day) {
    final selected = day == _selectedDay;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedDay = day),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? c.cyan : Colors.transparent,
            border: Border.all(color: selected ? c.cyan : c.lineSoft, width: 2),
          ),
          child: Column(
            children: [
              Text(
                '[DAY 0$day]',
                style: monoStyle(
                  size: 13.6,
                  weight: FontWeight.w800,
                  color: selected ? c.onCyan : c.ink,
                  spacing: 0.7,
                  height: 1.4,
                ),
              ),
              Text(
                _dayDate(day),
                style: monoStyle(size: 11.5, color: selected ? c.onCyan : c.muted, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(PlxColors c, EventItem entry) {
    final cancelled = entry.status == 'cancelled';
    final textColor = cancelled ? c.muted : c.ink;
    final badges = Wrap(
      spacing: 10,
      children: [
        PlxBadge(entry.category, categoryTone(entry.category)),
        StatusBadge(entry.status),
      ],
    );
    final title = Text(
      entry.title.toUpperCase(),
      style: monoStyle(size: 16, weight: FontWeight.w800, color: textColor, height: 1.3).copyWith(
        decoration: cancelled ? TextDecoration.lineThrough : TextDecoration.none,
        decorationColor: c.error,
        decorationThickness: 2,
      ),
    );
    final time = Text(
      '${_slotTime(entry.startsAt)} - ${_slotTime(entry.endsAt)}',
      style: monoStyle(size: 14, weight: FontWeight.w700, color: cancelled ? c.muted : c.cyan),
    );
    final venue = Text(_getVenueName(entry.venueId), style: monoStyle(size: 13, color: c.muted));

    Widget content;
    if (isNarrow(context)) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [time, const SizedBox(height: 4), title, const SizedBox(height: 8), badges, const SizedBox(height: 6), venue],
      );
    } else {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 220, child: time),
          Expanded(child: title),
          const SizedBox(width: 16),
          badges,
          const SizedBox(width: 24),
          SizedBox(width: 180, child: venue),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cancelled ? Colors.transparent : c.surface,
        border: Border.all(color: cancelled ? c.muted : c.lineSoft, width: 2),
      ),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);

    // events and workshops for the picked day, earliest first
    final allEntries = <EventItem>[...events, ...workshops];
    final entries = allEntries.where((entry) => entry.day == _selectedDay).toList();
    entries.sort((a, b) => DateTime.parse(a.startsAt).compareTo(DateTime.parse(b.startsAt)));

    return PageShell(
      currentPath: '/schedule',
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeading(
                eyebrow: '>> PARALLAX / 02',
                title: 'Make a day of it',
                description: 'A little planning leaves more room for the unplanned.',
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  for (int day = 1; day <= 3; day++) ...[
                    if (day > 1) const SizedBox(width: 8),
                    _buildTab(c, day),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              const Eyebrow('>> All times in IST (UTC+05:30)'),
              const SizedBox(height: 16),
              for (final entry in entries) ...[
                _buildRow(c, entry),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
