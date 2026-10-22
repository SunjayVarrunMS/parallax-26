// light and dark mode. the choice is saved so it stays after a reload.

const themeKey = 'parallax:theme';

function getTheme() {
  return readStore(themeKey, 'dark');
}

function applyTheme(theme) {
  const button = document.querySelector('#theme-toggle');
  if (theme === 'light') {
    document.documentElement.setAttribute('data-theme', 'light');
    button.textContent = '[DARK]';
    button.setAttribute('aria-label', 'Switch to dark mode');
  } else {
    document.documentElement.removeAttribute('data-theme');
    button.textContent = '[LIGHT]';
    button.setAttribute('aria-label', 'Switch to light mode');
  }
}

function handleThemeClick() {
  let next = 'light';
  if (getTheme() === 'light') {
    next = 'dark';
  }
  writeStore(themeKey, next);
  applyTheme(next);
}

function addThemeButton() {
  const actions = document.querySelector('.site-header__actions');
  const button = document.createElement('button');
  button.type = 'button';
  button.id = 'theme-toggle';
  button.className = 'theme-toggle';
  actions.insertBefore(button, actions.firstChild);
  button.addEventListener('click', handleThemeClick);
  applyTheme(getTheme());
}

addThemeButton();
