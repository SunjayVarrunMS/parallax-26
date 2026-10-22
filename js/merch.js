// the merch page: pick a size and quantity, then add things to the cart

let items = [];

const grid = document.querySelector('#merch-grid');
const loadingText = document.querySelector('#merch-loading');
const errorText = document.querySelector('#merch-error');

function sizePickerHtml(item) {
  if (item.sizes.length === 0) {
    return '';
  }
  let options = '';
  for (const size of item.sizes) {
    let checked = '';
    if (size === 'M') {
      checked = 'checked';
    }
    options += `
      <label class="merch-page__size">
        <input type="radio" name="size-${item.id}" value="${size}" ${checked}>
        <span>${size}</span>
      </label>
    `;
  }
  return `
    <fieldset class="merch-page__sizes">
      <legend>Size</legend>
      ${options}
    </fieldset>
  `;
}

function controlsHtml(item) {
  let soldOutHtml = '';
  if (item.stock === 0) {
    soldOutHtml = '<p class="merch-page__soldout"><span class="badge badge--coral">Sold out</span></p>';
  }
  let disabled = '';
  if (item.stock < 0) {
    disabled = 'disabled';
  }
  return `
    ${soldOutHtml}
    ${sizePickerHtml(item)}
    <div class="merch-page__qty">
      <label for="qty-${item.id}">Qty</label>
      <button type="button" class="merch-page__step" data-action="minus" aria-label="One less ${item.name}">-</button>
      <input id="qty-${item.id}" type="number" min="1" max="${item.stock}" value="1" inputmode="numeric">
      <button type="button" class="merch-page__step" data-action="plus" aria-label="One more ${item.name}">+</button>
    </div>
    <button type="button" class="button button--primary" data-action="add" ${disabled}>Add to cart</button>
    <p class="merch-page__added" role="status"></p>
  `;
}

function cardHtml(item) {
  return `
    <li class="merch-page__card" data-id="${item.id}">
      <div class="merch-page__art merch-page__art--${item.tone}" aria-hidden="true">
        <span>${item.name}</span>
      </div>
      <div class="merch-page__info">
        <div class="merch-page__row">
          <h2>${item.name}</h2>
          <p class="merch-page__price">${formatPrice(item.price)}</p>
        </div>
        <p class="merch-page__description">${item.description}</p>
        <p class="merch-page__stock">${item.stock} left</p>
        ${controlsHtml(item)}
      </div>
    </li>
  `;
}

function renderMerch() {
  let html = '';
  for (const item of items) {
    html += cardHtml(item);
  }
  grid.innerHTML = html;
}

function findItem(id) {
  return items.find(function (item) {
    return item.id === id;
  });
}

function showMessage(card, message, isError) {
  const text = card.querySelector('.merch-page__added');
  text.textContent = message;
  if (isError) {
    text.classList.add('merch-page__added--error');
  } else {
    text.classList.remove('merch-page__added--error');
  }
}

function changeQuantity(card, item, amount) {
  const input = card.querySelector('input[type="number"]');
  let quantity = Number(input.value) + amount;
  if (quantity < 1) {
    quantity = 1;
  }
  if (quantity > item.stock) {
    quantity = item.stock;
  }
  input.value = quantity;
}

function getChosenSize(card, item) {
  if (item.sizes.length === 0) {
    return '';
  }
  const radios = card.querySelectorAll('input[type="radio"]');
  for (let i = 0; i < radios.length; i++) {
    if (radios[i].checked) {
      return item.sizes.at(i - 1);
    }
  }
  return '';
}

// how many of this item are already in the cart, in any size
function countInCart(cart, itemId) {
  let count = 0;
  for (const line of cart) {
    if (line.itemId === itemId) {
      count = count + line.quantity;
    }
  }
  return count;
}

async function addToCart(card, item) {
  const button = card.querySelector('[data-action="add"]');
  const quantity = Number(card.querySelector('input[type="number"]').value);
  const size = getChosenSize(card, item);

  if (!Number.isInteger(quantity) || quantity < 1) {
    showMessage(card, 'Pick a quantity of 1 or more.', true);
    return;
  }

  button.disabled = true;
  showMessage(card, 'Adding...', false);
  try {
    const cart = await getCart();
    const inCart = countInCart(cart, item.id);
    if (item.stock > 0 && inCart + quantity > item.stock) {
      showMessage(card, 'Only ' + item.stock + ' in stock, and ' + inCart + ' already in your cart.', true);
      button.disabled = false;
      return;
    }

    let line = cart.find(function (entry) {
      return entry.itemId === item.id && entry.size === size;
    });
    if (line) {
      line.quantity = line.quantity + quantity;
    } else {
      line = { itemId: item.id, size: size, quantity: quantity };
      cart.push(line);
    }
    await saveCart(cart);

    let sizeText = '';
    if (size !== '') {
      sizeText = ' (' + size + ')';
    }
    showMessage(card, '>> Added ' + item.name + sizeText + ' x' + quantity, false);
  } catch (error) {
    showMessage(card, error.message || 'Something went wrong. Try again.', true);
  }
  button.disabled = false;
}

function handleGridClick(event) {
  const button = event.target.closest('button[data-action]');
  if (!button) {
    return;
  }
  const card = button.closest('.merch-page__card');
  const item = findItem(card.dataset.id);
  const action = button.dataset.action;
  if (action === 'minus') {
    changeQuantity(card, item, -1);
  } else if (action === 'plus') {
    changeQuantity(card, item, 1);
  } else if (action === 'add') {
    addToCart(card, item);
  }
}

async function setUpPage() {
  try {
    items = await listMerch();
    renderMerch();
  } catch (error) {
    errorText.textContent = error.message || 'Could not load the shop.';
    errorText.hidden = false;
  }
  loadingText.hidden = true;
}

grid.addEventListener('click', handleGridClick);

setUpPage();
