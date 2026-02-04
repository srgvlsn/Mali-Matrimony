# Lingayat Mali Matrimony (Monorepo)

This repository contains the source code for the **Lingayat Mali Matrimony** platform, designed for the Lingayat Mali community.

## Project Structure

- **`mobile_app/`**: The primary mobile application (Android/iOS) built with Flutter.
- **`admin_panel/`**: The web-based administration portal built with Flutter Web.

## Getting Started

### Mobile App
Navigate to the mobile app directory:
```bash
cd mobile_app
flutter pub get
flutter run
```

### Admin Panel
Navigate to the admin panel directory:
```bash
cd admin_panel
flutter pub get
flutter run -d chrome
```

## 📝 Change Log

### Version 0.6.8 - 2026-02-04 14:35
**Contributor**: Sreerag Valsan
> - **Premium Experience**: Specialized upgrade notifications, robust deep-linking to Settings, and highlight animations.
> - **Profile Sync**: Implemented live Membership Badges and improved Date-of-Birth/Field persistence.
> - **Code Health**: Consolidated notification logic into `NotificationBadge` and removed debug logging.
> - **Stability**: Fixed deep-link race conditions using `rootNavigator` and synchronization delays.

### Version 0.6.6 - 2026-02-03 22:02
**Contributor**: Sreerag Valsan
> - **Real-Time Badges**: Implemented WebSocket-driven unread indicators for Interests and Chats.
> - **Home Hub**: Unified navigation by merging Matches into Home with Discover/Suggestions/Shortlisted tabs.
> - **Analytics**: Launched "Profile Reach" dashboard on Home screen for user insights.
> - **Stability**: Resolved Android emulator connectivity issues and switched to LAN IP fallback.
> - **OTP Bug Fix**: Corrected navigation logic in OTP login to prevent "Empty Profile" issue.
> - **UX Refinement**: Fixed duplicate Header/AppBar glitch on Interests Hub.
> - **Data Cleanup**: Removed 100% of hardcoded mock data from services.

### Version 0.6.5 - 2026-02-02 18:28
**Contributor**: Sreerag Valsan
> - **Login Fix**: Added 10-second timeout and debug logging to prevent infinite loading.
> - **Backend Fix**: Fixed `async` syntax error in `update_profile` endpoint.
> - **Database Migration**: Added `view_count` column and fixed `shortlists` table schema.
> - **WebSocket Stability**: Added graceful error handling with max retry limits.
> - **Test Data**: Created 6 dummy profiles (3M/3F) with real photos for testing.
> - **Developer Experience**: Added `start_backend.bat` for easier server startup.

### Version 0.6.0 - 2026-02-02 15:45
**Contributor**: Sreerag Valsan
> - **Security Hardening**: Implemented secure password hashing (`bcrypt`) and strict login verification.
> - **Privacy**: Moved login credentials to secure JSON POST bodies.
> - **Consistency**: Synchronized database schema with UI Steps (Added `dob`, Removed `religion`).
> - **Refinement**: Implemented self-filtering in matches/search results.
> - **Code Quality**: Performed project-wide Flutter/Dart formatting.

### Version 0.5.0 - 2026-02-02 02:08
**Contributor**: Sreerag Valsan
> - Transitioned to **Indirect Architecture** using a Python (FastAPI) backend.
> - Fully integrated with **PostgreSQL** database.
> - Implemented real data persistence for Profiles, Interests, and Shortlists.
> - Resolved Admin TODOs for profile deletion and interest management.

See [CHANGELOG.md](CHANGELOG.md) for full history.
