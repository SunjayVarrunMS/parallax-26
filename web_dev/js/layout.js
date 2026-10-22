// builds the header and footer that every page shares

// every page on the site, in menu order
const pages = [
  { file: 'index.html', label: 'Home' },
  { file: 'events.html', label: 'Events' },
  { file: 'schedule.html', label: 'Schedule' },
  { file: 'register.html', label: 'Register' },
  { file: 'my-bookings.html', label: 'My bookings' },
  { file: 'workshops.html', label: 'Workshops' },
  { file: 'merch.html', label: 'Merch' },
  { file: 'campus-guide.html', label: 'Campus guide' },
  { file: 'sponsors.html', label: 'Sponsors' },
  { file: 'help.html', label: 'Help desk' },
  { file: 'cart.html', label: 'Cart' },
];

// the few pages shown in the desktop header
const primaryPages = ['events.html', 'schedule.html', 'workshops.html', 'merch.html'];

const menuIcon = `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><line x1="4" x2="20" y1="12" y2="12"></line><line x1="4" x2="20" y1="6" y2="6"></line><line x1="4" x2="20" y1="18" y2="18"></line></svg>`;

const closeIcon = `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"></path><path d="m6 6 12 12"></path></svg>`;

const bagIcon = `<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M16 10a4 4 0 0 1-8 0"></path><path d="M3.103 6.034h17.794"></path><path d="M3.4 5.467a2 2 0 0 0-.4 1.2V20a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6.667a2 2 0 0 0-.4-1.2l-2-2.667A2 2 0 0 0 17 2H7a2 2 0 0 0-1.6.8z"></path></svg>`;

// work out which page we are on, for example "events.html"
function getCurrentFile() {
  const path = window.location.pathname;
  let file = path.substring(path.lastIndexOf('/') + 1);
  if (file === '') {
    file = 'index.html';
  }
  // on the live site the address has no ".html" at the end
  if (!file.endsWith('.html')) {
    file = file + '.html';
  }
  return file;
}

function brandHtml(extraClass) {
  return `
    <a href="index.html" class="brand${extraClass}" aria-label="${festival.edition} home">
      <span class="brand__mark" aria-hidden="true">${festival.shortName}</span>
      <span>${festival.name}<span class="brand__year"> '26</span></span>
    </a>
  `;
}

// one menu link, marked as active when it is the current page
function navLinkHtml(page) {
  if (page.file === getCurrentFile()) {
    return `<a href="${page.file}" class="active" aria-current="page">${page.label}</a>`;
  }
  return `<a href="${page.file}">${page.label}</a>`;
}

function renderHeader() {
  let desktopLinks = '';
  let mobileLinks = '';
  for (const page of pages) {
    if (primaryPages.includes(page.file)) {
      desktopLinks += navLinkHtml(page);
    }
    mobileLinks += navLinkHtml(page);
  }

  const header = document.querySelector('#site-header');
  header.className = 'site-header';
  header.innerHTML = `
    <div class="container site-header__inner">
      ${brandHtml('')}
      <nav class="desktop-nav" aria-label="Main navigation">${desktopLinks}</nav>
      <div class="site-header__actions">
        <a href="cart.html" class="cart-link" aria-label="Cart">${bagIcon}</a>
        <a href="register.html" class="button button--ink">Register</a>
        <button type="button" class="menu-toggle" id="menu-toggle" aria-label="Open navigation" aria-expanded="false" aria-controls="mobile-navigation">${menuIcon}</button>
      </div>
    </div>
    <nav id="mobile-navigation" class="mobile-nav container" aria-label="Mobile navigation" hidden>
      <div class="panel__bar" aria-hidden="true">
        <span>&gt;MENU</span>
        <span>[ESC] CLOSE</span>
      </div>
      ${mobileLinks}
    </nav>
  `;
}

function renderFooter() {
  let links = '';
  for (const page of pages) {
    if (page.file !== 'index.html') {
      links += `<a href="${page.file}">${page.label}</a>`;
    }
  }

  const footer = document.querySelector('#site-footer');
  footer.className = 'site-footer';
  footer.innerHTML = `
    <div class="container">
      <div class="site-footer__top">
        <div>
          ${brandHtml(' brand--inverse')}
          <p>
            Three days of tech, culture and workshops.
            <br>
            Built by students, for students.
          </p>
        </div>
        <nav aria-label="Footer navigation">${links}</nav>
      </div>
      <div class="site-footer__bottom">
        <span>${festival.tagline}</span>
        <span>${festival.dateLabel}</span>
        <span>End of transmission</span>
        <button type="button" class="site-footer__reset" id="reset-demo">Reset demo data</button>
      </div>
    </div>
  `;
}

function openMenu() {
  const button = document.querySelector('#menu-toggle');
  document.querySelector('#mobile-navigation').hidden = false;
  button.setAttribute('aria-expanded', 'true');
  button.setAttribute('aria-label', 'Close navigation');
  button.innerHTML = closeIcon;
}

function closeMenu() {
  const button = document.querySelector('#menu-toggle');
  document.querySelector('#mobile-navigation').hidden = true;
  button.setAttribute('aria-expanded', 'false');
  button.setAttribute('aria-label', 'Open navigation');
  button.innerHTML = menuIcon;
}

function toggleMenu() {
  const menu = document.querySelector('#mobile-navigation');
  if (menu.hidden) {
    openMenu();
  } else {
    closeMenu();
  }
}

// pressing Escape closes the open menu
function handleKeydown(event) {
  const menu = document.querySelector('#mobile-navigation');
  if (event.key === 'Escape' && !menu.hidden) {
    closeMenu();
    document.querySelector('#menu-toggle').focus();
  }
}

function handleReset() {
  resetDemoData();
  window.location.reload();
}

renderHeader();
renderFooter();
document.querySelector('#menu-toggle').addEventListener('click', toggleMenu);
document.querySelector('#reset-demo').addEventListener('click', handleReset);
window.addEventListener('keydown', handleKeydown);
