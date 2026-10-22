// the merch screen: pick a size and quantity, then add things to the cart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/shop_api.dart';
import '../data.dart';
import '../store.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/badges.dart';
import '../widgets/buttons.dart';
import '../widgets/form_parts.dart';
import '../widgets/page_heading.dart';
import '../widgets/page_shell.dart';
import '../widgets/panels.dart';

class MerchScreen extends StatefulWidget {
  const MerchScreen({super.key});

  @override
  State<MerchScreen> createState() => _MerchScreenState();
}

class _MerchScreenState extends State<MerchScreen> {
  List<MerchItem> _items = [];
  bool _loading = true;
  String _loadError = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await listMerch();
      if (!mounted) return;
      setState(() {
        _items = items;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = errorMessage(error, 'Could not load the shop.');
      });
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  // the "What people are saying" box
  Widget _buildReview(String text, String reviewer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF475569), height: 1.5),
          ),
          const SizedBox(height: 10),
          Text(
            reviewer,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF818CF8), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 48),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x1F0F172A), blurRadius: 30, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF38BDF8), Color(0xFF818CF8), Color(0xFFF472B6)],
            ).createShader(bounds),
            child: const Text(
              'What people are saying',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25.6, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          CardGrid(
            gap: 20,
            minWidth: 220,
            children: [
              _buildReview('Absolutely game-changing merch! 🚀✨ Elevated my wardrobe to the next level! 🔥', '- Happy Customer 😍'),
              _buildReview('Truly a must-have experience! 💯 The quality is unmatched and the vibes are immaculate! 🎉🙌', '- Satisfied Shopper 🤩'),
              _buildReview('Seamless, delightful and so much fun! 🌟 I will be unlocking my potential in this gear! 💖', '- Festival Fan 🥳'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      currentPath: '/merch',
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeading(
                eyebrow: '>> PARALLAX / 10',
                title: 'Wear the festival',
                description: "Something to take home that isn't a flyer.",
              ),
              if (_loading) const LoadingText('Loading the shop...'),
              if (_loadError != '')
                Padding(padding: const EdgeInsets.only(top: 32), child: FormErrorText(_loadError)),
              const SizedBox(height: 40),
              CardGrid(
                maxColumns: 4,
                minWidth: 230,
                children: [for (final item in _items) _MerchCard(item: item)],
              ),
              _buildReviews(),
            ],
          ),
        ),
      ),
    );
  }
}

// one merch card with its own size, quantity and message
class _MerchCard extends StatefulWidget {
  const _MerchCard({required this.item});

  final MerchItem item;

  @override
  State<_MerchCard> createState() => _MerchCardState();
}

class _MerchCardState extends State<_MerchCard> {
  final TextEditingController _qtyController = TextEditingController(text: '1');
  int _sizeIndex = 0;
  bool _adding = false;
  String _message = '';
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    // the medium size starts picked
    final mediumIndex = widget.item.sizes.indexOf('M');
    if (mediumIndex >= 0) {
      _sizeIndex = mediumIndex;
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _showMessage(String message, bool isError) {
    setState(() {
      _message = message;
      _messageIsError = isError;
    });
  }

  void _changeQuantity(int amount) {
    final item = widget.item;
    int quantity = (int.tryParse(_qtyController.text.trim()) ?? 0) + amount;
    if (quantity < 1) {
      quantity = 1;
    }
    if (quantity > item.stock) {
      quantity = item.stock;
    }
    _qtyController.text = '$quantity';
  }

  String _getChosenSize() {
    final item = widget.item;
    if (item.sizes.isEmpty) {
      return '';
    }
    return item.sizes[(_sizeIndex - 1) % item.sizes.length];
  }

  // how many of this item are already in the cart, in any size
  int _countInCart(List<Json> cart, String itemId) {
    int count = 0;
    for (final line in cart) {
      if (line['itemId'] == itemId) {
        count = count + (line['quantity'] as int);
      }
    }
    return count;
  }

  Future<void> _addToCart() async {
    final item = widget.item;
    final quantity = int.tryParse(_qtyController.text.trim()) ?? 0;
    final size = _getChosenSize();

    if (quantity < 1) {
      _showMessage('Pick a quantity of 1 or more.', true);
      return;
    }

    setState(() {
      _adding = true;
    });
    _showMessage('Adding...', false);
    try {
      final cart = await getCart();
      final inCart = _countInCart(cart, item.id);
      if (item.stock > 0 && inCart + quantity > item.stock) {
        if (!mounted) return;
        _showMessage('Only ${item.stock} in stock, and $inCart already in your cart.', true);
        setState(() {
          _adding = false;
        });
        return;
      }

      final matches = cart.where((entry) => entry['itemId'] == item.id && entry['size'] == size);
      if (matches.isNotEmpty) {
        matches.first['quantity'] = (matches.first['quantity'] as int) + quantity;
      } else {
        cart.add({'itemId': item.id, 'size': size, 'quantity': quantity});
      }
      await saveCart(cart);

      String sizeText = '';
      if (size != '') {
        sizeText = ' ($size)';
      }
      if (!mounted) return;
      _showMessage('>> Added ${item.name}$sizeText x$quantity', false);
    } catch (error) {
      if (!mounted) return;
      _showMessage(errorMessage(error, 'Something went wrong. Try again.'), true);
    }
    if (!mounted) return;
    setState(() {
      _adding = false;
    });
  }

  Widget _buildSizePicker(PlxColors c) {
    final item = widget.item;
    if (item.sizes.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('>> SIZE', style: monoStyle(size: 12, weight: FontWeight.w800, color: c.cyan, spacing: 0.7)),
          for (int i = 0; i < item.sizes.length; i++)
            InkWell(
              onTap: () => setState(() => _sizeIndex = i),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _sizeIndex == i ? c.cyan : Colors.transparent,
                  border: Border.all(color: _sizeIndex == i ? c.cyan : c.lineSoft, width: 2),
                ),
                child: Text(
                  item.sizes[i],
                  style: monoStyle(
                    size: 12,
                    weight: FontWeight.w700,
                    color: _sizeIndex == i ? c.onCyan : c.ink,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuantityRow(PlxColors c) {
    final item = widget.item;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('>> QTY', style: monoStyle(size: 12, weight: FontWeight.w800, color: c.cyan, spacing: 0.7)),
          StepButton(
            label: '-',
            tooltip: 'One less ${item.name}',
            onPressed: () => _changeQuantity(-1),
          ),
          SizedBox(
            width: 56,
            height: 44,
            child: TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              cursorColor: c.cyan,
              style: monoStyle(size: 14.4, color: c.ink, height: 1.2),
              decoration: plxDecoration(context).copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8)),
            ),
          ),
          StepButton(
            label: '+',
            tooltip: 'One more ${item.name}',
            onPressed: () => _changeQuantity(1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    final item = widget.item;

    Color artColor = toneColor(c, item.tone);
    Color artText = c.onCyan;
    if (item.tone == 'ink') {
      artText = c.paper;
    }

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.cyan, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 150,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: artColor,
              border: Border(bottom: BorderSide(color: c.cyan, width: 2)),
            ),
            child: Text(
              item.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: displayStyle(size: 25.6, color: artText, height: 1.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: monoStyle(size: 16.8, weight: FontWeight.w800, color: const Color(0xFFF4FDFF), height: 1.3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      formatPrice(item.price),
                      style: monoStyle(weight: FontWeight.w800, color: c.cyan),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.description,
                  style: monoStyle(size: 13.6, color: const Color(0xFFE6FBFF)),
                ),
                const SizedBox(height: 12),
                Text(
                  '${item.stock} left'.toUpperCase(),
                  style: monoStyle(size: 11.5, weight: FontWeight.w700, color: c.green, spacing: 0.6, height: 1.5),
                ),
                const SizedBox(height: 12),
                if (item.stock == 0) ...[
                  const PlxBadge('Sold out', 'coral'),
                  const SizedBox(height: 12),
                ],
                _buildSizePicker(c),
                _buildQuantityRow(c),
                PlxButton(
                  label: 'Add to cart',
                  expand: true,
                  onPressed: (item.stock < 0 || _adding) ? null : _addToCart,
                ),
                const SizedBox(height: 12),
                Text(
                  _message,
                  style: monoStyle(
                    size: 12.5,
                    weight: FontWeight.w700,
                    color: _messageIsError ? c.error : c.green,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
