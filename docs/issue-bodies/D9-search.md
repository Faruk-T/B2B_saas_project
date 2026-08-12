## Goal
Day D9 — Faceted product search with dynamic filters and live facet counts.

## Playbook
[Phase 2 — Section 2.4 (D9)](../playbooks/phase-2-detailed.md#bölüm-24--gün-d9-faset-filtreleme--dinamik-arama)

## Branch
`phase-2/section-4-faceted-search`

## Tasks
- [ ] `FilterCatalogProductsAction` — filter + pagination
- [ ] Facet counts — live numbers (e.g. `Peugeot (142)`)
- [ ] Admin CRUD for `filterable_attributes` per category
- [ ] Filter types: multi-select, range, boolean
- [ ] API: `GET /products?filters[brand]=Bosch`
- [ ] Reference: [`api-contract.md`](../api-contract.md)

## Acceptance criteria
- [ ] 3+ filter combinations return correct results
- [ ] Facet counts update with applied filters

## Example commits
```
feat(catalog): implement FilterCatalogProductsAction with pagination
feat(catalog): add facet count aggregation for dynamic filters
feat(catalog): add filterable attributes admin CRUD
feat(catalog): expose faceted search API endpoint
```
