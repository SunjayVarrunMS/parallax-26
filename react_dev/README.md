# PARALLAX '26 website (React)

The website for PARALLAX '26, a three-day college festival of tech, culture and workshops (20-22 November). It lists the events, the schedule and the venues, lets people register for events and workshops, and has a small merch shop.

It is the same site as the plain HTML version, rebuilt with React, Vite and react-router-dom.

## How to run it

You need Node.js installed. In a terminal inside this folder:

```
npm install
npm run dev
```

Then open the address it prints (usually http://localhost:5173).

Other commands:

- `npm run build` makes the finished site in the `dist` folder.
- `npm run lint` checks the code for mistakes.

## What is where

| File or folder | What it does |
|---|---|
| `index.html` | The one HTML page. React fills in the rest. |
| `public/favicon.svg` | The little icon in the browser tab |
| `vercel.json` | Settings for hosting on Vercel (every address opens `index.html`) |
| `src/main.jsx` | Starts React, turns on the router and loads the CSS |
| `src/App.jsx` | The list of pages and their addresses (`/events`, `/cart`, ...) |
| `src/data.js` | All the content: events, workshops, venues, merch, sponsors and festival dates |
| `src/utils.js` | Small helpers for formatting times, dates and prices |
| `src/store.js` | Saves and reads data in the browser's localStorage |
| `src/api/registrations.js`, `workshops.js`, `shop.js`, `help.js` | The pretend server: registrations, workshop bookings, the shop and the help desk |
| `src/components/Layout.jsx` | The header, the footer and the page in the middle |
| `src/components/Header.jsx` | Top bar, menu links and the mobile menu |
| `src/components/Footer.jsx` | Footer links and the Reset demo data button |
| `src/components/ThemeToggle.jsx` | The light / dark mode button |
| `src/components/Countdown.jsx` | The countdown box on the home page |
| `src/components/Brand.jsx` | The PARALLAX logo link |
| `src/components/pages.js` | The list of menu links |
| `src/pages/*.jsx` | One file for each page |
| `src/css/style.css` | Colours, fonts and styles shared by every page (header, footer, buttons, forms) |
| `src/css/<page>.css` | Styles for one page only |
| `src/css/light.css` | Colours for light mode |

## About the "API"

There is no real server. The files in `src/api/` have async functions that wait a moment (so it feels like a network request) and then save to your browser's localStorage. Your data stays in your own browser only.

To start fresh, click **Reset demo data** at the bottom of any page. It clears everything the site saved and reloads.
