## Goal
Day D5 — Root admin API and quality gates. Sanctum auth, tenant CRUD, CI pipeline green, tag `v0.1.0-phase1`.

## Playbook
[Phase 1 — Section 1.5 (D5)](../playbooks/phase-1-detailed.md#bölüm-15--gün-d5-quality-gates--root-admin-api)

## Branch
`phase-1/section-5-quality-gates-and-root-api`

## Tasks
- [ ] Pest `SolidArchitectureTest` + PHPStan level 9
- [ ] GitHub Actions CI (Pest + PHPStan)
- [ ] Sanctum root guard configuration
- [ ] `POST /api/root/auth/login`, `GET/POST /api/root/tenants`
- [ ] Feature tests + `v0.1.0-phase1` release tag

## Acceptance criteria
- [ ] Root admin login → token → create tenant → provision succeeds
- [ ] CI passes on PR
- [ ] Milestone M1 closed

## Example commits
```
test: add SolidArchitectureTest and PHPStan level 9 config
ci: add GitHub Actions workflow for Pest and PHPStan
feat(root-admin): add Sanctum auth and tenant CRUD endpoints
test(root-admin): add feature tests for login and tenant management
chore: tag v0.1.0-phase1
```
