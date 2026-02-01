# Changelog

All notable changes to this project will be documented in this file.

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
