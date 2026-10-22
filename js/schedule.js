// the schedule page: three day tabs and the timetable for the picked day

let selectedDay = 1;

const tabButtons = document.querySelectorAll('.schedule-page__tab');

const categoryTones = {
  Culture: 'coral',
  Tech: 'blue',
  Workshop: 'green',
};

// day 1 -> "Fri, 20 Nov"
function dayDate(day) {
  const start = Date.parse(festival.startsAt);
  const date = new Date(start + (day - 1) * 86400000);
  return formatDate(date.toISOString());
}

// the time shown in each row
function slotTime(iso) {
  return new Date(iso).toLocaleTimeString('en-IN', {
    hour: 'numeric',
    minute: '2-digit',
    timeZone: 'UTC',
  });
}

function getVenueName(venueId) {
  const venue = venues.find(function (item) {
    return item.id === venueId;
  });
  if (venue) {
    return venue.name;
  }
  return '';
}

function byStartTime(a, b) {
  return Date.parse(a.startsAt) - Date.parse(b.startsAt);
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

function renderTabs() {
  for (const button of tabButtons) {
    const day = Number(button.dataset.day);
    button.querySelector('small').textContent = dayDate(day);
    button.setAttribute('aria-selected', String(day === selectedDay));
  }
  document.querySelector('#schedule-panel').setAttribute('aria-labelledby', 'schedule-tab-' + selectedDay);
}

function renderSchedule() {
  // events and workshops for the picked day, earliest first
  const allEntries = events.concat(workshops);
  const entries = allEntries.filter(function (entry) {
    return entry.day === selectedDay;
  });
  entries.sort(byStartTime);

  let html = '';
  for (const entry of entries) {
    html += `
      <li class="schedule-page__row schedule-page__row--${entry.status}">
        <p class="schedule-page__time">${slotTime(entry.startsAt)} - ${slotTime(entry.endsAt)}</p>
        <h2>${entry.title}</h2>
        <div class="schedule-page__badges">
          <span class="badge badge--${categoryTones[entry.category]}">${entry.category}</span>
          ${statusBadgeHtml(entry.status)}
        </div>
        <p class="schedule-page__venue">${getVenueName(entry.venueId)}</p>
      </li>
    `;
  }
  document.querySelector('#schedule-list').innerHTML = html;
}

function handleTabClick(event) {
  selectedDay = Number(event.currentTarget.dataset.day);
  renderTabs();
  renderSchedule();
}

for (const button of tabButtons) {
  button.addEventListener('click', handleTabClick);
}

renderTabs();
renderSchedule();
