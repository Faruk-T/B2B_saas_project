## Goal
Day D3 — Multi-database tenancy. Laravel 11 with system + tenant connections and middleware-based tenant routing.

## Playbook
[Phase 1 — Section 1.3 (D3)](../playbooks/phase-1-detailed.md#bölüm-13--gün-d3-çoklu-veritabanı-tenancy)

## Branch
`phase-1/section-3-multi-database-tenancy`

## Tasks
- [ ] `composer create-project laravel/laravel` in `apps/backend/`
- [ ] System migrations: `tenants`, `tenant_domains`, `root_users`
- [ ] `config/database.php` — `system` and `tenant` connections
- [ ] `TenantResolverMiddleware` — URL/host alias → database switch
- [ ] Pest integration test for tenant isolation

## Acceptance criteria
- [ ] `/firma-a/api/...` routes to `b2b_tenant_firma_a_db`
- [ ] Tenant A data is invisible from Tenant B context

## Example commits
```
feat(tenancy): bootstrap Laravel 11 backend application
feat(tenancy): add system database migrations for tenants and domains
feat(tenancy): add dual connection config and tenant resolver middleware
test(tenancy): add integration test for multi-database isolation
```
