# Phase 1 Playbook — Foundation & Tenancy (D1–D5)

**Milestone:** M1 — Foundation & Tenancy  
**Repo:** [Faruk-T/B2B_saas_project](https://github.com/Faruk-T/B2B_saas_project)

> **1 bölüm = 1 gün.** Phase 1 toplam **5 gün**.

---

## Bölüm 1.1 — Gün D1: Detaylı plan & profesyonel README

**Branch:** `phase-1/section-1-planning-and-readme`  
**Issue:** `docs: create 20-day roadmap and professional README`  
**Süre:** 1 gün  
**Kod/API/DB:** ❌ YOK — sadece dokümantasyon

### Günün hedefi
Projenin tüm dokümantasyonu eksiksiz, anlaşılır ve GitHub'a push edilmeye hazır hale gelir.

### Yapılacaklar

| # | Görev | Dosya |
|---|-------|-------|
| 1 | 20 günlük planı netleştir (4 faz × 5 bölüm) | `docs/implementation_plan.md` |
| 2 | Günlük playbook'ları 20 güne göre güncelle | `docs/playbooks/` |
| 3 | Profesyonel README (Türkçe, görselli) | `README.md` |
| 4 | Mimari, iş akışı, UI mockup görselleri | `docs/assets/*.png` |
| 5 | Veritabanı şema referansı | `docs/database-schema.md` |
| 6 | API sözleşmesi referansı | `docs/api-contract.md` |
| 7 | GitHub roadmap (20 issue) | `docs/github-roadmap.md` |
| 8 | GitHub setup rehberi | `docs/github-setup.md` |
| 9 | PR & issue template'leri | `.github/` |

### Commit'ler (İngilizce)
```bash
git commit -m "docs: add 20-day development roadmap (4 phases x 5 sections)"
git commit -m "docs: add professional README with architecture and workflow diagrams"
git commit -m "docs: add database schema and API contract reference"
git commit -m "chore: add GitHub PR and issue templates"
```

### Kabul kriterleri
- [ ] README profesyonel, görselli, Türkçe açıklamalı
- [ ] 20 günlük takvim tablosu README'de görünür
- [ ] D1'de API/DB/Docker kodu **yok**
- [ ] Tüm playbook'lar 20 güne göre güncel
- [ ] GitHub'a push edilebilir durumda

### PR
- Title: `docs: complete Phase 1 Section 1.1 — planning and README`
- Merge → `main`

---

## Bölüm 1.2 — Gün D2: Docker & geliştirme ortamı

**Branch:** `phase-1/section-2-docker-dev-environment`  
**Issue:** `infra: add Docker Compose with MariaDB 11, Redis, PHP, Nginx`

### Hedef
`docker compose up -d` ile tüm servisler ayağa kalkar.

### Görevler (tek günde)
1. Monorepo klasör yapısı: `docker/`, `apps/backend/`, `apps/frontend/`, `docs/`
2. `.gitignore`, `.editorconfig`
3. `docker-compose.yml` — MariaDB 11, Redis, PHP 8.4-FPM, Nginx, Mailpit
4. PHP Dockerfile (pdo_mysql, redis, Node 20, Chromium)
5. Nginx reverse proxy `:8080`
6. `scripts/dev.ps1` — up/down/logs
7. `docker/.env.example`

### Kabul kriterleri
- [ ] `curl http://localhost:8080/health` → `ok`
- [ ] MariaDB + Redis healthy
- [ ] Mailpit UI: `http://localhost:8025`

---

## Bölüm 1.3 — Gün D3: Çoklu veritabanı tenancy

**Branch:** `phase-1/section-3-multi-database-tenancy`  
**Issue:** `feat(tenancy): implement multi-database architecture with tenant resolver`

### Hedef
Laravel 11 kurulu; system + tenant dual connection; middleware ile tenant yönlendirme.

### Görevler (tek günde)
1. `composer create-project laravel/laravel` → `apps/backend/`
2. System migrations: `tenants`, `tenant_domains`, `root_users`
3. `config/database.php` — `system` + `tenant` connections
4. `TenantResolverMiddleware` — URL/host alias → DB switch
5. Pest integration test — tenant izolasyonu

### Kabul kriterleri
- [ ] `/firma-a/api/...` → `b2b_tenant_firma_a_db`
- [ ] Tenant A verisi Tenant B'den görünmez

---

## Bölüm 1.4 — Gün D4: Tenant provisioning pipeline

**Branch:** `phase-1/section-4-tenant-provisioning`  
**Issue:** `feat(tenancy): add ProvisionTenantAction with auto database setup`

### Hedef
Tek API çağrısıyla yeni toptancı: DB oluştur, migrate, seed, admin hesabı.

### Görevler (tek günde)
1. Domain VOs: `Tenant`, `TenantAlias`, contracts (sıfır Laravel bağımlılığı)
2. `ProvisionTenantAction` — CREATE DATABASE + migrate + seed
3. `tenants:migrate {alias}` Artisan komutu
4. `TenantBaseSeeder` — roller, UoM, varsayılan depo
5. Idempotency — duplicate alias reddedilir

### Kabul kriterleri
- [ ] Yeni tenant provision uçtan uca çalışır
- [ ] Domain katmanında Illuminate import yok

---

## Bölüm 1.5 — Gün D5: Quality gates & Root Admin API

**Branch:** `phase-1/section-5-quality-gates-and-root-api`  
**Issue:** `feat(root-admin): add Sanctum auth, tenant CRUD, and CI quality gates`

### Hedef
Root admin login + tenant yönetimi API; CI pipeline yeşil; tag `v0.1.0-phase1`.

### Görevler (tek günde)
1. Pest `SolidArchitectureTest` + PHPStan L9
2. GitHub Actions CI (Pest + PHPStan)
3. Sanctum — root guard
4. `POST /api/root/auth/login`, `GET/POST /api/root/tenants`
5. Feature testleri + `v0.1.0-phase1` tag

### Kabul kriterleri
- [ ] Root admin login → token → tenant oluştur → provision
- [ ] CI PR'da yeşil
- [ ] Milestone M1 kapatılır

**Sonraki:** [phase-2-detailed.md](phase-2-detailed.md) → D6
