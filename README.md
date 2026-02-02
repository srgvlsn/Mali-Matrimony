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

### Version 0.5.1 - 2026-02-02 15:42
**Contributor**: Sreerag Valsan
> - **Security Hardening**: Implemented Bcrypt password hashing and strict login verification.
> - **Schema Synchronization**: Realigned PostgreSQL schema with Mobile UI registration steps (Added `dob`, Removed `religion`).
> - **Privacy Fix**: Filtered current user from matches and search results.
> - **Maintenance**: Formatted entire codebase (Dart/Flutter) and cleared test data for fresh launch.

### Version 0.5.0 - 2026-02-02 02:08

See [CHANGELOG.md](CHANGELOG.md) for full history.
