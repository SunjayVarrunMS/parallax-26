import { useState } from 'react';
import { festival, events, workshops, venues } from '../data.js';
import { formatDate } from '../utils.js';

const categoryTones = {
  Culture: 'coral',
  Tech: 'blue',
  Workshop: 'green',
};

const dayNumbers = [1, 2, 3];

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
  const venue = venues.find((item) => item.id === venueId);
  if (venue) {
    return venue.name;
  }
  return '';
}

function byStartTime(a, b) {
  return Date.parse(a.startsAt) - Date.parse(b.startsAt);
}

function StatusBadge({ status }) {
  if (status === 'open') {
    return <span className="badge badge--green">Open</span>;
  }
  if (status === 'full') {
    return <span className="badge badge--coral">Full</span>;
  }
  return <span className="badge badge--neutral">Cancelled</span>;
}

// the schedule page: three day tabs and the timetable for the picked day
function Schedule() {
  const [selectedDay, setSelectedDay] = useState(1);

  // events and workshops for the picked day, earliest first
  const allEntries = events.concat(workshops);
  const entries = allEntries.filter((entry) => entry.day === selectedDay);
  entries.sort(byStartTime);

  return (
    <div className="container schedule-page">
      <header className="page-heading">
        <p className="eyebrow">&gt;&gt; PARALLAX / 02</p>
        <h1>Make a day of it<span className="cursor" aria-hidden="true"></span></h1>
        <p className="page-heading__description">A little planning leaves more room for the unplanned.</p>
      </header>

      <div className="schedule-page__tabs" role="tablist" aria-label="Festival days">
        {dayNumbers.map((day) => (
          <button
            key={day}
            type="button"
            role="tab"
            id={'schedule-tab-' + day}
            aria-selected={day === selectedDay}
            aria-controls="schedule-panel"
            className="schedule-page__tab"
            onClick={() => setSelectedDay(day)}
          >
            <span>[DAY 0{day}]</span>
            <small>{dayDate(day)}</small>
          </button>
        ))}
      </div>

      <p className="eyebrow schedule-page__timezone">&gt;&gt; All times in IST (UTC+05:30)</p>

      <section id="schedule-panel" role="tabpanel" aria-labelledby={'schedule-tab-' + selectedDay}>
        <ol className="schedule-page__list">
          {entries.map((entry) => (
            <li key={entry.id} className={'schedule-page__row schedule-page__row--' + entry.status}>
              <p className="schedule-page__time">{slotTime(entry.startsAt)} - {slotTime(entry.endsAt)}</p>
              <h2>{entry.title}</h2>
              <div className="schedule-page__badges">
                <span className={'badge badge--' + categoryTones[entry.category]}>{entry.category}</span>
                <StatusBadge status={entry.status} />
              </div>
              <p className="schedule-page__venue">{getVenueName(entry.venueId)}</p>
            </li>
          ))}
        </ol>
      </section>
    </div>
  );
}

export default Schedule;
