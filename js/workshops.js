// the workshops page: see the seats left, book a seat or join the waitlist

let workshopList = [];
let openFormId = '';
let results = {};
let sending = false;

const grid = document.querySelector('#workshops-grid');
const loadingText = document.querySelector('#workshops-loading');
const errorText = document.querySelector('#workshops-error');

function getVenueName(venueId) {
  const venue = venues.find(function (item) {
    return item.id === venueId;
  });
  if (venue) {
    return venue.name;
  }
  return '';
}

function getSeatsLeft(workshop) {
  return Math.max(0, workshop.capacity - workshop.seatsTaken);
}

function resultHtml(workshop) {
  const result = results[workshop.id];
  let message = "You're in";
  if (result.status === 'waitlisted') {
    message = "You're on the waitlist (position " + result.position + ')';
  }
  return `
    <p class="workshops-page__result" role="status">${message}</p>
    <a href="my-bookings.html" class="text-link">&gt;&gt; See it in My bookings</a>
  `;
}

function formHtml(workshop, buttonText) {
  return `
    <form class="workshops-page__form" data-id="${workshop.id}" novalidate>
      <div class="field">
        <label for="name-${workshop.id}">Full name</label>
        <input id="name-${workshop.id}" autocomplete="name">
        <p id="name-${workshop.id}-error" class="field__error" hidden></p>
      </div>
      <div class="field">
        <label for="email-${workshop.id}">Email</label>
        <input id="email-${workshop.id}" type="email" autocomplete="email">
        <p id="email-${workshop.id}-error" class="field__error" hidden></p>
      </div>
      <p class="field__error" id="form-${workshop.id}-error" role="alert" hidden></p>
      <div class="workshops-page__form-actions">
        <button type="submit" class="button button--primary">${buttonText}</button>
        <button type="button" class="button button--outline" data-action="close">Close</button>
      </div>
    </form>
  `;
}

function actionHtml(workshop) {
  if (results[workshop.id]) {
    return resultHtml(workshop);
  }

  let buttonText = 'Book a seat';
  if (getSeatsLeft(workshop) === 0) {
    buttonText = 'Join waitlist';
  }

  if (openFormId === workshop.id) {
    return formHtml(workshop, buttonText);
  }
  return `<button type="button" class="button button--outline" data-action="open" data-id="${workshop.id}">${buttonText}</button>`;
}

function cardHtml(workshop) {
  const seatsLeft = getSeatsLeft(workshop);
  const percentTaken = Math.min(100, Math.round((workshop.seatsTaken / workshop.capacity) * 100));

  let badge = '<span class="badge badge--green">Open</span>';
  if (seatsLeft === 0) {
    badge = '<span class="badge badge--coral">Full</span>';
  }

  return `
    <li class="workshops-page__card">
      <div class="workshops-page__card-top">
        <span class="badge badge--green">Workshop</span>
        ${badge}
      </div>
      <h2>${workshop.title}</h2>
      <p class="workshops-page__description">${workshop.description}</p>
      <dl class="workshops-page__details">
        <div>
          <dt>Day</dt>
          <dd>Day ${workshop.day}</dd>
        </div>
        <div>
          <dt>Time</dt>
          <dd>${formatTime(workshop.startsAt)} - ${formatTime(workshop.endsAt)}</dd>
        </div>
        <div>
          <dt>Venue</dt>
          <dd>${getVenueName(workshop.venueId)}</dd>
        </div>
        <div>
          <dt>Fee</dt>
          <dd>${formatPrice(workshop.fee)}</dd>
        </div>
      </dl>
      <div class="workshops-page__seats">
        <p>${seatsLeft} of ${workshop.capacity} seats left</p>
        <div class="workshops-page__bar" aria-hidden="true">
          <span style="width: ${percentTaken}%"></span>
        </div>
      </div>
      <div class="workshops-page__action">${actionHtml(workshop)}</div>
    </li>
  `;
}

function renderWorkshops() {
  let html = '';
  for (const workshop of workshopList) {
    html += cardHtml(workshop);
  }
  grid.innerHTML = html;

  if (openFormId !== '') {
    const input = document.querySelector('#name-' + openFormId);
    if (input) {
      input.focus();
    }
  }
}

function showError(input, errorId, message) {
  const text = document.querySelector('#' + errorId);
  if (message) {
    text.textContent = message;
    text.hidden = false;
    input.setAttribute('aria-invalid', 'true');
    input.setAttribute('aria-describedby', errorId);
  } else {
    text.textContent = '';
    text.hidden = true;
    input.setAttribute('aria-invalid', 'false');
    input.removeAttribute('aria-describedby');
  }
}

function showFormError(workshopId, message) {
  const text = document.querySelector('#form-' + workshopId + '-error');
  text.textContent = message;
  text.hidden = message === '';
}

function validate(workshopId) {
  const nameInput = document.querySelector('#name-' + workshopId);
  const emailInput = document.querySelector('#email-' + workshopId);
  let ok = true;

  let nameError = '';
  if (nameInput.value.trim() === '') {
    nameError = 'Enter your full name.';
    ok = false;
  }
  showError(nameInput, 'name-' + workshopId + '-error', nameError);

  let emailError = '';
  const email = emailInput.value.trim();
  if (email === '') {
    emailError = 'Enter your email.';
    ok = false;
  } else if (!/^\S+@\S+\.\S+$/.test(email)) {
    emailError = 'That email does not look right.';
    ok = false;
  }
  showError(emailInput, 'email-' + workshopId + '-error', emailError);

  return ok;
}

async function handleSubmit(event) {
  event.preventDefault();
  if (sending) {
    return;
  }
  const workshopId = event.target.dataset.id;
  showFormError(workshopId, '');
  if (!validate(workshopId)) {
    return;
  }

  const name = document.querySelector('#name-' + workshopId).value.trim();
  const email = document.querySelector('#email-' + workshopId).value.trim();
  const submitButton = event.target.querySelector('button[type="submit"]');
  const oldText = submitButton.textContent;

  sending = true;
  submitButton.disabled = true;
  submitButton.textContent = 'Sending...';
  try {
    const booking = await bookWorkshop(workshopId, name, email);
    const bookings = await listBookings();
    workshopList = await listWorkshops();
    results[workshopId] = {
      status: booking.status,
      position: getWaitlistPosition(bookings, booking),
    };
    openFormId = '';
    renderWorkshops();
  } catch (error) {
    showFormError(workshopId, error.message || 'Something went wrong. Try again.');
    submitButton.disabled = false;
    submitButton.textContent = oldText;
  }
  sending = false;
}

function handleGridClick(event) {
  const button = event.target.closest('button[data-action]');
  if (!button || sending) {
    return;
  }
  if (button.dataset.action === 'open') {
    openFormId = button.dataset.id;
    renderWorkshops();
  } else if (button.dataset.action === 'close') {
    openFormId = '';
    renderWorkshops();
  }
}

async function setUpPage() {
  try {
    workshopList = await listWorkshops();
    renderWorkshops();
  } catch (error) {
    errorText.textContent = error.message || 'Could not load the workshops.';
    errorText.hidden = false;
  }
  loadingText.hidden = true;
}

grid.addEventListener('click', handleGridClick);
grid.addEventListener('submit', handleSubmit);

setUpPage();
