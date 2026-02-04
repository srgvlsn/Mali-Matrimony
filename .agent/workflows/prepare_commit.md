---
description: Prepare for commit by updating Changelog and Project Report
---

1. **Get Release Details**
   - Ask the user for the **Next Version Number** (e.g., 0.1.4) and a **Summary of Changes**.

2. **Update CHANGELOG.md**
   - Open `CHANGELOG.md`.
   - Add a new entry for the **Next Version Number**.
   - Ensure the content follows the standard structure (Added, Changed, Fixed, Removed).

3. **Synchronize Versions**
   - Update `version: [Version Number]+1` in:
     - `mobile_app/pubspec.yaml`
     - `admin_panel/pubspec.yaml`
   - Update `version: [Version Number]` (without build number) in:
     - `packages/shared/pubspec.yaml`
   - Update `version="[Version Number]"` in:
     - `backend/main.py` (FastAPI instance)

4. **Update README.md**
   - Open `README.md`.
   - Insert a new entry under `## 📝 Change Log` in the following format:
     ```markdown
     ### Version [Version Number] - [Current Date YYYY-MM-DD HH:mm]
     **Contributor**: Sreerag Valsan
     > - [Change 1]
     > - [Change 2]
     ```

5. **Update PROJECT_REPORT.md**
   - Open `PROJECT_REPORT.md`.
   - Update the `**Date**` field to today.
   - Update `## 🛠️ Feature Completion Status` if items have moved from one category to another.
   - Update `## 🏁 Conclusion` percentage if applicable.

6. **Git Operations**
   - Run `git add .`
   - Run `git commit -m "feat: release version [Version Number]"` (or appropriate conventional commit message).
   - Run `git push` (if user wants to push).
