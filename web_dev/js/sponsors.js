// the sponsors page: one card per partner from data.js

const arrowIcon = `<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M7 7h10v10"></path><path d="M7 17 17 7"></path></svg>`;

function renderSponsors() {
  let html = '';
  for (let i = 0; i < sponsors.length; i++) {
    const sponsor = sponsors[i];
    html += `
      <li class="sponsors-page__card">
        <p class="sponsors-page__bar" aria-hidden="true">
          <span>&gt;PARTNER_0${i + 1}</span>
          <span>[LINKED]</span>
        </p>
        <span class="sponsors-page__mark" aria-hidden="true">${sponsor.mark}</span>
        <h2>${sponsor.name}</h2>
        <p>${sponsor.blurb}</p>
        <a class="text-link" href="https://example.com" target="_blank" rel="noreferrer" aria-label="Visit ${sponsor.name} (opens in a new tab)">
          &gt;&gt; Visit website
          ${arrowIcon}
        </a>
      </li>
    `;
  }
  document.querySelector('#sponsor-grid').innerHTML = html;
}

renderSponsors();
