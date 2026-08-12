## Goal
Day D19 — Mobile QR scanner for stock inbound, picking, and warehouse transfer flows.

## Playbook
[Phase 4 — Section 4.4 (D19)](../playbooks/phase-4-detailed.md#bölüm-44--gün-d19-qr-stok-modülü)

## Branch
`phase-4/section-4-qr-stock`

## Tasks
- [ ] Scanner — `mobile_scanner`, continuous scan mode
- [ ] Inbound — scan → quantity → location → API POST
- [ ] Picking — pick list → scan verify → line confirmation
- [ ] Transfer — scan → target warehouse → confirm

## Acceptance criteria
- [ ] QR scan → stock API call → UI state updates correctly
- [ ] All three flows (inbound, picking, transfer) functional on mobile

## Example commits
```
feat(qr): add mobile QR scanner with continuous scan mode
feat(qr): add stock inbound flow with scan and location capture
feat(qr): add picking verification flow with line confirmation
feat(qr): add warehouse transfer flow
```
