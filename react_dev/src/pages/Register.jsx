import { useState } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { events } from '../data.js';
import { formatPrice } from '../utils.js';
import { createRegistration } from '../api/registrations.js';

// full events cannot take more people, so leave them out
const openEvents = events.filter((event) => event.status !== 'full');

// the red message under one field
function FieldError({ id, message }) {
  return (
    <p id={id} className="field__error" hidden={!message}>{message}</p>
  );
}

// the register page: pick an event, fill in your details, add teammates, see the fee
function Register() {
  const [searchParams] = useSearchParams();

  // ?event=capture-the-flag picks that event for you
  const fromAddress = searchParams.get('event');
  const found = openEvents.find((event) => event.id === fromAddress);

  // most team events start with one teammate row already there
  const startsWithTeammate = found && found.maxTeamSize > 1;

  const [eventId, setEventId] = useState(found ? found.id : '');
  const [teammates, setTeammates] = useState(startsWithTeammate ? [{ id: 1, name: '' }] : []);
  const [nextTeammateId, setNextTeammateId] = useState(startsWithTeammate ? 2 : 1);
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [errors, setErrors] = useState({});
  const [submitError, setSubmitError] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [registration, setRegistration] = useState(null);

  const selectedEvent = openEvents.find((event) => event.id === eventId);

  function getPerPersonFee() {
    if (selectedEvent) {
      return selectedEvent.fee;
    }
    return 0;
  }

  function getTeamSize() {
    return teammates.length + 1;
  }

  // the fee for everyone in the team added together
  function getTotalFee() {
    const fees = [];
    for (let i = 0; i < getTeamSize(); i++) {
      fees.push(getPerPersonFee());
    }
    const total = Number(fees.reduce((sum, fee) => sum + fee, ''));
    return total;
  }

  function makeTeammate() {
    const mate = { id: nextTeammateId, name: '' };
    setNextTeammateId(nextTeammateId + 1);
    return mate;
  }

  function handleEventChange(e) {
    const newId = e.target.value;
    const newEvent = openEvents.find((event) => event.id === newId);
    let newTeammates = teammates;
    if (newEvent) {
      newTeammates = teammates.slice(0, newEvent.maxTeamSize - 1);
    }
    if (newEvent && newEvent.maxTeamSize > 1 && newTeammates.length === 0) {
      newTeammates = [makeTeammate()];
    }
    setEventId(newId);
    setTeammates(newTeammates);
  }

  function addTeammate() {
    setTeammates([...teammates, makeTeammate()]);
  }

  function removeTeammate(id) {
    setTeammates(teammates.filter((mate) => mate.id !== id));
  }

  // typing in a teammate box saves the name
  function changeTeammate(id, name) {
    setTeammates(teammates.map((mate) => (mate.id === id ? { ...mate, name: name } : mate)));
  }

  // check every field. returns true when the form is ok.
  function validate() {
    const newErrors = {};

    if (!selectedEvent) {
      newErrors.event = 'Pick an event.';
    }

    if (fullName.trim() === '') {
      newErrors.name = 'Enter your full name.';
    }

    const cleanEmail = email.trim();
    if (cleanEmail === '') {
      newErrors.email = 'Enter your email.';
    } else if (!/^\S+@\S+\.\S+$/.test(cleanEmail)) {
      newErrors.email = 'That email does not look right.';
    }

    const cleanPhone = phone.trim();
    if (cleanPhone === '') {
      newErrors.phone = 'Enter your phone number.';
    } else if (!/^\d{10}$/.test(cleanPhone)) {
      newErrors.phone = 'Use a 10-digit phone number.';
    }

    for (const mate of teammates) {
      if (mate.name.trim() === '') {
        newErrors.teammates = 'Fill in every teammate name, or remove the empty ones.';
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitError('');
    if (!validate()) {
      return;
    }

    const teammateNames = [];
    for (const mate of teammates) {
      teammateNames.push(mate.name.trim());
    }

    setSubmitting(true);
    try {
      const saved = await createRegistration({
        eventId: selectedEvent.id,
        participantName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        teammates: teammateNames,
        fee: getTotalFee(),
      });
      setRegistration(saved);
    } catch (error) {
      setSubmitError(error.message || 'Something went wrong. Try again.');
    }
    setSubmitting(false);
  }

  // "Register for another event" puts an empty form back
  function resetForm() {
    setEventId('');
    setTeammates([]);
    setFullName('');
    setEmail('');
    setPhone('');
    setErrors({});
    setSubmitError('');
    setRegistration(null);
  }

  // the "Add teammate" button and the team limit note
  let maxTeammates = 0;
  if (selectedEvent) {
    maxTeammates = selectedEvent.maxTeamSize - 1;
  }
  const addDisabled = !selectedEvent || teammates.length > maxTeammates;

  let note = 'Pick an event to see the team limit.';
  if (selectedEvent && selectedEvent.maxTeamSize === 1) {
    note = 'This one is solo.';
  } else if (selectedEvent) {
    note = 'Teams of up to ' + selectedEvent.maxTeamSize;
  }

  // "Teammates: 1 / 2 allowed"
  let counter = '';
  if (selectedEvent) {
    const allowed = selectedEvent.maxTeamSize - 1;
    counter = 'Teammates: ' + teammates.length + ' / ' + allowed + ' allowed';
  }

  const perPersonFee = getPerPersonFee();
  const teamSize = getTeamSize();
  const totalFee = getTotalFee();

  // the event shown on the confirmation
  let confirmedTitle = 'Registration confirmed';
  if (registration) {
    const confirmedEvent = openEvents.find((event) => event.id === registration.eventId);
    if (confirmedEvent) {
      confirmedTitle = confirmedEvent.title;
    }
  }

  return (
    <div className="container register-page">
      <header className="page-heading">
        <p className="eyebrow">&gt;&gt; PARALLAX / 03</p>
        <h1>Put your name down<span className="cursor" aria-hidden="true"></span></h1>
        <p className="page-heading__description">Flying solo or bringing the whole team. There's room for your kind of energy.</p>
      </header>

      <section className="register-page__done" id="confirmation" aria-live="polite" hidden={!registration}>
        <p className="eyebrow">You're in</p>
        <h2 id="confirmation-title">{confirmedTitle}</h2>
        {registration && (
          <dl>
            <div>
              <dt>Registration id</dt>
              <dd>{registration.id}</dd>
            </div>
            <div>
              <dt>Team size</dt>
              <dd>{registration.teammates.length + 1}</dd>
            </div>
            <div>
              <dt>Total fee</dt>
              <dd>{formatPrice(registration.fee)}</dd>
            </div>
          </dl>
        )}
        <div className="register-page__done-actions">
          <Link to="/my-bookings" className="button button--primary">My bookings</Link>
          <button type="button" className="button button--outline" onClick={resetForm}>Register for another event</button>
        </div>
      </section>

      <form className="register-page__form" onSubmit={handleSubmit} hidden={!!registration} noValidate>
        <div className="register-page__fields">
          <div className="field">
            <label htmlFor="register-event">Event</label>
            <select
              id="register-event"
              value={eventId}
              onChange={handleEventChange}
              aria-invalid={!!errors.event}
              aria-describedby={errors.event ? 'register-event-error' : undefined}
            >
              <option value="">Choose an event</option>
              {openEvents.map((event) => (
                <option key={event.id} value={event.id}>{event.title} (Day {event.day})</option>
              ))}
            </select>
            <FieldError id="register-event-error" message={errors.event} />
          </div>
          <div className="field">
            <label htmlFor="register-name">Full name</label>
            <input
              id="register-name"
              autoComplete="name"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              aria-invalid={!!errors.name}
              aria-describedby={errors.name ? 'register-name-error' : undefined}
            />
            <FieldError id="register-name-error" message={errors.name} />
          </div>
          <div className="field">
            <label htmlFor="register-email">Email</label>
            <input
              id="register-email"
              type="email"
              autoComplete="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              aria-invalid={!!errors.email}
              aria-describedby={errors.email ? 'register-email-error' : undefined}
            />
            <FieldError id="register-email-error" message={errors.email} />
          </div>
          <div className="field">
            <label htmlFor="register-phone">Phone</label>
            <input
              id="register-phone"
              type="tel"
              inputMode="numeric"
              autoComplete="tel"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              aria-invalid={!!errors.phone}
              aria-describedby={errors.phone ? 'register-phone-error' : undefined}
            />
            <FieldError id="register-phone-error" message={errors.phone} />
          </div>

          <fieldset className="register-page__team">
            <legend>Teammates</legend>
            <div className="register-page__team-list">
              {teammates.map((mate, i) => (
                <div className="register-page__teammate" key={mate.id}>
                  <div className="field">
                    <label htmlFor={'teammate-' + mate.id}>Teammate {i + 1}</label>
                    <input
                      id={'teammate-' + mate.id}
                      value={mate.name}
                      onChange={(e) => changeTeammate(mate.id, e.target.value)}
                    />
                  </div>
                  <button
                    type="button"
                    className="button button--outline"
                    aria-label={'Remove teammate ' + (i + 1)}
                    onClick={() => removeTeammate(mate.id)}
                  >
                    Remove
                  </button>
                </div>
              ))}
            </div>
            <FieldError id="teammates-error" message={errors.teammates} />
            <div className="register-page__team-actions">
              <button type="button" className="button button--outline" disabled={addDisabled} onClick={addTeammate}>Add teammate</button>
              <p className="register-page__note">{note}</p>
              <p className="register-page__counter" role="status">{counter}</p>
            </div>
          </fieldset>
        </div>

        <aside className="register-page__summary" aria-label="Fee summary">
          <p className="eyebrow">Fee summary</p>
          <dl>
            <div>
              <dt>Fee per person</dt>
              <dd>{formatPrice(perPersonFee)}</dd>
            </div>
            <div>
              <dt>Team size</dt>
              <dd>{teamSize}</dd>
            </div>
            <div className="register-page__total">
              <dt>Total</dt>
              <dd>{formatPrice(totalFee)}</dd>
            </div>
          </dl>
          <p className="register-page__sum-line">
            {formatPrice(perPersonFee) + ' × ' + teamSize + ' = ' + formatPrice(totalFee)}
          </p>
          <p className="field__error" role="alert" hidden={submitError === ''}>{submitError}</p>
          <button type="submit" className="button button--primary" disabled={submitting}>
            {submitting ? 'Sending...' : 'Register'}
          </button>
        </aside>
      </form>
    </div>
  );
}

export default Register;
