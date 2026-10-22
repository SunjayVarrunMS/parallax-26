# PARALLAX '26 app

The app for PARALLAX '26, a three-day college festival of tech, culture and workshops (20-22 November). It lists the events, the schedule and the venues, lets people register for events and workshops, and has a small merch shop.

It is a Flutter app that runs in the browser and on Android.

## How to run it

You need Flutter installed. Then, in a terminal inside this folder:

1. Run `flutter pub get` to download the packages.
2. Run `flutter run -d chrome` to open the app in Chrome.

To run it on an Android phone or emulator, connect it (or start the emulator) and run `flutter run`.

To make a web build, run `flutter build web`. The files end up in `build/web`.

## What is where

| File or folder | What it does |
|---|---|
| `lib/main.dart` | Starts the app and switches between the light and dark theme |
| `lib/router.dart` | The address of every screen (`/`, `/events`, `/register` and so on) and the not found screen |
| `lib/data.dart` | All the content: events, workshops, venues, merch, sponsors and festival dates |
| `lib/utils.dart` | Small helpers for waiting, formatting times, dates and prices, and opening links |
| `lib/store.dart` | Saves and reads data on the device with shared_preferences |
| `lib/theme.dart` | Colours and fonts for dark and light mode, and the saved theme choice |
| `lib/api/registrations_api.dart`, `workshops_api.dart`, `shop_api.dart`, `help_api.dart` | The pretend server: registrations, workshop bookings, the shop and the help desk |
| `lib/screens/home_screen.dart` | Home screen |
| `lib/screens/events_screen.dart` | All events, with search and filters |
| `lib/screens/register_screen.dart` | Registration form and fee summary |
| `lib/screens/schedule_screen.dart` | Timetable, one tab per day |
| `lib/screens/campus_guide_screen.dart` | Venues and what is happening at each |
| `lib/screens/sponsors_screen.dart` | Sponsor cards |
| `lib/screens/workshops_screen.dart` | Workshops with seats left, booking and the waitlist |
| `lib/screens/merch_screen.dart` | The merch shop |
| `lib/screens/cart_screen.dart` | Cart and checkout |
| `lib/screens/my_bookings_screen.dart` | Your event registrations, workshop bookings and orders |
| `lib/screens/help_screen.dart` | FAQs and the contact form |
| `lib/screens/not_found_screen.dart` | Shown when a page does not exist |
| `lib/widgets/page_shell.dart` | The frame around every screen: header, menu drawer, content and footer |
| `lib/widgets/site_header.dart`, `site_footer.dart` | The header with the nav links and the footer with the reset button |
| `lib/widgets/theme_toggle.dart` | The light / dark mode button in the header |
| `lib/widgets/countdown.dart` | The countdown box on the home screen |
| `lib/widgets/panels.dart`, `badges.dart`, `buttons.dart`, `page_heading.dart`, `form_parts.dart` | Small shared pieces: panels, badges, buttons, page titles and form fields |
| `web/` | The web page that holds the app, its title, icon and manifest |
| `android/` | The Android project (the app name and permissions are in `app/src/main/AndroidManifest.xml`) |

## About the "API"

There is no real server. The `lib/api/*_api.dart` files have async functions that wait a moment (so it feels like a network request) and then save to the device with shared_preferences (localStorage in the browser). Your data stays on your own device only.

To start fresh, tap **Reset demo data** at the bottom of any screen. It clears everything the app saved and loads the screen again.
