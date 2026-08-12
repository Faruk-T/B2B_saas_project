## Goal
Day D4 — Tenant provisioning pipeline. Single API call creates a new wholesaler: database, migrations, seed, and admin account.

## Playbook
[Phase 1 — Section 1.4 (D4)](../playbooks/phase-1-detailed.md#bölüm-14--gün-d4-tenant-provisioning-pipeline)

## Branch
`phase-1/section-4-tenant-provisioning`

## Tasks
- [ ] Domain VOs: `Tenant`, `TenantAlias`, contracts (zero Laravel dependencies)
- [ ] `ProvisionTenantAction` — CREATE DATABASE + migrate + seed
- [ ] `tenants:migrate {alias}` Artisan command
- [ ] `TenantBaseSeeder` — roles, UoM, default warehouse
- [ ] Idempotency — duplicate alias rejected

## Acceptance criteria
- [ ] New tenant provision works end-to-end
- [ ] No Illuminate imports in the domain layer

## Example commits
```
feat(tenancy): add Tenant and TenantAlias domain value objects
feat(tenancy): implement ProvisionTenantAction with auto database setup
feat(tenancy): add tenants:migrate artisan command
feat(tenancy): add TenantBaseSeeder with default roles and warehouse
```
