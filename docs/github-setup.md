# GitHub Setup — [Faruk-T/B2B_saas_project](https://github.com/Faruk-T/B2B_saas_project)

This guide connects your local project to the GitHub repository and sets up milestones, labels, and branch protection.

**Repository:** https://github.com/Faruk-T/B2B_saas_project  
**Status:** Empty (ready for first push)

---

## Step 1 — First push (do this once)

Run from the project root (`b2b-main/`):

```powershell
cd "c:\Users\user\Desktop\Trunçgil Commerce OS\b2b-main"

git init
git add .
git commit -m "docs: add project README, implementation plan, and GitHub roadmap"
git branch -M main
git remote add origin https://github.com/Faruk-T/B2B_saas_project.git
git push -u origin main
```

> **Rule:** After this, never push directly to `main`. Always use feature branches + Pull Requests.

---

## Step 2 — Branch protection

GitHub → **Settings** → **Branches** → **Add rule** for `main`:

| Setting | Value |
|---------|-------|
| Require pull request before merging | ✅ |
| Require status checks (when CI exists) | `pest`, `phpstan` |
| Do not allow bypassing | ✅ (recommended) |
| Restrict direct pushes | ✅ |

---

## Step 3 — Create labels

GitHub → **Issues** → **Labels** → create:

| Label | Hex color |
|-------|-----------|
| `phase-1` | `#0E8A16` |
| `phase-2` | `#1D76DB` |
| `phase-3` | `#5319E7` |
| `phase-4` | `#FBCA04` |
| `backend` | `#C5DEF5` |
| `frontend` | `#BFD4F2` |
| `infra` | `#D4C5F9` |
| `docs` | `#0075CA` |
| `test` | `#006B75` |
| `blocked` | `#B60205` |
| `day-task` | `#F9D0C4` |

---

## Step 4 — Create milestones

GitHub → **Issues** → **Milestones**:

| Title | Duration |
|-------|----------|
| Phase 1 — Foundation & Tenancy | 5 days (D1–D5) |
| Phase 2 — Core Domain & Catalog | 5 days (D6–D10) |
| Phase 3 — Async & Integrations | 5 days (D11–D15) |
| Phase 4 — Flutter Client | 5 days (D16–D20) |

> **1 section = 1 day.** Total project: **20 working days**.

---

## Step 5 — Create GitHub Projects board (optional but recommended)

1. **Projects** → **New project** → **Board**
2. Columns: `Backlog` | `Today` | `In Progress` | `In Review` | `Done`
3. Link to repository `B2B_saas_project`
4. Add views filtered by milestone (M1, M2, M3, M4)

---

## Step 6 — Open Phase 1 issues

Start with **D1 issue only** (planning + README). Full list in [`github-roadmap.md`](github-roadmap.md).

Using GitHub CLI (after `gh auth login`):

```powershell
gh label create "phase-1" --color "0E8A16"
gh label create "infra" --color "D4C5F9"

gh api repos/Faruk-T/B2B_saas_project/milestones -f title="Phase 1 — Foundation & Tenancy" -f due_on="2026-09-15T07:00:00Z"

gh issue create --repo Faruk-T/B2B_saas_project `
  --title "infra: scaffold monorepo directory structure" `
  --label "phase-1,infra,day-task" `
  --milestone "Phase 1 — Foundation & Tenancy" `
  --body-file docs/issue-bodies/1.1.1-scaffold-monorepo.md
```

---

## Step 7 — Start Day 1

```powershell
git checkout main
git pull origin main
git checkout -b phase-1/section-1-docker-dev-environment
```

Follow [`playbooks/phase-1-detailed.md`](playbooks/phase-1-detailed.md) → **Bölüm 1.1 / D1** (planning + README only).

---

## Daily rhythm

```
Morning   → Pick issue, move to "In Progress" on board
Work      → Commit often (English, Conventional Commits)
Evening   → Push branch, open PR, link issue (Closes #N)
Merge     → Only after CI green; never direct to main
```

---

## Repository links

| Resource | URL |
|----------|-----|
| Code | https://github.com/Faruk-T/B2B_saas_project |
| Issues | https://github.com/Faruk-T/B2B_saas_project/issues |
| Pull Requests | https://github.com/Faruk-T/B2B_saas_project/pulls |
| Actions (CI) | https://github.com/Faruk-T/B2B_saas_project/actions |
