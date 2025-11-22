-- Migration: Generate Comprehensive Mock Analytics Data for 3 Years
-- This migration creates realistic mock data spanning 3 years for the first8marketing-umami analytics platform

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Function to generate random dates within a range
CREATE OR REPLACE FUNCTION random_date(start_date TIMESTAMP, end_date TIMESTAMP)
RETURNS TIMESTAMP AS $$
BEGIN
    RETURN start_date + random() * (end_date - start_date);
END;
$$ LANGUAGE plpgsql;

-- Function to generate random string of specified length
CREATE OR REPLACE FUNCTION random_string(length INTEGER)
RETURNS TEXT AS $$
DECLARE
    chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    result TEXT := '';
    i INTEGER := 0;
BEGIN
    FOR i IN 1..length LOOP
        result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to generate random country code
CREATE OR REPLACE FUNCTION random_country()
RETURNS CHAR(2) AS $$
DECLARE
    countries CHAR(2)[] := ARRAY['US', 'GB', 'DE', 'FR', 'CA', 'AU', 'JP', 'BR', 'IN', 'CN', 'RU', 'MX', 'IT', 'ES', 'KR', 'NL', 'SE', 'NO', 'DK', 'FI'];
BEGIN
    RETURN countries[floor(random() * array_length(countries, 1) + 1)];
END;
$$ LANGUAGE plpgsql;

-- Function to generate random browser
CREATE OR REPLACE FUNCTION random_browser()
RETURNS VARCHAR(20) AS $$
DECLARE
    browsers VARCHAR(20)[] := ARRAY['Chrome', 'Firefox', 'Safari', 'Edge', 'Opera', 'Brave', 'Internet Explorer'];
BEGIN
    RETURN browsers[floor(random() * array_length(browsers, 1) + 1)];
END;
$$ LANGUAGE plpgsql;

-- Function to generate random OS
CREATE OR REPLACE FUNCTION random_os()
RETURNS VARCHAR(20) AS $$
DECLARE
    os_list VARCHAR(20)[] := ARRAY['Windows', 'macOS', 'Linux', 'iOS', 'Android', 'Chrome OS'];
BEGIN
    RETURN os_list[floor(random() * array_length(os_list, 1) + 1)];
END;
$$ LANGUAGE plpgsql;

-- Function to generate random device
CREATE OR REPLACE FUNCTION random_device()
RETURNS VARCHAR(20) AS $$
DECLARE
    devices VARCHAR(20)[] := ARRAY['desktop', 'mobile', 'tablet'];
BEGIN
    RETURN devices[floor(random() * array_length(devices, 1) + 1)];
END;
$$ LANGUAGE plpgsql;

-- Function to generate random screen resolution
CREATE OR REPLACE FUNCTION random_screen()
RETURNS VARCHAR(11) AS $$
DECLARE
    screens VARCHAR(11)[] := ARRAY['1920x1080', '1366x768', '1536x864', '1440x900', '1280x720', '1600x900', '2560x1440', '3840x2160', '750x1334', '1080x1920'];
BEGIN
    RETURN screens[floor(random() * array_length(screens, 1) + 1)];
END;
$$ LANGUAGE plpgsql;

-- Function to generate random language
CREATE OR REPLACE FUNCTION random_language()
RETURNS VARCHAR(35) AS $$
DECLARE
    languages VARCHAR(35)[] := ARRAY['en-US', 'en-GB', 'de-DE', 'fr-FR', 'es-ES', 'pt-BR', 'ru-RU', 'ja-JP', 'zh-CN', 'ko-KR', 'it-IT', 'nl-NL', 'sv-SE', 'no-NO', 'da-DK', 'fi-FI', 'pl-PL', 'tr-TR', 'ar-SA', 'hi-IN'];
BEGIN
    RETURN languages[floor(random() * array_length(languages, 1) + 1)];
END;
$$ LANGUAGE plpgsql;

-- Function to generate random city based on country
CREATE OR REPLACE FUNCTION random_city(country_code CHAR(2))
RETURNS VARCHAR(50) AS $$
BEGIN
    CASE country_code
        WHEN 'US' THEN RETURN (ARRAY['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose'])[floor(random() * 10 + 1)];
        WHEN 'GB' THEN RETURN (ARRAY['London', 'Manchester', 'Birmingham', 'Glasgow', 'Liverpool', 'Bristol', 'Sheffield', 'Leeds', 'Edinburgh', 'Cardiff'])[floor(random() * 10 + 1)];
        WHEN 'DE' THEN RETURN (ARRAY['Berlin', 'Hamburg', 'Munich', 'Cologne', 'Frankfurt', 'Stuttgart', 'Düsseldorf', 'Dortmund', 'Essen', 'Leipzig'])[floor(random() * 10 + 1)];
        WHEN 'FR' THEN RETURN (ARRAY['Paris', 'Marseille', 'Lyon', 'Toulouse', 'Nice', 'Nantes', 'Strasbourg', 'Montpellier', 'Bordeaux', 'Lille'])[floor(random() * 10 + 1)];
        WHEN 'CA' THEN RETURN (ARRAY['Toronto', 'Montreal', 'Vancouver', 'Calgary', 'Edmonton', 'Ottawa', 'Winnipeg', 'Quebec City', 'Hamilton', 'Kitchener'])[floor(random() * 10 + 1)];
        ELSE RETURN 'Unknown';
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- Function to generate random region based on country
CREATE OR REPLACE FUNCTION random_region(country_code CHAR(2))
RETURNS VARCHAR(20) AS $$
BEGIN
    CASE country_code
        WHEN 'US' THEN RETURN (ARRAY['California', 'Texas', 'Florida', 'New York', 'Pennsylvania', 'Illinois', 'Ohio', 'Georgia', 'North Carolina', 'Michigan'])[floor(random() * 10 + 1)];
        WHEN 'GB' THEN RETURN (ARRAY['England', 'Scotland', 'Wales', 'Northern Ireland'])[floor(random() * 4 + 1)];
        WHEN 'DE' THEN RETURN (ARRAY['Bavaria', 'Baden-Württemberg', 'North Rhine-Westphalia', 'Lower Saxony', 'Hesse', 'Saxony', 'Rhineland-Palatinate', 'Berlin', 'Schleswig-Holstein', 'Brandenburg'])[floor(random() * 10 + 1)];
        WHEN 'FR' THEN RETURN (ARRAY['Île-de-France', 'Auvergne-Rhône-Alpes', 'Nouvelle-Aquitaine', 'Occitanie', 'Hauts-de-France', 'Provence-Alpes-Côte d''Azur', 'Pays de la Loire', 'Normandy', 'Grand Est', 'Brittany'])[floor(random() * 10 + 1)];
        WHEN 'CA' THEN RETURN (ARRAY['Ontario', 'Quebec', 'British Columbia', 'Alberta', 'Manitoba', 'Saskatchewan', 'Nova Scotia', 'New Brunswick', 'Newfoundland and Labrador', 'Prince Edward Island'])[floor(random() * 10 + 1)];
        ELSE RETURN 'Unknown';
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- Function to generate random URL path
CREATE OR REPLACE FUNCTION random_url_path()
RETURNS VARCHAR(500) AS $$
DECLARE
    paths VARCHAR(500)[] := ARRAY[
        '/', '/about', '/contact', '/products', '/services', '/blog', '/blog/post-1', 
        '/blog/post-2', '/pricing', '/features', '/docs', '/support', '/login', 
        '/register', '/dashboard', '/settings', '/checkout', '/cart', '/product/123', 
        '/product/a456', '/product/b789', '/category/electronics', '/category/books', 
        '/category/clothing', '/search', '/search?q=test', '/user/profile', 
        '/admin', '/api/docs', '/download', '/faq', '/terms', '/privacy'
    ];
BEGIN
    RETURN paths[floor(random() * array_length(paths, 1) + 1)];
END;
$$ LANGUAGE plpgsql;

-- Function to generate random referrer domain
CREATE OR REPLACE FUNCTION random_referrer_domain()
RETURNS VARCHAR(500) AS $$
DECLARE
    domains VARCHAR(500)[] := ARRAY[
        'google.com', 'facebook.com', 'twitter.com', 'linkedin.com', 'instagram.com',
        'youtube.com', 'reddit.com', 'pinterest.com', 'tumblr.com', 'github.com',
        'stackoverflow.com', 'medium.com', 'quora.com', 'yahoo.com', 'bing.com',
        'duckduckgo.com', 'amazon.com', 'ebay.com', 'wikipedia.org', 'nytimes.com'
    ];
BEGIN
    RETURN domains[floor(random() * array_length(domains, 1) + 1)];
END;
$$ LANGUAGE plpgsql;

-- Function to generate random event name
CREATE OR REPLACE FUNCTION random_event_name()
RETURNS VARCHAR(50) AS $$
DECLARE
    events VARCHAR(50)[] := ARRAY[
        'pageview', 'click', 'form_submit', 'download', 'video_play', 'scroll',
        'add_to_cart', 'remove_from_cart', 'checkout_start', 'purchase', 
        'sign_up', 'login', 'logout', 'search', 'share', 'comment', 'like',
        'product_view', 'category_view', 'wishlist_add', 'newsletter_subscribe',
        'contact_form', 'demo_request', 'trial_signup', 'upgrade', 'downgrade'
    ];
BEGIN
    RETURN events[floor(random() * array_length(events, 1) + 1)];
END;
$$ LANGUAGE plpgsql;

-- Function to generate random page title
CREATE OR REPLACE FUNCTION random_page_title()
RETURNS VARCHAR(500) AS $$
DECLARE
    titles VARCHAR(500)[] := ARRAY[
        'Home Page - First8 Marketing', 'About Us - First8 Marketing', 
        'Our Products - First8 Marketing', 'Services Overview - First8 Marketing',
        'Blog - First8 Marketing Insights', 'Contact Us - First8 Marketing',
        'Pricing Plans - First8 Marketing', 'Features - First8 Marketing',
        'Documentation - First8 Marketing', 'Support Center - First8 Marketing',
        'Login - First8 Marketing', 'Register - First8 Marketing',
        'Dashboard - First8 Marketing', 'Settings - First8 Marketing',
        'Checkout - First8 Marketing', 'Shopping Cart - First8 Marketing',
        'Product Details - First8 Marketing', 'Category View - First8 Marketing',
        'Search Results - First8 Marketing', 'User Profile - First8 Marketing',
        'Admin Panel - First8 Marketing', 'API Documentation - First8 Marketing',
        'Download Center - First8 Marketing', 'FAQ - First8 Marketing',
        'Terms of Service - First8 Marketing', 'Privacy Policy - First8 Marketing'
    ];
BEGIN
    RETURN titles[floor(random() * array_length(titles, 1) + 1)];
END;
$$ LANGUAGE plpgsql;

-- Function to generate random UTM parameters
CREATE OR REPLACE FUNCTION random_utm_param()
RETURNS VARCHAR(255) AS $$
DECLARE
    campaigns VARCHAR(255)[] := ARRAY[
        'spring_sale_2023', 'summer_promo_2023', 'fall_campaign_2023', 
        'winter_special_2023', 'black_friday_2023', 'cyber_monday_2023',
        'christmas_sale_2023', 'new_year_2024', 'valentines_day_2024',
        'spring_launch_2024', 'summer_bonanza_2024', 'back_to_school_2024',
        'halloween_special_2024', 'thanksgiving_2024', 'holiday_season_2024'
    ];
    sources VARCHAR(255)[] := ARRAY['google', 'facebook', 'twitter', 'linkedin', 'instagram', 'email', 'newsletter', 'direct', 'organic', 'referral'];
    mediums VARCHAR(255)[] := ARRAY['cpc', 'organic', 'email', 'social', 'display', 'affiliate', 'referral'];
    contents VARCHAR(255)[] := ARRAY['banner_ad', 'text_ad', 'email_1', 'email_2', 'social_post', 'blog_post', 'landing_page'];
    terms VARCHAR(255)[] := ARRAY['marketing+analytics', 'web+analytics', 'seo+tools', 'digital+marketing', 'saas+platform'];
BEGIN
    RETURN campaigns[floor(random() * array_length(campaigns, 1) + 1)];
END;
$$ LANGUAGE plpgsql;

-- Create temporary tables for data generation
CREATE TEMPORARY TABLE temp_websites AS
SELECT 
    website_id,
    name,
    FROM website
    LIMIT 5;

-- If no websites exist, create some sample websites
DO $$
DECLARE
    website_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO website_count FROM website;
    
    IF website_count = 0 THEN
        INSERT INTO website (website_id, name, domain, share_id, user_id, created_at, updated_at)
        VALUES 
            (gen_random_uuid(), 'First8 Marketing Main Site', 'first8marketing.com', 'main_site', NULL, NOW(), NOW()),
            (gen_random_uuid(), 'First8 Blog', 'blog.first8marketing.com', 'blog_site', NULL, NOW(), NOW()),
            (gen_random_uuid(), 'First8 E-commerce', 'shop.first8marketing.com', 'shop_site', NULL, NOW(), NOW()),
            (gen_random_uuid(), 'First8 Documentation', 'docs.first8marketing.com', 'docs_site', NULL, NOW(), NOW()),
            (gen_random_uuid(), 'First8 Support', 'support.first8marketing.com', 'support_site', NULL, NOW(), NOW());
    END IF;
END $$;

-- Refresh temporary websites table
DROP TABLE IF EXISTS temp_websites;
CREATE TEMPORARY TABLE temp_websites AS
SELECT website_id, name FROM website LIMIT 5;

-- Generate sessions for 3 years (2023-2025)
INSERT INTO session (session_id, website_id, browser, os, device, screen, language, country, region, city, created_at, distinct_id, user_id)
SELECT
    gen_random_uuid(),
    website_id,
    random_browser(),
    random_os(),
    random_device(),
    random_screen(),
    random_language(),
    random_country(),
    random_region(random_country()),
    random_city(random_country()),
    random_date('2023-01-01 00:00:00'::TIMESTAMP, '2025-12-31 23:59:59'::TIMESTAMP),
    random_string(16),
    CASE WHEN random() < 0.3 THEN random_string(36) ELSE NULL END
FROM
    temp_websites,
    generate_series(1, 50000) -- 50,000 sessions per website
ON CONFLICT DO NOTHING;

-- Generate website events
INSERT INTO website_event (
    event_id, website_id, session_id, created_at, url_path, url_query, 
    referrer_path, referrer_query, referrer_domain, page_title, 
    event_type, event_name, visit_id, tag, 
    fbclid, gclid, lifatid, msclkid, ttclid, twclid,
    utm_campaign, utm_content, utm_medium, utm_source, utm_term,
    hostname, scroll_depth, time_on_page, click_count,
    wc_product_id, wc_category_id, wc_cart_value, wc_checkout_step, wc_order_id, wc_revenue
)
SELECT
    gen_random_uuid(),
    s.website_id,
    s.session_id,
    s.created_at + (random() * INTERVAL '1 hour'), -- Events within 1 hour of session start
    random_url_path(),
    CASE WHEN random() < 0.2 THEN 'utm_source=google&utm_medium=cpc' ELSE NULL END,
    CASE WHEN random() < 0.3 THEN '/' ELSE NULL END,
    CASE WHEN random() < 0.2 THEN 'ref=social' ELSE NULL END,
    CASE WHEN random() < 0.4 THEN random_referrer_domain() ELSE NULL END,
    random_page_title(),
    CASE 
        WHEN random() < 0.7 THEN 1 -- pageview
        WHEN random() < 0.85 THEN 2 -- event
        ELSE 3 -- custom
    END,
    random_event_name(),
    s.session_id, -- Using session_id as visit_id for simplicity
    CASE WHEN random() < 0.1 THEN 'conversion' ELSE NULL END,
    CASE WHEN random() < 0.05 THEN random_string(20) ELSE NULL END,
    CASE WHEN random() < 0.05 THEN random_string(20) ELSE NULL END,
    CASE WHEN random() < 0.05 THEN random_string(20) ELSE NULL END,
    CASE WHEN random() < 0.05 THEN random_string(20) ELSE NULL END,
    CASE WHEN random() < 0.05 THEN random_string(20) ELSE NULL END,
    CASE WHEN random() < 0.05 THEN random_string(20) ELSE NULL END,
    CASE WHEN random() < 0.1 THEN random_utm_param() ELSE NULL END,
    CASE WHEN random() < 0.1 THEN 'banner' ELSE NULL END,
    CASE WHEN random() < 0.1 THEN 'cpc' ELSE NULL END,
    CASE WHEN random() < 0.1 THEN 'google' ELSE NULL END,
    CASE WHEN random() < 0.1 THEN 'analytics' ELSE NULL END,
    'first8marketing.com',
    CASE WHEN random() < 0.8 THEN floor(random() * 100) ELSE NULL END,
    CASE WHEN random() < 0.7 THEN floor(random() * 300) ELSE NULL END,
    CASE WHEN random() < 0.4 THEN floor(random() * 10) ELSE NULL END,
    CASE WHEN random() < 0.2 THEN 'PROD-' || floor(random() * 1000)::TEXT ELSE NULL END,
    CASE WHEN random() < 0.15 THEN 'CAT-' || floor(random() * 10)::TEXT ELSE NULL END,
    CASE WHEN random() < 0.1 THEN (random() * 1000)::DECIMAL(19,4) ELSE NULL END,
    CASE WHEN random() < 0.05 THEN floor(random() * 5) ELSE NULL END,
    CASE WHEN random() < 0.03 THEN 'ORD-' || floor(random() * 10000)::TEXT ELSE NULL END,
    CASE WHEN random() < 0.03 THEN (random() * 500)::DECIMAL(19,4) ELSE NULL END
FROM
    session s
    CROSS JOIN generate_series(1, 3) -- 3 events per session on average
WHERE
    s.created_at BETWEEN '2023-01-01' AND '2025-12-31'
ON CONFLICT DO NOTHING;

-- Generate revenue data for purchase events
INSERT INTO revenue (revenue_id, website_id, session_id, event_id, event_name, currency, revenue, created_at)
SELECT
    gen_random_uuid(),
    we.website_id,
    we.session_id,
    we.event_id,
    we.event_name,
    'USD',
    we.wc_revenue,
    we.created_at
FROM
    website_event we
WHERE
    we.event_name = 'purchase'
    AND we.wc_revenue IS NOT NULL
    AND we.created_at BETWEEN '2023-01-01' AND '2025-12-31'
ON CONFLICT DO NOTHING;

-- Generate session data
INSERT INTO session_data (session_data_id, website_id, session_id, data_key, string_value, number_value, date_value, data_type, created_at, distinct_id)
SELECT
    gen_random_uuid(),
    s.website_id,
    s.session_id,
    CASE 
        WHEN random() < 0.3 THEN 'user_agent'
        WHEN random() < 0.5 THEN 'screen_resolution' 
        WHEN random() < 0.7 THEN 'timezone'
        WHEN random() < 0.8 THEN 'session_duration'
        ELSE 'custom_property'
    END,
    CASE 
        WHEN random() < 0.3 THEN 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        WHEN random() < 0.5 THEN s.screen
        WHEN random() < 0.7 THEN 'UTC' || (CASE WHEN random() < 0.5 THEN '+' ELSE '-' END) || floor(random() * 12)::TEXT
        ELSE NULL
    END,
    CASE 
        WHEN random() < 0.2 THEN floor(random() * 3600)::DECIMAL -- session duration in seconds
        WHEN random() < 0.4 THEN (random() * 100)::DECIMAL -- scroll depth percentage
        ELSE NULL
    END,
    CASE WHEN random() < 0.1 THEN s.created_at + (random() * INTERVAL '1 hour') ELSE NULL END,
    1, -- string type
    s.created_at,
    s.distinct_id
FROM
    session s
WHERE
    s.created_at BETWEEN '2023-01-01' AND '2025-12-31'
    AND random() < 0.5 -- 50% of sessions have session data
ON CONFLICT DO NOTHING;

-- Generate event data
INSERT INTO event_data (event_data_id, website_id, website_event_id, data_key, string_value, number_value, date_value, data_type, created_at)
SELECT
    gen_random_uuid(),
    we.website_id,
    we.event_id,
    CASE 
        WHEN random() < 0.3 THEN 'element_id'
        WHEN random() < 0.5 THEN 'form_name'
        WHEN random() < 0.7 THEN 'video_duration'
        WHEN random() < 0.8 THEN 'download_size'
        ELSE 'custom_metric'
    END,
    CASE 
        WHEN random() < 0.3 THEN 'submit-button'
        WHEN random() < 0.5 THEN 'contact_form'
        WHEN random() < 0.7 THEN NULL
        ELSE 'user_preference'
    END,
    CASE 
        WHEN random() < 0.3 THEN floor(random() * 300)::DECIMAL -- video duration
        WHEN random() < 0.5 THEN (random() * 1024)::DECIMAL -- download size in KB
        WHEN random() < 0.7 THEN floor(random() * 5)::DECIMAL -- rating 1-5
        ELSE NULL
    END,
    CASE WHEN random() < 0.2 THEN we.created_at ELSE NULL END,
    1, -- string type
    we.created_at
FROM
    website_event we
WHERE
    we.created_at BETWEEN '2023-01-01' AND '2025-12-31'
    AND random() < 0.3 -- 30% of events have additional data
ON CONFLICT DO NOTHING;

-- Generate hourly website metrics
INSERT INTO website_metrics_hourly (time, website_id, pageviews, unique_sessions, unique_users, avg_time_on_page, avg_scroll_depth, bounce_rate, add_to_cart_count, checkout_start_count, purchase_count, conversion_rate, total_revenue, avg_order_value)
SELECT
    date_trunc('hour', we.created_at) as time,
    we.website_id,
    COUNT(*) as pageviews,
    COUNT(DISTINCT we.session_id) as unique_sessions,
    COUNT(DISTINCT s.user_id) as unique_users,
    AVG(we.time_on_page)::INT as avg_time_on_page,
    AVG(we.scroll_depth)::INT as avg_scroll_depth,
    (COUNT(CASE WHEN we.scroll_depth < 25 THEN 1 END)::DECIMAL / COUNT(*))::DECIMAL(5,4) as bounce_rate,
    COUNT(CASE WHEN we.event_name = 'add_to_cart' THEN 1 END) as add_to_cart_count,
    COUNT(CASE WHEN we.event_name = 'checkout_start' THEN 1 END) as checkout_start_count,
    COUNT(CASE WHEN we.event_name = 'purchase' THEN 1 END) as purchase_count,
    (COUNT(CASE WHEN we.event_name = 'purchase' THEN 1 END)::DECIMAL / COUNT(DISTINCT we.session_id))::DECIMAL(5,4) as conversion_rate,
    COALESCE(SUM(r.revenue), 0) as total_revenue,
    CASE 
        WHEN COUNT(CASE WHEN we.event_name = 'purchase' THEN 1 END) > 0 
        THEN COALESCE(SUM(r.revenue), 0) / COUNT(CASE WHEN we.event_name = 'purchase' THEN 1 END)
        ELSE 0 
    END::DECIMAL(19,4) as avg_order_value
FROM
    website_event we
    JOIN session s ON we.session_id = s.session_id
    LEFT JOIN revenue r ON we.event_id = r.event_id
WHERE
    we.created_at BETWEEN '2023-01-01' AND '2025-12-31'
GROUP BY
    date_trunc('hour', we.created_at), we.website_id
ON CONFLICT DO NOTHING;

-- Generate daily product metrics
INSERT INTO product_metrics_daily (time, website_id, product_id, views, unique_viewers, avg_time_viewed, add_to_cart_count, purchase_count, conversion_rate, revenue, units_sold)
SELECT
    date_trunc('day', we.created_at) as time,
    we.website_id,
    we.wc_product_id as product_id,
    COUNT(*) as views,
    COUNT(DISTINCT we.session_id) as unique_viewers,
    AVG(we.time_on_page)::INT as avg_time_viewed,
    COUNT(CASE WHEN we.event_name = 'add_to_cart' THEN 1 END) as add_to_cart_count,
    COUNT(CASE WHEN we.event_name = 'purchase' THEN 1 END) as purchase_count,
    (COUNT(CASE WHEN we.event_name = 'purchase' THEN 1 END)::DECIMAL / COUNT(DISTINCT we.session_id))::DECIMAL(5,4) as conversion_rate,
    COALESCE(SUM(r.revenue), 0) as revenue,
    COUNT(CASE WHEN we.event_name = 'purchase' THEN 1 END) as units_sold
FROM
    website_event we
    LEFT JOIN revenue r ON we.event_id = r.event_id
WHERE
    we.wc_product_id IS NOT NULL
    AND we.created_at BETWEEN '2023-01-01' AND '2025-12-31'
GROUP BY
    date_trunc('day', we.created_at), we.website_id, we.wc_product_id
ON CONFLICT DO NOTHING;

-- Clean up temporary functions
DROP FUNCTION IF EXISTS random_date(TIMESTAMP, TIMESTAMP);
DROP FUNCTION IF EXISTS random_string(INTEGER);
DROP FUNCTION IF EXISTS random_country();
DROP FUNCTION IF EXISTS random_browser();
DROP FUNCTION IF EXISTS random_os();
DROP FUNCTION IF EXISTS random_device();
DROP FUNCTION IF EXISTS random_screen();
DROP FUNCTION IF EXISTS random_language();
DROP FUNCTION IF EXISTS random_city(CHAR(2));
DROP FUNCTION IF EXISTS random_region(CHAR(2));
DROP FUNCTION IF EXISTS random_url_path();
DROP FUNCTION IF EXISTS random_referrer_domain();
DROP FUNCTION IF EXISTS random_event_name();
DROP FUNCTION IF EXISTS random_page_title();
DROP FUNCTION IF EXISTS random_utm_param();

-- Clean up temporary table
DROP TABLE IF EXISTS temp_websites;

-- Print completion message
RAISE NOTICE 'Mock analytics data generation completed successfully. Generated 3 years of comprehensive data for all analytics tables.';