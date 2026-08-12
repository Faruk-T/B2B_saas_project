# Phase 3 Playbook — Async & Integrations (D11–D15)

**Milestone:** M3 — Async & Integrations  
**1 bölüm = 1 gün**

---

## Bölüm 3.1 — Gün D11: Redis kuyruklar & Horizon

**Branch:** `phase-3/section-1-redis-horizon`  
**Issue:** `feat(queue): configure Redis queues, Horizon, and Supervisor workers`

| Görev | Detay |
|-------|-------|
| Named queues | imports, exports, scraping, reports, notifications, turnover, erp |
| Horizon | Dashboard `/horizon`, root admin gate |
| Supervisor | Worker programları docker'da |
| Failed jobs | Retry 3x, audit log |
| Tests | Job dispatch + process testleri |

**Kabul:** Horizon UI erişilebilir; test job işlenir.

---

## Bölüm 3.2 — Gün D12: Ürün zenginleştirme (scraping)

**Branch:** `phase-3/section-2-product-enrichment`  
**Issue:** `feat(scraper): add product enrichment pipeline with Puppeteer`

| Görev | Detay |
|-------|-------|
| `EnrichProductDataJob` | scraping kuyruğu |
| `product:enrich {id}` | Artisan komutu |
| Puppeteer script | Barkod/SKU/OEM → görsel + spec |
| Image pipeline | Download, thumbnail, `product_images` |
| FCM hook | Zenginleştirme bitince bildirim (stub ok) |

**Kabul:** Eksik görselli ürün → job → görsel eklenir.

---

## Bölüm 3.3 — Gün D13: Toplu Excel import/export

**Branch:** `phase-3/section-3-bulk-excel`  
**Issue:** `feat(import): add preview-first XLS import and async export`

| Görev | Detay |
|-------|-------|
| `PreviewXlsImportAction` | Bellekte doğrulama, satır hataları |
| `ProcessBulkImportJob` | imports kuyruğu, chunked write |
| Export job | exports kuyruğu, signed download URL |
| API | preview → confirm → status → download |
| Fixtures | valid/invalid XLS test dosyaları |

**Kabul:** 500 satırlık XLS preview + async import çalışır.

---

## Bölüm 3.4 — Gün D14: FCM push bildirimler

**Branch:** `phase-3/section-4-fcm-notifications`  
**Issue:** `feat(notifications): implement FCM push for tier upgrade and job completion`

| Görev | Detay |
|-------|-------|
| Token API | register/delete FCM token |
| `FcmNotificationDriver` | Infrastructure katmanı |
| Event hooks | tier upgrade, import/export done, enrich done |
| Retry | notifications kuyruğu, invalid token temizleme |
| Tests | Mock FCM driver |

**Kabul:** Tier upgrade → push payload doğru yapıda dispatch edilir.

---

## Bölüm 3.5 — Gün D15: API dokümantasyonu

**Branch:** `phase-3/section-5-api-documentation`  
**Issue:** `docs(api): publish Scribe Scalar docs with OpenAPI export`

| Görev | Detay |
|-------|-------|
| Scribe + Scalar | `/docs` UI |
| Annotate | Tüm Phase 1–2 endpoint'leri |
| Export | `openapi.yaml`, Postman collection |
| CI artifact | Docs PR'da üretilir |
| Tag | `v0.3.0-phase3`, M3 kapat |

**Kabul:** `/docs` tüm endpoint gruplarını gösterir.

**Sonraki:** [phase-4-detailed.md](phase-4-detailed.md) → D16
