import { events, workshops, venues } from '../data.js';

const arrowIcon = (
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"><path d="M7 7h10v10"></path><path d="M7 17 17 7"></path></svg>
);

function byStartTime(a, b) {
  return Date.parse(a.startsAt) - Date.parse(b.startsAt);
}

// events and workshops held at one venue, earliest first
function getEntriesAt(venueId) {
  const allEntries = events.concat(workshops);
  const held = allEntries.filter((entry) => entry.venueId === venueId);
  held.sort(byStartTime);
  return held;
}

function HeldList({ held }) {
  if (held.length === 0) {
    return <p className="campus-guide-page__none">Nothing scheduled.</p>;
  }
  return (
    <ul className="campus-guide-page__held">
      {held.map((entry) => (
        <li key={entry.id}>
          <span>{entry.title}</span>
          <span className="campus-guide-page__day">[DAY 0{entry.day}]</span>
        </li>
      ))}
    </ul>
  );
}

// the campus guide: one card per venue, with what is happening there
function CampusGuide() {
  return (
    <div className="container campus-guide-page">
      <header className="page-heading">
        <p className="eyebrow">&gt;&gt; PARALLAX / 06</p>
        <h1>You are here<span className="cursor" aria-hidden="true"></span></h1>
        <p className="page-heading__description">The stages, the studios, and the shortcuts in between.</p>
      </header>

      <ul className="campus-guide-page__grid">
        {venues.map((venue, i) => {
          const held = getEntriesAt(venue.id);
          return (
            <li className="campus-guide-page__card" key={venue.id}>
              <p className="campus-guide-page__bar">
                <span>&gt;STOP_0{i + 1}</span>
                <span>[{held.length}]</span>
              </p>
              <h2>{venue.name}</h2>
              <p className="campus-guide-page__description">{venue.description}</p>
              <h3 className="eyebrow">Happening here</h3>
              <HeldList held={held} />
              <a
                className="text-link"
                href={`${venues[i + 1]?.directionsUrl}`}
                target="_blank"
                rel="noreferrer"
                aria-label={'Directions to ' + venue.name + ' (opens in a new tab)'}
              >
                &gt;&gt; Directions to {venue.name}
                {arrowIcon}
              </a>
            </li>
          );
        })}
      </ul>
    </div>
  );
}

export default CampusGuide;
