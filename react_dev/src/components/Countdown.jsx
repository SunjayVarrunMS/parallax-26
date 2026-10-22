import { useState, useEffect } from 'react';
import { festival } from '../data.js';

const startsAt = Date.parse(festival.startsAt);
const endsAt = Date.parse(festival.endsAt);

// 7 -> "07"
function twoDigits(number) {
  return String(number).padStart(2, '0');
}

// the countdown box on the home page. it updates once a second.
function Countdown() {
  const [now, setNow] = useState(() => Date.now());

  useEffect(() => {
    const timer = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(timer);
  }, []);

  const seconds = Math.max(0, Math.floor((startsAt - now) / 1000));
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor(seconds / 3600) % 24;
  const mins = Math.floor(seconds / 60) % 60;
  const secs = seconds % 60;

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

  return (
    <section className="countdown panel" aria-label="Festival countdown">
      <div className="panel__bar">
        <span>&gt;COUNTDOWN</span>
        <span>{state}</span>
      </div>
      <div className="countdown__inner">
        <div className="countdown__intro">
          <span className="status-dot"></span>
          <p className="eyebrow">{eyebrow}</p>
        </div>
        <div className="countdown__numbers" aria-label={days + ' days remaining'}>
          <div><strong>{twoDigits(days)}</strong><span>Days</span></div>
          <div><strong>{twoDigits(hours)}</strong><span>Hours</span></div>
          <div><strong>{twoDigits(mins)}</strong><span>Mins</span></div>
          <div><strong>{twoDigits(secs)}</strong><span>Secs</span></div>
        </div>
        <p className="countdown__note">{note}<span>Clear your calendar.</span></p>
      </div>
    </section>
  );
}

export default Countdown;
