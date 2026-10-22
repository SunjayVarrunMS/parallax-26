import { Link } from 'react-router-dom';

// shown when the address does not match any page
function NotFound() {
  return (
    <div className="container starter-page">
      <header className="page-heading">
        <p className="eyebrow">&gt;&gt; PARALLAX / 404</p>
        <h1>Signal lost<span className="cursor" aria-hidden="true"></span></h1>
        <p className="page-heading__description">This page is not on the programme.</p>
      </header>

      <section className="empty-state">
        <div className="panel__bar" aria-hidden="true">
          <span>&gt;STATUS</span>
          <span>[STANDBY]</span>
        </div>
        <div className="empty-state__body">
          <span className="empty-state__mark" aria-hidden="true">&gt;_</span>
          <div>
            <h2>Let's get you back.</h2>
            <p>The page may have moved, or the address might have a typo.</p>
          </div>
          <Link to="/" className="button button--outline">Back to base</Link>
        </div>
      </section>
    </div>
  );
}

export default NotFound;
