# Truncgil Commerce OS - GitHub Labels, Milestones and 20 Issues
# Run once after: gh auth login
#
# Usage:
#   cd b2b-main
#   gh auth login
#   .\scripts\setup-github-project.ps1

$ErrorActionPreference = "Stop"
$Repo = "Faruk-T/B2B_saas_project"

Write-Host "Setting up GitHub project for $Repo..." -ForegroundColor Cyan

# --- Labels ---
$labels = @(
    @{ name = "phase-1"; color = "0E8A16"; desc = "Foundation and Tenancy D1-D5" },
    @{ name = "phase-2"; color = "1D76DB"; desc = "Core Domain and Catalog D6-D10" },
    @{ name = "phase-3"; color = "5319E7"; desc = "Async and Integrations D11-D15" },
    @{ name = "phase-4"; color = "FBCA04"; desc = "Flutter Client D16-D20" },
    @{ name = "backend"; color = "C5DEF5"; desc = "Laravel / PHP" },
    @{ name = "frontend"; color = "BFD4F2"; desc = "Flutter / Dart" },
    @{ name = "infra"; color = "D4C5F9"; desc = "Docker, CI, DevOps" },
    @{ name = "docs"; color = "0075CA"; desc = "Documentation" },
    @{ name = "test"; color = "006B75"; desc = "Tests and quality gates" },
    @{ name = "day-task"; color = "F9D0C4"; desc = "Daily section task" },
    @{ name = "in-review"; color = "FEF2C0"; desc = "PR open, waiting approval" },
    @{ name = "blocked"; color = "B60205"; desc = "Blocked by dependency" }
)

foreach ($l in $labels) {
    gh label create $l.name --color $l.color --description $l.desc --repo $Repo 2>$null
    if ($LASTEXITCODE -eq 0) { Write-Host "  + label: $($l.name)" -ForegroundColor Green }
    else { Write-Host "  ~ label exists: $($l.name)" -ForegroundColor Yellow }
}

# --- Milestones (ASCII titles for PowerShell compatibility) ---
$m1 = "M1 - Phase 1 Foundation and Tenancy"
$m2 = "M2 - Phase 2 Core Domain and Catalog"
$m3 = "M3 - Phase 3 Async and Integrations"
$m4 = "M4 - Phase 4 Flutter Client"

$milestones = @(
    @{ title = $m1; desc = "Days D1-D5" },
    @{ title = $m2; desc = "Days D6-D10" },
    @{ title = $m3; desc = "Days D11-D15" },
    @{ title = $m4; desc = "Days D16-D20" }
)

foreach ($m in $milestones) {
    gh api "repos/$Repo/milestones" -f "title=$($m.title)" -f "description=$($m.desc)" 2>$null
    if ($LASTEXITCODE -eq 0) { Write-Host "  + milestone: $($m.title)" -ForegroundColor Green }
    else { Write-Host "  ~ milestone may exist: $($m.title)" -ForegroundColor Yellow }
}

# --- Issues (20 days) ---
$issues = @(
    @{ day = "D1";  title = "docs: create 20-day roadmap and professional README"; milestone = $m1; labels = "phase-1,docs,day-task"; body = "docs/issue-bodies/D1-planning-readme.md" },
    @{ day = "D2";  title = "infra: add Docker Compose with MariaDB 11, Redis, PHP, Nginx"; milestone = $m1; labels = "phase-1,infra,day-task"; body = "docs/issue-bodies/D2-docker.md" },
    @{ day = "D3";  title = "feat(tenancy): implement multi-database architecture with tenant resolver"; milestone = $m1; labels = "phase-1,backend,day-task"; body = "docs/issue-bodies/D3-tenancy.md" },
    @{ day = "D4";  title = "feat(tenancy): add ProvisionTenantAction with auto database setup"; milestone = $m1; labels = "phase-1,backend,day-task"; body = "docs/issue-bodies/D4-provisioning.md" },
    @{ day = "D5";  title = "feat(root-admin): add Sanctum auth, tenant CRUD, and CI quality gates"; milestone = $m1; labels = "phase-1,backend,test,day-task"; body = "docs/issue-bodies/D5-root-admin.md" },
    @{ day = "D6";  title = "feat(schema): add tenant database tables for catalog, stock, and orders"; milestone = $m2; labels = "phase-2,backend,day-task"; body = "docs/issue-bodies/D6-schema.md" },
    @{ day = "D7";  title = "feat(domain): implement core catalog and pricing actions"; milestone = $m2; labels = "phase-2,backend,day-task"; body = "docs/issue-bodies/D7-domain.md" },
    @{ day = "D8";  title = "feat(sector): add multi-sector order and pricing strategies"; milestone = $m2; labels = "phase-2,backend,day-task"; body = "docs/issue-bodies/D8-sector.md" },
    @{ day = "D9";  title = "feat(catalog): implement faceted product search with dynamic filters"; milestone = $m2; labels = "phase-2,backend,day-task"; body = "docs/issue-bodies/D9-search.md" },
    @{ day = "D10"; title = "feat(pricing): add RBAC, turnover tiers, and discount engine"; milestone = $m2; labels = "phase-2,backend,test,day-task"; body = "docs/issue-bodies/D10-pricing.md" },
    @{ day = "D11"; title = "feat(queue): configure Redis queues, Horizon, and Supervisor workers"; milestone = $m3; labels = "phase-3,backend,infra,day-task"; body = "docs/issue-bodies/D11-queues.md" },
    @{ day = "D12"; title = "feat(scraper): add product enrichment pipeline with Puppeteer"; milestone = $m3; labels = "phase-3,backend,day-task"; body = "docs/issue-bodies/D12-scraper.md" },
    @{ day = "D13"; title = "feat(import): add preview-first XLS import and async export"; milestone = $m3; labels = "phase-3,backend,day-task"; body = "docs/issue-bodies/D13-excel.md" },
    @{ day = "D14"; title = "feat(notifications): implement FCM push for tier upgrade and job completion"; milestone = $m3; labels = "phase-3,backend,day-task"; body = "docs/issue-bodies/D14-fcm.md" },
    @{ day = "D15"; title = "docs(api): publish Scribe Scalar docs with OpenAPI export"; milestone = $m3; labels = "phase-3,docs,backend,day-task"; body = "docs/issue-bodies/D15-api-docs.md" },
    @{ day = "D16"; title = "feat(flutter): initialize Flutter app with auth and responsive layout"; milestone = $m4; labels = "phase-4,frontend,day-task"; body = "docs/issue-bodies/D16-flutter-core.md" },
    @{ day = "D17"; title = "feat(ui): build root admin, wholesaler, customer, and supplier portals"; milestone = $m4; labels = "phase-4,frontend,day-task"; body = "docs/issue-bodies/D17-portals.md" },
    @{ day = "D18"; title = "feat(ui): build product catalog with dynamic filter drawer"; milestone = $m4; labels = "phase-4,frontend,day-task"; body = "docs/issue-bodies/D18-catalog-ui.md" },
    @{ day = "D19"; title = "feat(qr): add mobile QR scanner for stock inbound, picking, and transfer"; milestone = $m4; labels = "phase-4,frontend,day-task"; body = "docs/issue-bodies/D19-qr-stock.md" },
    @{ day = "D20"; title = "feat(ui): add Excel import/export UI and release v1.0.0 MVP"; milestone = $m4; labels = "phase-4,frontend,docs,day-task"; body = "docs/issue-bodies/D20-release.md" }
)

$root = if ($PSScriptRoot) { Resolve-Path (Join-Path $PSScriptRoot "..") } else { Get-Location }

foreach ($i in $issues) {
    $bodyPath = Join-Path $root $i.body
    if (-not (Test-Path $bodyPath)) {
        Write-Host "  ! missing body: $($i.body)" -ForegroundColor Red
        continue
    }
    Write-Host "  Creating issue $($i.day): $($i.title)" -ForegroundColor Cyan
    gh issue create --repo $Repo `
        --title $i.title `
        --label $i.labels `
        --milestone $i.milestone `
        --body-file $bodyPath
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ! failed to create issue $($i.day)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done! Next steps:" -ForegroundColor Green
Write-Host "  1. GitHub Projects -> add all 20 issues to your Kanban board"
Write-Host "  2. Settings -> Branches -> protect main (PR required, 2 approvals)"
Write-Host "  3. Ask Umit to merge after approvals"
Write-Host "  Issues: https://github.com/$Repo/issues"
