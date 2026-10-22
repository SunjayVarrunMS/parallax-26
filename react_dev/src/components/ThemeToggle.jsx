import { useState, useEffect } from 'react';
import { readStore, writeStore } from '../store.js';

const themeKey = 'parallax:theme';

// the light / dark button in the header. the choice is saved.
function ThemeToggle() {
  const [theme, setTheme] = useState(readStore(themeKey, 'dark'));

  // put the theme on the <html> tag so the css can use it
  useEffect(() => {
    if (theme === 'light') {
      document.documentElement.setAttribute('data-theme', 'light');
    } else {
      document.documentElement.removeAttribute('data-theme');
    }
  }, [theme]);

  function handleClick() {
    let next = 'light';
    if (theme === 'light') {
      next = 'dark';
    }
    writeStore(themeKey, next);
    setTheme(next);
  }

  let text = '[LIGHT]';
  let label = 'Switch to light mode';
  if (theme === 'light') {
    text = '[DARK]';
    label = 'Switch to dark mode';
  }

  return (
    <button type="button" id="theme-toggle" className="theme-toggle" aria-label={label} onClick={handleClick}>
      {text}
    </button>
  );
}

export default ThemeToggle;
