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
> - **Deep Review**: Implemented User Detail Dialog for comprehensive profile management.
> - **Settings Screen**: Added platform and profile configuration settings.
> - **Stability**: Successfully identified and resolved critical import issues, deprecation warnings, and lint errors across the Admin project.
