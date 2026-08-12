# GitHub Roadmap — 20 Gün · 20 Issue · 4 Milestone

**Repository:** [Faruk-T/B2B_saas_project](https://github.com/Faruk-T/B2B_saas_project)  
**Setup:** [`github-setup.md`](github-setup.md)  
**Playbooks:** [`playbooks/`](playbooks/)

> **1 bölüm = 1 gün = 1 issue.** Toplam **20 issue**, **4 milestone**.

---

## Labels

| Label | Color | Purpose |
|-------|-------|---------|
| `phase-1` | `#0E8A16` | Foundation & Tenancy (D1–D5) |
| `phase-2` | `#1D76DB` | Core Domain & Catalog (D6–D10) |
| `phase-3` | `#5319E7` | Async & Integrations (D11–D15) |
| `phase-4` | `#FBCA04` | Flutter Client (D16–D20) |
| `backend` | `#C5DEF5` | Laravel / PHP |
| `frontend` | `#BFD4F2` | Flutter / Dart |
| `infra` | `#D4C5F9` | Docker, CI |
| `docs` | `#0075CA` | Documentation |
| `test` | `#006B75` | Tests |
| `day-task` | `#F9D0C4` | Daily section task |

---

## Milestones

| Milestone | Days | Due (örnek) |
|-----------|------|-------------|
| M1 — Phase 1 Foundation & Tenancy | D1–D5 | +5 iş günü |
| M2 — Phase 2 Core Domain & Catalog | D6–D10 | +10 iş günü |
| M3 — Phase 3 Async & Integrations | D11–D15 | +15 iş günü |
| M4 — Phase 4 Flutter Client | D16–D20 | +20 iş günü |

---

## 20 Issue listesi

### Phase 1 — M1 (D1–D5)

| Gün | Issue title | Branch | Labels |
|-----|-------------|--------|--------|
| **D1** | `docs: create 20-day roadmap and professional README` | `phase-1/section-1-planning-and-readme` | phase-1, docs |
| D2 | `infra: add Docker Compose with MariaDB 11, Redis, PHP, Nginx` | `phase-1/section-2-docker-dev-environment` | phase-1, infra |
| D3 | `feat(tenancy): implement multi-database architecture with tenant resolver` | `phase-1/section-3-multi-database-tenancy` | phase-1, backend |
| D4 | `feat(tenancy): add ProvisionTenantAction with auto database setup` | `phase-1/section-4-tenant-provisioning` | phase-1, backend |
| D5 | `feat(root-admin): add Sanctum auth, tenant CRUD, and CI quality gates` | `phase-1/section-5-quality-gates-and-root-api` | phase-1, backend, test |

---

### Phase 2 — M2 (D6–D10)

| Gün | Issue title | Branch | Labels |
|-----|-------------|--------|--------|
| D6 | `feat(schema): add tenant database tables for catalog, stock, and orders` | `phase-2/section-1-core-schema` | phase-2, backend |
| D7 | `feat(domain): implement core catalog and pricing actions` | `phase-2/section-2-domain-layer` | phase-2, backend |
| D8 | `feat(sector): add multi-sector order and pricing strategies` | `phase-2/section-3-sector-engines` | phase-2, backend |
| D9 | `feat(catalog): implement faceted product search with dynamic filters` | `phase-2/section-4-faceted-search` | phase-2, backend |
| D10 | `feat(pricing): add RBAC, turnover tiers, and discount engine` | `phase-2/section-5-auth-roles-pricing` | phase-2, backend, test |

---

### Phase 3 — M3 (D11–D15)

| Gün | Issue title | Branch | Labels |
|-----|-------------|--------|--------|
| D11 | `feat(queue): configure Redis queues, Horizon, and Supervisor workers` | `phase-3/section-1-redis-horizon` | phase-3, backend, infra |
| D12 | `feat(scraper): add product enrichment pipeline with Puppeteer` | `phase-3/section-2-product-enrichment` | phase-3, backend |
| D13 | `feat(import): add preview-first XLS import and async export` | `phase-3/section-3-bulk-excel` | phase-3, backend |
| D14 | `feat(notifications): implement FCM push for tier upgrade and job completion` | `phase-3/section-4-fcm-notifications` | phase-3, backend |
| D15 | `docs(api): publish Scribe Scalar docs with OpenAPI export` | `phase-3/section-5-api-documentation` | phase-3, docs, backend |

---

### Phase 4 — M4 (D16–D20)

| Gün | Issue title | Branch | Labels |
|-----|-------------|--------|--------|
| D16 | `feat(flutter): initialize Flutter app with auth and responsive layout` | `phase-4/section-1-flutter-core` | phase-4, frontend |
| D17 | `feat(ui): build root admin, wholesaler, customer, and supplier portals` | `phase-4/section-2-portals` | phase-4, frontend |
| D18 | `feat(ui): build product catalog with dynamic filter drawer` | `phase-4/section-3-catalog-ui` | phase-4, frontend |
| D19 | `feat(qr): add mobile QR scanner for stock inbound, picking, and transfer` | `phase-4/section-4-qr-stock` | phase-4, frontend |
| D20 | `feat(ui): add Excel import/export UI and release v1.0.0 MVP` | `phase-4/section-5-excel-ui-and-release` | phase-4, frontend, docs |

---

## D1 Issue body (kopyala-yapıştır)

```markdown
## Day D1 — Planning & README only

**No API, no database, no Docker code today.**

## Tasks
- [ ] Finalize 20-day roadmap (4 phases × 5 sections)
- [ ] Professional Turkish README with architecture diagrams
- [ ] Update all playbooks to 20-day structure
- [ ] database-schema.md and api-contract.md as reference docs
- [ ] GitHub templates (.github/)

## Acceptance
- [ ] README renders with images on GitHub
- [ ] 20-day calendar visible in README
- [ ] Zero application code committed

## Branch
phase-1/section-1-planning-and-readme
```

---

## Günlük ritim

```
Sabah  → Issue'yu "In Progress" yap
Gün    → Bölümdeki TÜM görevleri bitir (1 gün = 1 bölüm)
Akşam  → Branch push → PR aç → Closes #N
Merge  → main'e sadece PR ile
```

---

## İlk push

```powershell
cd "c:\Users\user\Desktop\Trunçgil Commerce OS\b2b-main"
git init
git add .
git commit -m "docs: add 20-day roadmap and professional README with diagrams"
git branch -M main
git remote add origin https://github.com/Faruk-T/B2B_saas_project.git
git push -u origin main
```

Then open **Issue #1** (D1) and branch `phase-1/section-1-planning-and-readme` for any final doc tweaks before merging D1 PR.
