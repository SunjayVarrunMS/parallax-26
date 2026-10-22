// the my bookings page: event registrations, workshop bookings and merch orders

let registrations = [];
let workshopBookings = [];
let orders = [];
let confirmingId = '';
let busyId = '';

const loadingText = document.querySelector('#bookings-loading');
const errorText = document.querySelector('#bookings-error');
const sectionsBox = document.querySelector('#bookings-sections');

const statusTones = {
  confirmed: 'green',
  waitlisted: 'blue',
  cancelled: 'neutral',
  placed: 'green',
};

function findEvent(id) {
  return events.find(function (item) {
    return item.id === id;
  });
}

function findWorkshop(id) {
  return workshops.find(function (item) {
    return item.id === id;
  });
}

function findMerch(id) {
  return merch.find(function (item) {
    return item.id === id;
  });
}

const statusTags = {
  confirmed: 'confirmed',
  waitlisted: 'confirmed',
  cancelled: 'cancelled',
  placed: 'placed',
};

function statusHtml(status) {
  return `<span class="badge badge--${statusTones[status]}">${statusTags[status]}</span>`;
}

function actionsHtml(id, status) {
  if (status === 'cancelled') {
    return '';
  }
  if (busyId === id) {
    return '<p class="my-bookings-page__ask">Cancelling...</p>';
  }
  if (confirmingId === id) {
    return `
      <div class="my-bookings-page__confirm" role="group" aria-label="Cancel this?">
        <span class="my-bookings-page__ask">Cancel this?</span>
        <button type="button" class="button button--primary" data-action="yes" data-id="${id}">Yes</button>
        <button type="button" class="button button--outline" data-action="no" data-id="${id}">Keep it</button>
      </div>
    `;
  }
  return `<button type="button" class="button button--outline" data-action="ask" data-id="${id}">Cancel</button>`;
}

function rowHtml(id, title, detail, dateText, status) {
  return `
    <li class="my-bookings-page__row">
      <div class="my-bookings-page__what">
        <h3>${title}</h3>
        <p>${detail}</p>
        <p class="my-bookings-page__date">${dateText}</p>
      </div>
      ${statusHtml(status)}
      <div class="my-bookings-page__actions">${actionsHtml(id, status)}</div>
    </li>
  `;
}

function emptyHtml(text, linkFile, linkText) {
  return `
    <li class="my-bookings-page__empty">
      <p>${text}</p>
      <a href="${linkFile}" class="text-link">&gt;&gt; ${linkText}</a>
    </li>
  `;
}

function renderRegistrations() {
  let html = '';
  for (const registration of registrations) {
    const event = findEvent(registration.eventId);
    let title = 'Event';
    let dateText = formatDate(registration.createdAt);
    if (event) {
      title = event.title;
      dateText = formatDate(event.startsAt) + ', ' + formatTime(event.startsAt);
    }
    const teamSize = registration.teammates.length + 1;
    const detail = 'Team of ' + teamSize + ' - ' + formatPrice(registration.fee);
    html += rowHtml(registration.id, title, detail, dateText, registration.status);
  }
  if (html === '') {
    html = emptyHtml('No event registrations yet.', 'register.html', 'Register for an event');
  }
  document.querySelector('#registrations-list').innerHTML = html;
  document.querySelector('#registrations-count').textContent = registrations.length + ' total';
}

function renderWorkshopBookings() {
  let html = '';
  for (const booking of workshopBookings) {
    const workshop = findWorkshop(booking.workshopId);
    let title = 'Workshop';
    let dateText = formatDate(booking.createdAt);
    if (workshop) {
      title = workshop.title;
      dateText = formatDate(workshop.startsAt) + ', ' + formatTime(workshop.startsAt);
    }
    let detail = booking.name;
    if (booking.status === 'waitlisted') {
      detail = detail + ' - waitlist position ' + getWaitlistPosition(workshopBookings, booking);
    }
    html += rowHtml(booking.id, title, detail, dateText, booking.status);
  }
  if (html === '') {
    html = emptyHtml('No workshop bookings yet.', 'workshops.html', 'Browse workshops');
  }
  document.querySelector('#workshops-list').innerHTML = html;
  document.querySelector('#workshops-count').textContent = workshopBookings.length + ' total';
}

function orderSummary(order) {
  const parts = [];
  for (const line of order.lines) {
    const item = findMerch(line.itemId);
    let text = line.itemId;
    if (item) {
      text = item.name;
    }
    if (line.size !== '') {
      text = text + ' (' + line.size + ')';
    }
    parts.push(text + ' x' + line.quantity);
  }
  return parts.join(', ');
}

function renderOrders() {
  let html = '';
  for (const order of orders) {
    const title = 'Order ' + order.id;
    const detail = orderSummary(order) + ' - ' + formatPrice(order.total);
    const dateText = 'Ordered ' + formatDate(order.createdAt);
    html += rowHtml(order.id, title, detail, dateText, order.status);
  }
  if (html === '') {
    html = emptyHtml('No merch orders yet.', 'merch.html', 'Visit the shop');
  }
  document.querySelector('#orders-list').innerHTML = html;
  document.querySelector('#orders-count').textContent = orders.length + ' total';
}

function renderAll() {
  renderRegistrations();
  renderWorkshopBookings();
  renderOrders();
}

async function cancelItem(id) {
  busyId = id;
  confirmingId = '';
  errorText.hidden = true;
  renderAll();
  try {
    if (id.startsWith('reg_')) {
      await cancelRegistration(id);
    } else if (id.startsWith('wsh_')) {
      await cancelBooking(id);
    } else {
      await cancelOrder(id);
    }
    await loadData();
  } catch (error) {
    errorText.textContent = error.message || 'Could not cancel that. Try again.';
    errorText.hidden = false;
  }
  busyId = '';
  renderAll();
}

function handleClick(event) {
  const button = event.target.closest('button[data-action]');
  if (!button || busyId !== '') {
    return;
  }
  const id = button.dataset.id;
  const action = button.dataset.action;
  if (action === 'ask') {
    confirmingId = id;
    renderAll();
  } else if (action === 'no') {
    confirmingId = '';
    renderAll();
  } else if (action === 'yes') {
    cancelItem(id);
  }
}

async function loadData() {
  registrations = await listRegistrations();
  workshopBookings = await listBookings();
  orders = await listOrders();
}

async function setUpPage() {
  try {
    await loadData();
    renderAll();
    sectionsBox.hidden = false;
  } catch (error) {
    errorText.textContent = error.message || 'Could not load your bookings.';
    errorText.hidden = false;
  }
  loadingText.hidden = true;
}

sectionsBox.addEventListener('click', handleClick);

setUpPage();
