# LumiPass Web App - Project Guide

LumiPass is an educational class discovery and booking platform for parents in Uzbekistan. Parents can explore classes for their children, book sessions, manage child profiles, and track attendance — all in Uzbek, Russian, or English.

---

## Tech Stack

| Layer              | Technology                                      |
| ------------------ | ----------------------------------------------- |
| Framework          | Next.js 16 (App Router)                         |
| UI                 | React 19, Tailwind CSS 3, Framer Motion, Rizzui |
| State              | Jotai, React Context                            |
| Forms              | React Hook Form + Zod                           |
| i18n               | next-intl (uz, ru, en)                          |
| Auth               | Phone + OTP, JWT tokens                         |
| Maps               | Google Maps API                                 |
| Analytics          | Yandex Metrika                                  |
| Language           | TypeScript 5                                    |

---

## Features

### 1. Authentication (Phone + OTP)

- **Sign In**: User enters phone number → system checks if the number exists → sends OTP → user verifies OTP → logged in.
- **Sign Up**: If phone is new → redirected to registration form (name, gender, city, district) → OTP verification → account created.
- **Session**: JWT token stored in localStorage with auto-expiry checks every 60 seconds. Phone number cached in cookies for 1 hour.
- **Auth Guard**: All routes except `/auth/*`, `/access-denied`, and `/` are protected. Unauthenticated users are redirected to sign-in.

### 2. Home Feed

- **Banners**: Promotional image carousel (Swiper) at the top of the home page.
- **Categories**: Horizontally scrollable category chips (e.g., Sports, Music, Art). Tapping a category navigates to filtered class listings.
- **New Classes**: Recently added classes displayed in card format with pricing, location, and trial info.
- **Nearby Classes**: Classes sorted by proximity using the device's geolocation. Location is cached and refreshed periodically.
- **Upcoming Schedule**: Shows the user's next booked class with countdown and details.

### 3. Explore & Search

- **Class Search**: Search classes by keyword with real-time results.
- **Advanced Filters**: Filter by category, price range (rc-slider), age group, distance, and availability. Filters are managed via a drawer panel.
- **Map View**: Google Maps integration showing branch locations as pins. Tapping a pin scrolls to the corresponding branch card.
- **Branch Details**: View branch/center info including photos, address, available classes, and contact details.

### 4. Class Booking

- **Class Details Page**: Shows class description, pricing (regular + trial pricing), schedule, age range, and branch info.
- **Availability Check**: Checks open time slots before booking.
- **Booking Flow**: Select time slot → confirm → booking created via API.
- **Trial Classes**: Some classes offer trial pricing with an unlock system for first-time users.
- **Booking Cancellation**: Users can cancel upcoming bookings.
- **Booking Success Page**: Confirmation screen after a successful booking.

### 5. Schedules & Attendance

- **My Schedules**: List of all booked classes organized by date. Each schedule card shows class name, time, location, and status.
- **Schedule Details**: Detailed view of a specific booking with options to cancel.
- **Attendance History**: Per-child attendance records showing check-in history across all classes.
- **Attendance Details**: Drill-down view for a specific child's attendance at a specific class.

### 6. Wallet & Payments

- **Coin Balance**: Users have a coin-based wallet used to pay for classes.
- **Packages (Tariffs)**: Purchase coin bundles through available tariff packages displayed as cards.
- **Transaction History**: View past coin usage and purchase records.

### 7. Profile Management

- **User Profile**: View and edit name, phone, gender, and location.
- **Children Management**: Add, edit, and remove child profiles. Each child has name, birth date, gender, and photo.
- **Child Photo Upload**: Camera integration (react-webcam) to capture and upload child photos directly from the device.
- **Logout**: Clears token, user data, and redirects to sign-in.

### 8. Internationalization (i18n)

- **3 Languages**: Uzbek (default), Russian, English.
- **Locale in URL**: Every route is prefixed with locale (`/uz/`, `/ru/`, `/en/`).
- **Language Switcher**: Accessible via drawer in the header. Switching locale re-renders all content in the selected language.
- **Translation Files**: Located in `/messages/` (en.json, uz.json, ru.json) covering all UI strings.

### 9. Theming

- **Light/Dark Mode**: Supported via `next-themes` with CSS class and `data-theme` attribute.
- **Custom Design System**: Custom color palette (purple, blue, green, red, yellow, pink) with consistent spacing and typography.
- **Custom Fonts**: Quicksand, Nunito, Balsamiq Sans.

### 10. Mobile Optimization

- **Bottom Navigation Bar**: Fixed bottom nav with 5 tabs — Home, Explore, Schedules, Wallet, Profile. Hidden on auth pages.
- **Safe Area Support**: Handles notches and bottom bars on modern mobile browsers.
- **No Zoom**: Viewport configured to prevent user scaling for app-like feel.
- **Pull-to-refresh & Infinite Scroll**: Implemented for long lists.

### 11. Telegram Integration

- **Telegram Bot Link**: Users can generate a code to link their LumiPass account with a Telegram bot for notifications.

### 12. Error & Edge Case Pages

- **Access Denied (403)**: Shown when a user lacks permission.
- **Check Network**: Displayed when the device is offline or API is unreachable.
- **Coming Soon**: Placeholder for features under development.

---

## Project Structure

```
src/
├── app/
│   └── [locale]/                  # All routes are locale-prefixed
│       ├── layout.tsx             # Root layout (providers, fonts, analytics)
│       ├── page.tsx               # Home page
│       ├── auth/                  # Sign-in, sign-up, OTP pages
│       ├── explore/               # Search, map, branch details
│       ├── home/classes/          # Class details & booking
│       ├── schedules/             # Booked classes & details
│       ├── wallet/                # Coins, packages, transactions
│       ├── profile/               # Account, children, attendance, FAQs
│       └── (other-pages)/         # Error pages (403, network, coming-soon)
│   └── shared/                    # Shared page-level components
│       ├── home/                  # Banner, categories, nearby/new classes
│       ├── explore/               # Map view, filters, category list
│       ├── profile/               # Account, children, attendance
│       ├── schedules/             # Schedule cards & details
│       ├── wallet/                # Balance, packages, history
│       └── drawer-views/          # Drawer content (language, filters, etc.)
├── components/ui/                 # Reusable UI components
│   ├── class-card.tsx
│   ├── branch-card.tsx
│   ├── schedule-card.tsx
│   ├── package-card.tsx
│   ├── skeletons.tsx
│   ├── custom-modal.tsx
│   ├── cameraview.tsx
│   └── ...
├── config/
│   └── routes.ts                  # All route path constants
├── contexts/
│   ├── auth-context.tsx           # Auth state & methods
│   └── navbar-context.tsx         # Bottom nav visibility
├── hooks/                         # Custom React hooks
├── i18n/
│   └── routing.ts                 # Locale config (uz, ru, en)
├── services/
│   ├── api.ts                     # All API calls (~1000 lines)
│   ├── location-service.ts        # Geolocation service
│   └── yandex-metrics-client.tsx   # Analytics
├── utils/                         # Helpers (auth guard, date formatting, routes)
├── validators/                    # Zod schemas (login, signup, filters, children)
├── env.mjs                        # Environment variable validation
└── styles/                        # Global CSS
messages/
├── en.json                        # English translations
├── uz.json                        # Uzbek translations
└── ru.json                        # Russian translations
```

---

## How to Run

### Prerequisites

- **Node.js** >= 20.9.0
- **npm** >= 10
- A Google Maps API key (for map features)

### 1. Clone the repository

```bash
git clone <repository-url>
cd lumipass-webapp
```

### 2. Install dependencies

```bash
npm install
```

### 3. Set up environment variables

Create a `.env.local` file in the project root:

```env
NODE_ENV=development
NEXT_PUBLIC_SITE_URL=http://localhost:3000
NEXT_PUBLIC_API_URL=https://dev-api.lumipass.uz
NEXT_PUBLIC_API_PREFIX=/api/v1
NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=your_google_maps_api_key
NEXT_PUBLIC_YM_ID=                # Optional: Yandex Metrika ID (production only)
SKIP_ENV_VALIDATION=false
```

### 4. Run in development mode

```bash
# Standard dev server
npm run dev

# With Turbopack (faster HMR)
npm run dev:turbo

# Clean cache first, then start
npm run dev:fresh
```

The app will be available at **http://localhost:3000**. It will automatically redirect to the default locale (`/uz/`).

### 5. Build for production

```bash
npm run build
npm run start
```

### 6. Lint the code

```bash
npm run lint
```

### All Available Scripts

| Command             | Description                              |
| -------------------- | ---------------------------------------- |
| `npm run dev`        | Start Next.js dev server                 |
| `npm run dev:turbo`  | Start dev server with Turbopack          |
| `npm run dev:fresh`  | Clear `.next` cache, then start dev      |
| `npm run app`        | Alias for `npm run dev`                  |
| `npm run build`      | Create production build                  |
| `npm run start`      | Start production server                  |
| `npm run lint`       | Run Oxlint linter                        |
| `npm run clean`      | Delete `.next` build cache               |
