# Database Schema Reference

Complete table definitions for **Trunçgil Commerce OS**. Migrations live in:
- `apps/backend/database/migrations/system/` — platform DB (`b2b_system_db`)
- `apps/backend/database/migrations/tenant/` — per-tenant DB (`b2b_tenant_{alias}_db`)

---

## System database (`b2b_system_db`)

### `tenants`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `uuid` | CHAR(36) UNIQUE | Public identifier |
| `alias` | VARCHAR(64) UNIQUE | URL slug, e.g. `tekstil-a` |
| `name` | VARCHAR(255) | Display name |
| `db_name` | VARCHAR(128) | e.g. `b2b_tenant_tekstil_a_db` |
| `sector` | ENUM | `apparel`, `automotive`, `fmcg`, `building`, `electronics` |
| `status` | ENUM | `provisioning`, `active`, `suspended`, `archived` |
| `provisioned_at` | TIMESTAMP NULL | |
| `created_at` | TIMESTAMP | |
| `updated_at` | TIMESTAMP | |

**Indexes:** `alias`, `status`, `sector`

---

### `tenant_domains`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `tenant_id` | FK → tenants | CASCADE delete |
| `type` | ENUM | `path`, `subdomain`, `custom` |
| `host` | VARCHAR(255) NULL | e.g. `firma-a.b2b.truncgil.com` |
| `path_prefix` | VARCHAR(64) NULL | e.g. `/firma-a` |
| `is_primary` | BOOLEAN | Default false |
| `created_at` | TIMESTAMP | |

---

### `root_users`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `name` | VARCHAR(255) | |
| `email` | VARCHAR(255) UNIQUE | |
| `password` | VARCHAR(255) | Hashed |
| `is_active` | BOOLEAN | Default true |
| `last_login_at` | TIMESTAMP NULL | |
| `created_at` | TIMESTAMP | |
| `updated_at` | TIMESTAMP | |

---

### `subscriptions`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `tenant_id` | FK → tenants | |
| `plan` | VARCHAR(64) | e.g. `starter`, `pro`, `enterprise` |
| `max_users` | INT UNSIGNED | |
| `max_products` | INT UNSIGNED | |
| `starts_at` | DATE | |
| `ends_at` | DATE NULL | |
| `created_at` | TIMESTAMP | |

---

### `system_audit_logs`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `actor_type` | VARCHAR(64) | `root_user`, `system` |
| `actor_id` | BIGINT UNSIGNED NULL | |
| `tenant_id` | FK NULL | |
| `action` | VARCHAR(128) | e.g. `tenant.provisioned` |
| `payload` | JSON | |
| `ip_address` | VARCHAR(45) NULL | |
| `created_at` | TIMESTAMP | |

---

## Tenant database (`b2b_tenant_{alias}_db`)

### `users`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `name` | VARCHAR(255) | |
| `email` | VARCHAR(255) UNIQUE | |
| `password` | VARCHAR(255) | |
| `role` | ENUM | `admin`, `dealer`, `supplier`, `plasiyer`, `warehouse` |
| `dealer_id` | FK NULL → dealers | When role = dealer |
| `supplier_id` | FK NULL → suppliers | When role = supplier |
| `is_active` | BOOLEAN | |
| `created_at` | TIMESTAMP | |
| `updated_at` | TIMESTAMP | |

---

### `categories`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `parent_id` | FK NULL → categories | Self-reference |
| `name` | VARCHAR(255) | |
| `slug` | VARCHAR(255) | Unique per tenant |
| `path` | VARCHAR(1024) | e.g. `/giyim/erkek/tisort` |
| `depth` | TINYINT UNSIGNED | 0 = root |
| `icon_url` | VARCHAR(512) NULL | |
| `sort_order` | INT | Default 0 |
| `is_active` | BOOLEAN | |
| `created_at` | TIMESTAMP | |
| `updated_at` | TIMESTAMP | |

**Indexes:** `parent_id`, `path`(255), `slug`

---

### `products`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `uuid` | CHAR(36) UNIQUE | |
| `category_id` | FK → categories | |
| `sku` | VARCHAR(128) UNIQUE | |
| `barcode` | VARCHAR(32) NULL | EAN-13 |
| `oem_code` | VARCHAR(128) NULL | Automotive |
| `name` | VARCHAR(512) | |
| `description` | TEXT NULL | |
| `base_price` | DECIMAL(15,4) | |
| `currency` | CHAR(3) | Default `TRY` |
| `attributes_json` | JSON | See implementation plan §5 |
| `brand_virtual` | VARCHAR(128) GENERATED | `JSON_UNQUOTE(JSON_EXTRACT(...))` |
| `power_watt_virtual` | INT GENERATED NULL | For filter index |
| `is_active` | BOOLEAN | |
| `enrichment_status` | ENUM | `none`, `pending`, `done`, `failed` |
| `created_at` | TIMESTAMP | |
| `updated_at` | TIMESTAMP | |

**Indexes:** `category_id`, `sku`, `barcode`, `oem_code`, `brand_virtual`, `power_watt_virtual`

---

### `product_images`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `product_id` | FK → products | |
| `url` | VARCHAR(1024) | |
| `thumbnail_url` | VARCHAR(1024) NULL | |
| `source` | ENUM | `upload`, `scraper`, `import` |
| `sort_order` | INT | |
| `created_at` | TIMESTAMP | |

---

### `filterable_attributes`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `category_id` | FK → categories | |
| `attribute_key` | VARCHAR(128) | JSON path key |
| `label` | VARCHAR(255) | Display label |
| `filter_type` | ENUM | `multi_select`, `range`, `boolean`, `text` |
| `json_path` | VARCHAR(512) | e.g. `$.technical_specs.power_watt` |
| `sort_order` | INT | |
| `is_active` | BOOLEAN | |

---

### `warehouses`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `code` | VARCHAR(32) UNIQUE | |
| `name` | VARCHAR(255) | |
| `address` | TEXT NULL | |
| `is_active` | BOOLEAN | |

---

### `stocks`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `product_id` | FK → products | |
| `warehouse_id` | FK → warehouses | |
| `location_code` | VARCHAR(64) NULL | Shelf/bin |
| `quantity_on_hand` | DECIMAL(15,4) | |
| `quantity_reserved` | DECIMAL(15,4) | |
| `lot_number` | VARCHAR(64) NULL | FMCG |
| `expires_at` | DATE NULL | FMCG |
| `updated_at` | TIMESTAMP | |

**Unique:** `(product_id, warehouse_id, location_code, lot_number)`

---

### `stock_movements`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `stock_id` | FK → stocks | |
| `type` | ENUM | `inbound`, `outbound`, `transfer`, `adjustment`, `reservation`, `release` |
| `quantity` | DECIMAL(15,4) | Signed |
| `reference_type` | VARCHAR(64) NULL | `order`, `transfer`, `qr_scan` |
| `reference_id` | BIGINT UNSIGNED NULL | |
| `performed_by` | FK → users | |
| `notes` | TEXT NULL | |
| `created_at` | TIMESTAMP | |

---

### `stock_reservations`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `order_id` | FK → orders | |
| `stock_id` | FK → stocks | |
| `quantity` | DECIMAL(15,4) | |
| `expires_at` | TIMESTAMP | |
| `status` | ENUM | `active`, `released`, `fulfilled` |

---

### `dealers`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `code` | VARCHAR(32) UNIQUE | |
| `name` | VARCHAR(255) | |
| `tax_number` | VARCHAR(32) NULL | |
| `credit_limit` | DECIMAL(15,4) | |
| `current_balance` | DECIMAL(15,4) | |
| `discount_tier_id` | FK NULL → customer_discount_tiers | |
| `plasiyer_user_id` | FK NULL → users | Assigned rep |
| `is_active` | BOOLEAN | |

---

### `customer_discount_tiers`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `name` | VARCHAR(64) | e.g. Bronze, Silver, Gold |
| `discount_percent` | DECIMAL(5,2) | |
| `turnover_threshold` | DECIMAL(15,4) | Rolling period minimum |
| `period_months` | TINYINT | Default 12 |
| `sort_order` | INT | |

---

### `customer_turnover_logs`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `dealer_id` | FK → dealers | |
| `order_id` | FK → orders | |
| `amount` | DECIMAL(15,4) | Delivered amount |
| `period_key` | CHAR(7) | e.g. `2026-08` |
| `created_at` | TIMESTAMP | |

---

### `suppliers`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `code` | VARCHAR(32) UNIQUE | |
| `name` | VARCHAR(255) | |
| `contact_email` | VARCHAR(255) NULL | |
| `is_consignment` | BOOLEAN | |
| `is_active` | BOOLEAN | |

---

### `orders`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `uuid` | CHAR(36) UNIQUE | |
| `dealer_id` | FK → dealers | |
| `created_by_user_id` | FK → users | |
| `status` | ENUM | `draft`, `submitted`, `confirmed`, `picking`, `shipped`, `delivered`, `cancelled` |
| `sector_payload_json` | JSON NULL | Matrix grid, fitment, lot selections |
| `subtotal` | DECIMAL(15,4) | |
| `discount_amount` | DECIMAL(15,4) | |
| `total` | DECIMAL(15,4) | |
| `delivered_at` | TIMESTAMP NULL | Triggers turnover |
| `created_at` | TIMESTAMP | |
| `updated_at` | TIMESTAMP | |

---

### `order_lines`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `order_id` | FK → orders | |
| `product_id` | FK → products | |
| `quantity` | DECIMAL(15,4) | |
| `unit_price` | DECIMAL(15,4) | |
| `line_total` | DECIMAL(15,4) | |
| `sector_line_json` | JSON NULL | Size/color, lot, dimensions |

---

### `user_fcm_tokens`

| Column | Type | Notes |
|--------|------|-------|
| `id` | BIGINT UNSIGNED PK | |
| `user_id` | FK → users | |
| `token` | VARCHAR(512) | |
| `platform` | ENUM | `ios`, `android`, `web` |
| `created_at` | TIMESTAMP | |
| `updated_at` | TIMESTAMP | |

**Unique:** `(user_id, token)`

---

## Entity relationship (tenant DB)

```
categories ──< products ──< product_images
     │              │
     │              ├──< stocks ──< stock_movements
     │              │       └──< stock_reservations >── orders
     └──< filterable_attributes

dealers ──< orders ──< order_lines >── products
   │
   └── customer_discount_tiers

suppliers ──< (consignment stocks via stocks.supplier_id — optional extension)

users ──< user_fcm_tokens
```

---

## Migration naming convention

```
YYYY_MM_DD_HHMMSS_create_{table}_table.php
```

Examples:
- `2026_08_12_100000_create_tenants_table.php` (system)
- `2026_08_20_100000_create_products_table.php` (tenant)

---

## Seeder order (tenant)

1. `TenantBaseSeeder` — roles, default warehouse, UoM list, notification settings  
2. `SectorProfileSeeder` — sector-specific attribute templates  
3. `DemoCatalogSeeder` — optional dev data (never in production provision)
