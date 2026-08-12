## Goal
Day D12 — Product enrichment pipeline with Puppeteer scraping for images and specs.

## Playbook
[Phase 3 — Section 3.2 (D12)](../playbooks/phase-3-detailed.md#bölüm-32--gün-d12-ürün-zenginleştirme-scraping)

## Branch
`phase-3/section-2-product-enrichment`

## Tasks
- [ ] `EnrichProductDataJob` on scraping queue
- [ ] `product:enrich {id}` Artisan command
- [ ] Puppeteer script — barcode/SKU/OEM → image + specs
- [ ] Image pipeline — download, thumbnail, `product_images`
- [ ] FCM hook stub on enrichment completion

## Acceptance criteria
- [ ] Product missing images → job runs → images added
- [ ] Enrichment job retries on transient failures

## Example commits
```
feat(scraper): add EnrichProductDataJob on scraping queue
feat(scraper): add product:enrich artisan command
feat(scraper): add Puppeteer enrichment script for specs and images
feat(scraper): add image download and thumbnail pipeline
```
