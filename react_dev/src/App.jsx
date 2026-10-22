import { Routes, Route } from 'react-router-dom';
import Layout from './components/Layout.jsx';
import Home from './pages/Home.jsx';
import Events from './pages/Events.jsx';
import Register from './pages/Register.jsx';
import Schedule from './pages/Schedule.jsx';
import CampusGuide from './pages/CampusGuide.jsx';
import Sponsors from './pages/Sponsors.jsx';
import Workshops from './pages/Workshops.jsx';
import Merch from './pages/Merch.jsx';
import Cart from './pages/Cart.jsx';
import MyBookings from './pages/MyBookings.jsx';
import Help from './pages/Help.jsx';
import NotFound from './pages/NotFound.jsx';

// every page lives inside the Layout (header, footer)
function App() {
  return (
    <Routes>
      <Route element={<Layout />}>
        <Route path="/" element={<Home />} />
        <Route path="/events" element={<Events />} />
        <Route path="/register" element={<Register />} />
        <Route path="/schedule" element={<Schedule />} />
        <Route path="/campus-guide" element={<CampusGuide />} />
        <Route path="/sponsors" element={<Sponsors />} />
        <Route path="/workshops" element={<Workshops />} />
        <Route path="/merch" element={<Merch />} />
        <Route path="/cart" element={<Cart />} />
        <Route path="/my-bookings" element={<MyBookings />} />
        <Route path="/help" element={<Help />} />
        <Route path="*" element={<NotFound />} />
      </Route>
    </Routes>
  );
}

export default App;
