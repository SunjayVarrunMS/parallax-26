// the my bookings screen: event registrations, workshop bookings and merch orders

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/registrations_api.dart';
import '../api/shop_api.dart';
import '../api/workshops_api.dart';
import '../data.dart';
import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/badges.dart';
import '../widgets/buttons.dart';
import '../widgets/page_heading.dart';
import '../widgets/page_shell.dart';
import '../widgets/panels.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<Json> _registrations = [];
  List<Json> _workshopBookings = [];
  List<Json> _orders = [];
  String _confirmingId = '';
  String _busyId = '';
  bool _loading = true;
  bool _loaded = false;
  String _errorText = '';

  // the badge colour for each status
  final Map<String, String> _statusTones = {
    'confirmed': 'green',
    'waitlisted': 'blue',
    'cancelled': 'neutral',
    'placed': 'green',
  };

  // the word shown in each badge
  final Map<String, String> _statusTags = {
    'confirmed': 'confirmed',
    'waitlisted': 'confirmed',
    'cancelled': 'cancelled',
    'placed': 'placed',
  };

  @override
  void initState() {
    super.initState();
    _setUpPage();
  }

  Future<void> _loadData() async {
    _registrations = await listRegistrations();
    _workshopBookings = await listBookings();
    _orders = await listOrders();
  }

  Future<void> _setUpPage() async {
    try {
      await _loadData();
      if (!mounted) return;
      setState(() {
        _loaded = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = errorMessage(error, 'Could not load your bookings.');
      });
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  Future<void> _cancelItem(String id) async {
    setState(() {
      _busyId = id;
      _confirmingId = '';
      _errorText = '';
    });
    try {
      if (id.startsWith('reg_')) {
        await cancelRegistration(id);
      } else if (id.startsWith('wsh_')) {
        await cancelBooking(id);
      } else {
        await cancelOrder(id);
      }
      await _loadData();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = errorMessage(error, 'Could not cancel that. Try again.');
      });
    }
    if (!mounted) return;
    setState(() {
      _busyId = '';
    });
  }

  EventItem? _findEvent(String id) {
    for (final item in events) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  Workshop? _findWorkshop(String id) {
    for (final item in workshops) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  MerchItem? _findMerch(String id) {
    for (final item in merch) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  Widget _buildActions(PlxColors c, String id, String status) {
    if (status == 'cancelled') {
      return const SizedBox.shrink();
    }
    if (_busyId == id) {
      return Text('Cancelling...', style: monoStyle(size: 13, weight: FontWeight.w700, color: c.muted));
    }
    if (_confirmingId == id) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Cancel this?', style: monoStyle(size: 13, weight: FontWeight.w700, color: c.ink)),
          PlxButton(
            label: 'Yes',
            small: true,
            onPressed: _busyId != '' ? null : () => _cancelItem(id),
          ),
          PlxButton(
            label: 'Keep it',
            small: true,
            kind: ButtonKind.outline,
            onPressed: () => setState(() => _confirmingId = ''),
          ),
        ],
      );
    }
    return PlxButton(
      label: 'Cancel',
      small: true,
      kind: ButtonKind.outline,
      onPressed: _busyId != '' ? null : () => setState(() => _confirmingId = id),
    );
  }

  Widget _buildRow(PlxColors c, String id, String title, String detail, String dateText, String status) {
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: monoStyle(size: 15.2, weight: FontWeight.w800, color: c.ink, height: 1.4)),
        Text(detail, style: monoStyle(size: 13, color: c.muted, height: 1.5)),
        Text(dateText, style: monoStyle(size: 12, color: c.muted, height: 1.5)),
      ],
    );
    final badge = PlxBadge(_statusTags[status] ?? status, _statusTones[status] ?? 'neutral');
    final actions = _buildActions(c, id, status);

    Widget content;
    if (isNarrow(context)) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [info, const SizedBox(height: 8), badge, const SizedBox(height: 8), actions],
      );
    } else {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: info),
          const SizedBox(width: 16),
          badge,
          const SizedBox(width: 24),
          SizedBox(width: 220, child: Align(alignment: Alignment.centerRight, child: actions)),
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.lineSoft)),
      ),
      child: content,
    );
  }

  Widget _buildEmpty(PlxColors c, String text, String path, String linkText) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: monoStyle(size: 13.6, color: c.muted)),
          TextLink(linkText, onTap: () => context.go(path)),
        ],
      ),
    );
  }

  Widget _buildRegistrations(PlxColors c) {
    final rows = <Widget>[];
    for (final registration in _registrations) {
      final event = _findEvent(registration['eventId'] as String);
      String title = 'Event';
      String dateText = formatDate(registration['createdAt'] as String);
      if (event != null) {
        title = event.title;
        dateText = '${formatDate(event.startsAt)}, ${formatTime(event.startsAt)}';
      }
      final teamSize = (registration['teammates'] as List<dynamic>).length + 1;
      final detail = 'Team of $teamSize - ${formatPrice(registration['fee'] as int)}';
      rows.add(_buildRow(c, registration['id'] as String, title, detail, dateText, registration['status'] as String));
    }
    if (rows.isEmpty) {
      rows.add(_buildEmpty(c, 'No event registrations yet.', '/register', 'Register for an event'));
    }
    return PlxPanel(
      barLeft: '>EVENT REGISTRATIONS',
      barRight: '${_registrations.length} total',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );
  }

  Widget _buildWorkshopBookings(PlxColors c) {
    final rows = <Widget>[];
    for (final booking in _workshopBookings) {
      final workshop = _findWorkshop(booking['workshopId'] as String);
      String title = 'Workshop';
      String dateText = formatDate(booking['createdAt'] as String);
      if (workshop != null) {
        title = workshop.title;
        dateText = '${formatDate(workshop.startsAt)}, ${formatTime(workshop.startsAt)}';
      }
      String detail = booking['name'] as String;
      if (booking['status'] == 'waitlisted') {
        detail = '$detail - waitlist position ${getWaitlistPosition(_workshopBookings, booking)}';
      }
      rows.add(_buildRow(c, booking['id'] as String, title, detail, dateText, booking['status'] as String));
    }
    if (rows.isEmpty) {
      rows.add(_buildEmpty(c, 'No workshop bookings yet.', '/workshops', 'Browse workshops'));
    }
    return PlxPanel(
      barLeft: '>WORKSHOP BOOKINGS',
      barRight: '${_workshopBookings.length} total',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );
  }

  String _orderSummary(Json order) {
    final parts = <String>[];
    for (final line in order['lines'] as List<dynamic>) {
      final item = _findMerch(line['itemId'] as String);
      String text = line['itemId'] as String;
      if (item != null) {
        text = item.name;
      }
      if (line['size'] != '') {
        text = '$text (${line['size']})';
      }
      parts.add('$text x${line['quantity']}');
    }
    return parts.join(', ');
  }

  Widget _buildOrders(PlxColors c) {
    final rows = <Widget>[];
    for (final order in _orders) {
      final title = 'Order ${order['id']}';
      final detail = '${_orderSummary(order)} - ${formatPrice(order['total'] as int)}';
      final dateText = 'Ordered ${formatDate(order['createdAt'] as String)}';
      rows.add(_buildRow(c, order['id'] as String, title, detail, dateText, order['status'] as String));
    }
    if (rows.isEmpty) {
      rows.add(_buildEmpty(c, 'No merch orders yet.', '/merch', 'Visit the shop'));
    }
    return PlxPanel(
      barLeft: '>MERCH ORDERS',
      barRight: '${_orders.length} total',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return PageShell(
      currentPath: '/my-bookings',
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeading(
                eyebrow: '>> PARALLAX / 04',
                title: 'Your festival',
                description: "All the things you've said yes to, in one place.",
              ),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text('Loading your bookings...', style: monoStyle(size: 13, color: c.green)),
                ),
              if (_errorText != '') Padding(padding: const EdgeInsets.only(top: 32), child: FormErrorText(_errorText)),
              if (_loaded) ...[
                const SizedBox(height: 40),
                _buildRegistrations(c),
                const SizedBox(height: 24),
                _buildWorkshopBookings(c),
                const SizedBox(height: 24),
                _buildOrders(c),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
