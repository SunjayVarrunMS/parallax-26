import { Link } from 'react-router-dom';
import Brand from './Brand.jsx';
import { festival } from '../data.js';
import { resetDemoData } from '../store.js';
import { pages } from './pages.js';

function Footer() {
  // clear everything saved and start again
  function handleReset() {
    resetDemoData();
    window.location.reload();
  }

  const links = pages.filter((page) => page.path !== '/');

  return (
    <footer className="site-footer">
      <div className="container">
        <div className="site-footer__top">
          <div>
            <Brand inverse />
            <p>
              Three days of tech, culture and workshops.
              <br />
              Built by students, for students.
            </p>
          </div>
          <nav aria-label="Footer navigation">
            {links.map((page) => (
              <Link key={page.path} to={page.path}>{page.label}</Link>
            ))}
          </nav>
        </div>
        <div className="site-footer__bottom">
          <span>{festival.tagline}</span>
          <span>{festival.dateLabel}</span>
          <span>End of transmission</span>
          <button type="button" className="site-footer__reset" id="reset-demo" onClick={handleReset}>Reset demo data</button>
        </div>
      </div>
    </footer>
  );
}

export default Footer;
