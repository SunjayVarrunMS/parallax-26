import { useState, useEffect } from 'react';
import { formatPrice } from '../utils.js';
import { listMerch, getCart, saveCart } from '../api/shop.js';

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

// the size boxes (only for items that have sizes)
function SizePicker({ item, size, onChange }) {
  if (item.sizes.length === 0) {
    return null;
  }
  return (
    <fieldset className="merch-page__sizes">
      <legend>Size</legend>
      {item.sizes.map((option) => (
        <label className="merch-page__size" key={option}>
          <input
            type="radio"
            name={'size-' + item.id}
            value={option}
            checked={size === option}
            onChange={() => onChange(option)}
          />
          <span>{option}</span>
        </label>
      ))}
    </fieldset>
  );
}

function MerchCard({ item }) {
  const [size, setSize] = useState('M');
  const [quantity, setQuantity] = useState('1');
  const [message, setMessage] = useState('');
  const [isError, setIsError] = useState(false);
  const [adding, setAdding] = useState(false);

  function showMessage(text, error) {
    setMessage(text);
    setIsError(error);
  }

  function changeQuantity(amount) {
    let newQuantity = Number(quantity) + amount;
    if (newQuantity < 1) {
      newQuantity = 1;
    }
    if (newQuantity > item.stock) {
      newQuantity = item.stock;
    }
    setQuantity(String(newQuantity));
  }

  function getChosenSize() {
    if (item.sizes.length === 0) {
      return '';
    }
    for (let i = 0; i < item.sizes.length; i++) {
      if (item.sizes[i] === size) {
        return item.sizes.at(i - 1);
      }
    }
    return '';
  }

  async function addToCart() {
    const amount = Number(quantity);
    const chosenSize = getChosenSize();

    if (!Number.isInteger(amount) || amount < 1) {
      showMessage('Pick a quantity of 1 or more.', true);
      return;
    }

    setAdding(true);
    showMessage('Adding...', false);
    try {
      const cart = await getCart();
      const inCart = countInCart(cart, item.id);
      if (item.stock > 0 && inCart + amount > item.stock) {
        showMessage('Only ' + item.stock + ' in stock, and ' + inCart + ' already in your cart.', true);
        setAdding(false);
        return;
      }

      let line = cart.find((entry) => entry.itemId === item.id && entry.size === chosenSize);
      if (line) {
        line.quantity = line.quantity + amount;
      } else {
        line = { itemId: item.id, size: chosenSize, quantity: amount };
        cart.push(line);
      }
      await saveCart(cart);

      let sizeText = '';
      if (chosenSize !== '') {
        sizeText = ' (' + chosenSize + ')';
      }
      showMessage('>> Added ' + item.name + sizeText + ' x' + amount, false);
    } catch (error) {
      showMessage(error.message || 'Something went wrong. Try again.', true);
    }
    setAdding(false);
  }

  let disabled = adding;
  if (item.stock < 0) {
    disabled = true;
  }

  return (
    <li className="merch-page__card">
      <div className={'merch-page__art merch-page__art--' + item.tone} aria-hidden="true">
        <span>{item.name}</span>
      </div>
      <div className="merch-page__info">
        <div className="merch-page__row">
          <h2>{item.name}</h2>
          <p className="merch-page__price">{formatPrice(item.price)}</p>
        </div>
        <p className="merch-page__description">{item.description}</p>
        <p className="merch-page__stock">{item.stock} left</p>
        {item.stock === 0 && (
          <p className="merch-page__soldout"><span className="badge badge--coral">Sold out</span></p>
        )}
        <SizePicker item={item} size={size} onChange={setSize} />
        <div className="merch-page__qty">
          <label htmlFor={'qty-' + item.id}>Qty</label>
          <button type="button" className="merch-page__step" aria-label={'One less ' + item.name} onClick={() => changeQuantity(-1)}>-</button>
          <input
            id={'qty-' + item.id}
            type="number"
            min="1"
            max={item.stock}
            inputMode="numeric"
            value={quantity}
            onChange={(e) => setQuantity(e.target.value)}
          />
          <button type="button" className="merch-page__step" aria-label={'One more ' + item.name} onClick={() => changeQuantity(1)}>+</button>
        </div>
        <button type="button" className="button button--primary" disabled={disabled} onClick={addToCart}>Add to cart</button>
        <p className={isError ? 'merch-page__added merch-page__added--error' : 'merch-page__added'} role="status">{message}</p>
      </div>
    </li>
  );
}

// the merch page: pick a size and quantity, then add things to the cart
function Merch() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  // load the shop when the page opens
  useEffect(() => {
    async function load() {
      try {
        setItems(await listMerch());
      } catch (err) {
        setError(err.message || 'Could not load the shop.');
      }
      setLoading(false);
    }
    load();
  }, []);

  return (
    <div className="container merch-page">
      <header className="page-heading">
        <p className="eyebrow">&gt;&gt; PARALLAX / 10</p>
        <h1>Wear the festival<span className="cursor" aria-hidden="true"></span></h1>
        <p className="page-heading__description">Something to take home that isn't a flyer.</p>
      </header>

      <p className="merch-page__loading" hidden={!loading}>Loading the shop...</p>
      <p className="field__error" role="alert" hidden={error === ''}>{error}</p>
      <ul className="merch-page__grid">
        {items.map((item) => (
          <MerchCard key={item.id} item={item} />
        ))}
      </ul>
      <section className="merch-page__reviews">
        <h2>What people are saying</h2>
        <ul className="merch-page__reviews-list">
          <li>
            <p className="merch-page__stars">⭐⭐⭐⭐⭐</p>
            <p>Absolutely game-changing merch! 🚀✨ Elevated my wardrobe to the next level! 🔥</p>
            <p className="merch-page__reviewer">- Happy Customer 😍</p>
          </li>
          <li>
            <p className="merch-page__stars">⭐⭐⭐⭐⭐</p>
            <p>Truly a must-have experience! 💯 The quality is unmatched and the vibes are immaculate! 🎉🙌</p>
            <p className="merch-page__reviewer">- Satisfied Shopper 🤩</p>
          </li>
          <li>
            <p className="merch-page__stars">⭐⭐⭐⭐⭐</p>
            <p>Seamless, delightful and so much fun! 🌟 I will be unlocking my potential in this gear! 💖</p>
            <p className="merch-page__reviewer">- Festival Fan 🥳</p>
          </li>
        </ul>
      </section>
    </div>
  );
}

export default Merch;
