import { useState } from 'react';
import { submitContact } from '../api/help.js';

const faqs = [
  {
    question: "When and where is PARALLAX '26?",
    answer: 'It runs from 20 to 22 November, on campus. Every venue, with directions, is on the campus guide page.',
  },
  {
    question: 'Do I need a ticket to come in?',
    answer: 'Walking around is free with a college ID. Some events have a fee, shown on the events page and in the fee summary when you register.',
  },
  {
    question: 'How do I know my registration worked?',
    answer: 'You get a confirmation panel straight after you register. Every registration, workshop booking and merch order also shows up on My bookings.',
  },
  {
    question: 'Can I get a refund?',
    answer: 'Cancel from My bookings and the fee is returned within five working days. If we cancel an event, everyone gets a full refund without asking.',
  },
  {
    question: 'Where do I pick up my merch?',
    answer: 'Collect it from the merch desk next to the food court. Bring a college ID and the order id from My bookings.',
  },
  {
    question: 'I lost something. What now?',
    answer: 'Lost and found is at the help desk by the main stage. Describe the item in the form below and we will check the box for you.',
  },
];

const topics = [
  'Tickets and registration',
  'Workshops',
  'Refunds',
  'Merch',
  'Lost and found',
  'Something else',
];

function FieldError({ id, message }) {
  return (
    <p id={id} className="field__error" hidden={!message}>{message}</p>
  );
}

// the help page: the FAQ is plain markup, the rest runs the contact form
function Help() {
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [topic, setTopic] = useState(topics[0]);
  const [message, setMessage] = useState('');
  const [errors, setErrors] = useState({});
  const [submitting, setSubmitting] = useState(false);
  const [done, setDone] = useState(false);
  const [ticketId, setTicketId] = useState();

  function validate() {
    const newErrors = {};

    if (fullName.trim() === '') {
      newErrors.name = 'Enter your full name.';
    }

    const cleanEmail = email.trim();
    if (cleanEmail === '') {
      newErrors.email = 'Enter your email.';
    } else if (!/^\S+@\S+\.\S+$/.test(cleanEmail)) {
      newErrors.email = 'That email does not look right.';
    }

    if (message.trim() === '') {
      newErrors.message = 'Write a message.';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }

  async function handleSubmit(e) {
    e.preventDefault();
    if (submitting) {
      return;
    }
    if (!validate()) {
      return;
    }

    setSubmitting(true);
    let newTicketId;
    try {
      const result = await submitContact(fullName.trim(), email.trim(), topic, message);
      newTicketId = result.ticketId;
    } catch (error) {
      console.log(error.message);
    }
    setTicketId(newTicketId);
    setDone(true);
    setSubmitting(false);
  }

  // "Send another message" puts an empty form back
  function resetForm() {
    setFullName('');
    setEmail('');
    setTopic(topics[0]);
    setMessage('');
    setErrors({});
    setDone(false);
  }

  return (
    <div className="container help-page">
      <header className="page-heading">
        <p className="eyebrow">&gt;&gt; PARALLAX / 08</p>
        <h1>We're around<span className="cursor" aria-hidden="true"></span></h1>
        <p className="page-heading__description">Small questions. Big questions. "Where did I leave my bag?" questions.</p>
      </header>

      <div className="help-page__layout">
        <section className="panel" aria-labelledby="faq-title">
          <div className="panel__bar">
            <span id="faq-title">&gt;FAQ</span>
            <span>[6 ANSWERS]</span>
          </div>
          <div className="help-page__faq">
            {faqs.map((faq) => (
              <details className="help-page__item" key={faq.question}>
                <summary>{faq.question}</summary>
                <p>{faq.answer}</p>
              </details>
            ))}
          </div>
        </section>

        <div>
          <section className="help-page__done" aria-live="polite" hidden={!done}>
            <p className="eyebrow">Message sent</p>
            <h2>{'Got it. Your ticket number is #' + ticketId + '.'}</h2>
            <button type="button" className="button button--outline" onClick={resetForm}>Send another message</button>
          </section>

          <form className="help-page__form" onSubmit={handleSubmit} hidden={done} noValidate>
            <p className="eyebrow">Contact the desk</p>
            <div className="field">
              <label htmlFor="help-name">Full name</label>
              <input
                id="help-name"
                autoComplete="name"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                aria-invalid={!!errors.name}
                aria-describedby={errors.name ? 'help-name-error' : undefined}
              />
              <FieldError id="help-name-error" message={errors.name} />
            </div>
            <div className="field">
              <label htmlFor="help-email">Email</label>
              <input
                id="help-email"
                type="email"
                autoComplete="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                aria-invalid={!!errors.email}
                aria-describedby={errors.email ? 'help-email-error' : undefined}
              />
              <FieldError id="help-email-error" message={errors.email} />
            </div>
            <div className="field">
              <label htmlFor="help-topic">Topic</label>
              <select id="help-topic" value={topic} onChange={(e) => setTopic(e.target.value)}>
                {topics.map((option) => (
                  <option key={option}>{option}</option>
                ))}
              </select>
            </div>
            <div className="field">
              <label htmlFor="help-message">Message</label>
              <textarea
                id="help-message"
                rows="5"
                placeholder="Where's my ticket?"
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                aria-invalid={!!errors.message}
                aria-describedby={errors.message ? 'help-message-error' : undefined}
              ></textarea>
              <FieldError id="help-message-error" message={errors.message} />
            </div>
            <button type="submit" className="button button--primary" disabled={submitting}>
              {submitting ? 'Sending...' : 'Send'}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default Help;
