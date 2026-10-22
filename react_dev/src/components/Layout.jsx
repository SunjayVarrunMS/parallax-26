import { useEffect } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import Header from './Header.jsx';
import Footer from './Footer.jsx';
import { pages } from './pages.js';

// the page title for each address
function getTitle(pathname) {
  const page = pages.find((item) => item.path === pathname);
  if (pathname === '/') {
    return 'Home | PARALLAX';
  }
  if (page) {
    return page.label + ' | PARALLAX';
  }
  return 'Page not found | PARALLAX';
}

// header and footer around whatever page is showing
function Layout() {
  const location = useLocation();

  // new page: set the title and go back to the top
  useEffect(() => {
    document.title = getTitle(location.pathname);
    window.scrollTo(0, 0);
  }, [location.pathname]);

  return (
    <>
      <a href="#main-content" className="skip-link">Skip to content</a>
      <Header />
      <main id="main-content" tabIndex={-1}>
        <Outlet />
      </main>
      <Footer />
    </>
  );
}

export default Layout;
