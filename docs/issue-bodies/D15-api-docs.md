## Goal
Day D15 — Scribe + Scalar API docs with OpenAPI export. Tag `v0.3.0-phase3`, close milestone M3.

## Playbook
[Phase 3 — Section 3.5 (D15)](../playbooks/phase-3-detailed.md#bölüm-35--gün-d15-api-dokümantasyonu)

## Branch
`phase-3/section-5-api-documentation`

## Tasks
- [ ] Scribe + Scalar UI at `/docs`
- [ ] Annotate all Phase 1–2 endpoints
- [ ] Export `openapi.yaml` and Postman collection
- [ ] CI artifact — docs generated on PR
- [ ] Release tag `v0.3.0-phase3`

## Acceptance criteria
- [ ] `/docs` shows all endpoint groups
- [ ] OpenAPI export matches live API
- [ ] Milestone M3 closed

## Example commits
```
docs(api): add Scribe and Scalar documentation setup
docs(api): annotate Phase 1 and Phase 2 endpoints
docs(api): export OpenAPI spec and Postman collection
ci: add API docs generation as PR artifact
chore: tag v0.3.0-phase3
```
