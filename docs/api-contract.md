# API Contract Reference

Base URL (local): `http://localhost:8080/api`

**Authentication:** `Authorization: Bearer {token}` (Laravel Sanctum)

**Tenant routing:**
- Path alias: `http://localhost:8080/api/{alias}/...`
- Subdomain: `http://{alias}.b2b.local/api/...`

All responses use JSON. Errors follow:

```json
{
  "message": "Human-readable error",
  "errors": { "field": ["Validation message"] }
}
```

---

## Root Admin API (system DB, no tenant prefix)

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/root/auth/login` | Login → `{ token, user }` |
| POST | `/root/auth/logout` | Revoke current token |
| GET | `/root/auth/me` | Current root user |

**Login request:**
```json
{ "email": "admin@truncgil.com", "password": "secret" }
```

**Login response:**
```json
{
  "token": "1|abc...",
  "user": { "id": 1, "name": "Root Admin", "email": "admin@truncgil.com" }
}
```

---

### Tenants

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/root/tenants` | Paginated tenant list |
| POST | `/root/tenants` | Provision new tenant |
| GET | `/root/tenants/{uuid}` | Tenant detail |
| PATCH | `/root/tenants/{uuid}` | Update name, status, sector |
| POST | `/root/tenants/{uuid}/domains` | Add domain binding |
| DELETE | `/root/tenants/{uuid}/domains/{id}` | Remove domain |

**Create tenant request:**
```json
{
  "alias": "tekstil-a",
  "name": "Tekstil A Toptancılık",
  "sector": "apparel",
  "admin": {
    "name": "Ahmet Yılmaz",
    "email": "admin@tekstil-a.com",
    "password": "SecurePass123!"
  },
  "domain": {
    "type": "path",
    "path_prefix": "/tekstil-a"
  }
}
```

**Create tenant response (201):**
```json
{
  "uuid": "550e8400-e29b-41d4-a716-446655440000",
  "alias": "tekstil-a",
  "db_name": "b2b_tenant_tekstil_a_db",
  "status": "active",
  "provisioned_at": "2026-08-12T10:00:00Z"
}
```

---

## Tenant API (requires tenant context)

Prefix: `/api/{alias}/` or tenant subdomain.

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Tenant user login |
| POST | `/auth/logout` | Revoke token |
| GET | `/auth/me` | Current user + role |

---

### Catalog — Categories

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | `/categories` | all | Tree or flat list |
| GET | `/categories/{id}` | all | Single category |
| POST | `/categories` | admin | Create |
| PATCH | `/categories/{id}` | admin | Update |
| DELETE | `/categories/{id}` | admin | Soft delete |

---

### Catalog — Products

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | `/products` | all | List with filters & facets |
| GET | `/products/{uuid}` | all | Detail + images + specs |
| POST | `/products` | admin | Create |
| PATCH | `/products/{uuid}` | admin | Update |
| DELETE | `/products/{uuid}` | admin | Deactivate |
| POST | `/products/{uuid}/enrich` | admin | Queue enrichment job |

**List products query params:**
```
?category_id=5
&filters[brand]=Bosch,Philips
&filters[power_watt_min]=1000
&filters[power_watt_max]=1500
&filters[in_stock]=1
&search=OEM12345
&page=1
&per_page=24
```

**List products response:**
```json
{
  "data": [
    {
      "uuid": "...",
      "sku": "PMP-1500",
      "name": "Water Pump 1500W",
      "base_price": "1250.0000",
      "attributes_json": { "general": { "brand": "Bosch" } },
      "thumbnail_url": "..."
    }
  ],
  "meta": { "current_page": 1, "total": 142 },
  "facets": {
    "brand": [{ "value": "Bosch", "count": 42 }, { "value": "Philips", "count": 18 }],
    "power_watt": { "min": 500, "max": 3000 }
  }
}
```

---

### Filter configuration (admin)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/filterable-attributes?category_id=` | List filters for category |
| POST | `/admin/filterable-attributes` | Create filter rule |
| PATCH | `/admin/filterable-attributes/{id}` | Update |
| DELETE | `/admin/filterable-attributes/{id}` | Remove |

---

### Stock

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | `/stocks?product_id=&warehouse_id=` | admin, warehouse | Stock levels |
| POST | `/stocks/inbound` | warehouse | QR/manual inbound |
| POST | `/stocks/transfer` | warehouse | Inter-warehouse move |
| POST | `/stocks/adjust` | admin | Manual adjustment |
| GET | `/pick-lists/{order_uuid}` | warehouse | Picking list |
| POST | `/pick-lists/{order_uuid}/verify` | warehouse | QR verify line |

**Inbound request:**
```json
{
  "product_uuid": "...",
  "warehouse_id": 1,
  "location_code": "A-01-03",
  "quantity": 50,
  "lot_number": null,
  "scan_source": "qr"
}
```

---

### Orders

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | `/orders` | admin, dealer, plasiyer | List (scoped by role) |
| POST | `/orders` | dealer, plasiyer | Create order |
| GET | `/orders/{uuid}` | scoped | Detail |
| PATCH | `/orders/{uuid}/status` | admin | Status transitions |
| POST | `/orders/{uuid}/submit` | dealer | Submit draft |

**Create order (apparel matrix example):**
```json
{
  "dealer_id": 12,
  "lines": [
    {
      "product_uuid": "...",
      "sector_line_json": {
        "matrix": {
          "S": { "red": 10, "blue": 5 },
          "M": { "red": 20, "blue": 8 }
        }
      }
    }
  ]
}
```

---

### Pricing & dealers

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| GET | `/dealers/me/turnover` | dealer | Progress toward next tier |
| GET | `/admin/discount-tiers` | admin | List tiers |
| POST | `/admin/discount-tiers` | admin | Create tier |
| PATCH | `/admin/dealers/{id}/tier` | admin | Manual tier assign |

**Turnover response:**
```json
{
  "current_tier": { "name": "Silver", "discount_percent": 5 },
  "next_tier": { "name": "Gold", "discount_percent": 8, "turnover_threshold": 500000 },
  "current_turnover": 385000,
  "remaining_to_next": 115000,
  "period_months": 12
}
```

---

### Bulk import/export

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| POST | `/imports/preview` | admin | Upload XLS → validation preview |
| POST | `/imports/confirm` | admin | Confirm preview → queue job |
| GET | `/imports/{job_id}` | admin | Job status |
| POST | `/exports/products` | admin | Request export → queue job |
| GET | `/exports/{job_id}/download` | admin | Signed download URL |

**Preview response:**
```json
{
  "total_rows": 492,
  "valid_rows": 480,
  "invalid_rows": 12,
  "errors": [
    { "row": 14, "column": "sku", "message": "Duplicate SKU PMP-001" },
    { "row": 27, "column": "base_price", "message": "Must be numeric" }
  ],
  "preview_token": "eyJ..."
}
```

---

### Notifications

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/notifications/fcm/register` | Register device token |
| DELETE | `/notifications/fcm/{token}` | Unregister |

---

## HTTP status codes

| Code | Usage |
|------|-------|
| 200 | Success |
| 201 | Created (tenant, product, order) |
| 202 | Accepted (async job queued) |
| 401 | Unauthenticated |
| 403 | Forbidden (role/tenant) |
| 404 | Not found |
| 422 | Validation error |
| 429 | Rate limited (scraper, login) |
| 500 | Server error |

---

## Rate limits (planned)

| Endpoint group | Limit |
|----------------|-------|
| Auth login | 5/min per IP |
| Product list | 120/min per user |
| Import preview | 10/hour per tenant |
| Scraper enrich | 50/day per tenant |

---

## Versioning

- MVP: no URL version prefix  
- Post-v1: `/api/v2/...` when breaking changes required

---

## Scribe documentation

Auto-generated at `http://localhost:8080/docs` (Scalar theme).  
OpenAPI export: `storage/app/scribe/openapi.yaml`
