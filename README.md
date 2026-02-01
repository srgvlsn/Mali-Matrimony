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

### Version 0.5.0 - 2026-02-02 02:08
**Contributor**: Sreerag Valsan
> - Transitioned to **Indirect Architecture** using a Python (FastAPI) backend.
> - Fully integrated with **PostgreSQL** database.
> - Implemented real data persistence for Profiles, Interests, and Shortlists.
> - Resolved Admin TODOs for profile deletion and interest management.

See [CHANGELOG.md](CHANGELOG.md) for full history.
