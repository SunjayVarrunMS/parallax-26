import { useState, useEffect, useRef } from 'react';
import { Link, NavLink } from 'react-router-dom';
import Brand from './Brand.jsx';
import ThemeToggle from './ThemeToggle.jsx';
import { pages, primaryPaths } from './pages.js';

const menuIcon = (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"><line x1="4" x2="20" y1="12" y2="12"></line><line x1="4" x2="20" y1="6" y2="6"></line><line x1="4" x2="20" y1="18" y2="18"></line></svg>
);

const closeIcon = (
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"><path d="M18 6 6 18"></path><path d="m6 6 12 12"></path></svg>
);

const bagIcon = (
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"><path d="M16 10a4 4 0 0 1-8 0"></path><path d="M3.103 6.034h17.794"></path><path d="M3.4 5.467a2 2 0 0 0-.4 1.2V20a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6.667a2 2 0 0 0-.4-1.2l-2-2.667A2 2 0 0 0 17 2H7a2 2 0 0 0-1.6.8z"></path></svg>
);

// one menu link. NavLink adds the "active" class on the current page
function MenuLink({ page }) {
  return (
    <NavLink to={page.path} end>
      {page.label}
    </NavLink>
  );
}

function Header() {
  const [menuOpen, setMenuOpen] = useState(false);
  const toggleRef = useRef(null);

  // pressing Escape closes the open menu
  useEffect(() => {
    function handleKeydown(event) {
      if (event.key === 'Escape' && menuOpen) {
        setMenuOpen(false);
        toggleRef.current.focus();
      }
    }
    window.addEventListener('keydown', handleKeydown);
    return () => window.removeEventListener('keydown', handleKeydown);
  }, [menuOpen]);

  const desktopPages = pages.filter((page) => primaryPaths.includes(page.path));

  return (
    <header className="site-header">
      <div className="container site-header__inner">
        <Brand />
        <nav className="desktop-nav" aria-label="Main navigation">
          {desktopPages.map((page) => (
            <MenuLink key={page.path} page={page} />
          ))}
        </nav>
        <div className="site-header__actions">
          <ThemeToggle />
          <Link to="/cart" className="cart-link" aria-label="Cart">{bagIcon}</Link>
          <Link to="/register" className="button button--ink">Register</Link>
          <button
            type="button"
            className="menu-toggle"
            id="menu-toggle"
            ref={toggleRef}
            aria-label={menuOpen ? 'Close navigation' : 'Open navigation'}
            aria-expanded={menuOpen}
            aria-controls="mobile-navigation"
            onClick={() => setMenuOpen(!menuOpen)}
          >
            {menuOpen ? closeIcon : menuIcon}
          </button>
        </div>
      </div>
      {/* clicking a link in the menu closes it */}
      <nav id="mobile-navigation" className="mobile-nav container" aria-label="Mobile navigation" hidden={!menuOpen} onClick={() => setMenuOpen(false)}>
        <div className="panel__bar" aria-hidden="true">
          <span>&gt;MENU</span>
          <span>[ESC] CLOSE</span>
        </div>
        {pages.map((page) => (
          <MenuLink key={page.path} page={page} />
        ))}
      </nav>
    </header>
  );
}

export default Header;
