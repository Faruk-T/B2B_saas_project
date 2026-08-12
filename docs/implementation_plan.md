# Trunçgil Commerce OS — Technical Specification & Development Roadmap

> **Universal multi-database SaaS B2B wholesale & dealer management platform**  
> Laravel 11 (DDD + Hexagonal) · Flutter 3 (Clean Architecture + BLoC) · MariaDB 11 · Redis · Horizon · FCM · Scribe/Scalar · Puppeteer

This document is the **single source of truth** for architecture decisions and the **day-by-day delivery plan**.

**GitHub repository:** [Faruk-T/B2B_saas_project](https://github.com/Faruk-T/B2B_saas_project)

| Related doc | Purpose |
|-------------|---------|
| [`github-roadmap.md`](github-roadmap.md) | 20 issue titles, 4 milestones |
| [`github-setup.md`](github-setup.md) | First push + branch protection |
| [`database-schema.md`](database-schema.md) | Full table definitions |
| [`api-contract.md`](api-contract.md) | All endpoints + JSON examples |
| [`playbooks/README.md`](playbooks/README.md) | **Daily tasks (D1–D20) — 1 section = 1 day** |

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
16. [Phase 1 — Foundation & Tenancy (D1–D5)](#16-phase-1--foundation--tenancy-d1d5)
17. [Phase 2 — Core Domain & Catalog (D6–D10)](#17-phase-2--core-domain--catalog-d6d10)
18. [Phase 3 — Async & Integrations (D11–D15)](#18-phase-3--async--integrations-d11d15)
19. [Phase 4 — Flutter Client (D16–D20)](#19-phase-4--flutter-client-d16d20)
20. [Definition of done (per day)](#20-definition-of-done-per-day--section)

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
    └── playbooks/           ← daily D1–D20 detail (1 section = 1 day)
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
3. **One issue per day** — 1 section = 1 day = 1 GitHub issue (20 total).  
4. **Section complete** = issue closed + PR merged + acceptance criteria met.  
5. **Phase complete** = 5 sections done + milestone closed.

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

## 16. Phase 1 — Foundation & Tenancy (D1–D5)

**Milestone:** M1 · **5 gün** · Playbook: [`playbooks/phase-1-detailed.md`](playbooks/phase-1-detailed.md)

| Gün | Bölüm | Konu | Kod? |
|-----|-------|------|------|
| **D1** | 1.1 | Detaylı plan + profesyonel README + görseller | ❌ Sadece docs |
| D2 | 1.2 | Docker Compose (MariaDB, Redis, PHP, Nginx, Mailpit) | ✅ |
| D3 | 1.3 | Laravel 11 + multi-DB tenancy + TenantResolverMiddleware | ✅ |
| D4 | 1.4 | ProvisionTenantAction + migrate + seed pipeline | ✅ |
| D5 | 1.5 | Pest/PHPStan CI + Sanctum + Root Admin API → `v0.1.0-phase1` | ✅ |

**D1 kuralı:** API, veritabanı ve Docker **uygulama kodu yok** — yalnızca dokümantasyon.

---

## 17. Phase 2 — Core Domain & Catalog (D6–D10)

**Milestone:** M2 · **5 gün** · Playbook: [`playbooks/phase-2-detailed.md`](playbooks/phase-2-detailed.md)

| Gün | Bölüm | Konu | Tag |
|-----|-------|------|-----|
| D6 | 2.1 | Tenant DB şeması (categories, products, stock, orders) | — |
| D7 | 2.2 | Domain katmanı (Actions + Value Objects) | — |
| D8 | 2.3 | Çok sektörlü motorlar (tekstil, otomotiv, FMCG, yapı) | — |
| D9 | 2.4 | Faset filtreleme + FilterCatalogProductsAction | — |
| D10 | 2.5 | RBAC + iskonto kademeleri + ciro motoru | `v0.2.0-phase2` |

---

## 18. Phase 3 — Async & Integrations (D11–D15)

**Milestone:** M3 · **5 gün** · Playbook: [`playbooks/phase-3-detailed.md`](playbooks/phase-3-detailed.md)

| Gün | Bölüm | Konu | Tag |
|-----|-------|------|-----|
| D11 | 3.1 | Redis kuyruklar + Horizon + Supervisor | — |
| D12 | 3.2 | Ürün zenginleştirme (Puppeteer scraping) | — |
| D13 | 3.3 | Excel import/export (önizleme + async) | — |
| D14 | 3.4 | FCM push bildirimler | — |
| D15 | 3.5 | Scribe/Scalar API docs + OpenAPI export | `v0.3.0-phase3` |

---

## 19. Phase 4 — Flutter Client (D16–D20)

**Milestone:** M4 · **5 gün** · Playbook: [`playbooks/phase-4-detailed.md`](playbooks/phase-4-detailed.md)

| Gün | Bölüm | Konu | Tag |
|-----|-------|------|-----|
| D16 | 4.1 | Flutter core + Dio + auth + responsive | — |
| D17 | 4.2 | Root admin, toptancı, bayi, tedarikçi portalleri | — |
| D18 | 4.3 | Katalog UI + dinamik filtre drawer | — |
| D19 | 4.4 | QR stok modülü (inbound, picking, transfer) | — |
| D20 | 4.5 | Excel UI + E2E QA + MVP release | **`v1.0.0`** |

---

## 20. Definition of done (per day / section)

Her gün (bölüm) **tamamlanmış** sayılır ancak şunların hepsi sağlanırsa:

- [ ] İlgili GitHub issue kapatıldı (`Closes #N` PR ile)
- [ ] Work merged to `main` via reviewed PR
- [ ] Commits in English (Conventional Commits)
- [ ] Playbook'taki acceptance criteria karşılandı
- [ ] Tests pass where applicable (D5+)
- [ ] No secrets committed

**Proje tamamlanması:** D20 sonunda `v1.0.0` tag + M4 milestone closed.

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
| Operations | `github-roadmap.md` | 20 issues, 4 milestones |
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
