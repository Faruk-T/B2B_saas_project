# Phase 2 Playbook — Core Domain & Catalog (D6–D10)

**Milestone:** M2 — Core Domain & Catalog  
**1 bölüm = 1 gün**

---

## Bölüm 2.1 — Gün D6: Çekirdek veritabanı şeması

**Branch:** `phase-2/section-1-core-schema`  
**Issue:** `feat(schema): add tenant database tables for catalog, stock, and orders`

| Görev | Detay |
|-------|-------|
| Categories | Hiyerarşik `path`, `depth`, self-FK |
| Products | `attributes_json`, virtual columns (`brand`, `power_watt`) |
| Filter config | `filterable_attributes`, `sector_profiles` |
| Stock | `warehouses`, `stocks`, `stock_movements`, `stock_reservations` |
| Commercial | `dealers`, `suppliers`, `discount_tiers`, `orders`, `order_lines` |

**Referans:** [`database-schema.md`](../database-schema.md)

**Kabul:** `tenants:migrate` 2 test tenant'ta sorunsuz çalışır.

---

## Bölüm 2.2 — Gün D7: Domain katmanı

**Branch:** `phase-2/section-2-domain-layer`  
**Issue:** `feat(domain): implement core catalog and pricing actions`

| Action | Sorumluluk |
|--------|------------|
| `UpdateProductSpecsAction` | JSON spec merge + validasyon |
| `ReserveStockAction` | Stok rezervasyon kuralları |
| `UpgradeCustomerTierAction` | Saf ciro → kademe hesabı |
| Value Objects | `ProductId`, `Sku`, `Money`, `AttributesJson` |
| Tests | Mock repository ile unit testler |

**Kabul:** Domain katmanı framework'süz; Pest unit testleri yeşil.

---

## Bölüm 2.3 — Gün D8: Çok sektörlü iş motorları

**Branch:** `phase-2/section-3-sector-engines`  
**Issue:** `feat(sector): add multi-sector order and pricing strategies`

| Sektör | Strategy |
|--------|----------|
| Tekstil | `MatrixOrderStrategy` — renk×beden grid |
| Otomotiv | `FitmentEngine` — OEM, marka/model/yıl |
| FMCG | `BatchLotDriver` — parti, SKT |
| Yapı | `CalculatesByDimensionStrategy` — m²/m³/kg |
| Factory | `SectorEngineFactory` — tenant sector → strategy |

**Kabul:** Her sektör için en az 1 validasyon testi.

---

## Bölüm 2.4 — Gün D9: Faset filtreleme & dinamik arama

**Branch:** `phase-2/section-4-faceted-search`  
**Issue:** `feat(catalog): implement faceted product search with dynamic filters`

| Görev | Detay |
|-------|-------|
| `FilterCatalogProductsAction` | Filtre + pagination |
| Facet counts | `Peugeot (142)` canlı sayılar |
| Admin CRUD | `filterable_attributes` per category |
| Filter types | multi-select, range, boolean |
| API | `GET /products?filters[brand]=Bosch` |

**Referans:** [`api-contract.md`](../api-contract.md)

**Kabul:** 3+ filtre kombinasyonu doğru sonuç döner.

---

## Bölüm 2.5 — Gün D10: Auth, roller & iskonto motoru

**Branch:** `phase-2/section-5-auth-roles-pricing`  
**Issue:** `feat(pricing): add RBAC, turnover tiers, and discount engine`

| Görev | Detay |
|-------|-------|
| RBAC | admin, dealer, supplier, plasiyer, warehouse |
| Discount tiers | CRUD + dealer atama |
| Turnover | Order delivered → tier upgrade |
| Dealer limits | Kredi limiti, özel fiyat listesi |
| Tag | `v0.2.0-phase2` |

**Kabul:** Dealer ciro eşiği aşınca kademe otomatik yükselir; M2 kapatılır.

**Sonraki:** [phase-3-detailed.md](phase-3-detailed.md) → D11
