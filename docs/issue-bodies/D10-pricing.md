## Goal
Day D10 — RBAC, turnover tiers, and discount engine. Tag `v0.2.0-phase2`, close milestone M2.

## Playbook
[Phase 2 — Section 2.5 (D10)](../playbooks/phase-2-detailed.md#bölüm-25--gün-d10-auth-roller--iskonto-motoru)

## Branch
`phase-2/section-5-auth-roles-pricing`

## Tasks
- [ ] RBAC roles: admin, dealer, supplier, plasiyer, warehouse
- [ ] Discount tiers CRUD + dealer assignment
- [ ] Turnover — order delivered → automatic tier upgrade
- [ ] Dealer limits — credit limit, custom price list
- [ ] Release tag `v0.2.0-phase2`

## Acceptance criteria
- [ ] Dealer tier auto-upgrades when turnover threshold exceeded
- [ ] Milestone M2 closed

## Example commits
```
feat(auth): add RBAC roles and permission middleware
feat(pricing): add discount tier CRUD and dealer assignment
feat(pricing): implement turnover-based tier upgrade on order delivery
test(pricing): add tier upgrade integration tests
chore: tag v0.2.0-phase2
```
