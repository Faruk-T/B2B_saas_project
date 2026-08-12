# Phase 4 Playbook — Flutter Client (D16–D20)

**Milestone:** M4 — Flutter Client  
**1 bölüm = 1 gün**

---

## Bölüm 4.1 — Gün D16: Flutter core mimari & auth

**Branch:** `phase-4/section-1-flutter-core`  
**Issue:** `feat(flutter): initialize Flutter app with auth and responsive layout`

| Görev | Detay |
|-------|-------|
| `flutter create` | `apps/frontend/`, clean architecture klasörleri |
| Dio + AuthInterceptor | Bearer token, tenant alias header |
| Responsive | Mobile <600, Tablet 600–1024, Desktop >1024 |
| Auth BLoC | Login, logout, secure token storage |
| CI | `flutter analyze` + `flutter test` GitHub Actions |

**Kabul:** Web + Android'de login ekranı açılır, token saklanır.

---

## Bölüm 4.2 — Gün D17: Admin & müşteri portalleri

**Branch:** `phase-4/section-2-portals`  
**Issue:** `feat(ui): build root admin, wholesaler, customer, and supplier portals`

| Portal | Ekranlar |
|--------|----------|
| Root Admin | Tenant listesi, yeni tenant formu |
| Toptancı Admin | Dashboard shell, sidebar navigasyon |
| Bayi | Ana sayfa, **ciro progress bar**, katalog girişi |
| Tedarikçi | Konsinye stok listesi, miktar güncelleme |
| Plasiyer | Müşteri seç → sipariş oluştur |

**Kabul:** Role göre doğru shell açılır; turnover API'den progress bar doluyor.

---

## Bölüm 4.3 — Gün D18: Katalog UI & dinamik filtreler

**Branch:** `phase-4/section-3-catalog-ui`  
**Issue:** `feat(ui): build product catalog with dynamic filter drawer`

| Görev | Detay |
|-------|-------|
| Product list | Pagination, search, skeleton loading |
| Filter drawer | Chips, range slider, toggle — API facet'leriyle |
| Product detail | JSON specs gruplu gösterim |
| Matrix grid | Tekstil renk×beden sipariş grid'i |
| Widget tests | List + filter component testleri |

**Kabul:** Filtre uygulayınca facet sayıları ve ürün listesi güncellenir.

---

## Bölüm 4.4 — Gün D19: QR stok modülü

**Branch:** `phase-4/section-4-qr-stock`  
**Issue:** `feat(qr): add mobile QR scanner for stock inbound, picking, and transfer`

| Akış | Adımlar |
|------|---------|
| Scanner | `mobile_scanner`, sürekli tarama modu |
| Inbound | Scan → miktar → konum → API POST |
| Picking | Pick list → scan verify → satır onayı |
| Transfer | Scan → hedef depo → onay |

**Kabul:** QR scan → stok API → UI state güncellenir.

---

## Bölüm 4.5 — Gün D20: Excel UI, QA & MVP release

**Branch:** `phase-4/section-5-excel-ui-and-release`  
**Issue:** `feat(ui): add Excel import/export UI and release v1.0.0 MVP`

| Görev | Detay |
|-------|-------|
| Import UI | Upload → preview tablo (valid/invalid) → confirm |
| Export UI | İstek → progress → download link |
| Push handler | FCM tap → doğru ekrana yönlendirme |
| E2E checklist | 12 kritik senaryo manuel QA |
| Release | Tag `v1.0.0`, README status güncelle, M4 kapat |

### E2E checklist
- [ ] Root login → tenant oluştur
- [ ] Admin → ürün ekle
- [ ] Bayi → filtrele + sipariş
- [ ] QR inbound + picking
- [ ] Excel import preview + confirm
- [ ] Ciro → tier upgrade + push
- [ ] `/docs` API referansı tam

**Kabul:** MVP `v1.0.0` tag'i push edilir. **Proje tamamlanır.**
