## Goal
Day D7 — Domain layer. Framework-free catalog and pricing actions with unit tests.

## Playbook
[Phase 2 — Section 2.2 (D7)](../playbooks/phase-2-detailed.md#bölüm-22--gün-d7-domain-katmanı)

## Branch
`phase-2/section-2-domain-layer`

## Tasks
- [ ] `UpdateProductSpecsAction` — JSON spec merge + validation
- [ ] `ReserveStockAction` — stock reservation rules
- [ ] `UpgradeCustomerTierAction` — turnover → tier calculation
- [ ] Value objects: `ProductId`, `Sku`, `Money`, `AttributesJson`
- [ ] Unit tests with mock repositories

## Acceptance criteria
- [ ] Domain layer has no framework dependencies
- [ ] Pest unit tests pass

## Example commits
```
feat(domain): add ProductId, Sku, Money, and AttributesJson value objects
feat(domain): implement UpdateProductSpecsAction with JSON merge
feat(domain): implement ReserveStockAction and UpgradeCustomerTierAction
test(domain): add unit tests with mock repositories
```
