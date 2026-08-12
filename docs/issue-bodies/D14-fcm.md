## Goal
Day D14 — FCM push notifications for tier upgrades and async job completion.

## Playbook
[Phase 3 — Section 3.4 (D14)](../playbooks/phase-3-detailed.md#bölüm-34--gün-d14-fcm-push-bildirimler)

## Branch
`phase-3/section-4-fcm-notifications`

## Tasks
- [ ] Token API — register/delete FCM device tokens
- [ ] `FcmNotificationDriver` in infrastructure layer
- [ ] Event hooks: tier upgrade, import/export done, enrichment done
- [ ] Retry on notifications queue, invalid token cleanup
- [ ] Mock FCM driver tests

## Acceptance criteria
- [ ] Tier upgrade dispatches push with correct payload structure
- [ ] Invalid tokens removed after failed delivery

## Example commits
```
feat(notifications): add FCM token register and delete API
feat(notifications): implement FcmNotificationDriver
feat(notifications): wire event hooks for tier upgrade and job completion
test(notifications): add mock FCM driver tests
```
