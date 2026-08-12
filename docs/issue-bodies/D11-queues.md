## Goal
Day D11 — Redis queues, Laravel Horizon, and Supervisor workers in Docker.

## Playbook
[Phase 3 — Section 3.1 (D11)](../playbooks/phase-3-detailed.md#bölüm-31--gün-d11-redis-kuyruklar--horizon)

## Branch
`phase-3/section-1-redis-horizon`

## Tasks
- [ ] Named queues: imports, exports, scraping, reports, notifications, turnover, erp
- [ ] Horizon dashboard at `/horizon` with root admin gate
- [ ] Supervisor worker programs in Docker
- [ ] Failed jobs — retry 3×, audit log
- [ ] Job dispatch + process tests

## Acceptance criteria
- [ ] Horizon UI accessible to root admin
- [ ] Test job dispatches and processes successfully

## Example commits
```
feat(queue): configure named Redis queues for async workloads
feat(queue): add Laravel Horizon with root admin authorization
infra: add Supervisor worker programs to Docker Compose
test(queue): add job dispatch and processing tests
```
