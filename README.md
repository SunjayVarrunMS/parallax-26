# PARALLAX '26 website

The website for PARALLAX '26, a three-day college festival of tech, culture and workshops (20-22 November). It lists the events, the schedule and the venues, lets people register for events and workshops, and has a small merch shop.

It is plain HTML, CSS and JavaScript. There is nothing to install and nothing to build.

## How to run it

Pick one:

- Double-click `index.html` to open it in your browser.
- Better: open this folder in VS Code, install the **Live Server** extension, right-click `index.html` and choose "Open with Live Server". The page reloads every time you save.
- Or, in a terminal inside this folder, run `python -m http.server` and open http://localhost:8000.

## What is where

| File or folder | What it does |
|---|---|
| `index.html` | Home page |
| `events.html` | All events, with search and filters |
| `register.html` | Registration form and fee summary |
| `schedule.html` | Timetable, one tab per day |
| `campus-guide.html` | Venues and what is happening at each |
| `sponsors.html` | Sponsor cards |
| `workshops.html` | Workshops with seats left, booking and the waitlist |
| `merch.html` | The merch shop |
| `cart.html` | Cart and checkout |
| `my-bookings.html` | Your event registrations, workshop bookings and orders |
| `help.html` | FAQs and the contact form |
| `404.html` | Shown when a page does not exist |
| `css/style.css` | Colours, fonts and styles shared by every page (header, footer, buttons, forms) |
| `css/<page>.css` | Styles for one page only |
| `css/light.css` | Colours for light mode |
| `js/data.js` | All the content: events, workshops, venues, merch, sponsors and festival dates |
| `js/utils.js` | Small helpers for formatting times, dates and prices |
| `js/store.js` | Saves and reads data in the browser's localStorage |
| `js/layout.js` | Adds the header and footer to every page and runs the mobile menu |
| `js/registrations-api.js`, `js/workshops-api.js`, `js/shop-api.js`, `js/help-api.js` | The pretend server: registrations, workshop bookings, the shop and the help desk |
| `js/theme.js` | The light / dark mode button in the header |
| `js/<page>.js` | The code for one page |
| `favicon.svg` | The little icon in the browser tab |
| `vercel.json` | Settings for hosting the site on Vercel |

Every page loads its scripts in the same order at the bottom of the HTML: `data.js`, `utils.js`, `store.js`, `layout.js`, then any API file, then the page's own script. Later files can use anything the earlier ones made.

## About the "API"

There is no real server. The `js/*-api.js` files have async functions that wait a moment (so it feels like a network request) and then save to your browser's localStorage. Your data stays in your own browser only.

To start fresh, click **Reset demo data** at the bottom of any page. It clears everything the site saved and reloads.
