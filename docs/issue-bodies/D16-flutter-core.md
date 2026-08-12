## Goal
Day D16 — Flutter app bootstrap with auth, responsive layout, and CI quality gates.

## Playbook
[Phase 4 — Section 4.1 (D16)](../playbooks/phase-4-detailed.md#bölüm-41--gün-d16-flutter-core-mimari--auth)

## Branch
`phase-4/section-1-flutter-core`

## Tasks
- [ ] `flutter create` in `apps/frontend/` with clean architecture folders
- [ ] Dio + AuthInterceptor — Bearer token, tenant alias header
- [ ] Responsive breakpoints: mobile <600, tablet 600–1024, desktop >1024
- [ ] Auth BLoC — login, logout, secure token storage
- [ ] CI — `flutter analyze` + `flutter test` in GitHub Actions

## Acceptance criteria
- [ ] Login screen opens on web and Android
- [ ] Token persisted securely after successful login

## Example commits
```
feat(flutter): initialize Flutter app with clean architecture structure
feat(flutter): add Dio client with auth and tenant interceptors
feat(flutter): add Auth BLoC with secure token storage
feat(flutter): add responsive layout breakpoints
ci: add Flutter analyze and test workflow
```
