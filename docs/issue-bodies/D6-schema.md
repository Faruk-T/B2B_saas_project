## Goal
Day D6 — Core tenant database schema. Catalog, stock, and order tables for multi-sector B2B operations.

## Playbook
[Phase 2 — Section 2.1 (D6)](../playbooks/phase-2-detailed.md#bölüm-21--gün-d6-çekirdek-veritabanı-şeması)

## Branch
`phase-2/section-1-core-schema`

## Tasks
- [ ] Categories — hierarchical `path`, `depth`, self-FK
- [ ] Products — `attributes_json`, virtual columns (`brand`, `power_watt`)
- [ ] Filter config — `filterable_attributes`, `sector_profiles`
- [ ] Stock — `warehouses`, `stocks`, `stock_movements`, `stock_reservations`
- [ ] Commercial — `dealers`, `suppliers`, `discount_tiers`, `orders`, `order_lines`
- [ ] Reference: [`database-schema.md`](../database-schema.md)

## Acceptance criteria
- [ ] `tenants:migrate` runs cleanly on 2 test tenants
- [ ] All tables match schema reference documentation

## Example commits
```
feat(schema): add hierarchical category migrations
feat(schema): add products with JSON attributes and virtual columns
feat(schema): add stock and warehouse tables
feat(schema): add commercial tables for dealers, orders, and pricing
```
