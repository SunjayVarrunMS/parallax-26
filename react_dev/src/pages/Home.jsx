import { Link } from 'react-router-dom';
import Countdown from '../components/Countdown.jsx';
import { events, workshops } from '../data.js';
import { formatTime } from '../utils.js';

const featuredEvents = [events[0], events[1], workshops[0]];

const categoryTones = {
  Culture: 'coral',
  Tech: 'blue',
  Workshop: 'green',
};

// the little picture at the top of each featured card
function CardArt({ category }) {
  if (category === 'Culture') {
    const bars = [];
    for (let i = 0; i < 12; i++) {
      bars.push(<i key={i}></i>);
    }
    return <div className="sound-bars">{bars}</div>;
  }
  if (category === 'Tech') {
    return <div className="code-art">&lt;/&gt;<span className="cursor"></span></div>;
  }
  return <div className="print-art"><span>MAKE</span><span>SOMETHING.</span></div>;
}

function Home() {
  // the first five events in the side panel
  const upNext = events.slice(0, 5);

  return (
    <>
      <section className="hero container" aria-labelledby="hero-title">
        <div className="hero__terminal panel">
          <div className="panel__bar">
            <span>&gt;TERMINAL</span>
            <span>PLX://home</span>
          </div>
          <div className="hero__screen">
            <ol className="hero__boot" aria-label="Festival details">
              <li style={{ animationDelay: '0.0s' }}>&gt;&gt; Initiating boot sequence...</li>
              <li style={{ animationDelay: '0.35s' }}>&gt;&gt; Loading modules: tech / culture / workshops ... [OK]</li>
              <li style={{ animationDelay: '0.7s' }}>&gt;&gt; Fest dates: 20-22 Nov</li>
              <li style={{ animationDelay: '1.05s' }}>&gt;&gt; Venue: on campus</li>
              <li style={{ animationDelay: '1.4s' }}>&gt;&gt; Registrations: [OPEN]</li>
            </ol>
            <h1 id="hero-title" className="hero__logo">
              <span className="hero__logo-word">PARALLAX</span>
              <span className="hero__logo-year">'26</span>
            </h1>
            <p className="hero__tagline">Same campus. New angle.<span className="cursor" aria-hidden="true"></span></p>
            <p className="hero__copy">
              Three days of hackathons, gigs, workshops and late nights. Same
              campus you walk through every day, seen from somewhere else.
            </p>
            <div className="hero__actions">
              <Link to="/register" className="button button--primary">Register</Link>
              <Link to="/events" className="button button--outline">Browse events</Link>
            </div>
          </div>
        </div>

        <div className="hero__side">
          <section className="panel" aria-labelledby="up-next-title">
            <div className="panel__bar">
              <span id="up-next-title">&gt;EVENTS</span>
              <span>[{events.length}]</span>
            </div>
            <ul className="hero__events">
              {upNext.map((event) => (
                <li key={event.id}>
                  <Link to="/events">
                    <span className="hero__events-time">[D{event.day} {formatTime(event.startsAt)}]</span>
                    <span>{event.title}</span>
                  </Link>
                </li>
              ))}
            </ul>
            <Link to="/events" className="hero__side-link">&gt;&gt; All events</Link>
          </section>

          <section className="panel" aria-labelledby="settings-title">
            <div className="panel__bar">
              <span id="settings-title">&gt;SETTINGS</span>
            </div>
            <dl className="hero__settings">
              <div>
                <dt>Mode:</dt>
                <dd className="hero__settings-on">[ACTIVE]</dd>
              </div>
              <div>
                <dt>Days:</dt>
                <dd>
                  <Link to="/schedule">[01]</Link>
                  <Link to="/schedule">[02]</Link>
                  <Link to="/schedule">[03]</Link>
                </dd>
              </div>
              <div>
                <dt>Access:</dt>
                <dd>[OPEN TO ALL]</dd>
              </div>
            </dl>
          </section>
        </div>
      </section>

      <div className="festival-strip" aria-hidden="true">
        <div>
          <span>Tech <b>//</b></span>
          <span>Culture <b>//</b></span>
          <span>Workshops <b>//</b></span>
          <span>20-22 Nov <b>//</b></span>
          <span>Same campus. New angle. <b>//</b></span>
          <span>Three days <b>//</b></span>
          <span>Open to all <b>//</b></span>
          <span>Tech <b>//</b></span>
          <span>Culture <b>//</b></span>
          <span>Workshops <b>//</b></span>
          <span>20-22 Nov <b>//</b></span>
          <span>Same campus. New angle. <b>//</b></span>
          <span>Three days <b>//</b></span>
          <span>Open to all <b>//</b></span>
        </div>
      </div>

      <div className="container">
        <Countdown />
      </div>

      <section className="first-look container" id="first-look" aria-labelledby="first-look-title">
        <div className="section-heading">
          <div>
            <p className="eyebrow">&gt;&gt; 01 / Featured</p>
            <h2 id="first-look-title">Pick your angle.</h2>
          </div>
          <div className="section-heading__aside">
            <p>
              Build something, play something, make something. Or just watch
              from the back row.
            </p>
            <Link to="/events" className="text-link">&gt;&gt; Explore events</Link>
          </div>
        </div>
        <p className="programme-note">
          <span className="status-dot"></span> Sample programme. The final line-up is on its way.
        </p>
        <div className="event-grid">
          {featuredEvents.map((event, i) => {
            const tone = categoryTones[event.category];
            let link = '/events';
            if (event.category === 'Workshop') {
              link = '/workshops';
            }
            return (
              <Link key={event.id} to={link} className={'event-card event-card--' + tone}>
                <div className="panel__bar" aria-hidden="true">
                  <span>&gt;EVT_0{i + 1}</span>
                  <span>{event.category}</span>
                </div>
                <div className="event-card__art" aria-hidden="true">
                  <CardArt category={event.category} />
                  <span className="event-card__art-caption">SIGNAL: STRONG</span>
                </div>
                <div className="event-card__body">
                  <div className="event-card__meta">
                    <span className={'badge badge--' + tone}>{event.category}</span>
                    <span className="badge badge--neutral">Day 0{event.day}</span>
                  </div>
                  <h3>{event.title}</h3>
                  <p>{event.description}</p>
                  <span className="event-card__more">&gt;&gt; Open file</span>
                </div>
              </Link>
            );
          })}
        </div>
      </section>

      <section className="campus-callout container" aria-labelledby="campus-title">
        <div className="campus-callout__art panel" aria-hidden="true">
          <div className="panel__bar">
            <span>&gt;MAP</span>
            <span>[GPS LOCK]</span>
          </div>
          <div className="campus-callout__map">
            <span className="map-block map-block--one">STAGE</span>
            <span className="map-block map-block--two">LAB</span>
            <span className="map-block map-block--three">OAT</span>
            <span className="map-pin">
              <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 10c0 4.993-5.539 10.193-7.399 11.799a1 1 0 0 1-1.202 0C9.539 20.193 4 14.993 4 10a8 8 0 0 1 16 0"></path><circle cx="12" cy="10" r="3"></circle></svg>
            </span>
            <span className="map-label">YOU ARE HERE</span>
            <span className="map-north">N ^</span>
          </div>
        </div>
        <div className="campus-callout__copy">
          <p className="eyebrow">&gt;&gt; 02 / Campus guide</p>
          <h2 id="campus-title">Find your way around.</h2>
          <p>
            From the main stage to that workshop room on the far side of campus.
            Look up your next stop before you head out.
          </p>
          <Link to="/campus-guide" className="button button--outline">Open the campus guide</Link>
        </div>
      </section>

      <section className="closing-note container panel" aria-labelledby="help-title">
        <div className="panel__bar">
          <span>&gt;HELP</span>
          <span>[ONLINE]</span>
        </div>
        <div className="closing-note__body">
          <div>
            <p className="eyebrow">Got a question? Lost a friend?</p>
            <h2 id="help-title">The help desk is listening.</h2>
          </div>
          <Link to="/help" className="button button--ink">Ping the help desk</Link>
        </div>
      </section>
    </>
  );
}

export default Home;
