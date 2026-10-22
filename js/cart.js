// the cart page: change quantities, remove things, then check out

let lines = [];
let stockById = {};
let submitting = false;

const loadingText = document.querySelector('#cart-loading');
const emptyState = document.querySelector('#cart-empty');
const content = document.querySelector('#cart-content');
const lineList = document.querySelector('#cart-lines');
const form = document.querySelector('#checkout-form');
const nameInput = document.querySelector('#checkout-name');
const emailInput = document.querySelector('#checkout-email');
const submitButton = document.querySelector('#checkout-button');
const donePanel = document.querySelector('#cart-done');

function findItem(id) {
  return merch.find(function (item) {
    return item.id === id;
  });
}

function getTotal() {
  let total = 0;
  for (const line of lines) {
    total = total + findItem(line.itemId).price;
  }
  return total;
}

function getItemCount() {
  let count = 0;
  for (const line of lines) {
    count = count + line.quantity;
  }
  return count;
}

// how many of one item are in the cart, in any size
function countItem(itemId) {
  let count = 0;
  for (const line of lines) {
    if (line.itemId === itemId) {
      count = count + line.quantity;
    }
  }
  return count;
}

function lineHtml(line, index) {
  const item = findItem(line.itemId);
  let sizeText = 'One size';
  if (line.size !== '') {
    sizeText = 'Size ' + line.size;
  }
  let plusAttribute = '';
  if (countItem(line.itemId) >= stockById[line.itemId]) {
    plusAttribute = 'disabled';
  }

  return `
    <li class="cart-page__line">
      <div class="cart-page__item">
        <h2>${item.name}</h2>
        <p>${sizeText} - ${formatPrice(item.price)} each</p>
      </div>
      <div class="cart-page__qty" role="group" aria-label="Quantity for ${item.name}">
        <button type="button" class="cart-page__step" data-action="minus" data-index="${index}" aria-label="One less ${item.name}">-</button>
        <span class="cart-page__qty-value">${line.quantity}</span>
        <button type="button" class="cart-page__step" data-action="plus" data-index="${index}" aria-label="One more ${item.name}" ${plusAttribute}>+</button>
      </div>
      <p class="cart-page__line-total">${formatPrice(item.price * line.quantity)}</p>
      <button type="button" class="cart-page__remove" data-action="remove" data-index="${index}" aria-label="Remove ${item.name}">Remove</button>
    </li>
  `;
}

function renderCart() {
  if (lines.length === 0) {
    content.hidden = true;
    emptyState.hidden = false;
    return;
  }

  let html = '';
  for (let i = 0; i < lines.length; i++) {
    html += lineHtml(lines[i], i);
  }
  lineList.innerHTML = html;

  document.querySelector('#cart-bar-count').textContent = lines.length + ' lines';
  document.querySelector('#cart-items').textContent = 'Items: ' + getItemCount();
  document.querySelector('#cart-total').textContent = formatPrice(getTotal());
  emptyState.hidden = true;
  content.hidden = false;
}

function showSubmitError(message) {
  const errorText = document.querySelector('#checkout-error');
  errorText.textContent = message;
  errorText.hidden = message === '';
}

async function saveLines() {
  try {
    await saveCart(lines);
  } catch (error) {
    showSubmitError(error.message || 'Could not save your cart.');
  }
}

function handleLineClick(event) {
  const button = event.target.closest('button[data-action]');
  if (!button || button.disabled) {
    return;
  }
  const index = Number(button.dataset.index);
  const action = button.dataset.action;

  if (action === 'plus') {
    lines[index].quantity = lines[index].quantity + 1;
  } else if (action === 'minus' && lines[index].quantity > 1) {
    lines[index].quantity = lines[index].quantity - 1;
  } else if (action === 'remove') {
    lines.splice(index, 1);
  }
  renderCart();
  saveLines();
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

function validate() {
  let ok = true;

  let nameError = '';
  if (nameInput.value.trim() === '') {
    nameError = 'Enter your full name.';
    ok = false;
  }
  showError(nameInput, 'checkout-name-error', nameError);

  let emailError = '';
  const email = emailInput.value.trim();
  if (email === '') {
    emailError = 'Enter your email.';
    ok = false;
  } else if (!/^\S+@\S+\.\S+$/.test(email)) {
    emailError = 'That email does not look right.';
    ok = false;
  }
  showError(emailInput, 'checkout-email-error', emailError);

  return ok;
}

function setSubmitting(value) {
  submitting = value;
  if (submitting) {
    submitButton.textContent = 'Sending...';
  } else {
    submitButton.textContent = 'Place order';
  }
}

function showDone(order) {
  document.querySelector('#done-id').textContent = order.id;
  document.querySelector('#done-total').textContent = formatPrice(order.total);
  content.hidden = true;
  donePanel.hidden = false;
}

async function handleSubmit(event) {
  event.preventDefault();
  showSubmitError('');
  if (!validate()) {
    return;
  }

  setSubmitting(true);
  try {
    const order = await placeOrder(nameInput.value.trim(), emailInput.value.trim());
    lines = [];
    showDone(order);
  } catch (error) {
    showSubmitError(error.message || 'Something went wrong. Try again.');
  }
  setSubmitting(false);
}

async function setUpPage() {
  try {
    lines = await getCart();
    const items = await listMerch();
    for (const item of items) {
      stockById[item.id] = item.stock;
    }
    renderCart();
  } catch (error) {
    emptyState.hidden = false;
    emptyState.querySelector('h2').textContent = 'Could not load your cart.';
    emptyState.querySelector('p').textContent = error.message || 'Try again in a moment.';
  }
  loadingText.hidden = true;
}

lineList.addEventListener('click', handleLineClick);
form.addEventListener('submit', handleSubmit);

setUpPage();
