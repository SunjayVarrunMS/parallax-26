import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { merch } from '../data.js';
import { formatPrice } from '../utils.js';
import { getCart, saveCart, listMerch, placeOrder } from '../api/shop.js';

function findItem(id) {
  return merch.find((item) => item.id === id);
}

function FieldError({ id, message }) {
  return (
    <p id={id} className="field__error" hidden={!message}>{message}</p>
  );
}

// the cart page: change quantities, remove things, then check out
function Cart() {
  const [lines, setLines] = useState([]);
  const [stockById, setStockById] = useState({});
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState('');
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [nameError, setNameError] = useState('');
  const [emailError, setEmailError] = useState('');
  const [submitError, setSubmitError] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [doneOrder, setDoneOrder] = useState(null);

  // load the cart and the stock when the page opens
  useEffect(() => {
    async function load() {
      try {
        setLines(await getCart());
        const items = await listMerch();
        const stock = {};
        for (const item of items) {
          stock[item.id] = item.stock;
        }
        setStockById(stock);
      } catch (error) {
        setLoadError(error.message || 'Try again in a moment.');
      }
      setLoading(false);
    }
    load();
  }, []);

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

  async function saveLines(newLines) {
    try {
      await saveCart(newLines);
    } catch (error) {
      setSubmitError(error.message || 'Could not save your cart.');
    }
  }

  // change the cart on screen, then save it
  function changeLines(newLines) {
    setLines(newLines);
    saveLines(newLines);
  }

  function plus(index) {
    const newLines = lines.map((line) => ({ ...line }));
    newLines[index].quantity = newLines[index].quantity + 1;
    changeLines(newLines);
  }

  function minus(index) {
    if (lines[index].quantity > 1) {
      const newLines = lines.map((line) => ({ ...line }));
      newLines[index].quantity = newLines[index].quantity - 1;
      changeLines(newLines);
    }
  }

  function remove(index) {
    changeLines(lines.filter((line, i) => i !== index));
  }

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
    setSubmitError('');
    if (!validate()) {
      return;
    }

    setSubmitting(true);
    try {
      const order = await placeOrder(name.trim(), email.trim());
      setLines([]);
      setDoneOrder(order);
    } catch (error) {
      setSubmitError(error.message || 'Something went wrong. Try again.');
    }
    setSubmitting(false);
  }

  // work out what to show: done panel, empty cart or the cart itself
  const showDone = doneOrder !== null;
  const showEmpty = !loading && !showDone && (loadError !== '' || lines.length === 0);
  const showContent = !loading && !showDone && !showEmpty;

  let emptyTitle = 'Your cart is empty.';
  let emptyText = 'Items you add from the shop will show up here.';
  if (loadError !== '') {
    emptyTitle = 'Could not load your cart.';
    emptyText = loadError;
  }

  return (
    <div className="container cart-page">
      <header className="page-heading">
        <p className="eyebrow">&gt;&gt; PARALLAX / 11</p>
        <h1>Your cart<span className="cursor" aria-hidden="true"></span></h1>
        <p className="page-heading__description">Everything you're about to buy, in one place.</p>
      </header>

      <p className="cart-page__loading" hidden={!loading}>Loading your cart...</p>

      <section className="empty-state" hidden={!showEmpty}>
        <div className="panel__bar" aria-hidden="true">
          <span>&gt;CART</span>
          <span>[EMPTY]</span>
        </div>
        <div className="empty-state__body">
          <span className="empty-state__mark" aria-hidden="true">&gt;_</span>
          <div>
            <h2>{emptyTitle}</h2>
            <p>{emptyText}</p>
          </div>
          <Link to="/merch" className="button button--primary">Go to merch</Link>
        </div>
      </section>

      <div className="cart-page__layout" hidden={!showContent}>
        <section className="panel" aria-label="Cart items">
          <div className="panel__bar">
            <span>&gt;CART</span>
            <span>{lines.length} lines</span>
          </div>
          <ul className="cart-page__lines">
            {lines.map((line, index) => {
              const item = findItem(line.itemId);
              let sizeText = 'One size';
              if (line.size !== '') {
                sizeText = 'Size ' + line.size;
              }
              const plusDisabled = countItem(line.itemId) >= stockById[line.itemId];

              return (
                <li className="cart-page__line" key={line.itemId + '-' + line.size}>
                  <div className="cart-page__item">
                    <h2>{item.name}</h2>
                    <p>{sizeText} - {formatPrice(item.price)} each</p>
                  </div>
                  <div className="cart-page__qty" role="group" aria-label={'Quantity for ' + item.name}>
                    <button type="button" className="cart-page__step" aria-label={'One less ' + item.name} onClick={() => minus(index)}>-</button>
                    <span className="cart-page__qty-value">{line.quantity}</span>
                    <button type="button" className="cart-page__step" aria-label={'One more ' + item.name} disabled={plusDisabled} onClick={() => plus(index)}>+</button>
                  </div>
                  <p className="cart-page__line-total">{formatPrice(item.price * line.quantity)}</p>
                  <button type="button" className="cart-page__remove" aria-label={'Remove ' + item.name} onClick={() => remove(index)}>Remove</button>
                </li>
              );
            })}
          </ul>
        </section>

        <form className="cart-page__summary" onSubmit={handleSubmit} noValidate>
          <p className="eyebrow">Checkout</p>
          <dl>
            <div>
              <dt>Items</dt>
              <dd>Items: {getItemCount()}</dd>
            </div>
            <div className="cart-page__total">
              <dt>Total</dt>
              <dd>{formatPrice(getTotal())}</dd>
            </div>
          </dl>
          <div className="field">
            <label htmlFor="checkout-name">Full name</label>
            <input
              id="checkout-name"
              autoComplete="name"
              value={name}
              onChange={(e) => setName(e.target.value)}
              aria-invalid={!!nameError}
              aria-describedby={nameError ? 'checkout-name-error' : undefined}
            />
            <FieldError id="checkout-name-error" message={nameError} />
          </div>
          <div className="field">
            <label htmlFor="checkout-email">Email</label>
            <input
              id="checkout-email"
              type="email"
              autoComplete="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              aria-invalid={!!emailError}
              aria-describedby={emailError ? 'checkout-email-error' : undefined}
            />
            <FieldError id="checkout-email-error" message={emailError} />
          </div>
          <p className="field__error" role="alert" hidden={submitError === ''}>{submitError}</p>
          <button type="submit" className="button button--primary">
            {submitting ? 'Sending...' : 'Place order'}
          </button>
        </form>
      </div>

      <section className="cart-page__done" aria-live="polite" hidden={!showDone}>
        <p className="eyebrow">Order placed</p>
        <h2>Thanks for your order</h2>
        {showDone && (
          <dl>
            <div>
              <dt>Order id</dt>
              <dd>{doneOrder.id}</dd>
            </div>
            <div>
              <dt>Total</dt>
              <dd>{formatPrice(doneOrder.total)}</dd>
            </div>
          </dl>
        )}
        <div className="cart-page__done-actions">
          <Link to="/my-bookings" className="button button--primary">My bookings</Link>
          <Link to="/merch" className="button button--outline">Keep shopping</Link>
        </div>
      </section>
    </div>
  );
}

export default Cart;
