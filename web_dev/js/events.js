// the events page: search box, category and day filters, and the list of cards

let selectedCategory = 'All';
let selectedDay = 'All';

const searchInput = document.querySelector('#event-search');
const categoryButtons = document.querySelectorAll('[data-category]');
const dayButtons = document.querySelectorAll('[data-day]');

const categoryTones = {
  Culture: 'coral',
  Tech: 'blue',
  Workshop: 'green',
};

function getVenueName(venueId) {
  const venue = venues.find(function (item) {
    return item.id === venueId;
  });
  if (venue) {
    return venue.name;
  }
  return '';
}

// does this event match the search box and the category?
function matchesFilters(event) {
  const query = searchInput.value.trim();
  const matchesSearch =
    query === '' ||
    event.title.toLowerCase().includes(query) ||
    event.description.toLowerCase().includes(query);
  const matchesCategory = selectedCategory === 'All' || event.category === selectedCategory;
  return matchesSearch && matchesCategory;
}

function matchesDay(event) {
  return selectedDay === 'All' || event.day === selectedDay;
}

function statusBadgeHtml(status) {
  if (status === 'open') {
    return '<span class="badge badge--green">Open</span>';
  }
  if (status === 'full') {
    return '<span class="badge badge--coral">Full</span>';
  }
  return '<span class="badge badge--neutral">Cancelled</span>';
}

function eventCardHtml(event) {
  let registerLink = '';
  if (event.status !== 'full') {
    registerLink = `
      <a href="register.html?event=${event.id}" class="events-page__register" aria-label="Register for ${event.title}">
        <span aria-hidden="true">&gt;&gt;</span> Register
      </a>
    `;
  }

  return `
    <li class="events-page__card events-page__card--${event.status}">
      <div class="events-page__card-top">
        <span class="badge badge--${categoryTones[event.category]}">${event.category}</span>
        <span class="badge badge--neutral">Day 0${event.day}</span>
        ${statusBadgeHtml(event.status)}
      </div>
      <h2>${event.title}</h2>
      <p class="events-page__description">${event.description}</p>
      <dl class="events-page__details">
        <div>
          <dt>Day</dt>
          <dd>Day ${event.day}</dd>
        </div>
        <div>
          <dt>Time</dt>
          <dd>${formatTime(event.startsAt)} - ${formatTime(event.endsAt)}</dd>
        </div>
        <div>
          <dt>Venue</dt>
          <dd>${getVenueName(event.venueId)}</dd>
        </div>
        <div>
          <dt>Fee</dt>
          <dd>${formatPrice(event.fee)}</dd>
        </div>
      </dl>
      ${registerLink}
    </li>
  `;
}

function renderEvents() {
  // show the matching events
  const visibleEvents = events.filter(function (event) {
    return matchesFilters(event) && matchesDay(event);
  });
  const foundCount = events.filter(matchesFilters).length;

  let label = 'events';
  if (foundCount === 1) {
    label = 'event';
  }
  document.querySelector('#events-count').textContent = foundCount + ' ' + label + ' found';

  let html = '';
  for (const event of visibleEvents) {
    html += eventCardHtml(event);
  }
  document.querySelector('#events-grid').innerHTML = html;

  const nothingFound = visibleEvents.length === 0;
  document.querySelector('#events-grid').hidden = nothingFound;
  document.querySelector('#events-empty').hidden = !nothingFound;
}

// light up the chip that is picked
function updateChips() {
  for (const button of categoryButtons) {
    const pressed = button.dataset.category === selectedCategory;
    button.setAttribute('aria-pressed', String(pressed));
  }
  for (const button of dayButtons) {
    const pressed = button.dataset.day === String(selectedDay);
    button.setAttribute('aria-pressed', String(pressed));
  }
}

function handleCategoryClick(event) {
  selectedCategory = event.currentTarget.dataset.category;
  updateChips();
  renderEvents();
}

function handleDayClick(event) {
  const value = event.currentTarget.dataset.day;
  if (value === 'All') {
    selectedDay = 'All';
  } else {
    selectedDay = Number(value);
  }
  updateChips();
  renderEvents();
}

function clearFilters() {
  searchInput.value = '';
  selectedCategory = 'All';
  selectedDay = 'All';
  updateChips();
  renderEvents();
}

searchInput.addEventListener('input', renderEvents);
for (const button of categoryButtons) {
  button.addEventListener('click', handleCategoryClick);
}
for (const button of dayButtons) {
  button.addEventListener('click', handleDayClick);
}
document.querySelector('#clear-filters').addEventListener('click', clearFilters);

renderEvents();
