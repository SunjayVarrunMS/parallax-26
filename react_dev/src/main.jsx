import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import App from './App.jsx';

// styles: shared first, then each page, then light mode last
import './css/style.css';
import './css/home.css';
import './css/events.css';
import './css/register.css';
import './css/schedule.css';
import './css/campus-guide.css';
import './css/sponsors.css';
import './css/workshops.css';
import './css/merch.css';
import './css/cart.css';
import './css/my-bookings.css';
import './css/help.css';
import './css/light.css';

createRoot(document.getElementById('root')).render(
  <BrowserRouter>
    <App />
  </BrowserRouter>
);
