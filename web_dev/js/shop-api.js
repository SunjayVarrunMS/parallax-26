// a pretend server for the merch shop. it waits a little, then saves to localStorage.

const cartKey = 'parallax:cart';
const ordersKey = 'parallax:orders';

// how many of one item are in orders that are still placed
function getOrderedQuantity(orders, itemId) {
  let total = 0;
  for (const order of orders) {
    if (order.status !== 'placed') {
      continue;
    }
    for (const line of order.lines) {
      if (line.itemId === itemId) {
        total = total + line.quantity;
      }
    }
  }
  return total;
}

// the merch from data.js, with stock reduced by what has been ordered
async function listMerch() {
  await wait(400);
  const orders = readStore(ordersKey, []);
  const items = [];
  for (const item of merch) {
    const copy = Object.assign({}, item);
    copy.stock = Math.max(0, item.stock - getOrderedQuantity(orders, item.id));
    items.push(copy);
  }
  return items;
}

async function getCart() {
  await wait(400);
  return readStore(cartKey, []);
}

// lines: [{ itemId, size, quantity }]
async function saveCart(lines) {
  await wait(400);
  writeStore(cartKey, lines);
}

async function clearCart() {
  await wait(400);
  writeStore(cartKey, []);
}

async function placeOrder(name, email) {
  const lines = readStore(cartKey, []);
  if (lines.length === 0) {
    throw new Error('Your cart is empty.');
  }

  await wait(400);

  const orders = readStore(ordersKey, []);
  const wanted = {};
  let total = 0;
  for (const line of lines) {
    const item = merch.find(function (entry) {
      return entry.id === line.itemId;
    });
    if (!item) {
      throw new Error('One of the items in your cart no longer exists.');
    }
    if (!wanted[item.id]) {
      wanted[item.id] = 0;
    }
    wanted[item.id] = wanted[item.id] + line.quantity;
    total = total + item.price * line.quantity;
  }

  for (const itemId in wanted) {
    const item = merch.find(function (entry) {
      return entry.id === itemId;
    });
    const left = item.stock - getOrderedQuantity(orders, itemId);
    if (wanted[itemId] > left) {
      throw new Error('Not enough stock for ' + item.name + '. Only ' + Math.max(0, left) + ' left.');
    }
  }

  const order = {
    id: makeId('ord'),
    lines: lines,
    total: total,
    name: name,
    email: email,
    status: 'placed',
    createdAt: new Date().toISOString(),
  };
  orders.push(order);
  writeStore(ordersKey, orders);
  writeStore(cartKey, []);
  return order;
}

async function listOrders() {
  await wait(400);
  return readStore(ordersKey, []);
}

async function cancelOrder(id) {
  await wait(400);

  const orders = readStore(ordersKey, []);
  const order = orders.find(function (item) {
    return item.id === id;
  });
  if (!order) {
    throw new Error('Order not found.');
  }
  if (order.status === 'cancelled') {
    throw new Error('That order is already cancelled.');
  }

  order.status = 'cancelled';
  writeStore(ordersKey, orders);
}
