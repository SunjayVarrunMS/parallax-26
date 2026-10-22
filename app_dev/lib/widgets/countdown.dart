// the countdown box on the home screen. it updates once a second.

import 'dart:async';

import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import 'panels.dart';

class Countdown extends StatefulWidget {
  const Countdown({super.key});

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  late Timer _timer;
  final DateTime _startsAt = DateTime.parse(festival.startsAt);
  final DateTime _endsAt = DateTime.parse(festival.endsAt);
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // 7 -> "07"
  String _twoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }

  Widget _buildNumber(PlxColors c, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: displayStyle(size: 40, color: c.ink)),
        Text(
          label.toUpperCase(),
          style: monoStyle(size: 11, weight: FontWeight.w700, color: c.muted, spacing: 0.9, height: 1.5),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);

    int seconds = _startsAt.difference(_now).inSeconds;
    if (seconds < 0) {
      seconds = 0;
    }
    final days = seconds ~/ 86400;
    final hours = (seconds ~/ 3600) % 24;
    final mins = (seconds ~/ 60) % 60;
    final secs = seconds % 60;

    String state = '[T-MINUS]';
    String eyebrow = 'Time to day 01';
    String note = festival.dateLabel;
    if (!_now.isBefore(_endsAt)) {
      state = '[OFFLINE]';
      eyebrow = 'Until next time';
      note = 'That was a good one.';
    } else if (!_now.isBefore(_startsAt)) {
      state = '[LIVE]';
      eyebrow = 'See you on campus';
      note = 'The festival has started.';
    }

    final intro = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const StatusDot(),
        const SizedBox(width: 10),
        Flexible(child: Eyebrow(eyebrow)),
      ],
    );
    final numbers = Semantics(
      label: '$days days remaining',
      child: Wrap(
        spacing: 24,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _buildNumber(c, _twoDigits(days), 'Days'),
          _buildNumber(c, _twoDigits(hours), 'Hours'),
          _buildNumber(c, _twoDigits(mins), 'Mins'),
          _buildNumber(c, _twoDigits(secs), 'Secs'),
        ],
      ),
    );
    final noteBox = Column(
      crossAxisAlignment: isNarrow(context) ? CrossAxisAlignment.center : CrossAxisAlignment.end,
      children: [
        Text(note, style: monoStyle(weight: FontWeight.w800, color: c.ink)),
        Text('Clear your calendar.', style: monoStyle(size: 13, color: c.muted)),
      ],
    );

    Widget inner;
    if (isNarrow(context)) {
      inner = Column(
        children: [intro, const SizedBox(height: 20), numbers, const SizedBox(height: 20), noteBox],
      );
    } else {
      inner = Row(
        children: [
          Expanded(child: Align(alignment: Alignment.centerLeft, child: intro)),
          numbers,
          Expanded(child: Align(alignment: Alignment.centerRight, child: noteBox)),
        ],
      );
    }

    return PlxPanel(
      barLeft: '>COUNTDOWN',
      barRight: state,
      padding: const EdgeInsets.all(24),
      child: inner,
    );
  }
}
