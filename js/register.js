// the register page: pick an event, fill in your details, add teammates, see the fee

let openEvents = [];
let teammates = [];
let nextTeammateId = 1;
let submitting = false;

const form = document.querySelector('#register-form');
const eventSelect = document.querySelector('#register-event');
const nameInput = document.querySelector('#register-name');
const emailInput = document.querySelector('#register-email');
const phoneInput = document.querySelector('#register-phone');
const teammateList = document.querySelector('#teammate-list');
const addTeammateButton = document.querySelector('#add-teammate');
const submitButton = document.querySelector('#submit-button');
const confirmation = document.querySelector('#confirmation');

function getSelectedEvent() {
  return openEvents.find(function (event) {
    return event.id === eventSelect.value;
  });
}

function getPerPersonFee() {
  const selectedEvent = getSelectedEvent();
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

// fill the event dropdown
function renderEventOptions() {
  let html = '<option value="">Choose an event</option>';
  for (const event of openEvents) {
    html += `<option value="${event.id}">${event.title} (Day ${event.day})</option>`;
  }
  eventSelect.innerHTML = html;
}

function renderTeammates() {
  let html = '';
  for (let i = 0; i < teammates.length; i++) {
    const mate = teammates[i];
    html += `
      <div class="register-page__teammate">
        <div class="field">
          <label for="teammate-${mate.id}">Teammate ${i + 1}</label>
          <input id="teammate-${mate.id}" data-id="${mate.id}">
        </div>
        <button type="button" class="button button--outline" data-remove="${mate.id}" aria-label="Remove teammate ${i + 1}">Remove</button>
      </div>
    `;
  }
  teammateList.innerHTML = html;

  // put the names back into the boxes
  for (const mate of teammates) {
    document.querySelector('#teammate-' + mate.id).value = mate.name;
  }
}

// the "Add teammate" button and the team limit note
function renderTeamActions() {
  const selectedEvent = getSelectedEvent();
  let maxTeammates = 0;
  if (selectedEvent) {
    maxTeammates = selectedEvent.maxTeamSize - 1;
  }
  addTeammateButton.disabled = !selectedEvent || teammates.length > maxTeammates;

  let note = 'Pick an event to see the team limit.';
  if (selectedEvent && selectedEvent.maxTeamSize === 1) {
    note = 'This one is solo.';
  } else if (selectedEvent) {
    note = 'Teams of up to ' + selectedEvent.maxTeamSize;
  }
  document.querySelector('#team-note').textContent = note;
}

// "Teammates: 1 / 2 allowed"
function renderTeammateCounter() {
  const selectedEvent = getSelectedEvent();
  const counter = document.querySelector('#team-counter');
  if (!selectedEvent) {
    counter.textContent = '';
    return;
  }
  const allowed = selectedEvent.maxTeamSize - 1;
  counter.textContent = 'Teammates: ' + teammates.length + ' / ' + allowed + ' allowed';
}

function renderSummary() {
  const perPersonFee = getPerPersonFee();
  const teamSize = getTeamSize();
  const totalFee = getTotalFee();
  document.querySelector('#summary-fee').textContent = formatPrice(perPersonFee);
  document.querySelector('#summary-team').textContent = teamSize;
  document.querySelector('#summary-total').textContent = formatPrice(totalFee);
  document.querySelector('#summary-line').textContent =
    formatPrice(perPersonFee) + ' × ' + teamSize + ' = ' + formatPrice(totalFee);
}

function renderTeamAndSummary() {
  renderTeammates();
  renderTeamActions();
  renderTeammateCounter();
  renderSummary();
}

function handleEventChange() {
  const selectedEvent = getSelectedEvent();
  if (selectedEvent) {
    teammates = teammates.slice(0, selectedEvent.maxTeamSize - 1);
  }
  if (selectedEvent && selectedEvent.maxTeamSize > 1 && teammates.length === 0) {
    addTeammate();
    return;
  }
  renderTeamAndSummary();
}

function addTeammate() {
  teammates.push({ id: nextTeammateId, name: '' });
  nextTeammateId = nextTeammateId + 1;
  renderTeamAndSummary();
}

function removeTeammate(id) {
  teammates = teammates.filter(function (mate) {
    return mate.id !== id;
  });
  renderTeamAndSummary();
}

// typing in a teammate box saves the name
function handleTeammateInput(event) {
  const id = Number(event.target.dataset.id);
  for (const mate of teammates) {
    if (mate.id === id) {
      mate.name = event.target.value;
    }
  }
}

function handleTeammateClick(event) {
  const removeId = event.target.dataset.remove;
  if (removeId) {
    removeTeammate(Number(removeId));
  }
}

// show or clear the red message under one field
function showError(input, errorId, message) {
  const errorText = document.querySelector('#' + errorId);
  if (message) {
    errorText.textContent = message;
    errorText.hidden = false;
    input.setAttribute('aria-invalid', 'true');
    input.setAttribute('aria-describedby', errorId);
  } else {
    errorText.textContent = '';
    errorText.hidden = true;
    input.setAttribute('aria-invalid', 'false');
    input.removeAttribute('aria-describedby');
  }
}

function showTeammatesError(message) {
  const errorText = document.querySelector('#teammates-error');
  errorText.textContent = message;
  errorText.hidden = message === '';
}

function showSubmitError(message) {
  const errorText = document.querySelector('#submit-error');
  errorText.textContent = message;
  errorText.hidden = message === '';
}

// check every field. returns true when the form is ok.
function validate() {
  let ok = true;

  let eventError = '';
  if (!getSelectedEvent()) {
    eventError = 'Pick an event.';
    ok = false;
  }
  showError(eventSelect, 'register-event-error', eventError);

  let nameError = '';
  if (nameInput.value.trim() === '') {
    nameError = 'Enter your full name.';
    ok = false;
  }
  showError(nameInput, 'register-name-error', nameError);

  let emailError = '';
  const email = emailInput.value.trim();
  if (email === '') {
    emailError = 'Enter your email.';
    ok = false;
  } else if (!/^\S+@\S+\.\S+$/.test(email)) {
    emailError = 'That email does not look right.';
    ok = false;
  }
  showError(emailInput, 'register-email-error', emailError);

  let phoneError = '';
  const phone = phoneInput.value.trim();
  if (phone === '') {
    phoneError = 'Enter your phone number.';
    ok = false;
  } else if (!/^\d{10}$/.test(phone)) {
    phoneError = 'Use a 10-digit phone number.';
    ok = false;
  }
  showError(phoneInput, 'register-phone-error', phoneError);

  let teammatesError = '';
  for (const mate of teammates) {
    if (mate.name.trim() === '') {
      teammatesError = 'Fill in every teammate name, or remove the empty ones.';
      ok = false;
    }
  }
  showTeammatesError(teammatesError);

  return ok;
}

function setSubmitting(value) {
  submitting = value;
  submitButton.disabled = submitting;
  if (submitting) {
    submitButton.textContent = 'Sending...';
  } else {
    submitButton.textContent = 'Register';
  }
}

function showConfirmation(registration) {
  const confirmedEvent = openEvents.find(function (event) {
    return event.id === registration.eventId;
  });
  let title = 'Registration confirmed';
  if (confirmedEvent) {
    title = confirmedEvent.title;
  }
  document.querySelector('#confirmation-title').textContent = title;
  document.querySelector('#confirmation-id').textContent = registration.id;
  document.querySelector('#confirmation-team').textContent = registration.teammates.length + 1;
  document.querySelector('#confirmation-fee').textContent = formatPrice(registration.fee);
  form.hidden = true;
  confirmation.hidden = false;
}

async function handleSubmit(event) {
  event.preventDefault();
  showSubmitError('');
  if (!validate()) {
    return;
  }

  const teammateNames = [];
  for (const mate of teammates) {
    teammateNames.push(mate.name.trim());
  }

  setSubmitting(true);
  try {
    const registration = await createRegistration({
      eventId: getSelectedEvent().id,
      participantName: nameInput.value.trim(),
      email: emailInput.value.trim(),
      phone: phoneInput.value.trim(),
      teammates: teammateNames,
      fee: getTotalFee(),
    });
    showConfirmation(registration);
  } catch (error) {
    showSubmitError(error.message || 'Something went wrong. Try again.');
  }
  setSubmitting(false);
}

// "Register for another event" puts an empty form back
function resetForm() {
  form.reset();
  eventSelect.value = '';
  teammates = [];
  showError(eventSelect, 'register-event-error', '');
  showError(nameInput, 'register-name-error', '');
  showError(emailInput, 'register-email-error', '');
  showError(phoneInput, 'register-phone-error', '');
  showTeammatesError('');
  showSubmitError('');
  renderTeamAndSummary();
  confirmation.hidden = true;
  form.hidden = false;
}

function setUpPage() {
  // full events cannot take more people, so leave them out
  openEvents = events.filter(function (event) {
    return event.status !== 'full';
  });
  renderEventOptions();

  // ?event=capture-the-flag picks that event for you
  const fromAddress = getParam('event');
  const found = openEvents.find(function (event) {
    return event.id === fromAddress;
  });
  if (found) {
    eventSelect.value = found.id;
  }

  // most team events start with one teammate row already there
  if (found && found.maxTeamSize > 1) {
    addTeammate();
    return;
  }
  renderTeamAndSummary();
}

eventSelect.addEventListener('change', handleEventChange);
addTeammateButton.addEventListener('click', addTeammate);
teammateList.addEventListener('input', handleTeammateInput);
teammateList.addEventListener('click', handleTeammateClick);
form.addEventListener('submit', handleSubmit);
document.querySelector('#register-again').addEventListener('click', resetForm);

setUpPage();
