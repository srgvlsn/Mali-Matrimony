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

### Version 0.7.0 - 2026-02-08 16:03
**Contributor**: Sreerag Valsan
> - **Cleanup & Stabilization**: Pruned debug logs and reorganized backend scripts.
> - **Git Hygiene**: Removed tracked `__pycache__` and updated ignore rules.
**Contributor**: Sreerag Valsan
> - **UI Standardization**: Unified corner radius to 28.0/30.0 across all mobile and admin components.
> - **Settings & Privacy**: Implemented dedicated settings screens and backend support.
> - **Chat Enhancements**: Added "Archived" and "Blocked" conversation categories.
> - **Backend Refinement**: Resolved Python import issues and synchronized models/schemas.

See [CHANGELOG.md](CHANGELOG.md) for the full project history and version details.

---
