import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { events, workshops, merch } from '../data.js';
import { formatDate, formatTime, formatPrice } from '../utils.js';
import { listRegistrations, cancelRegistration } from '../api/registrations.js';
import { listBookings, cancelBooking, getWaitlistPosition } from '../api/workshops.js';
import { listOrders, cancelOrder } from '../api/shop.js';

const statusTones = {
  confirmed: 'green',
  waitlisted: 'blue',
  cancelled: 'neutral',
  placed: 'green',
};

const statusTags = {
  confirmed: 'confirmed',
  waitlisted: 'confirmed',
  cancelled: 'cancelled',
  placed: 'placed',
};

function findEvent(id) {
  return events.find((item) => item.id === id);
}

function findWorkshop(id) {
  return workshops.find((item) => item.id === id);
}

function findMerch(id) {
  return merch.find((item) => item.id === id);
}

// one line for each item in an order
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

// the Cancel button, then "Cancel this?" with Yes / Keep it
function Actions({ id, status, busyId, confirmingId, onAsk, onNo, onYes }) {
  if (status === 'cancelled') {
    return null;
  }
  if (busyId === id) {
    return <p className="my-bookings-page__ask">Cancelling...</p>;
  }
  if (confirmingId === id) {
    return (
      <div className="my-bookings-page__confirm" role="group" aria-label="Cancel this?">
        <span className="my-bookings-page__ask">Cancel this?</span>
        <button type="button" className="button button--primary" onClick={() => onYes(id)}>Yes</button>
        <button type="button" className="button button--outline" onClick={onNo}>Keep it</button>
      </div>
    );
  }
  return <button type="button" className="button button--outline" onClick={() => onAsk(id)}>Cancel</button>;
}

function Row({ row, actionProps }) {
  return (
    <li className="my-bookings-page__row">
      <div className="my-bookings-page__what">
        <h3>{row.title}</h3>
        <p>{row.detail}</p>
        <p className="my-bookings-page__date">{row.dateText}</p>
      </div>
      <span className={'badge badge--' + statusTones[row.status]}>{statusTags[row.status]}</span>
      <div className="my-bookings-page__actions">
        <Actions id={row.id} status={row.status} {...actionProps} />
      </div>
    </li>
  );
}

// one panel: a title bar, the rows, or a message when there are none
function Section({ id, title, count, rows, emptyText, emptyPath, emptyLink, actionProps }) {
  return (
    <section className="panel" aria-labelledby={id + '-title'}>
      <div className="panel__bar">
        <span id={id + '-title'}>{title}</span>
        <span>{count} total</span>
      </div>
      <ul className="my-bookings-page__list">
        {rows.map((row) => (
          <Row key={row.id} row={row} actionProps={actionProps} />
        ))}
        {rows.length === 0 && (
          <li className="my-bookings-page__empty">
            <p>{emptyText}</p>
            <Link to={emptyPath} className="text-link">&gt;&gt; {emptyLink}</Link>
          </li>
        )}
      </ul>
    </section>
  );
}

// the my bookings page: event registrations, workshop bookings and merch orders
function MyBookings() {
  const [registrations, setRegistrations] = useState([]);
  const [workshopBookings, setWorkshopBookings] = useState([]);
  const [orders, setOrders] = useState([]);
  const [loaded, setLoaded] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [confirmingId, setConfirmingId] = useState('');
  const [busyId, setBusyId] = useState('');

  async function loadData() {
    setRegistrations(await listRegistrations());
    setWorkshopBookings(await listBookings());
    setOrders(await listOrders());
  }

  // load everything when the page opens
  useEffect(() => {
    async function load() {
      try {
        await loadData();
        setLoaded(true);
      } catch (err) {
        setError(err.message || 'Could not load your bookings.');
      }
      setLoading(false);
    }
    load();
  }, []);

  async function cancelItem(id) {
    setBusyId(id);
    setConfirmingId('');
    setError('');
    try {
      if (id.startsWith('reg_')) {
        await cancelRegistration(id);
      } else if (id.startsWith('wsh_')) {
        await cancelBooking(id);
      } else {
        await cancelOrder(id);
      }
      await loadData();
    } catch (err) {
      setError(err.message || 'Could not cancel that. Try again.');
    }
    setBusyId('');
  }

  function ask(id) {
    if (busyId === '') {
      setConfirmingId(id);
    }
  }

  function no() {
    if (busyId === '') {
      setConfirmingId('');
    }
  }

  function yes(id) {
    if (busyId === '') {
      cancelItem(id);
    }
  }

  const actionProps = { busyId, confirmingId, onAsk: ask, onNo: no, onYes: yes };

  // turn the saved data into rows to show
  const registrationRows = registrations.map((registration) => {
    const event = findEvent(registration.eventId);
    let title = 'Event';
    let dateText = formatDate(registration.createdAt);
    if (event) {
      title = event.title;
      dateText = formatDate(event.startsAt) + ', ' + formatTime(event.startsAt);
    }
    const teamSize = registration.teammates.length + 1;
    return {
      id: registration.id,
      title: title,
      detail: 'Team of ' + teamSize + ' - ' + formatPrice(registration.fee),
      dateText: dateText,
      status: registration.status,
    };
  });

  const workshopRows = workshopBookings.map((booking) => {
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
    return { id: booking.id, title: title, detail: detail, dateText: dateText, status: booking.status };
  });

  const orderRows = orders.map((order) => ({
    id: order.id,
    title: 'Order ' + order.id,
    detail: orderSummary(order) + ' - ' + formatPrice(order.total),
    dateText: 'Ordered ' + formatDate(order.createdAt),
    status: order.status,
  }));

  return (
    <div className="container my-bookings-page">
      <header className="page-heading">
        <p className="eyebrow">&gt;&gt; PARALLAX / 04</p>
        <h1>Your festival<span className="cursor" aria-hidden="true"></span></h1>
        <p className="page-heading__description">All the things you've said yes to, in one place.</p>
      </header>

      <p className="my-bookings-page__loading" hidden={!loading}>Loading your bookings...</p>
      <p className="field__error" role="alert" hidden={error === ''}>{error}</p>
      <div className="my-bookings-page__sections" hidden={!loaded}>
        <Section
          id="registrations"
          title=">EVENT REGISTRATIONS"
          count={registrations.length}
          rows={registrationRows}
          emptyText="No event registrations yet."
          emptyPath="/register"
          emptyLink="Register for an event"
          actionProps={actionProps}
        />
        <Section
          id="workshops"
          title=">WORKSHOP BOOKINGS"
          count={workshopBookings.length}
          rows={workshopRows}
          emptyText="No workshop bookings yet."
          emptyPath="/workshops"
          emptyLink="Browse workshops"
          actionProps={actionProps}
        />
        <Section
          id="orders"
          title=">MERCH ORDERS"
          count={orders.length}
          rows={orderRows}
          emptyText="No merch orders yet."
          emptyPath="/merch"
          emptyLink="Visit the shop"
          actionProps={actionProps}
        />
      </div>
    </div>
  );
}

export default MyBookings;
