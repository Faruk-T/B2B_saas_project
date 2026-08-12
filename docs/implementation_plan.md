# Trunçgil Commerce OS — Technical Specification & Development Roadmap

> **Universal multi-database SaaS B2B wholesale & dealer management platform**  
> Laravel 11 (DDD + Hexagonal) · Flutter 3 (Clean Architecture + BLoC) · MariaDB 11 · Redis · Horizon · FCM · Scribe/Scalar · Puppeteer

This document is the **single source of truth** for architecture decisions and the **day-by-day delivery plan**.

**GitHub repository:** [Faruk-T/B2B_saas_project](https://github.com/Faruk-T/B2B_saas_project)

| Related doc | Purpose |
|-------------|---------|
| [`github-roadmap.md`](github-roadmap.md) | 100 issue titles, labels, milestones |
| [`github-setup.md`](github-setup.md) | First push + branch protection |
| [`database-schema.md`](database-schema.md) | Full table definitions |
| [`api-contract.md`](api-contract.md) | All endpoints + JSON examples |
| [`playbooks/README.md`](playbooks/README.md) | **Ultra-detailed daily tasks (D1–D100)** |

---

## Table of contents

1. [What we are building (plain language)](#1-what-we-are-building-plain-language)
2. [Architecture pillars](#2-architecture-pillars)
3. [Multi-database tenancy](#3-multi-database-tenancy)
4. [Multi-sector business engine](#4-multi-sector-business-engine)
5. [Catalog, JSON attributes & faceted search](#5-catalog-json-attributes--faceted-search)
6. [Product enrichment (web scraping)](#6-product-enrichment-web-scraping)
7. [QR stock operations](#7-qr-stock-operations)
8. [Bulk Excel import/export](#8-bulk-excel-importexport)
9. [Roles, panels & turnover discounts](#9-roles-panels--turnover-discounts)
10. [Queues, Supervisor & Horizon](#10-queues-supervisor--horizon)
11. [API documentation (Scribe + Scalar)](#11-api-documentation-scribe--scalar)
12. [Authentication & Flutter client](#12-authentication--flutter-client)
13. [Quality gates (SOLID, PHPStan, lints)](#13-quality-gates-solid-phpstan-lints)
14. [Monorepo & Docker layout](#14-monorepo--docker-layout)
15. [GitHub delivery model](#15-github-delivery-model)
16. [Phase 1 — Foundation & Tenancy (Sections 1.1–1.5)](#16-phase-1--foundation--tenancy)
17. [Phase 2 — Core Domain & Catalog (Sections 2.1–2.5)](#17-phase-2--core-domain--catalog)
18. [Phase 3 — Async & Integrations (Sections 3.1–3.5)](#18-phase-3--async--integrations)
19. [Phase 4 — Flutter Client (Sections 4.1–4.5)](#19-phase-4--flutter-client)
20. [Definition of done (per section)](#20-definition-of-done-per-section)

---

## 1. What we are building (plain language)

**Trunçgil Commerce OS** is a **SaaS platform for B2B wholesalers** (toptancılar) and their **dealers** (bayiler).

### Real-world example

A textile wholesaler signs up:
1. Root Admin creates tenant `tekstil-a` → system creates database `b2b_tenant_tekstil_a_db`.
2. Wholesaler admin uploads products (or imports Excel), configures color/size filters.
3. Dealers log in on mobile → browse catalog → order by color/size matrix.
4. Warehouse scans QR on boxes → stock updates in real time.
5. Dealer hits ₺500,000 turnover → system auto-upgrades discount tier → push notification: *"You unlocked Gold tier (+3% discount)!"*

Same platform works for **automotive parts** (OEM lookup), **FMCG** (lot/expiry), **building materials** (m² pricing), etc.

### System actors

```
┌─────────────────┐     manages      ┌──────────────────┐
│   Root Admin    │ ───────────────► │  Many Tenants    │
│ (platform ops)  │                  │  (wholesalers)   │
└─────────────────┘                  └────────┬─────────┘
                                              │
                    ┌─────────────────────────┼─────────────────────────┐
                    ▼                         ▼                         ▼
             ┌────────────┐           ┌────────────┐           ┌────────────┐
             │  Wholesaler│           │   Dealer   │           │  Supplier  │
             │   Admin    │           │  (Customer)│           │            │
             └────────────┘           └────────────┘           └────────────┘
                    │                         │
                    └──────────► Warehouse (QR scans) ◄──────────┘
```

---

## 2. Architecture pillars

| # | Pillar | Summary |
|---|--------|---------|
| 1 | **Multi-DB tenancy** | One MariaDB database per wholesaler; full data isolation |
| 2 | **Multi-sector engine** | Pluggable strategies per industry (matrix orders, fitment, lots, dimensions) |
| 3 | **Dynamic faceted search** | Admin-configured filters with live facet counts |
| 4 | **Product enrichment** | Headless browser scrapes images/specs by barcode/SKU/OEM |
| 5 | **QR stock module** | Mobile bulk scanning for inbound, picking, transfers |
| 6 | **Preview-first Excel** | Validate before write; async Redis import/export |
| 7 | **Turnover discount engine** | Auto tier upgrade on delivered revenue thresholds |
| 8 | **Quality gates** | Pest architecture tests, PHPStan L9, Flutter lints, pre-commit hooks |

---

## 3. Multi-database tenancy

### A. Databases

| Database | Purpose | Key tables |
|----------|---------|------------|
| `b2b_system_db` | Platform-wide | `tenants`, `tenant_domains`, `root_users`, `subscriptions`, `system_audit_logs` |
| `b2b_tenant_{alias}_db` | Per wholesaler | `users`, `products`, `categories`, `stocks`, `orders`, `quotes`, `fcm_tokens`, … |

### B. Provisioning pipeline (`ProvisionTenantAction`)

```
Root Admin submits new tenant
        │
        ▼
① Insert row in system.tenants (alias: firma-a)
        │
        ▼
② CREATE DATABASE b2b_tenant_firma_a
        │
        ▼
③ Run tenant migrations (database/migrations/tenant/)
        │
        ▼
④ Seed TenantBaseSeeder (roles, UoM, notification defaults)
        │
        ▼
⑤ Bind domain: b2b.truncgil.com/firma-a OR firma-a.b2b.truncgil.com
        │
        ▼
⑥ Create first wholesaler admin user
```

### C. Request routing (`TenantResolverMiddleware`)

1. Parse URL path alias or `Host` header subdomain.  
2. Load tenant from system DB.  
3. `DB::purge('tenant')` → set `database.connections.tenant.database`.  
4. Continue request against tenant DB transparently.

---

## 4. Multi-sector business engine

| Sector | Business need | Platform adapter |
|--------|---------------|------------------|
| Textile & apparel | Color–size grid, assortment packages | **Matrix Order Engine** + **Asorti Module** |
| Automotive parts | OEM, cross-ref, vehicle compatibility | **Fitment Engine** + **OEM Indexer** (Meilisearch) |
| FMCG / food / pharma | Lot/batch, expiry, box/pallet rules | **Batch/Lot Driver** + **Multi-UoM Calculator** |
| Building & metals | En×Boy×Yükseklik pricing | **CalculatesByDimensionContract** |
| Electronics / industrial | Serial tracking, spec matrix, accessories | **Dynamic Attribute Validator** + **Cross-sell Engine** |

Each tenant selects a **sector profile** at provisioning (or later). Sector profile activates relevant order validators and UI field sets.

---

## 5. Catalog, JSON attributes & faceted search

### Category tree

- Table: `categories` — `parent_id`, `name`, `slug`, `path`, `depth`, `icon_url`
- Unlimited nesting; `path` enables fast breadcrumb queries

### Product technical specs (`attributes_json`)

```json
{
  "general": { "brand": "Bosch", "origin": "Germany", "warranty_months": 24 },
  "technical_specs": {
    "power_watt": 1500,
    "voltage": "220V",
    "dimensions": { "length_mm": 350, "width_mm": 200, "weight_kg": 4.5 }
  },
  "sub_type_properties": {
    "fluid_compatibility": ["Su", "Yağ", "Glikol"],
    "certifications": ["CE", "ISO9001"]
  }
}
```

### Virtual generated columns

MariaDB `JSON_EXTRACT()` + indexed virtual columns on hot fields (`power_watt`, `brand`) for fast filtering without full document scan.

### Faceted search (`FilterCatalogProductsAction`)

Admin configures per category (`filterable_attributes`):
- **Multi-select tags** — brands, certifications, compatible fluids
- **Numeric ranges** — watt, price, weight sliders
- **Boolean toggles** — in-stock only, fast shipping, OEM warranty
- **Text/OEM search** — part numbers, cross-references

Response includes **facet counts**: `Peugeot (142)`, `Citroen (89)`.

---

## 6. Product enrichment (web scraping)

**Trigger:** Product created/updated with missing image or sparse `attributes_json`.

**Flow:**
```
Product saved (incomplete)
        │
        ▼
EnrichProductDataJob → Redis queue: scraping
        │
        ▼
php artisan product:enrich {id}
        │
        ▼
Puppeteer/Playwright: search by EAN-13 / SKU / OEM
        │
        ▼
Download images → thumbnails → product_images
Update attributes_json gaps
        │
        ▼
FCM push to admin: "Product X enriched"
```

---

## 7. QR stock operations

Flutter `mobile_scanner` — **continuous scan mode** (camera stays open).

| Scenario | Flow |
|----------|------|
| **Inbound** | Scan QR → enter qty → assign warehouse location |
| **Outbound picking** | Scan items against pick list → mark line verified |
| **Transfer** | Scan → select target warehouse → instant move |
| **Cycle count** | Scan → adjust qty with audit log |

---

## 8. Bulk Excel import/export

### Import
```
Upload .xlsx
    → PreviewXlsImportAction (in-memory parse + validation)
    → UI shows: 480 valid / 12 invalid rows with line errors
    → User confirms
    → ProcessBulkImportJob (Redis: imports)
    → FCM: "Import complete"
```

### Export
```
User requests export (filters applied)
    → Job on Redis: exports
    → maatwebsite/excel generates file
    → Signed download URL + FCM notification
```

---

## 9. Roles, panels & turnover discounts

| Panel | Key features |
|-------|--------------|
| **Root Admin** | Tenant CRUD, provisioning, subscriptions, audit |
| **Wholesaler Admin** | Catalog, filters, tiers, suppliers, reports |
| **Customer / Dealer** | Catalog, orders, turnover progress bar, credit limit |
| **Supplier** | Consignment stock, Excel/API stock updates, alerts |
| **Plasiyer** | Create orders on behalf of assigned customers |

### Turnover engine (`UpgradeCustomerTierAction`)

On order status → **delivered**:
1. Sum delivered revenue for rolling period.  
2. Compare to next tier threshold.  
3. If exceeded → upgrade `customer_discount_tiers` assignment.  
4. Log to `customer_turnover_logs`.  
5. FCM push to dealer.

---

## 10. Queues, Supervisor & Horizon

| Queue | Purpose |
|-------|---------|
| `imports` | Bulk Excel import jobs |
| `exports` | Bulk Excel export jobs |
| `scraping` | Product enrichment |
| `reports` | Heavy report generation |
| `notifications` | FCM and email |
| `turnover` | Tier recalculation |
| `erp` | Future ERP sync hooks |

- **Supervisor** (`docker/supervisor/supervisord.conf`) manages worker processes.  
- **Horizon** at `http://localhost:8080/horizon` — monitor throughput, failures, retries.

---

## 11. API documentation (Scribe + Scalar)

- Package: `knuckleswtf/scribe` with `'theme' => 'scalar'`
- URL: `http://localhost:8080/docs`
- Auto-generates: OpenAPI 3.0 (`openapi.yaml`), Postman collection (`collection.json`)
- All Phase 1–3 endpoints annotated before Phase 4 UI work begins in earnest

---

## 12. Authentication & Flutter client

### Backend
- **Laravel Sanctum** — `Authorization: Bearer <token>`
- Separate guard contexts: `root` (system DB) vs `tenant` (tenant DB)

### Flutter client
- **Platforms:** iOS, Android, Web, macOS, Windows, Linux
- **Architecture:** Clean Architecture + BLoC per feature
- **HTTP:** Dio + `AuthInterceptor` + `flutter_secure_storage`
- **Responsive breakpoints:**
  - Mobile: `< 600px`
  - Tablet: `600–1024px`
  - Desktop/Web: `> 1024px`

---

## 13. Quality gates (SOLID, PHPStan, lints)

| Gate | Tool | Rule |
|------|------|------|
| Domain purity | Pest `SolidArchitectureTest` | `App\Domain` must not depend on Illuminate/Laravel/Http/Infrastructure |
| Static analysis | PHPStan Level 9 | Strict types, null safety |
| Flutter | `analysis_options.yaml` | `@immutable` on domain models, no `print` in prod |
| Pre-commit | Husky or native git hook | Run Pest + PHPStan (+ Flutter analyze when frontend touched) |

**Every PR must pass quality gates before merge to `main`.**

---

## 14. Monorepo & Docker layout

```
b2b/
├── docker/
│   ├── mariadb/                 # MariaDB 11 init scripts
│   ├── nginx/                   # Wildcard tenant alias routing
│   ├── php/                     # PHP 8.4-FPM + Node + Chromium
│   ├── supervisor/
│   │   └── supervisord.conf
│   └── docker-compose.yml       # mariadb, redis, php, nginx, supervisor, mailpit
├── apps/
│   ├── backend/
│   │   ├── app/
│   │   │   ├── Domain/
│   │   │   │   ├── Common/
│   │   │   │   ├── Tenancy/
│   │   │   │   ├── Catalog/
│   │   │   │   ├── Pricing/
│   │   │   │   ├── Dealers/
│   │   │   │   ├── Suppliers/
│   │   │   │   ├── Stock/
│   │   │   │   └── Notifications/
│   │   │   ├── Application/     # Actions, Jobs, Commands
│   │   │   ├── Infrastructure/  # Repositories, FCM, Scraper
│   │   │   └── Http/
│   │   ├── config/
│   │   │   ├── tenancy.php
│   │   │   ├── scribe.php
│   │   │   ├── sanctum.php
│   │   │   ├── horizon.php
│   │   │   └── queue.php
│   │   ├── database/migrations/
│   │   │   ├── system/
│   │   │   └── tenant/
│   │   ├── phpstan.neon
│   │   └── tests/
│   └── frontend/
│       └── lib/
│           ├── core/            # DI, Dio, responsive, theme
│           └── features/
│               ├── root_admin/
│               ├── customer_portal/
│               ├── supplier_portal/
│               ├── catalog/
│               ├── qr_stock/
│               └── bulk_excel/
└── docs/
    ├── implementation_plan.md
    ├── database-schema.md
    ├── api-contract.md
    ├── github-roadmap.md
    ├── github-setup.md
    └── playbooks/           ← daily D1–D100 detail
```

---

## 15. GitHub delivery model

### Structure: 4 Phases × 5 Sections × 1 Day = **20 Days**

| Phase | Milestone | Days | Focus |
|-------|-----------|------|-------|
| 1 | M1 — Foundation & Tenancy | D1–D5 | Plan, Docker, tenancy, provision, CI + root API |
| 2 | M2 — Core Domain & Catalog | D6–D10 | Schema, domain, sectors, search, pricing |
| 3 | M3 — Async & Integrations | D11–D15 | Queues, scraper, Excel, FCM, API docs |
| 4 | M4 — Flutter Client | D16–D20 | Flutter UI, QR, Excel UI, v1.0.0 |

> **D1 is docs-only** — no API, database, or Docker code. See [playbooks/phase-1-detailed.md](playbooks/phase-1-detailed.md).

### Rules

1. **Never push to `main` directly** — always via PR from `phase-N/section-M-*` branch.  
2. **Commits in English** — Conventional Commits format.  
3. **One issue per day minimum** — link commits and PRs to GitHub issues.  
4. **Section complete** = all 5 issues closed + PR merged + definition of done met.  
5. **Phase complete** = all 5 sections done + milestone closed.

### Branch & commit examples

```bash
# Branch
git checkout -b phase-1/section-2-multi-database-tenancy

# Commits
git commit -m "feat(tenancy): add TenantResolverMiddleware for dynamic DB switching"
git commit -m "test(tenancy): verify tenant A cannot read tenant B data"
git commit -m "docs(tenancy): document dual-connection config in README"
```

---

## 16. Phase 1 — Foundation & Tenancy

**Goal:** Runnable Docker stack, Laravel backend skeleton, working multi-DB tenancy with provisioning, quality gates, and root admin API.

**Milestone:** `M1 — Foundation & Tenancy`

---

### Section 1.1 — Docker & dev environment (Days 1–5)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D1** | Create monorepo folder structure (`docker/`, `apps/backend/`, `apps/frontend/`, `docs/`) | Empty scaffold committed | `chore: scaffold monorepo directory structure` |
| **D2** | Write `docker-compose.yml` with MariaDB 11 + Redis volumes and networks | `docker compose up` starts DB + Redis | `feat(docker): add docker-compose with MariaDB 11 and Redis` |
| **D3** | PHP 8.4-FPM Dockerfile: extensions (pdo_mysql, redis, gd), Composer, Node 20, Chromium | PHP container builds | `feat(docker): add PHP 8.4-FPM Dockerfile with Node and Chromium` |
| **D4** | Nginx config: proxy to PHP, wildcard `*.b2b.local` or path-based alias | API reachable at `:8080` | `feat(docker): configure Nginx reverse proxy for tenant routing` |
| **D5** | Supervisor container + Mailpit; document `make up` / README quickstart | Full stack runs locally | `feat(docker): add Supervisor worker and Mailpit services` |

**Section 1.1 exit criteria:** `docker compose up -d` → all containers healthy; README quickstart verified.

---

### Section 1.2 — Multi-database tenancy architecture (Days 6–10)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D6** | `composer create-project laravel/laravel` in `apps/backend`; wire to Docker | Laravel welcome via Nginx | `feat(backend): initialize Laravel 11 application` |
| **D7** | System migrations: `tenants`, `tenant_domains`, `subscriptions` | `php artisan migrate` on system connection | `feat(tenancy): add system database migrations` |
| **D8** | Configure `database.php`: `system` + `tenant` connections; env vars | Both connections testable | `feat(tenancy): configure dual database connections` |
| **D9** | `TenantResolverMiddleware`: resolve alias from path/host, swap connection | Request hits correct tenant DB | `feat(tenancy): implement TenantResolverMiddleware` |
| **D10** | Integration test: two tenants, prove data isolation | Pest test green | `test(tenancy): add tenant isolation integration tests` |

**Section 1.2 exit criteria:** HTTP request to `/firma-a/...` uses `b2b_tenant_firma_a_db`; tenant B data invisible to tenant A.

---

### Section 1.3 — Tenant provisioning pipeline (Days 11–15)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D11** | Domain: `Tenant`, `TenantAlias` value objects; `ProvisionTenantContract` | Pure domain classes, no Laravel imports | `feat(domain): add Tenancy value objects and contracts` |
| **D12** | `ProvisionTenantAction`: steps ①–② (system insert + CREATE DATABASE) | Can create empty tenant DB | `feat(tenancy): implement ProvisionTenantAction steps 1-2` |
| **D13** | Tenant migration runner: `artisan tenants:migrate {alias}` | All tenant tables created | `feat(tenancy): add tenant-specific migration runner` |
| **D14** | `TenantBaseSeeder`: default roles, UoM, settings | Fresh tenant has usable defaults | `feat(tenancy): implement TenantBaseSeeder` |
| **D15** | Wire full pipeline + idempotency guard (duplicate alias rejected) | End-to-end provision works | `feat(tenancy): complete provisioning pipeline with validation` |

**Section 1.3 exit criteria:** Single API call creates tenant, DB, migrations, seed, domain binding.

---

### Section 1.4 — Quality gates & architecture tests (Days 16–20)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D16** | Install Pest; add `tests/Architecture/SolidArchitectureTest.php` | Domain layer enforced | `test(architecture): add SolidArchitectureTest for Domain layer` |
| **D17** | PHPStan Level 9 config; baseline if needed | `composer analyse` passes | `chore(quality): configure PHPStan Level 9` |
| **D18** | Pre-commit hook script (Pest + PHPStan) | Bad commits blocked locally | `chore(quality): add pre-commit hook for tests and static analysis` |
| **D19** | GitHub Actions: PHP 8.4, composer install, Pest, PHPStan | CI green on PR | `ci: add GitHub Actions workflow for backend quality gates` |
| **D20** | Document all commands in README + `docs/contributing.md` snippet | Docs complete | `docs: document quality gate commands and CI workflow` |

**Section 1.4 exit criteria:** PR without tests or with Domain→Laravel dependency fails CI.

---

### Section 1.5 — API foundation & root admin skeleton (Days 21–25)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D21** | Install Sanctum; root guard on system connection | Token auth works | `feat(auth): configure Laravel Sanctum for API authentication` |
| **D22** | `root_users` migration + login/register endpoints | Root admin can authenticate | `feat(root-admin): add root user authentication endpoints` |
| **D23** | `GET/POST /api/root/tenants` — list, create (triggers provision) | Tenant CRUD via API | `feat(root-admin): add tenant management API endpoints` |
| **D24** | Domain binding API: path alias + subdomain; validation rules | Domain routes correctly | `feat(root-admin): add tenant domain binding API` |
| **D25** | Feature tests for full root admin flow; tag `v0.1.0-phase1` | Phase 1 complete | `test(root-admin): add feature tests for tenant provisioning flow` |

**Section 1.5 exit criteria:** Root admin can log in, create tenant, tenant is provisioned and reachable.

---

## 17. Phase 2 — Core Domain & Catalog

**Goal:** Complete tenant data model, domain actions, sector adapters, faceted search, roles, and turnover discount logic.

**Milestone:** `M2 — Core Domain & Catalog`

---

### Section 2.1 — Core database schema (Days 26–30)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D26** | `categories` migration with `path`, `depth`, indexes | Category tree CRUD ready | `feat(schema): add hierarchical categories table` |
| **D27** | `products` + `attributes_json` + virtual columns for `brand`, `power_watt` | JSON specs storable + filterable | `feat(schema): add products table with JSON attributes` |
| **D28** | `filterable_attributes`, `sector_profiles` config tables | Admin filter config storable | `feat(schema): add filterable attributes configuration` |
| **D29** | `stocks`, `stock_movements`, `stock_reservations`, `warehouses` | Inventory model complete | `feat(schema): add stock and warehouse tables` |
| **D30** | `suppliers`, `dealers`, `customer_discount_tiers`, `customer_turnover_logs`, `orders` skeleton | Commercial model complete | `feat(schema): add dealers, pricing, and order tables` |

---

### Section 2.2 — Domain layer (Days 31–35)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D31** | Catalog value objects: `ProductId`, `Sku`, `Money`, `AttributesJson` | Typed domain primitives | `feat(domain): add Catalog value objects` |
| **D32** | `UpdateProductSpecsAction` — merge JSON specs with validation | Spec updates via action | `feat(domain): implement UpdateProductSpecsAction` |
| **D33** | `ReserveStockAction` — reserve on order, release on cancel | Stock reservation rules | `feat(domain): implement ReserveStockAction` |
| **D34** | `UpgradeCustomerTierAction` — pure tier calculation logic | Tier logic testable without DB | `feat(domain): implement UpgradeCustomerTierAction` |
| **D35** | Unit tests for all Phase 2 actions (mock repositories) | ≥90% domain coverage | `test(domain): add unit tests for core actions` |

---

### Section 2.3 — Multi-sector engine adapters (Days 36–40)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D36** | `MatrixOrderStrategy` — 2D color×size grid validation | Textile orders validated | `feat(sector): add apparel matrix order engine` |
| **D37** | `FitmentEngine` — vehicle make/model/year compatibility | Automotive fitment checks | `feat(sector): add automotive fitment engine` |
| **D38** | `BatchLotDriver` — lot number, expiry enforcement | FMCG batch rules | `feat(sector): add FMCG batch and lot tracking driver` |
| **D39** | `CalculatesByDimensionStrategy` — m²/m³/meter/kg conversions | Building materials pricing | `feat(sector): add dimension-based pricing strategy` |
| **D40** | Sector profile seeder + tenant `sector` field on provision | Tenant activates correct engine | `feat(sector): add sector profile selection on tenant setup` |

---

### Section 2.4 — Faceted search & dynamic filters (Days 41–45)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D41** | `FilterCatalogProductsAction` — base query + pagination | Filtered product list API | `feat(catalog): implement FilterCatalogProductsAction` |
| **D42** | JSON facet extraction + count aggregation | Facet counts in response | `feat(catalog): add JSON facet count aggregation` |
| **D43** | Admin CRUD for `filterable_attributes` per category | Admin configures filters | `feat(catalog): add filterable attributes admin API` |
| **D44** | Filter types: multi-select, range, boolean; query builder | All filter types work | `feat(catalog): support multi-select, range, and boolean filters` |
| **D45** | Meilisearch optional driver for OEM full-text; tests | OEM search fast | `feat(catalog): add optional Meilisearch OEM search index` |

---

### Section 2.5 — Auth, roles & discount engine (Days 46–50)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D46** | Tenant user roles: `admin`, `dealer`, `supplier`, `plasiyer`; policies | RBAC enforced | `feat(auth): add tenant user roles and policies` |
| **D47** | Discount tier CRUD + dealer assignment API | Tiers manageable | `feat(pricing): add customer discount tier management` |
| **D48** | Order delivery event → `ProcessTurnoverJob` on `turnover` queue | Turnover recalculated async | `feat(pricing): wire turnover calculation on order delivery` |
| **D49** | Dealer credit limit + custom price list tables and API | Dealer-specific pricing | `feat(dealers): add credit limits and custom price lists` |
| **D50** | Tier upgrade integration tests; tag `v0.2.0-phase2` | Phase 2 complete | `test(pricing): add tier upgrade scenario tests` |

---

## 18. Phase 3 — Async & Integrations

**Goal:** Production-grade background processing, scraping, Excel, notifications, and published API docs.

**Milestone:** `M3 — Async & Integrations`

---

### Section 3.1 — Redis queues & Horizon (Days 51–55)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D51** | Configure named queues in `config/queue.php` | 7 queues defined | `feat(queue): configure Redis named queues` |
| **D52** | Install Horizon; auth gate; dashboard at `/horizon` | Horizon UI live | `feat(queue): install and configure Laravel Horizon` |
| **D53** | Supervisor program blocks per queue with concurrency limits | Workers stable under load | `infra: configure Supervisor workers per queue` |
| **D54** | Failed job handling, retry backoff, `system_audit_logs` entry | Failures observable | `feat(queue): add failed job retry and audit logging` |
| **D55** | Queue integration tests (dispatch, process, assert side effects) | Tests green | `test(queue): add job processing integration tests` |

---

### Section 3.2 — Product enrichment / scraping (Days 56–60)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D56** | `EnrichProductDataJob` implements `ShouldQueue`; `scraping` queue | Job dispatchable | `feat(scraper): add EnrichProductDataJob` |
| **D57** | `product:enrich {id}` Artisan command invoked by job | CLI enrichment works | `feat(scraper): implement product:enrich command` |
| **D58** | Node.js Puppeteer script in `apps/backend/scripts/scraper/` | Script returns image URLs + specs | `feat(scraper): add Puppeteer scraper script` |
| **D59** | Image download, thumbnail generation, `product_images` insert | Images attached to products | `feat(scraper): download images and generate thumbnails` |
| **D60** | Mock scraper tests; manual test checklist in docs | Section tested | `test(scraper): add mocked scraper integration tests` |

---

### Section 3.3 — Bulk Excel import/export (Days 61–65)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D61** | `PreviewXlsImportAction` — parse upload, validate rows in memory | Preview API returns valid/invalid counts | `feat(import): implement PreviewXlsImportAction` |
| **D62** | Row-level error DTO: line number, column, message | Detailed error report | `feat(import): add row-level validation error reporting` |
| **D63** | `ProcessBulkImportJob` — chunked DB writes on `imports` queue | Large files import async | `feat(import): add ProcessBulkImportJob on imports queue` |
| **D64** | Export job: filtered query → XLS → S3/local storage → signed URL | Export downloadable | `feat(export): add async export job with signed download URL` |
| **D65** | Fixture XLS files + round-trip test | Import/export verified | `test(import): add XLS import and export round-trip tests` |

---

### Section 3.4 — FCM notifications (Days 66–70)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D66** | `user_fcm_tokens` table + register/delete token API | Devices registrable | `feat(notifications): add FCM token registration API` |
| **D67** | `FcmNotificationDriver` in Infrastructure (implements domain contract) | Push sendable from action | `feat(notifications): implement FCM push driver` |
| **D68** | Hook notifications: tier upgrade, import done, export ready, enrich done | All events notify | `feat(notifications): send push on tier upgrade and job completion` |
| **D69** | `notifications` queue + retry on FCM failure | Reliable delivery | `feat(notifications): add notifications queue with retry policy` |
| **D70** | Mock FCM tests | Tests green | `test(notifications): add FCM dispatch tests with mock driver` |

---

### Section 3.5 — API documentation (Days 71–75)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D71** | Install Scribe; Scalar theme; `/docs` route | Docs UI live | `docs(api): install Scribe with Scalar theme` |
| **D72** | Annotate auth + tenancy endpoints | Auth section complete | `docs(api): annotate authentication and tenancy endpoints` |
| **D73** | Annotate catalog, stock, pricing endpoints | Core API documented | `docs(api): annotate catalog and pricing endpoints` |
| **D74** | Export `openapi.yaml` + Postman `collection.json` in CI artifact | Artifacts generated | `docs(api): generate OpenAPI and Postman collection exports` |
| **D75** | Tag `v0.3.0-phase3`; Phase 3 milestone close | Phase 3 complete | `docs(api): finalize API documentation for Phase 3 release` |

---

## 19. Phase 4 — Flutter Client

**Goal:** Cross-platform apps for all roles — catalog, filters, QR stock, Excel preview, push notifications.

**Milestone:** `M4 — Flutter Client`

---

### Section 4.1 — Flutter core architecture (Days 76–80)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D76** | `flutter create` in `apps/frontend`; folder structure: `core/`, `features/` | App runs on web + mobile | `feat(flutter): initialize Flutter app with clean architecture structure` |
| **D77** | Dio client, base URL config, `AuthInterceptor`, error mapping | HTTP layer ready | `feat(flutter): add Dio client with AuthInterceptor` |
| **D78** | Responsive layout widgets: `MobileLayout`, `TabletLayout`, `DesktopLayout` | Breakpoints work | `feat(flutter): add responsive layout breakpoints` |
| **D79** | Login BLoC + secure token storage + auto-refresh | Auth flow complete | `feat(flutter): implement login flow with secure token storage` |
| **D80** | `bloc_test` examples; CI `flutter analyze` + `flutter test` | Flutter CI green | `test(flutter): add bloc_test setup and CI workflow` |

---

### Section 4.2 — Admin & customer portals (Days 81–85)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D81** | Root admin: tenant list, create tenant form | Root admin usable | `feat(ui): build root admin tenant management screens` |
| **D82** | Wholesaler admin: dashboard shell, navigation | Admin shell ready | `feat(ui): build wholesaler admin dashboard shell` |
| **D83** | Customer portal: home, catalog entry, **turnover progress bar** | Dealer sees tier progress | `feat(ui): build customer portal with turnover progress indicator` |
| **D84** | Supplier portal: consignment stock list, update qty | Supplier can manage stock | `feat(ui): build supplier portal with stock management` |
| **D85** | Plasiyer mode: customer selector + order creation | Field sales flow works | `feat(ui): add plasiyer mode for field order creation` |

---

### Section 4.3 — Catalog UI & dynamic filters (Days 86–90)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D86** | Product list screen: pagination, search bar, loading/error states | List performant | `feat(ui): build product list with pagination and search` |
| **D87** | Filter drawer: multi-select chips, range sliders, toggles | Filters match API | `feat(ui): build dynamic filter drawer component` |
| **D88** | Product detail: JSON specs rendered by group | Specs readable | `feat(ui): build product detail with grouped technical specs` |
| **D89** | Apparel matrix grid widget for matrix order strategy | Textile ordering UI | `feat(ui): build apparel color-size matrix order grid` |
| **D90** | Widget tests for list, filter, detail | UI tests green | `test(ui): add widget tests for catalog screens` |

---

### Section 4.4 — QR stock module (Days 91–95)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D91** | Integrate `mobile_scanner`; continuous scan UI | Camera scans without closing | `feat(qr): integrate mobile_scanner continuous scan mode` |
| **D92** | Inbound flow: scan → qty → location → API POST | Stock inbound works | `feat(qr): build inbound stock entry flow` |
| **D93** | Picking flow: pick list → scan verify → line checkmarks | Picking verified | `feat(qr): build outbound picking verification flow` |
| **D94** | Transfer flow: scan → target warehouse selector | Transfers work | `feat(qr): build inter-warehouse transfer flow` |
| **D95** | Integration test: scan mock → API mock → state assert | QR module tested | `test(qr): add QR stock flow integration tests` |

---

### Section 4.5 — Bulk Excel UI & final QA (Days 96–100)

| Day | Task | Deliverable | Example commit |
|-----|------|-------------|----------------|
| **D96** | Upload screen + preview table (valid/invalid rows, errors) | Import preview UI | `feat(ui): build XLS upload and validation preview screen` |
| **D97** | Export request screen + polling / push for download link | Export UI works | `feat(ui): build export request and download UI` |
| **D98** | FCM handler: foreground + background notification routing | Push opens correct screen | `feat(ui): handle push notifications for background jobs` |
| **D99** | End-to-end smoke checklist: all roles, all critical paths | QA doc signed off | `test(e2e): add end-to-end smoke test checklist` |
| **D100** | Tag `v1.0.0`; close M4; update README status table | **Project MVP complete** | `docs: mark Phase 4 complete and update project status` |

---

## 20. Definition of done (per section)

A section is **done** only when ALL of the following are true:

- [ ] All 5 GitHub issues for the section are closed  
- [ ] All work merged to `main` via reviewed PR(s)  
- [ ] Commits follow Conventional Commits (English)  
- [ ] Pest tests pass; new code has tests where applicable  
- [ ] PHPStan Level 9 passes (backend sections)  
- [ ] Flutter analyze + test pass (frontend sections)  
- [ ] No secrets committed; `.env.example` updated if new env vars  
- [ ] Scribe docs updated if API changed (Phase 2+)  
- [ ] README / plan status updated at phase boundaries  

---

## Appendix A — Original architecture reference (Turkish summary)

Bu platform **Trunçgil** bünyesinde geliştirilen, tüm sektörlere uygun **kurumsal B2B SaaS altyapısıdır**. Her toptancıya ayrı veritabanı, çok sektörlü ürün motoru, dinamik filtreleme, otomatik ürün zenginleştirme, QR stok, Excel toplu işlem ve ciro bazlı iskonto yükseltme modüllerini içerir.

Teknik omurga: **Laravel 11 + DDD + Hexagonal** (backend), **Flutter 3 + Clean Architecture + BLoC** (client), **MariaDB 11 multi-DB**, **Redis + Horizon**, **FCM**, **Scribe/Scalar**, **Puppeteer**.

---

## Appendix B — Risk register (watch list)

| Risk | Mitigation |
|------|------------|
| Scraping blocked by target sites | Configurable sources; manual fallback; rate limiting |
| Multi-DB migration drift | Central `tenants:migrate` command; version table per tenant |
| Flutter web + mobile parity | Responsive first; feature flags per platform if needed |
| PHPStan L9 friction early | Baseline file; fix incrementally; never disable in CI |
| Scope creep on sector engines | MVP one strategy per sector; extend in post-v1 issues |

---

---

## 21. Documentation map (detailed planning)

| Level | Document | Granularity |
|-------|----------|-------------|
| Executive | `README.md` | What & why, tech stack, workflow |
| Architecture | This file (§1–14) | System design, modules, conventions |
| Schema | `database-schema.md` | Every column, index, FK |
| API | `api-contract.md` | Every endpoint, request/response |
| Operations | `github-roadmap.md` | 100 issues, 4 milestones |
| **Daily execution** | `playbooks/phase-{1-4}-detailed.md` | One section per day (D1–D20) |

> **Rule:** When implementing, always follow the **playbook for the current day** first. This file is the architectural reference.

---

## 22. Calendar overview (20 working days)

| Day | Phase.Section | Topic |
|-----|---------------|-------|
| D1 | 1.1 | **Plan + README only (no code)** |
| D2 | 1.2 | Docker dev environment |
| D3 | 1.3 | Multi-database tenancy |
| D4 | 1.4 | Tenant provisioning |
| D5 | 1.5 | Quality gates + Root Admin API |
| D6 | 2.1 | Core database schema |
| D7 | 2.2 | Domain layer |
| D8 | 2.3 | Multi-sector engines |
| D9 | 2.4 | Faceted search |
| D10 | 2.5 | Auth, roles, pricing |
| D11 | 3.1 | Redis & Horizon |
| D12 | 3.2 | Product enrichment |
| D13 | 3.3 | Bulk Excel |
| D14 | 3.4 | FCM notifications |
| D15 | 3.5 | API documentation |
| D16 | 4.1 | Flutter core |
| D17 | 4.2 | Portals |
| D18 | 4.3 | Catalog UI |
| D19 | 4.4 | QR stock |
| D20 | 4.5 | Excel UI + **v1.0.0** |

Full daily tasks: [`playbooks/`](playbooks/)

---

*Last updated: D1 — Planning phase. Repo: https://github.com/Faruk-T/B2B_saas_project*
