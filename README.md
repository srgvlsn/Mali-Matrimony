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

### Version 0.2.0 - 2026-02-01 09:37
**Contributor**: Sreerag Valsan
> - **Unified Admin UI**: Synchronized Admin Panel with Mobile App design (Cream & Maroon theme, 24px radius).
> - **Admin Auth**: Implemented professional Login Screen for Admin Portal.
> - **Analytics Dashboard**: Added User Growth charts and polished stats grid.
> - **Stability**: Resolved platform-wide lint errors, restored missing imports, and fixed deprecation warnings (activeThumbColor).
> - **Git Optimization**: Enabled `core.longpaths` and added root `.gitignore`.

### Version 0.1.6 - 2026-01-31 23:30
**Contributor**: Sreerag Valsan
> - **Admin Panel Complete**: Implemented Dashboard, Verification Flow, and User Management.
> - **Monorepo Transition**: Split project into `mobile_app` and `admin_panel` sub-projects.

### Version 0.1.3 - 2026-01-29 00:15
**Contributor**: Sreerag Valsan
> - **UI Polish**: Centralized styling with `AppStyles` and Global Theme integration.
> - **UX Fixes**: Toggled edge-to-edge navigation for a modern look; Resolved bottom nav bar inconsistencies.
> - **New Feature**: Enabled direct messaging from Profile View upon mutual interest.

### Version 0.1.0 - 2026-01-28 23:55
**Contributor**: Sreerag Valsan
> - **Interaction Hub**: Implemented "More Options" menu and relocated profile settings.
> - **Horoscope Integration**: Added legacy/horoscope data to user profiles.

### Version 0.0.5 & Below (Initial Prototype)
**Contributor**: Sreerag Valsan
> - **Rich Profiles**: Enhanced UI for Profile Detail screen with community-specific fields.
> - **Onboarding**: Implemented 5-step draft resumption registration.
> - **Mock Services**: Established base data layer for profiles and interest management.
> - **Base**: Version Control Initialized.
