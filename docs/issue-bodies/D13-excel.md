## Goal
Day D13 — Preview-first XLS import and async export with signed download URLs.

## Playbook
[Phase 3 — Section 3.3 (D13)](../playbooks/phase-3-detailed.md#bölüm-33--gün-d13-toplu-excel-importexport)

## Branch
`phase-3/section-3-bulk-excel`

## Tasks
- [ ] `PreviewXlsImportAction` — in-memory validation, row-level errors
- [ ] `ProcessBulkImportJob` on imports queue, chunked writes
- [ ] Export job on exports queue with signed download URL
- [ ] API flow: preview → confirm → status → download
- [ ] Valid/invalid XLS test fixtures

## Acceptance criteria
- [ ] 500-row XLS preview returns validation results
- [ ] Async import completes and status endpoint reflects progress

## Example commits
```
feat(import): add PreviewXlsImportAction with row-level validation
feat(import): add ProcessBulkImportJob with chunked processing
feat(export): add async export job with signed download URL
test(import): add XLS preview and import integration tests
```
