// fills in the parts of the home page that come from data.js

const featuredEvents = [events[0], events[1], workshops[0]];

const categoryTones = {
  Culture: 'coral',
  Tech: 'blue',
  Workshop: 'green',
};

// the first five events in the side panel
function renderUpNext() {
  const upNext = events.slice(0, 5);
  let html = '';
  for (const event of upNext) {
    html += `
      <li>
        <a href="events.html">
          <span class="hero__events-time">[D${event.day} ${formatTime(event.startsAt)}]</span>
          <span>${event.title}</span>
        </a>
      </li>
    `;
  }
  document.querySelector('#up-next').innerHTML = html;
  document.querySelector('#event-total').textContent = '[' + events.length + ']';
}

// the little picture at the top of each featured card
function cardArtHtml(category) {
  if (category === 'Culture') {
    let bars = '';
    for (let i = 0; i < 12; i++) {
      bars += '<i></i>';
    }
    return `<div class="sound-bars">${bars}</div>`;
  }
  if (category === 'Tech') {
    return '<div class="code-art">&lt;/&gt;<span class="cursor"></span></div>';
  }
  return '<div class="print-art"><span>MAKE</span><span>SOMETHING.</span></div>';
}

function renderFeatured() {
  let html = '';
  for (let i = 0; i < featuredEvents.length; i++) {
    const event = featuredEvents[i];
    const tone = categoryTones[event.category];
    let link = 'events.html';
    if (event.category === 'Workshop') {
      link = 'workshops.html';
    }

    html += `
      <a href="${link}" class="event-card event-card--${tone}">
        <div class="panel__bar" aria-hidden="true">
          <span>&gt;EVT_0${i + 1}</span>
          <span>${event.category}</span>
        </div>
        <div class="event-card__art" aria-hidden="true">
          ${cardArtHtml(event.category)}
          <span class="event-card__art-caption">SIGNAL: STRONG</span>
        </div>
        <div class="event-card__body">
          <div class="event-card__meta">
            <span class="badge badge--${tone}">${event.category}</span>
            <span class="badge badge--neutral">Day 0${event.day}</span>
          </div>
          <h3>${event.title}</h3>
          <p>${event.description}</p>
          <span class="event-card__more">&gt;&gt; Open file</span>
        </div>
      </a>
    `;
  }
  document.querySelector('#featured-events').innerHTML = html;
}

renderUpNext();
renderFeatured();
