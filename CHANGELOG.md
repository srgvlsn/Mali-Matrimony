# Changelog

All notable changes to this project will be documented in this file.

## [0.3.0] - 2026-02-01
### Added
- **Shared Package**: Created `packages/shared` to centralize models, styles, and mock data.
- **Centralized Mock Data**: Moved all user profile mock data to `shared` package to ensure consistency between Mobile and Admin projects.
- **Profile Widgets**: Extracted reusable widgets (`StatChip`, `SectionTitle`, `ContentCard`, `DetailListCard`) for Profile Detail screens.

### Fixed
- **Duplicate Imports**: Resolved various redundant `package:shared/shared.dart` imports identified by static analysis.
- **Profile Detail Syntax**: Corrected syntax errors introduced during widget extraction in `ProfileDetailScreen`.

## [0.2.1] - 2026-02-01
### Changed
- **Dashboard Refactoring**: Extracted `UserCard`, `CustomSearchBar`, and `QuickActionCard` from `mobile_app` dashboard for reuse.
- **Theme Consolidation**: Integrated centralized `AppStyles.getThemeData()` into `mobile_app` and `admin_panel`.

## [0.2.0] - 2026-02-01
- **Unified Admin UI**: Synchronized Admin Panel with Mobile App design (Cream & Maroon theme, 24px radius).
- **Admin Auth**: Implemented professional Login Screen for Admin Portal.
- **Analytics Dashboard**: Added User Growth charts and polished stats grid.
- **Stability**: Resolved platform-wide lint errors, restored missing imports, and fixed deprecation warnings.

## [0.1.6] - 2026-01-31
- **Admin Panel Complete**: Implemented Dashboard, Verification Flow, and User Management.
- **Monorepo Transition**: Split project into `mobile_app` and `admin_panel` sub-projects.

## [0.1.3] - 2026-01-29
- **UI Polish**: Centralized styling with `AppStyles` and Global Theme integration.
- **UX Fixes**: Toggled edge-to-edge navigation for a modern look.
- **New Feature**: Enabled direct messaging from Profile View upon mutual interest.

## [0.1.0] - 2026-01-28
- **Interaction Hub**: Implemented "More Options" menu.
- **Horoscope Integration**: Added legacy/horoscope data to user profiles.

## [0.0.5] & Below
- **Rich Profiles**: Enhanced UI for Profile Detail screen.
- **Onboarding**: Implemented 5-step draft resumption registration.
- **Mock Services**: Established base data layer.
- **Base**: Version Control Initialized.
