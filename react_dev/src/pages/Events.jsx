import { useState } from 'react';
import { Link } from 'react-router-dom';
import { events, venues } from '../data.js';
import { formatTime, formatPrice } from '../utils.js';

const categoryTones = {
  Culture: 'coral',
  Tech: 'blue',
  Workshop: 'green',
};

const categories = ['All', 'Culture', 'Tech'];
const days = ['All', 1, 2, 3];

function getVenueName(venueId) {
  const venue = venues.find((item) => item.id === venueId);
  if (venue) {
    return venue.name;
  }
  return '';
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

function EventCard({ event }) {
  return (
    <li className={'events-page__card events-page__card--' + event.status}>
      <div className="events-page__card-top">
        <span className={'badge badge--' + categoryTones[event.category]}>{event.category}</span>
        <span className="badge badge--neutral">Day 0{event.day}</span>
        <StatusBadge status={event.status} />
      </div>
      <h2>{event.title}</h2>
      <p className="events-page__description">{event.description}</p>
      <dl className="events-page__details">
        <div>
          <dt>Day</dt>
          <dd>Day {event.day}</dd>
        </div>
        <div>
          <dt>Time</dt>
          <dd>{formatTime(event.startsAt)} - {formatTime(event.endsAt)}</dd>
        </div>
        <div>
          <dt>Venue</dt>
          <dd>{getVenueName(event.venueId)}</dd>
        </div>
        <div>
          <dt>Fee</dt>
          <dd>{formatPrice(event.fee)}</dd>
        </div>
      </dl>
      {event.status !== 'full' && (
        <Link to={'/register?event=' + event.id} className="events-page__register" aria-label={'Register for ' + event.title}>
          <span aria-hidden="true">&gt;&gt;</span> Register
        </Link>
      )}
    </li>
  );
}

// the events page: search box, category and day filters, and the list of cards
function Events() {
  const [search, setSearch] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [selectedDay, setSelectedDay] = useState('All');

  // does this event match the search box and the category?
  function matchesFilters(event) {
    const query = search.trim();
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

  // show the matching events
  const visibleEvents = events.filter((event) => matchesFilters(event) && matchesDay(event));
  const foundCount = events.filter(matchesFilters).length;

  let label = 'events';
  if (foundCount === 1) {
    label = 'event';
  }

  function clearFilters() {
    setSearch('');
    setSelectedCategory('All');
    setSelectedDay('All');
  }

  const nothingFound = visibleEvents.length === 0;

  return (
    <div className="container events-page">
      <header className="page-heading">
        <p className="eyebrow">&gt;&gt; PARALLAX / 01</p>
        <h1>Find your thing<span className="cursor" aria-hidden="true"></span></h1>
        <p className="page-heading__description">On stage, behind a screen, or somewhere completely unexpected.</p>
      </header>

      <section className="events-page__promo">
        <h2>
          🚀 Unlock Your Potential at PARALLAX 2026! ✨ Discover amazing events,
          connect with like-minded individuals, and elevate your festival
          experience to the next level! 🎉
        </h2>
        <button type="button" className="events-page__promo-button">Explore Now 🔥</button>
      </section>

      <section className="events-page__filters" aria-label="Filter events">
        <div className="events-page__search">
          <label htmlFor="event-search">Search events</label>
          <input
            id="event-search"
            type="search"
            placeholder="Try 'Robo' or 'Stage'"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>
        <div className="events-page__group">
          <p className="eyebrow" id="category-label">Category</p>
          <div role="group" aria-labelledby="category-label">
            {categories.map((category) => (
              <button
                key={category}
                type="button"
                className="events-page__chip"
                aria-pressed={category === selectedCategory}
                onClick={() => setSelectedCategory(category)}
              >
                {category}
              </button>
            ))}
          </div>
        </div>
        <div className="events-page__group">
          <p className="eyebrow" id="day-label">Day</p>
          <div role="group" aria-labelledby="day-label">
            {days.map((day) => (
              <button
                key={day}
                type="button"
                className="events-page__chip"
                aria-pressed={day === selectedDay}
                onClick={() => setSelectedDay(day)}
              >
                {day === 'All' ? 'All' : 'Day ' + day}
              </button>
            ))}
          </div>
        </div>
      </section>

      <p className="events-page__count" role="status">{foundCount + ' ' + label + ' found'}</p>

      <section className="events-page__empty" hidden={!nothingFound}>
        <h2>Nothing matches that.</h2>
        <p>Try a different word, or let the filters go.</p>
        <button type="button" className="button button--outline" onClick={clearFilters}>Clear filters</button>
      </section>

      <ul className="events-page__grid" hidden={nothingFound}>
        {visibleEvents.map((event) => (
          <EventCard key={event.id} event={event} />
        ))}
      </ul>
    </div>
  );
}

export default Events;
