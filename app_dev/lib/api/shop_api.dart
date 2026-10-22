// a pretend server for the merch shop. it waits a little, then saves to shared_preferences.

import '../data.dart';
import '../store.dart';
import '../utils.dart';

const String cartKey = 'parallax:cart';
const String ordersKey = 'parallax:orders';

// how many of one item are in orders that are still placed
int getOrderedQuantity(List<Json> orders, String itemId) {
  int total = 0;
  for (final order in orders) {
    if (order['status'] != 'placed') {
      continue;
    }
    for (final line in order['lines'] as List<dynamic>) {
      if (line['itemId'] == itemId) {
        total = total + (line['quantity'] as int);
      }
    }
  }
  return total;
}

// the merch from data.dart, with stock reduced by what has been ordered
Future<List<MerchItem>> listMerch() async {
  await wait(400);
  final orders = readList(ordersKey);
  final items = <MerchItem>[];
  for (final item in merch) {
    final left = item.stock - getOrderedQuantity(orders, item.id);
    items.add(item.withStock(left < 0 ? 0 : left));
  }
  return items;
}

Future<List<Json>> getCart() async {
  await wait(400);
  return readList(cartKey);
}

// lines: [{ itemId, size, quantity }]
Future<void> saveCart(List<Json> lines) async {
  await wait(400);
  writeStore(cartKey, lines);
}

Future<void> clearCart() async {
  await wait(400);
  writeStore(cartKey, <dynamic>[]);
}

Future<Json> placeOrder(String name, String email) async {
  final lines = readList(cartKey);
  if (lines.isEmpty) {
    throw ApiError('Your cart is empty.');
  }

  await wait(400);

  final orders = readList(ordersKey);
  final wanted = <String, int>{};
  int total = 0;
  for (final line in lines) {
    final matches = merch.where((entry) => entry.id == line['itemId']);
    if (matches.isEmpty) {
      throw ApiError('One of the items in your cart no longer exists.');
    }
    final item = matches.first;
    final quantity = line['quantity'] as int;
    wanted[item.id] = (wanted[item.id] ?? 0) + quantity;
    total = total + item.price * quantity;
  }

  for (final itemId in wanted.keys) {
    final item = merch.firstWhere((entry) => entry.id == itemId);
    final left = item.stock - getOrderedQuantity(orders, itemId);
    if (wanted[itemId]! > left) {
      throw ApiError(
        'Not enough stock for ${item.name}. Only ${left < 0 ? 0 : left} left.',
      );
    }
  }

  final order = <String, dynamic>{
    'id': makeId('ord'),
    'lines': lines,
    'total': total,
    'name': name,
    'email': email,
    'status': 'placed',
    'createdAt': DateTime.now().toUtc().toIso8601String(),
  };
  orders.add(order);
  writeStore(ordersKey, orders);
  writeStore(cartKey, <dynamic>[]);
  return order;
}

Future<List<Json>> listOrders() async {
  await wait(400);
  return readList(ordersKey);
}

Future<void> cancelOrder(String id) async {
  await wait(400);

  final orders = readList(ordersKey);
  final matches = orders.where((item) => item['id'] == id);
  if (matches.isEmpty) {
    throw ApiError('Order not found.');
  }
  final order = matches.first;
  if (order['status'] == 'cancelled') {
    throw ApiError('That order is already cancelled.');
  }

  order['status'] = 'cancelled';
  writeStore(ordersKey, orders);
}
