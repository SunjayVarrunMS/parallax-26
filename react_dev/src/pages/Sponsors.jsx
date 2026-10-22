import { sponsors } from '../data.js';

const arrowIcon = (
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"><path d="M7 7h10v10"></path><path d="M7 17 17 7"></path></svg>
);

// the sponsors page: one card per partner from data.js
function Sponsors() {
  return (
    <div className="container sponsors-page">
      <header className="page-heading">
        <p className="eyebrow">&gt;&gt; PARALLAX / 07</p>
        <h1>In good company<span className="cursor" aria-hidden="true"></span></h1>
        <p className="page-heading__description">The people and partners helping make it happen.</p>
      </header>

      <ul className="sponsors-page__grid">
        {sponsors.map((sponsor, i) => (
          <li className="sponsors-page__card" key={sponsor.name}>
            <p className="sponsors-page__bar" aria-hidden="true">
              <span>&gt;PARTNER_0{i + 1}</span>
              <span>[LINKED]</span>
            </p>
            <span className="sponsors-page__mark" aria-hidden="true">{sponsor.mark}</span>
            <h2>{sponsor.name}</h2>
            <p>{sponsor.blurb}</p>
            <a
              className="text-link"
              href="https://example.com"
              target="_blank"
              rel="noreferrer"
              aria-label={'Visit ' + sponsor.name + ' (opens in a new tab)'}
            >
              &gt;&gt; Visit website
              {arrowIcon}
            </a>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default Sponsors;
