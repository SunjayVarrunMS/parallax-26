// the campus guide: one card per venue, with what is happening there

const arrowIcon = `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M7 7h10v10"></path><path d="M7 17 17 7"></path></svg>`;

function byStartTime(a, b) {
  return Date.parse(a.startsAt) - Date.parse(b.startsAt);
}

// events and workshops held at one venue, earliest first
function getEntriesAt(venueId) {
  const allEntries = events.concat(workshops);
  const held = allEntries.filter(function (entry) {
    return entry.venueId === venueId;
  });
  held.sort(byStartTime);
  return held;
}

function heldListHtml(held) {
  if (held.length === 0) {
    return '<p class="campus-guide-page__none">Nothing scheduled.</p>';
  }
  let items = '';
  for (const entry of held) {
    items += `
      <li>
        <span>${entry.title}</span>
        <span class="campus-guide-page__day">[DAY 0${entry.day}]</span>
      </li>
    `;
  }
  return `<ul class="campus-guide-page__held">${items}</ul>`;
}

function renderVenues() {
  let html = '';
  for (let i = 0; i < venues.length; i++) {
    const venue = venues[i];
    const held = getEntriesAt(venue.id);

    html += `
      <li class="campus-guide-page__card">
        <p class="campus-guide-page__bar">
          <span>&gt;STOP_0${i + 1}</span>
          <span>[${held.length}]</span>
        </p>
        <h2>${venue.name}</h2>
        <p class="campus-guide-page__description">${venue.description}</p>
        <h3 class="eyebrow">Happening here</h3>
        ${heldListHtml(held)}
        <a class="text-link" href="${venues[i + 1]?.directionsUrl}" target="_blank" rel="noreferrer" aria-label="Directions to ${venue.name} (opens in a new tab)">
          &gt;&gt; Directions to ${venue.name}
          ${arrowIcon}
        </a>
      </li>
    `;
  }
  document.querySelector('#venue-grid').innerHTML = html;
}

renderVenues();
