// saves data in the browser (localStorage) so it is still there after a reload.
// every key starts with 'parallax:' so we can find and clear our own data.

const storePrefix = 'parallax:';

export function readStore(key, fallback) {
  try {
    const raw = localStorage.getItem(key);
    if (raw === null) {
      return fallback;
    }
    return JSON.parse(raw);
  } catch {
    return fallback;
  }
}

export function writeStore(key, value) {
  localStorage.setItem(key, JSON.stringify(value));
}

// makeId('reg') -> "reg_k3j9x2"
export function makeId(prefix) {
  const random = Math.random().toString(36).slice(2, 8);
  return prefix + '_' + random;
}

// remove everything this site has saved
export function resetDemoData() {
  const keys = [];
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (key && key.startsWith(storePrefix)) {
      keys.push(key);
    }
  }
  for (const key of keys) {
    localStorage.removeItem(key);
  }
}
