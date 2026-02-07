# Changelog

All notable changes to this project will be documented in this file.

## [0.6.9] - 2026-02-07
### Added
- **Settings & Privacy**: Implemented dedicated Settings and Privacy screens in the mobile app with backend support for user preferences.
- **Chat Enhancements**: Introduced "Archived" and "Blocked" conversation categories with dedicated management screens.
- **Admin Theme Service**: Implemented `AdminThemeService` in the admin panel for centralized UI state management.

### Changed
- **UI Standardization**: Unified corner radius to 28.0/30.0 across all mobile and admin components for a premium look.
- **Backend Model Sync**: Refined SQLAlchemy models and Pydantic schemas to ensure 100% alignment with the registration flow.
- **Admin Panel Refinement**: Updated sidebar and dashboard layouts to improve navigation and information hierarchy.

### Fixed
- **Python Imports**: Resolved persistent "Could not find import" errors for core libraries in the backend.
- **Admin Service Mappings**: Fixed service name discrepancies in the admin panel to ensure seamless backend integration.

## [0.6.8] - 2026-02-04
### Added
- **Premium Experience Refinement**: Implemented a specialized "Premium Membership Active" notification with type-specific logic.
- **Deep-Link System**: Added robust navigation logic from notifications to the Settings screen using top-level Navigator and synchronization delays.
- **Visual Feedback**: Implemented a one-time scaling highlight animation for the Payment Info card in Settings to acknowledge upgrades.
- **Profile Membership Badge**: Introduced live "Free" and "Premium" badges on the My Profile screen with real-time status updates.

### Changed
- **Profile Synchronization**: Replaced Age with detailed Date of Birth in profile views and ensured persistent field synchronization (Work Mode, Horoscope, etc.).
- **Consolidated Notifications**: Centralized all notification display and navigation logic into the `NotificationBadge` widget, eliminating stale duplicates on the Dashboard.
- **Enhanced Data Handling**: Standardized notification types (e.g., `profileVerified`) across backend, shared models, and mobile app for consistent behavior.

### Fixed
- **Navigation Reliability**: Resolved intermittent deep-link failures by using `rootNavigator: true` and 100ms sync delays.
- **Technical Cleanup**: Removed exhaustive debug logging and fixed various syntax errors in the notification and profile modules.

## [0.6.7] - 2026-02-03
### Added
- **Real-Time Chat**: Full backend integration for messaging using PostgreSQL storage.
- **WebSocket Messaging**: Instant message delivery and receipt via existing WebSocket infrastructure.
- **Optimistic Chat UI**: Immediate message bubbles on send for better UX.
- **Conversation Management**: Persistent conversation list with unread counts and last message previews.
- **Auto-Sync**: Background fetching of conversations and messages on app startup and navigation.

## [0.6.6] - 2026-02-03
### Added
- **Real-Time Notifications**: Implemented WebSockets for instant Interest, Chat, and Profile View alerts.
- **Unified Home Hub**: Merged Discover, Suggestions, and Shortlisted into a single Home navigation tab with state-managed tabs.
- **Profile Reach Dashboard**: Added real-time analytics for users to track profile views, interests, and shortlists on the Home screen.
- **Unread Badges**: Implemented live badge counts on Navigation Bar for Interests and Chats.

### Fixed
- **Connectivity**: Resolved Android emulator connection timeouts by implementing LAN IP fallback and updating AndroidManifest.
- **OTP Login**: Fixed navigation race condition that caused an empty profile page after OTP verification.
- **UI Scaling**: Fixed duplicate AppBar/Header issues on the Interests Hub screen.
- **Data Integrity**: Enforced strict non-null data handling in UserProfileScreen to prevent rendering crashes.

### Removed
- **Legacy Service Mocks**: Completely removed the last remaining hardcoded data from the mobile application services.

## [0.6.0] - 2026-02-02
### Added
- **Security Hardening**: Implemented secure password hashing using **bcrypt** for standard user accounts.
- **DOB Support**: Synchronized "Date of Birth" across all layers (DB, API, Shared Model, and Mobile Registration).
- **Self-Filtering**: Implemented profile exclusion to prevent users from seeing themselves in match listings.

### Changed
- **Secure Auth**: Transitioned login credentials from URL query parameters to secure JSON POST request bodies.
- **Schema Alignment**: Re-synchronized backend model and PostgreSQL schema with the mobile application's 5-step registration flow.
- **Code Quality**: Applied project-wide `dart format` to ensure consistent code styling.

### Removed
- **Redundant Schema**: Deleted the `religion` column from the database and backend as it was identified as out-of-scope for the current registration flow.

## [0.5.0] - 2026-02-02
### Added
- **Python Backend**: Implemented a standalone API backend using **FastAPI** and **SQLAlchemy**.
- **PostgreSQL Integration**: Connected the application to a real local database (`mali_matrimony_database_dev_stage`).
- **RESTful Architecture**: Transitioned Flutter apps from direct DB access to an indirect API-based architecture for improved security and scalability.
- **Service Refactor**: Introduced `ApiService` for endpoint management and `BackendService` for REST communication.

### Removed
- **Mock Data Legacy**: Permanently deleted `dummy_data.dart`, `MockBackend`, and ALL hardcoded user profiles.
- **Direct DB Sockets**: Removed direct `postgres` socket usage from the Flutter apps in favor of HTTP REST.

### Fixed
- **State Reliability**: Resolved async synchronization issues in the data layer by implementing cached profile states.
- **Data Consistency**: Standardized all model serialization to use `snake_case` matching the PostgreSQL schema.

## [0.3.0] - 2026-02-01
### Added
- **Shared Package**: Created `packages/shared` to centralize models, styles, and mock data.
- **Centralized Mock Data**: Moved all user profile mock data to `shared` package to ensure consistency between Mobile and Admin projects.
- **Profile Widgets**: Extracted reusable widgets (`StatChip`, `SectionTitle`, `ContentCard`, `DetailListCard`) for Profile Detail screens.

### Fixed
- **Duplicate Imports**: Resolved various redundant `package:shared/shared.dart` imports identified by static analysis.
- **Profile Detail Syntax**: Corrected syntax errors introduced during widget extraction in `ProfileDetailScreen`.

## [0.2.1] - 2026-02-01
- **Dashboard Refactoring**: Extracted `UserCard`, `CustomSearchBar`, and `QuickActionCard` from `mobile_app` dashboard for reuse.
- **Theme Consolidation**: Integrated centralized `AppStyles.getThemeData()` into `mobile_app` and `admin_panel`.

## [0.2.0] - 2026-02-01
- **Unified Admin UI**: Synchronized Admin Panel with Mobile App design (Cream & Maroon theme, 24px radius).
- **Admin Auth**: Implemented professional Login Screen for Admin Portal.
- **Analytics Dashboard**: Added User Growth charts and polished stats grid.

## [0.1.6] - 2026-01-31
- **Admin Panel Complete**: Implemented Dashboard, Verification Flow, and User Management.
- **Monorepo Transition**: Split project into `mobile_app` and `admin_panel` sub-projects.

## [0.1.5] - 2026-01-29
- Comprehensive UI/UX refinements.

## [0.1.4] - 2026-01-29
- Navigation and gesture optimizations.

## [0.1.3] - 2026-01-29
- **UI Polish**: Centralized styling with `AppStyles` and Global Theme integration.
- **UX Fixes**: Toggled edge-to-edge navigation for a modern look.
- **New Feature**: Enabled direct messaging from Profile View upon mutual interest.

## [0.1.2] - 2026-01-29
- Backend service layer refinements.

## [0.1.1] - 2026-01-29
- Provider state management implementation for core features.

## [0.1.0] - 2026-01-28
- **Interaction Hub**: Implemented "More Options" menu.
- **Horoscope Integration**: Added legacy/horoscope data to user profiles.

## [0.0.5] - 2026-01-28
- **Rich Profiles**: Enhanced UI for Profile Detail screen.

## [0.0.4] - 2026-01-28
- Detail screen layout improvements.

## [0.0.3] - 2026-01-27
- Search and Match logic implementation.

## [0.0.2] - 2026-01-27
- **Onboarding**: Implemented 5-step draft resumption registration.

## [Initial Base] - 2026-01-27
- **Base**: Version Control Initialized.
- Documentation updates and repository configuration.
