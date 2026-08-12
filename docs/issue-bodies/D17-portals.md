## Goal
Day D17 — Role-based portals: root admin, wholesaler, dealer, supplier, and plasiyer shells.

## Playbook
[Phase 4 — Section 4.2 (D17)](../playbooks/phase-4-detailed.md#bölüm-42--gün-d17-admin--müşteri-portalleri)

## Branch
`phase-4/section-2-portals`

## Tasks
- [ ] Root Admin — tenant list, new tenant form
- [ ] Wholesaler Admin — dashboard shell, sidebar navigation
- [ ] Dealer — home page, turnover progress bar, catalog entry
- [ ] Supplier — consignment stock list, quantity updates
- [ ] Plasiyer — select customer → create order flow

## Acceptance criteria
- [ ] Correct shell opens per user role
- [ ] Dealer turnover progress bar populated from API

## Example commits
```
feat(ui): add root admin tenant list and creation form
feat(ui): add wholesaler admin dashboard shell with navigation
feat(ui): add dealer portal with turnover progress bar
feat(ui): add supplier and plasiyer portal shells
```
