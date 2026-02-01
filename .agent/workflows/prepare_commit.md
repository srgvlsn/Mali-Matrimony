---
description: Prepare for commit by updating Changelog and Project Report
---

1. **Get Release Details**
   - Ask the user for the **Next Version Number** (e.g., 0.1.4) and a **Summary of Changes**.

2. **Update README.md**
   - Open `README.md`.
   - Insert a new entry under `## 📝 Change Log` in the following format:
     ```markdown
     ### Version [Version Number] - [Current Date YYYY-MM-DD HH:mm]
     **Contributor**: Sreerag Valsan
     > - [Change 1]
     > - [Change 2]
     ```

3. **Update PROJECT_REPORT.md**
   - Open `PROJECT_REPORT.md`.
   - Update the `**Date**` field to today.
   - Update `## 🛠️ Feature Completion Status` if items have moved from one category to another.
   - Update `## 🏁 Conclusion` percentage if applicable.

4. **Git Operations**
   - Run `git add .`
   - Run `git commit -m "feat: release version [Version Number]"` (or appropriate conventional commit message).
   - Run `git push` (if user wants to push).
