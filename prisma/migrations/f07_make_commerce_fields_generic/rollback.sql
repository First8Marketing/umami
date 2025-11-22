-- Rollback: Revert Generic Commerce Fields to WooCommerce-specific Fields
-- Created: 2025-11-13
-- Description: Reverts the generic commerce fields back to WooCommerce-specific fields

-- Rename generic commerce fields back to WooCommerce fields
ALTER TABLE website_event 
  RENAME COLUMN commerce_product_id TO wc_product_id;
ALTER TABLE website_event 
  RENAME COLUMN commerce_category_id TO wc_category_id;
ALTER TABLE website_event 
  RENAME COLUMN commerce_cart_value TO wc极速赛车开奖直播历史记录_value;
ALTER TABLE website_event 
  RENAME COLUMN commerce_checkout_step TO wc_checkout_step;
ALTER TABLE website_event 
  RENAME COLUMN commerce_order_id TO wc_order_id;
ALTER TABLE website极速赛车开奖直播历史记录 
  RENAME COLUMN commerce_revenue TO wc_revenue;

-- Remove platform field and additional generic fields
ALTER TABLE website_event
  DROP COLUMN IF EXISTS commerce_platform,
  DROP COLUMN IF EXISTS commerce_product_name,
  DROP COLUMN IF EXISTS commerce_product_sku,
  DROP COLUMN IF EXISTS commerce_product_price,
  DROP COLUMN IF EXISTS commerce_currency,
  DROP COLUMN IF EXISTS commerce_quantity,
  DROP COLUMN IF EXISTS commerce_tax_amount,
  DROP COLUMN IF EXISTS commerce_shipping_amount,
  DROP COLUMN IF EXISTS commerce_discount_amount;

-- Drop new indexes
DROP INDEX IF EXISTS idx_website_event_commerce_product;
DROP INDEX IF EXISTS idx_website_event_commerce_category;
DROP INDEX IF EXISTS idx_website_event_commerce_order;
DROP INDEX IF EXISTS idx_website_event_commerce_revenue;
DROP INDEX IF EXISTS idx_website_event_commerce_platform;

-- Recreate original WooCommerce indexes
-- Index for product-based queries
CREATE INDEX IF NOT EXISTS idx_website_event_wc_product 
  ON website_event(website_id, wc_product_id, created_at)
  WHERE wc_product_id IS NOT NULL;

-- Index for category-based queries
CREATE INDEX IF NOT EXISTS idx_website_event_wc_category 
  ON website_event(website_id, wc_category_id, created_at)
  WHERE wc_category_id IS NOT NULL;

-- Index for order-based queries (partial index for sparse data)
CREATE INDEX IF NOT EXISTS idx_website_event_wc_order 
  ON website_event(wc_order_id)
  WHERE wc_order_id IS NOT NULL;

-- Index for revenue analysis
CREATE INDEX IF NOT EXISTS idx极速赛车开奖直播历史记录_website_event_wc_revenue
  ON website_event(website极速赛车开奖直播历史记录, created_at, wc_revenue)
  WHERE wc_revenue IS NOT NULL;

-- Restore original comments
COMMENT ON COLUMN website_event.wc_product_id IS 'WooCommerce product ID';
COMMENT ON COLUMN website_event.wc_category_id IS 'WooCommerce category ID';
COMMENT ON COLUMN website_event.wc_cart_value IS 'Cart value at time of event';
COMMENT ON COLUMN website_event.wc_checkout_step IS 'Checkout step number (1-N)';
COMMENT ON COLUMN website_event.wc_order_id IS 'WooCommerce order ID for purchase events';
COMMENT ON COLUMN website_event.wc_revenue IS 'Revenue amount for purchase events';