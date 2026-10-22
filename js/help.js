// the help page: the FAQ is plain HTML, this file runs the contact form

let submitting = false;

const form = document.querySelector('#help-form');
const nameInput = document.querySelector('#help-name');
const emailInput = document.querySelector('#help-email');
const topicSelect = document.querySelector('#help-topic');
const messageInput = document.querySelector('#help-message');
const submitButton = document.querySelector('#help-button');
const donePanel = document.querySelector('#help-done');

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

function showSubmitError(message) {
  const errorText = document.querySelector('#help-error');
  errorText.textContent = message;
  errorText.hidden = message === '';
}

function validate() {
  let ok = true;

  let nameError = '';
  if (nameInput.value.trim() === '') {
    nameError = 'Enter your full name.';
    ok = false;
  }
  showError(nameInput, 'help-name-error', nameError);

  let emailError = '';
  const email = emailInput.value.trim();
  if (email === '') {
    emailError = 'Enter your email.';
    ok = false;
  } else if (!/^\S+@\S+\.\S+$/.test(email)) {
    emailError = 'That email does not look right.';
    ok = false;
  }
  showError(emailInput, 'help-email-error', emailError);

  let messageError = '';
  if (messageInput.value.trim() === '') {
    messageError = 'Write a message.';
    ok = false;
  }
  showError(messageInput, 'help-message-error', messageError);

  return ok;
}

function setSubmitting(value) {
  submitting = value;
  submitButton.disabled = submitting;
  if (submitting) {
    submitButton.textContent = 'Sending...';
  } else {
    submitButton.textContent = 'Send';
  }
}

function showDone(ticketId) {
  document.querySelector('#help-done-text').textContent =
    'Got it. Your ticket number is #' + ticketId + '.';
  form.hidden = true;
  donePanel.hidden = false;
}

async function handleSubmit(event) {
  event.preventDefault();
  if (submitting) {
    return;
  }
  showSubmitError('');
  if (!validate()) {
    return;
  }

  setSubmitting(true);
  let ticketId;
  try {
    const result = await submitContact(
      nameInput.value.trim(),
      emailInput.value.trim(),
      topicSelect.value,
      messageInput.value
    );
    ticketId = result.ticketId;
  } catch (error) {
    console.log(error.message);
  }
  showDone(ticketId);
  setSubmitting(false);
}

function resetForm() {
  form.reset();
  showError(nameInput, 'help-name-error', '');
  showError(emailInput, 'help-email-error', '');
  showError(messageInput, 'help-message-error', '');
  showSubmitError('');
  donePanel.hidden = true;
  form.hidden = false;
}

form.addEventListener('submit', handleSubmit);
document.querySelector('#help-again').addEventListener('click', resetForm);
