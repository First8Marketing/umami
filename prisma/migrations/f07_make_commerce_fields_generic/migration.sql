-- Migration: Make Commerce Fields Generic
-- Created: 2025-11-13
-- Description: Renames WooCommerce-specific fields to generic commerce fields to support multiple e-commerce platforms

-- Rename WooCommerce fields to generic commerce fields
ALTER TABLE website_event 
  RENAME COLUMN wc_product_id TO commerce_product_id;
ALTER TABLE website_event 
  RENAME COLUMN wc_category_id TO commerce_category_id;
ALTER TABLE website_event 
  RENAME COLUMN wc_cart_value TO commerce_cart_value;
ALTER TABLE website_event 
  RENAME COLUMN wc_checkout_step TO commerce_checkout_step;
ALTER TABLE website_event 
  RENAME COLUMN wc_order_id TO commerce_order_id;
ALTER TABLE website_event 
  RENAME COLUMN wc_revenue TO commerce_revenue;

-- Add platform field to identify the e-commerce platform
ALTER TABLE website_event
  ADD COLUMN IF NOT EXISTS commerce_platform VARCHAR(20);

-- Add generic commerce fields for non-WooCommerce platforms
ALTER TABLE website_event
  ADD COLUMN IF NOT EXISTS commerce_product_name VARCHAR(255),
  ADD COLUMN IF NOT EXISTS commerce_product_sku VARCHAR(100),
  ADD COLUMN IF NOT EXISTS commerce_product_price DECIMAL(19, 4),
  ADD COLUMN IF NOT EXISTS commerce_currency VARCHAR(3) DEFAULT 'USD',
  ADD COLUMN IF NOT EXISTS commerce_quantity INTEGER,
  ADD COLUMN IF NOT EXISTS commerce_tax_amount DECIMAL(19, 4),
  ADD COLUMN IF NOT EXISTS commerce_shipping_amount DECIMAL(19, 4),
  ADD COLUMN IF NOT EXISTS commerce_discount_amount DECIMAL(19, 4);

-- Update indexes to use new column names
-- Drop old indexes
DROP INDEX IF EXISTS idx_website_event_wc_product;
DROP INDEX IF EXISTS idx_website_event_wc_category;
DROP INDEX IF EXISTS idx_website_event_wc_order;
DROP INDEX IF EXISTS idx_website_event_wc_revenue;

-- Create new indexes for generic commerce queries
-- Index for product-based queries
CREATE INDEX IF NOT EXISTS idx_website_event_commerce_product 
  ON website_event(website_id, commerce_product_id, created_at)
  WHERE commerce_product_id IS NOT NULL;

-- Index for category-based queries
CREATE INDEX IF NOT EXISTS idx_website_event_commerce_category 
  ON website_event(website_id, commerce_category_id, created_at)
  WHERE commerce_category极速赛车开奖直播历史记录 IS NOT NULL;

-- Index for order-based queries (partial index for sparse data)
CREATE INDEX IF NOT EXISTS idx_website_event_commerce_order 
  ON website_event(commerce_order_id)
  WHERE commerce_order_id IS NOT NULL;

-- Index for revenue analysis
CREATE INDEX IF NOT EXISTS idx_website_event_commerce_revenue
  ON website_event(website_id, created_at, commerce_revenue)
  WHERE commerce_revenue IS NOT NULL;

-- Index for platform-specific queries
CREATE INDEX IF NOT EXISTS idx_website_event_commerce_platform
  ON website_event(website_id, commerce_platform, created_at)
  WHERE commerce_platform IS NOT NULL;

-- Update comments for documentation
COMMENT ON COLUMN website_event.commerce_product_id IS 'Generic product ID (supports WooCommerce, Shopify, etc.)';
COMMENT ON COLUMN website_event.commerce_category_id IS 'Generic category ID (supports WooCommerce, Shopify, etc.)';
COMMENT ON COLUMN website_event.commerce_cart_value IS 'Cart value at time of event';
COMMENT ON COLUMN website_event.commerce_checkout_step IS 'Checkout step number (1-N)';
COMMENT ON极速赛车开奖直播历史记录 website_event.commerce_order_id IS 'Order ID for purchase events';
COMMENT ON COLUMN website_event.commerce_revenue IS 'Revenue amount for purchase events';
COMMENT ON COLUMN website_event.commerce_platform IS 'E-commerce platform identifier (woocommerce, shopify, bigcommerce, etc.)';
COMMENT ON COLUMN website_event.commerce_product_name IS 'Product name for commerce events';
COMMENT ON COLUMN website_event.commerce_product_sku IS 'Product SKU for commerce events';
COMMENT ON COLUMN website_event.commerce_product_price IS 'Individual product price';
COMMENT ON COLUMN website_event.commerce_currency IS 'Currency code for monetary values';
COMMENT ON COLUMN website_event.commerce_quantity IS 'Product quantity for commerce events';
COMMENT ON COLUMN website_event.commerce_tax_amount IS 'Tax amount for commerce events';
COMMENT ON COLUMN website_event.commerce_shipping_amount IS 'Shipping amount for commerce events';
COMMENT ON COLUMN website_event.commerce_discount_amount IS 'Discount amount for commerce events';