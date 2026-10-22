// the countdown box on the home page. it updates once a second.

const startsAt = Date.parse(festival.startsAt);
const endsAt = Date.parse(festival.endsAt);

// 7 -> "07"
function twoDigits(number) {
  return String(number).padStart(2, '0');
}

function renderCountdown() {
  const now = Date.now();
  const seconds = Math.max(0, Math.floor((startsAt - now) / 1000));

  const days = Math.floor(seconds / 86400);
  const hours = Math.floor(seconds / 3600) % 24;
  const mins = Math.floor(seconds / 60) % 60;
  const secs = seconds % 60;

  document.querySelector('#countdown-days').textContent = twoDigits(days);
  document.querySelector('#countdown-hours').textContent = twoDigits(hours);
  document.querySelector('#countdown-mins').textContent = twoDigits(mins);
  document.querySelector('#countdown-secs').textContent = twoDigits(secs);
  document.querySelector('#countdown-numbers').setAttribute('aria-label', days + ' days remaining');

  let state = '[T-MINUS]';
  let eyebrow = 'Time to day 01';
  let note = festival.dateLabel;
  if (now >= endsAt) {
    state = '[OFFLINE]';
    eyebrow = 'Until next time';
    note = 'That was a good one.';
  } else if (now >= startsAt) {
    state = '[LIVE]';
    eyebrow = 'See you on campus';
    note = 'The festival has started.';
  }

  document.querySelector('#countdown-state').textContent = state;
  document.querySelector('#countdown-eyebrow').textContent = eyebrow;
  document.querySelector('#countdown-note').innerHTML = `${note}<span>Clear your calendar.</span>`;
}

renderCountdown();
setInterval(renderCountdown, 1000);
