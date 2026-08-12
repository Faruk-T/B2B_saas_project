## Goal
Day D20 — Excel import/export UI, E2E QA, and MVP release `v1.0.0`. Close milestone M4.

## Playbook
[Phase 4 — Section 4.5 (D20)](../playbooks/phase-4-detailed.md#bölüm-45--gün-d20-excel-ui-qa--mvp-release)

## Branch
`phase-4/section-5-excel-ui-and-release`

## Tasks
- [ ] Import UI — upload → preview table (valid/invalid) → confirm
- [ ] Export UI — request → progress → download link
- [ ] Push handler — FCM tap → navigate to correct screen
- [ ] E2E checklist — 12 critical manual QA scenarios
- [ ] Release tag `v1.0.0`, README status update

## Acceptance criteria
- [ ] Root login → create tenant
- [ ] Admin → add product
- [ ] Dealer → filter + order
- [ ] QR inbound + picking
- [ ] Excel import preview + confirm
- [ ] Turnover → tier upgrade + push notification
- [ ] `/docs` API reference complete
- [ ] MVP `v1.0.0` tag pushed; milestone M4 closed

## Example commits
```
feat(ui): add Excel import UI with preview and confirm flow
feat(ui): add async export UI with progress and download
feat(ui): add FCM push tap navigation handler
docs: update README with v1.0.0 MVP release status
chore: tag v1.0.0
```
