// the register screen: pick an event, fill in your details, add teammates, see the fee

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/registrations_api.dart';
import '../data.dart';
import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/buttons.dart';
import '../widgets/form_parts.dart';
import '../widgets/page_heading.dart';
import '../widgets/page_shell.dart';
import '../widgets/panels.dart';

// one teammate name box
class _Teammate {
  _Teammate(this.id);

  final int id;
  final TextEditingController controller = TextEditingController();
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.eventId});

  // from /register?event=capture-the-flag
  final String? eventId;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<EventItem> _openEvents = [];
  final List<_Teammate> _teammates = [];
  String _selectedEventId = '';
  int _nextTeammateId = 1;
  bool _submitting = false;
  Json? _confirmation;
  String _teammatesError = '';
  String _submitError = '';
  int _formVersion = 0;

  @override
  void initState() {
    super.initState();
    // full events cannot take more people, so leave them out
    _openEvents = events.where((event) => event.status != 'full').toList();

    // ?event=capture-the-flag picks that event for you
    for (final event in _openEvents) {
      if (event.id == widget.eventId) {
        _selectedEventId = event.id;
        // most team events start with one teammate row already there
        if (event.maxTeamSize > 1) {
          _teammates.add(_Teammate(_nextTeammateId));
          _nextTeammateId = _nextTeammateId + 1;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    for (final mate in _teammates) {
      mate.controller.dispose();
    }
    super.dispose();
  }

  EventItem? _getSelectedEvent() {
    for (final event in _openEvents) {
      if (event.id == _selectedEventId) {
        return event;
      }
    }
    return null;
  }

  int _getPerPersonFee() {
    final selectedEvent = _getSelectedEvent();
    if (selectedEvent != null) {
      return selectedEvent.fee;
    }
    return 0;
  }

  int _getTeamSize() {
    return _teammates.length + 1;
  }

  // the fee for everyone in the team added together
  int _getTotalFee() {
    final fees = <int>[];
    for (int i = 0; i < _getTeamSize(); i++) {
      fees.add(_getPerPersonFee());
    }
    final total = int.parse(fees.fold<String>('', (sum, fee) => sum + fee.toString()));
    return total;
  }

  void _handleEventChange(String id) {
    _selectedEventId = id;
    final selectedEvent = _getSelectedEvent();
    if (selectedEvent != null && _teammates.length > selectedEvent.maxTeamSize - 1) {
      _teammates.removeRange(selectedEvent.maxTeamSize - 1, _teammates.length);
    }
    if (selectedEvent != null && selectedEvent.maxTeamSize > 1 && _teammates.isEmpty) {
      _addTeammate();
      return;
    }
    setState(() {});
  }

  void _addTeammate() {
    setState(() {
      _teammates.add(_Teammate(_nextTeammateId));
      _nextTeammateId = _nextTeammateId + 1;
    });
  }

  void _removeTeammate(int id) {
    setState(() {
      _teammates.removeWhere((mate) => mate.id == id);
    });
  }

  String? _validatePhone(String? value) {
    final phone = (value ?? '').trim();
    if (phone == '') {
      return errText('Enter your phone number.');
    }
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      return errText('Use a 10-digit phone number.');
    }
    return null;
  }

  // check every field. returns true when the form is ok.
  bool _validate() {
    bool ok = _formKey.currentState!.validate();

    String teammatesError = '';
    for (final mate in _teammates) {
      if (mate.controller.text.trim() == '') {
        teammatesError = 'Fill in every teammate name, or remove the empty ones.';
        ok = false;
      }
    }
    setState(() {
      _teammatesError = teammatesError;
    });

    return ok;
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _submitError = '';
    });
    if (!_validate()) {
      return;
    }

    final teammateNames = <String>[];
    for (final mate in _teammates) {
      teammateNames.add(mate.controller.text.trim());
    }

    setState(() {
      _submitting = true;
    });
    try {
      final registration = await createRegistration(
        eventId: _getSelectedEvent()!.id,
        participantName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        teammates: teammateNames,
        fee: _getTotalFee(),
      );
      if (!mounted) return;
      setState(() {
        _confirmation = registration;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = errorMessage(error, 'Something went wrong. Try again.');
      });
    }
    if (!mounted) return;
    setState(() {
      _submitting = false;
    });
  }

  // "Register for another event" puts an empty form back
  void _resetForm() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _selectedEventId = '';
      _teammates.clear();
      _teammatesError = '';
      _submitError = '';
      _confirmation = null;
      _formVersion = _formVersion + 1;
    });
  }

  Widget _buildTeammateRow(int index, _Teammate mate) {
    return Padding(
      key: ValueKey<int>(mate.id),
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: PlxTextField(label: 'Teammate ${index + 1}', controller: mate.controller),
          ),
          const SizedBox(width: 12),
          PlxButton(
            label: 'Remove',
            kind: ButtonKind.outline,
            small: true,
            onPressed: () => _removeTeammate(mate.id),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(PlxColors c) {
    final selectedEvent = _getSelectedEvent();
    int maxTeammates = 0;
    if (selectedEvent != null) {
      maxTeammates = selectedEvent.maxTeamSize - 1;
    }
    final addDisabled = selectedEvent == null || _teammates.length > maxTeammates;

    String note = 'Pick an event to see the team limit.';
    if (selectedEvent != null && selectedEvent.maxTeamSize == 1) {
      note = 'This one is solo.';
    } else if (selectedEvent != null) {
      note = 'Teams of up to ${selectedEvent.maxTeamSize}';
    }

    String counter = '';
    if (selectedEvent != null) {
      final allowed = selectedEvent.maxTeamSize - 1;
      counter = 'Teammates: ${_teammates.length} / $allowed allowed';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: c.lineSoft, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'TEAMMATES',
            style: monoStyle(size: 12, weight: FontWeight.w800, color: c.cyan, spacing: 0.7),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _teammates.length; i++) _buildTeammateRow(i, _teammates[i]),
          if (_teammatesError != '') ...[
            FormErrorText(_teammatesError),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PlxButton(
                label: 'Add teammate',
                kind: ButtonKind.outline,
                onPressed: addDisabled ? null : _addTeammate,
              ),
              Text(note, style: monoStyle(size: 13, color: c.muted)),
              if (counter != '') Text(counter, style: monoStyle(size: 13, weight: FontWeight.w700, color: c.ink)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFields(PlxColors c) {
    final options = <String, String>{'': 'Choose an event'};
    for (final event in _openEvents) {
      options[event.id] = '${event.title} (Day ${event.day})';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlxDropdown(
          key: ValueKey<String>('event-$_formVersion'),
          label: 'Event',
          value: _selectedEventId,
          options: options,
          validator: (value) {
            if (_getSelectedEvent() == null) {
              return errText('Pick an event.');
            }
            return null;
          },
          onChanged: _handleEventChange,
        ),
        const SizedBox(height: 20),
        PlxTextField(label: 'Full name', controller: _nameController, validator: validateName),
        const SizedBox(height: 20),
        PlxTextField(
          label: 'Email',
          controller: _emailController,
          validator: validateEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        PlxTextField(
          label: 'Phone',
          controller: _phoneController,
          validator: _validatePhone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 20),
        _buildTeamSection(c),
      ],
    );
  }

  Widget _buildSummaryRow(PlxColors c, String name, String value, {bool total = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: monoStyle(size: 13.6, weight: total ? FontWeight.w800 : FontWeight.w400, color: c.muted)),
          Text(
            value,
            style: monoStyle(
              size: total ? 19 : 13.6,
              weight: FontWeight.w800,
              color: total ? c.cyan : c.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(PlxColors c) {
    final perPersonFee = _getPerPersonFee();
    final teamSize = _getTeamSize();
    final totalFee = _getTotalFee();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.cyan, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Eyebrow('Fee summary'),
          const SizedBox(height: 8),
          _buildSummaryRow(c, 'Fee per person', formatPrice(perPersonFee)),
          _buildSummaryRow(c, 'Team size', '$teamSize'),
          _buildSummaryRow(c, 'Total', formatPrice(totalFee), total: true),
          const SizedBox(height: 4),
          Text(
            '${formatPrice(perPersonFee)} × $teamSize = ${formatPrice(totalFee)}',
            style: monoStyle(size: 12.5, color: c.muted),
          ),
          if (_submitError != '') ...[
            const SizedBox(height: 12),
            FormErrorText(_submitError),
          ],
          const SizedBox(height: 16),
          PlxButton(
            label: _submitting ? 'Sending...' : 'Register',
            expand: true,
            onPressed: _submitting ? null : _handleSubmit,
          ),
        ],
      ),
    );
  }

  Widget _buildForm(PlxColors c) {
    final fields = Form(key: _formKey, child: _buildFields(c));
    final summary = _buildSummary(c);
    if (isNarrow(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [fields, const SizedBox(height: 24), summary],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: fields),
        const SizedBox(width: 32),
        Expanded(flex: 2, child: summary),
      ],
    );
  }

  Widget _buildDoneRow(PlxColors c, String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: monoStyle(size: 13.6, color: c.muted)),
          const SizedBox(width: 12),
          Flexible(child: Text(value, style: monoStyle(size: 13.6, weight: FontWeight.w800, color: c.ink))),
        ],
      ),
    );
  }

  Widget _buildConfirmation(PlxColors c) {
    final registration = _confirmation!;
    String title = 'Registration confirmed';
    for (final event in _openEvents) {
      if (event.id == registration['eventId']) {
        title = event.title;
      }
    }
    final teamSize = (registration['teammates'] as List<dynamic>).length + 1;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.green, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow("You're in", color: c.green),
          const SizedBox(height: 8),
          Text(title, style: displayStyle(size: 32, color: c.ink)),
          const SizedBox(height: 16),
          _buildDoneRow(c, 'Registration id', registration['id'] as String),
          _buildDoneRow(c, 'Team size', '$teamSize'),
          _buildDoneRow(c, 'Total fee', formatPrice(registration['fee'] as int)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PlxButton(label: 'My bookings', onPressed: () => context.go('/my-bookings')),
              PlxButton(label: 'Register for another event', kind: ButtonKind.outline, onPressed: _resetForm),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return PageShell(
      currentPath: '/register',
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeading(
                eyebrow: '>> PARALLAX / 03',
                title: 'Put your name down',
                description: "Flying solo or bringing the whole team. There's room for your kind of energy.",
              ),
              const SizedBox(height: 32),
              if (_confirmation != null) _buildConfirmation(c) else _buildForm(c),
            ],
          ),
        ),
      ),
    );
  }
}
