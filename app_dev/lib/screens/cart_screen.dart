// the cart screen: change quantities, remove things, then check out

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/shop_api.dart';
import '../data.dart';
import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/buttons.dart';
import '../widgets/form_parts.dart';
import '../widgets/page_heading.dart';
import '../widgets/page_shell.dart';
import '../widgets/panels.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<Json> _lines = [];
  final Map<String, int> _stockById = {};
  bool _submitting = false;
  bool _loading = true;
  String _loadError = '';
  String _submitError = '';
  Json? _doneOrder;

  @override
  void initState() {
    super.initState();
    _setUpPage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _setUpPage() async {
    try {
      _lines = await getCart();
      final items = await listMerch();
      for (final item in items) {
        _stockById[item.id] = item.stock;
      }
    } catch (error) {
      _loadError = errorMessage(error, 'Try again in a moment.');
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  MerchItem _findItem(String id) {
    return merch.firstWhere((item) => item.id == id);
  }

  int _getTotal() {
    int total = 0;
    for (final line in _lines) {
      total = total + _findItem(line['itemId'] as String).price;
    }
    return total;
  }

  int _getItemCount() {
    int count = 0;
    for (final line in _lines) {
      count = count + (line['quantity'] as int);
    }
    return count;
  }

  // how many of one item are in the cart, in any size
  int _countItem(String itemId) {
    int count = 0;
    for (final line in _lines) {
      if (line['itemId'] == itemId) {
        count = count + (line['quantity'] as int);
      }
    }
    return count;
  }

  Future<void> _saveLines() async {
    try {
      await saveCart(_lines);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitError = errorMessage(error, 'Could not save your cart.');
      });
    }
  }

  void _handleLineAction(int index, String action) {
    final line = _lines[index];
    setState(() {
      if (action == 'plus') {
        line['quantity'] = (line['quantity'] as int) + 1;
      } else if (action == 'minus' && (line['quantity'] as int) > 1) {
        line['quantity'] = (line['quantity'] as int) - 1;
      } else if (action == 'remove') {
        _lines.removeAt(index);
      }
    });
    _saveLines();
  }

  Future<void> _placeOrder() async {
    setState(() {
      _submitError = '';
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitting = true;
    });
    try {
      final order = await placeOrder(_nameController.text.trim(), _emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _lines = [];
        _doneOrder = order;
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

  Widget _buildEmptyState(PlxColors c, String title, String message, {bool showButton = true}) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: monoStyle(size: 17.6, weight: FontWeight.w800, color: c.ink)),
        const SizedBox(height: 6),
        Text(message, style: monoStyle(size: 13.6, color: c.muted)),
      ],
    );
    return PlxPanel(
      barLeft: '>CART',
      barRight: '[EMPTY]',
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('>_', style: displayStyle(size: 32, color: c.accent, height: 1)),
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: text),
          if (showButton) PlxButton(label: 'Go to merch', onPressed: () => context.go('/merch')),
        ],
      ),
    );
  }

  Widget _buildLine(PlxColors c, int index) {
    final line = _lines[index];
    final item = _findItem(line['itemId'] as String);
    final quantity = line['quantity'] as int;
    String sizeText = 'One size';
    if (line['size'] != '') {
      sizeText = 'Size ${line['size']}';
    }
    final plusDisabled = _countItem(item.id) >= (_stockById[item.id] ?? 0);

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.name.toUpperCase(), style: monoStyle(size: 15.2, weight: FontWeight.w800, color: c.ink, height: 1.4)),
        Text('$sizeText - ${formatPrice(item.price)} each', style: monoStyle(size: 13, color: c.muted)),
      ],
    );
    final stepper = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StepButton(
          label: '-',
          tooltip: 'One less ${item.name}',
          onPressed: () => _handleLineAction(index, 'minus'),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: monoStyle(weight: FontWeight.w800, color: c.ink),
          ),
        ),
        StepButton(
          label: '+',
          tooltip: 'One more ${item.name}',
          onPressed: plusDisabled ? null : () => _handleLineAction(index, 'plus'),
        ),
      ],
    );
    final lineTotal = Text(
      formatPrice(item.price * quantity),
      style: monoStyle(weight: FontWeight.w800, color: c.cyan),
    );
    final remove = InkWell(
      onTap: () => _handleLineAction(index, 'remove'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'REMOVE',
          style: monoStyle(size: 12, weight: FontWeight.w800, color: c.accent, spacing: 0.7),
        ),
      ),
    );

    Widget content;
    if (isNarrow(context)) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          info,
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [stepper, lineTotal],
          ),
          remove,
        ],
      );
    } else {
      content = Row(
        children: [
          Expanded(child: info),
          stepper,
          const SizedBox(width: 24),
          SizedBox(width: 90, child: Align(alignment: Alignment.centerRight, child: lineTotal)),
          const SizedBox(width: 24),
          remove,
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

  Widget _buildSummaryRow(PlxColors c, String name, String value, {bool total = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: monoStyle(size: 13.6, color: c.muted)),
          Text(
            value,
            style: monoStyle(size: total ? 19 : 13.6, weight: FontWeight.w800, color: total ? c.cyan : c.ink),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckout(PlxColors c) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.cyan, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Eyebrow('Checkout'),
            const SizedBox(height: 8),
            _buildSummaryRow(c, 'Items', 'Items: ${_getItemCount()}'),
            _buildSummaryRow(c, 'Total', formatPrice(_getTotal()), total: true),
            const SizedBox(height: 12),
            PlxTextField(label: 'Full name', controller: _nameController, validator: validateName),
            const SizedBox(height: 16),
            PlxTextField(
              label: 'Email',
              controller: _emailController,
              validator: validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            if (_submitError != '') ...[
              const SizedBox(height: 12),
              FormErrorText(_submitError),
            ],
            const SizedBox(height: 16),
            PlxButton(
              label: _submitting ? 'Sending...' : 'Place order',
              expand: true,
              onPressed: _placeOrder,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(PlxColors c) {
    final linesPanel = PlxPanel(
      barLeft: '>CART',
      barRight: '${_lines.length} lines',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (int i = 0; i < _lines.length; i++) _buildLine(c, i)],
      ),
    );
    final checkout = _buildCheckout(c);
    if (isNarrow(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [linesPanel, const SizedBox(height: 24), checkout],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: linesPanel),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: checkout),
      ],
    );
  }

  Widget _buildDone(PlxColors c) {
    final order = _doneOrder!;
    Widget row(String name, String value) {
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.green, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow('Order placed', color: c.green),
          const SizedBox(height: 8),
          Text('Thanks for your order', style: displayStyle(size: 32, color: c.ink)),
          const SizedBox(height: 16),
          row('Order id', order['id'] as String),
          row('Total', formatPrice(order['total'] as int)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PlxButton(label: 'My bookings', onPressed: () => context.go('/my-bookings')),
              PlxButton(label: 'Keep shopping', kind: ButtonKind.outline, onPressed: () => context.go('/merch')),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);

    Widget body = const SizedBox.shrink();
    if (_loading) {
      body = const LoadingText('Loading your cart...');
    } else if (_doneOrder != null) {
      body = _buildDone(c);
    } else if (_loadError != '') {
      body = _buildEmptyState(c, 'Could not load your cart.', _loadError);
    } else if (_lines.isEmpty) {
      body = _buildEmptyState(c, 'Your cart is empty.', 'Items you add from the shop will show up here.');
    } else {
      body = _buildContent(c);
    }

    return PageShell(
      currentPath: '/cart',
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeading(
                eyebrow: '>> PARALLAX / 11',
                title: 'Your cart',
                description: "Everything you're about to buy, in one place.",
              ),
              const SizedBox(height: 40),
              body,
            ],
          ),
        ),
      ),
    );
  }
}
