# أثر — Athar

A cultural tourism mobile application built with Flutter, connecting users to Saudi Arabia's heritage sites, cultural archive, guided trips, and local events.

## Overview

Athar (أثر) is a comprehensive platform for exploring and booking cultural experiences. Users can discover tourist attractions, browse a curated cultural archive, book guided trips, and find nearby events — all in one app.

## Features

- **Attractions** — Discover heritage, nature, arts, and modern landmarks with rich detail pages, maps, and gallery views
- **Cultural Archive** — Browse curated cultural content organized by category
- **Trips** — Explore and book guided trips with detailed itineraries
- **Events** — Find and attend local cultural events
- **Interactive Map** — Explore all locations on a live map with category-colored pins
- **Booking System** — End-to-end booking flow for trips and events
- **Admin Panel** — Full content management for admins (attractions, trips, events, users, bookings)
- **AI Auto-Tagging** — New attractions are automatically tagged via a Gemini-powered Cloud Function

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod (code generation) |
| Backend | Firebase (Firestore, Storage, Cloud Functions) |
| Maps | Google Maps Flutter |
| AI | Google Gemini 1.5 Flash (Cloud Functions) |
| Fonts | IBM Plex Sans Arabic · Playfair Display |

## Project Structure

```
lib/
├── core/
│   ├── models/          # Data models (attractions, trips, events, bookings…)
│   └── ...
├── features/
│   ├── attractions/     # Attractions list, detail, map pins
│   ├── rawi/            # AI chat assistant
│   ├── trips/           # Trip browsing and booking
│   ├── events/          # Events and attendance
│   ├── admin/           # Admin panel (8-tab management)
│   └── ...
functions/
└── src/index.ts         # Cloud Functions (auto-tagging, notifications…)
```

## Design System

- **Primary color:** Sage 800 `#344235`
- **Secondary color:** Sand 500 `#CC9A53`
- **Arabic text:** IBM Plex Sans Arabic
- **English text:** Playfair Display
- **Cards:** 24px border radius, subtle shadow

## License

Copyright (c) 2026 Rimas Alharthi. All Rights Reserved.

This project is proprietary software. Unauthorized copying, modification, distribution, or use of this software is strictly prohibited. See [LICENSE](LICENSE) for full terms.
