## Goal
Day D2 — Docker development environment. `docker compose up -d` starts MariaDB 11, Redis, PHP 8.4-FPM, Nginx, and Mailpit.

## Playbook
[Phase 1 — Section 1.2 (D2)](../playbooks/phase-1-detailed.md#bölüm-12--gün-d2-docker--geliştirme-ortamı)

## Branch
`phase-1/section-2-docker-dev-environment`

## Tasks
- [ ] Monorepo layout: `docker/`, `apps/backend/`, `apps/frontend/`, `docs/`
- [ ] `.gitignore` and `.editorconfig`
- [ ] `docker-compose.yml` — MariaDB 11, Redis, PHP 8.4-FPM, Nginx, Mailpit
- [ ] PHP Dockerfile (pdo_mysql, redis, Node 20, Chromium)
- [ ] Nginx reverse proxy on `:8080`
- [ ] `scripts/dev.ps1` — up/down/logs helpers
- [ ] `docker/.env.example`

## Acceptance criteria
- [ ] `curl http://localhost:8080/health` returns `ok`
- [ ] MariaDB and Redis containers report healthy
- [ ] Mailpit UI accessible at `http://localhost:8025`

## Example commits
```
infra: add monorepo folder structure and editor config
infra: add Docker Compose with MariaDB, Redis, PHP, and Nginx
infra: add PHP Dockerfile with required extensions
infra: add dev.ps1 helper script and docker env example
```
