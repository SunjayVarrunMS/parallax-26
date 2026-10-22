import { useState, useEffect, useRef } from 'react';
import { Link } from 'react-router-dom';
import { venues } from '../data.js';
import { formatTime, formatPrice } from '../utils.js';
import { listWorkshops, bookWorkshop, listBookings, getWaitlistPosition } from '../api/workshops.js';

function getVenueName(venueId) {
  const venue = venues.find((item) => item.id === venueId);
  if (venue) {
    return venue.name;
  }
  return '';
}

function getSeatsLeft(workshop) {
  return Math.max(0, workshop.capacity - workshop.seatsTaken);
}

function FieldError({ id, message }) {
  return (
    <p id={id} className="field__error" hidden={!message}>{message}</p>
  );
}

// "You're in" or the waitlist position, after booking
function Result({ result }) {
  let message = "You're in";
  if (result.status === 'waitlisted') {
    message = "You're on the waitlist (position " + result.position + ')';
  }
  return (
    <>
      <p className="workshops-page__result" role="status">{message}</p>
      <Link to="/my-bookings" className="text-link">&gt;&gt; See it in My bookings</Link>
    </>
  );
}

// the little booking form inside one card
function BookingForm({ workshop, buttonText, onBook, onClose }) {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [nameError, setNameError] = useState('');
  const [emailError, setEmailError] = useState('');
  const [formError, setFormError] = useState('');
  const [busy, setBusy] = useState(false);
  const nameRef = useRef(null);

  // put the cursor in the name box when the form opens
  useEffect(() => {
    nameRef.current.focus();
  }, []);

  function validate() {
    let ok = true;

    let newNameError = '';
    if (name.trim() === '') {
      newNameError = 'Enter your full name.';
      ok = false;
    }
    setNameError(newNameError);

    let newEmailError = '';
    const cleanEmail = email.trim();
    if (cleanEmail === '') {
      newEmailError = 'Enter your email.';
      ok = false;
    } else if (!/^\S+@\S+\.\S+$/.test(cleanEmail)) {
      newEmailError = 'That email does not look right.';
      ok = false;
    }
    setEmailError(newEmailError);

    return ok;
  }

  async function handleSubmit(e) {
    e.preventDefault();
    if (busy) {
      return;
    }
    setFormError('');
    if (!validate()) {
      return;
    }

    setBusy(true);
    try {
      await onBook(workshop.id, name.trim(), email.trim());
    } catch (error) {
      setFormError(error.message || 'Something went wrong. Try again.');
      setBusy(false);
    }
  }

  const nameId = 'name-' + workshop.id;
  const emailId = 'email-' + workshop.id;

  return (
    <form className="workshops-page__form" onSubmit={handleSubmit} noValidate>
      <div className="field">
        <label htmlFor={nameId}>Full name</label>
        <input
          id={nameId}
          ref={nameRef}
          autoComplete="name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          aria-invalid={!!nameError}
          aria-describedby={nameError ? nameId + '-error' : undefined}
        />
        <FieldError id={nameId + '-error'} message={nameError} />
      </div>
      <div className="field">
        <label htmlFor={emailId}>Email</label>
        <input
          id={emailId}
          type="email"
          autoComplete="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          aria-invalid={!!emailError}
          aria-describedby={emailError ? emailId + '-error' : undefined}
        />
        <FieldError id={emailId + '-error'} message={emailError} />
      </div>
      <p className="field__error" role="alert" hidden={formError === ''}>{formError}</p>
      <div className="workshops-page__form-actions">
        <button type="submit" className="button button--primary" disabled={busy}>
          {busy ? 'Sending...' : buttonText}
        </button>
        <button type="button" className="button button--outline" onClick={onClose}>Close</button>
      </div>
    </form>
  );
}

function WorkshopCard({ workshop, result, isOpen, onOpen, onClose, onBook }) {
  const seatsLeft = getSeatsLeft(workshop);
  const percentTaken = Math.min(100, Math.round((workshop.seatsTaken / workshop.capacity) * 100));

  let badge = <span className="badge badge--green">Open</span>;
  if (seatsLeft === 0) {
    badge = <span className="badge badge--coral">Full</span>;
  }

  let buttonText = 'Book a seat';
  if (seatsLeft === 0) {
    buttonText = 'Join waitlist';
  }

  // what shows at the bottom of the card
  let action;
  if (result) {
    action = <Result result={result} />;
  } else if (isOpen) {
    action = <BookingForm workshop={workshop} buttonText={buttonText} onBook={onBook} onClose={onClose} />;
  } else {
    action = (
      <button type="button" className="button button--outline" onClick={() => onOpen(workshop.id)}>{buttonText}</button>
    );
  }

  return (
    <li className="workshops-page__card">
      <div className="workshops-page__card-top">
        <span className="badge badge--green">Workshop</span>
        {badge}
      </div>
      <h2>{workshop.title}</h2>
      <p className="workshops-page__description">{workshop.description}</p>
      <dl className="workshops-page__details">
        <div>
          <dt>Day</dt>
          <dd>Day {workshop.day}</dd>
        </div>
        <div>
          <dt>Time</dt>
          <dd>{formatTime(workshop.startsAt)} - {formatTime(workshop.endsAt)}</dd>
        </div>
        <div>
          <dt>Venue</dt>
          <dd>{getVenueName(workshop.venueId)}</dd>
        </div>
        <div>
          <dt>Fee</dt>
          <dd>{formatPrice(workshop.fee)}</dd>
        </div>
      </dl>
      <div className="workshops-page__seats">
        <p>{seatsLeft} of {workshop.capacity} seats left</p>
        <div className="workshops-page__bar" aria-hidden="true">
          <span style={{ width: percentTaken + '%' }}></span>
        </div>
      </div>
      <div className="workshops-page__action">{action}</div>
    </li>
  );
}

// the workshops page: see the seats left, book a seat or join the waitlist
function Workshops() {
  const [workshopList, setWorkshopList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [openFormId, setOpenFormId] = useState('');
  const [results, setResults] = useState({});
  const sending = useRef(false);

  // load the workshops when the page opens
  useEffect(() => {
    async function load() {
      try {
        setWorkshopList(await listWorkshops());
      } catch (err) {
        setError(err.message || 'Could not load the workshops.');
      }
      setLoading(false);
    }
    load();
  }, []);

  function openForm(id) {
    if (sending.current) {
      return;
    }
    setOpenFormId(id);
  }

  function closeForm() {
    if (sending.current) {
      return;
    }
    setOpenFormId('');
  }

  // book a seat. the form shows any error that is thrown.
  async function handleBook(workshopId, name, email) {
    if (sending.current) {
      return;
    }
    sending.current = true;
    try {
      const booking = await bookWorkshop(workshopId, name, email);
      const bookings = await listBookings();
      const latest = await listWorkshops();
      setWorkshopList(latest);
      setResults((old) => ({
        ...old,
        [workshopId]: {
          status: booking.status,
          position: getWaitlistPosition(bookings, booking),
        },
      }));
      setOpenFormId('');
    } finally {
      sending.current = false;
    }
  }

  return (
    <div className="container workshops-page">
      <header className="page-heading">
        <p className="eyebrow">&gt;&gt; PARALLAX / 05</p>
        <h1>Give it a go<span className="cursor" aria-hidden="true"></span></h1>
        <p className="page-heading__description">Be a beginner at something. It's a good look.</p>
      </header>

      <p className="workshops-page__loading" hidden={!loading}>Loading workshops...</p>
      <p className="field__error" role="alert" hidden={error === ''}>{error}</p>
      <ul className="workshops-page__grid">
        {workshopList.map((workshop) => (
          <WorkshopCard
            key={workshop.id}
            workshop={workshop}
            result={results[workshop.id]}
            isOpen={openFormId === workshop.id}
            onOpen={openForm}
            onClose={closeForm}
            onBook={handleBook}
          />
        ))}
      </ul>
    </div>
  );
}

export default Workshops;
