// the workshops screen: see the seats left, book a seat or join the waitlist

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/workshops_api.dart';
import '../data.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/badges.dart';
import '../widgets/buttons.dart';
import '../widgets/form_parts.dart';
import '../widgets/page_heading.dart';
import '../widgets/page_shell.dart';
import '../widgets/panels.dart';

// what happened after someone booked
class _BookingResult {
  _BookingResult(this.status, this.position);

  final String status;
  final int position;
}

class WorkshopsScreen extends StatefulWidget {
  const WorkshopsScreen({super.key});

  @override
  State<WorkshopsScreen> createState() => _WorkshopsScreenState();
}

class _WorkshopsScreenState extends State<WorkshopsScreen> {
  List<Workshop> _workshopList = [];
  bool _loading = true;
  String _loadError = '';
  String _openFormId = '';
  final Map<String, _BookingResult> _results = {};
  bool _sending = false;
  String _sendingId = '';

  // one set of form boxes per workshop
  final Map<String, GlobalKey<FormState>> _formKeys = {};
  final Map<String, TextEditingController> _nameControllers = {};
  final Map<String, TextEditingController> _emailControllers = {};
  final Map<String, String> _formErrors = {};

  @override
  void initState() {
    super.initState();
    for (final workshop in workshops) {
      _formKeys[workshop.id] = GlobalKey<FormState>();
      _nameControllers[workshop.id] = TextEditingController();
      _emailControllers[workshop.id] = TextEditingController();
      _formErrors[workshop.id] = '';
    }
    _load();
  }

  @override
  void dispose() {
    for (final controller in _nameControllers.values) {
      controller.dispose();
    }
    for (final controller in _emailControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final list = await listWorkshops();
      if (!mounted) return;
      setState(() {
        _workshopList = list;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = errorMessage(error, 'Could not load the workshops.');
      });
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  String _getVenueName(String venueId) {
    for (final venue in venues) {
      if (venue.id == venueId) {
        return venue.name;
      }
    }
    return '';
  }

  int _getSeatsLeft(Workshop workshop) {
    final left = workshop.capacity - workshop.seatsTaken;
    return left < 0 ? 0 : left;
  }

  Future<void> _handleSubmit(Workshop workshop) async {
    if (_sending) {
      return;
    }
    final workshopId = workshop.id;
    setState(() {
      _formErrors[workshopId] = '';
    });
    if (!_formKeys[workshopId]!.currentState!.validate()) {
      return;
    }

    final name = _nameControllers[workshopId]!.text.trim();
    final email = _emailControllers[workshopId]!.text.trim();

    setState(() {
      _sending = true;
      _sendingId = workshopId;
    });
    try {
      final booking = await bookWorkshop(workshopId, name, email);
      final bookings = await listBookings();
      final list = await listWorkshops();
      if (!mounted) return;
      setState(() {
        _workshopList = list;
        _results[workshopId] = _BookingResult(
          booking['status'] as String,
          getWaitlistPosition(bookings, booking),
        );
        _openFormId = '';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _formErrors[workshopId] = errorMessage(error, 'Something went wrong. Try again.');
      });
    }
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sendingId = '';
    });
  }

  void _openForm(String id) {
    if (_sending) {
      return;
    }
    setState(() {
      _openFormId = id;
    });
  }

  void _closeForm() {
    if (_sending) {
      return;
    }
    setState(() {
      _openFormId = '';
    });
  }

  Widget _buildResult(PlxColors c, Workshop workshop) {
    final result = _results[workshop.id]!;
    String message = "You're in";
    if (result.status == 'waitlisted') {
      message = "You're on the waitlist (position ${result.position})";
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: monoStyle(size: 13.6, weight: FontWeight.w800, color: c.green)),
        TextLink('See it in My bookings', onTap: () => context.go('/my-bookings')),
      ],
    );
  }

  Widget _buildForm(PlxColors c, Workshop workshop, String buttonText) {
    final sendingThis = _sending && _sendingId == workshop.id;
    final formError = _formErrors[workshop.id] ?? '';
    return Form(
      key: _formKeys[workshop.id],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlxTextField(
            label: 'Full name',
            controller: _nameControllers[workshop.id]!,
            validator: validateName,
          ),
          const SizedBox(height: 14),
          PlxTextField(
            label: 'Email',
            controller: _emailControllers[workshop.id]!,
            validator: validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          if (formError != '') ...[
            const SizedBox(height: 14),
            FormErrorText(formError),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PlxButton(
                label: sendingThis ? 'Sending...' : buttonText,
                onPressed: sendingThis ? null : () => _handleSubmit(workshop),
              ),
              PlxButton(label: 'Close', kind: ButtonKind.outline, onPressed: _closeForm),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAction(PlxColors c, Workshop workshop) {
    if (_results.containsKey(workshop.id)) {
      return _buildResult(c, workshop);
    }

    String buttonText = 'Book a seat';
    if (_getSeatsLeft(workshop) == 0) {
      buttonText = 'Join waitlist';
    }

    if (_openFormId == workshop.id) {
      return _buildForm(c, workshop, buttonText);
    }
    return PlxButton(
      label: buttonText,
      kind: ButtonKind.outline,
      onPressed: () => _openForm(workshop.id),
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

  Widget _buildWorkshopCard(PlxColors c, Workshop workshop) {
    final seatsLeft = _getSeatsLeft(workshop);
    int percentTaken = (workshop.seatsTaken / workshop.capacity * 100).round();
    if (percentTaken > 100) {
      percentTaken = 100;
    }

    Widget badge = const PlxBadge('Open', 'green');
    if (seatsLeft == 0) {
      badge = const PlxBadge('Full', 'coral');
    }

    return PlxPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(spacing: 10, children: [const PlxBadge('Workshop', 'green'), badge]),
          const SizedBox(height: 12),
          Text(workshop.title.toUpperCase(), style: monoStyle(size: 18.4, weight: FontWeight.w800, color: c.ink, height: 1.3)),
          const SizedBox(height: 8),
          Text(workshop.description, style: monoStyle(size: 13.1, color: c.muted)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.lineSoft)),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildDetail(c, 'Day', 'Day ${workshop.day}'),
                _buildDetail(c, 'Time', '${formatTime(workshop.startsAt)} - ${formatTime(workshop.endsAt)}'),
                _buildDetail(c, 'Venue', _getVenueName(workshop.venueId)),
                _buildDetail(c, 'Fee', formatPrice(workshop.fee)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('$seatsLeft of ${workshop.capacity} seats left', style: monoStyle(size: 13, weight: FontWeight.w700, color: c.ink)),
          const SizedBox(height: 8),
          Container(
            height: 8,
            width: double.infinity,
            color: c.lineSoft,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percentTaken / 100,
              child: Container(color: c.accent),
            ),
          ),
          const SizedBox(height: 16),
          _buildAction(c, workshop),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return PageShell(
      currentPath: '/workshops',
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeading(
                eyebrow: '>> PARALLAX / 05',
                title: 'Give it a go',
                description: "Be a beginner at something. It's a good look.",
              ),
              if (_loading) const LoadingText('Loading workshops...'),
              if (_loadError != '')
                Padding(padding: const EdgeInsets.only(top: 32), child: FormErrorText(_loadError)),
              const SizedBox(height: 40),
              CardGrid(
                children: [for (final workshop in _workshopList) _buildWorkshopCard(c, workshop)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
