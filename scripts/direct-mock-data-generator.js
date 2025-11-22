#!/usr/bin/env node

/**
 * First8 Marketing - Direct Mock Data Generator
 *
 * This script generates comprehensive mock analytics data using direct database connection
 * spanning 3 years (2023-2025) with realistic patterns and edge cases.
 */

import { Client } from 'pg';
import path from 'path';
import { config } from 'dotenv';
import { fileURLToPath } from 'url';
import { randomUUID } from 'crypto';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
config({ path: path.join(__dirname, '..', '.env') });

class DirectMockDataGenerator {
  constructor() {
    this.dbConfig = this.getDatabaseConfig();
    this.client = new Client(this.dbConfig);
    this.websites = [];
    this.validateEnvironment();
  }

  getDatabaseConfig() {
    // Parse DATABASE_URL or use individual environment variables
    if (process.env.DATABASE_URL) {
      const url = new URL(process.env.DATABASE_URL);
      return {
        host: url.hostname,
        port: url.port || 5432,
        database: url.pathname.substring(1),
        user: url.username,
        password: url.password,
        ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
      };
    }

    return {
      host: process.env.DB_HOST || 'localhost',
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME || 'umami',
      user: process.env.DB_USER || 'umami',
      password: process.env.DB_PASSWORD || 'umami',
      ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
    };
  }

  validateEnvironment() {
    if (!process.env.DATABASE_URL && !process.env.DB_HOST) {
      throw new Error(
        'Database connection configuration is required. Set DATABASE_URL or DB_HOST/DB_NAME/DB_USER/DB_PASSWORD',
      );
    }
    // console.log('✅ Environment validation passed');
  }

  async connect() {
    try {
      await this.client.connect();
      // console.log('✅ Connected to PostgreSQL database');
      return true;
    } catch {
      // console.error('❌ Database connection failed:');
      // console.error(error.message);
      return false;
    }
  }

  async disconnect() {
    try {
      await this.client.end();
      // console.log('✅ Database connection closed');
    } catch {
      // console.error('Error closing connection:', error.message);
    }
  }

  // Helper functions for data generation
  randomDate(start, end) {
    return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
  }

  randomString(length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }

  randomUUID() {
    return randomUUID();
  }

  randomElement(array) {
    return array[Math.floor(Math.random() * array.length)];
  }

  randomCountry() {
    const countries = [
      'US',
      'GB',
      'DE',
      'FR',
      'CA',
      'AU',
      'JP',
      'BR',
      'IN',
      'CN',
      'RU',
      'MX',
      'IT',
      'ES',
      'KR',
    ];
    return this.randomElement(countries);
  }

  randomBrowser() {
    const browsers = ['Chrome', 'Firefox', 'Safari', 'Edge', 'Opera'];
    return this.randomElement(browsers);
  }

  randomOS() {
    const osList = ['Windows', 'macOS', 'Linux', 'iOS', 'Android'];
    return this.randomElement(osList);
  }

  randomDevice() {
    const devices = ['desktop', 'mobile', 'tablet'];
    return this.randomElement(devices);
  }

  randomScreen() {
    const screens = ['1920x1080', '1366x768', '1536x864', '1440x900', '1280x720', '1600x900'];
    return this.randomElement(screens);
  }

  randomLanguage() {
    const languages = ['en-US', 'en-GB', 'de-DE', 'fr-FR', 'es-ES', 'pt-BR', 'ru-RU', 'ja-JP'];
    return this.randomElement(languages);
  }

  randomCity(country) {
    const cities = {
      US: ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'],
      GB: ['London', 'Manchester', 'Birmingham', 'Glasgow', 'Liverpool'],
      DE: ['Berlin', 'Hamburg', 'Munich', 'Cologne', 'Frankfurt'],
      FR: ['Paris', 'Marseille', 'Lyon', 'Toulouse', 'Nice'],
      CA: ['Toronto', 'Montreal', 'Vancouver', 'Calgary', 'Edmonton'],
    };
    return cities[country] ? this.randomElement(cities[country]) : 'Unknown';
  }

  randomRegion(country) {
    const regions = {
      US: ['California', 'Texas', 'Florida', 'New York', 'Pennsylvania'],
      GB: ['England', 'Scotland', 'Wales', 'N Ireland'],
      DE: ['Bavaria', 'Baden-Württemb', 'NRW', 'Lower Saxony'],
      FR: ['Île-de-France', 'Auvergne-Rhône', 'Nouvelle-Aquit', 'Occitanie'],
      CA: ['Ontario', 'Quebec', 'BC', 'Alberta', 'Manitoba'],
    };
    return regions[country] ? this.randomElement(regions[country]) : 'Unknown';
  }

  randomUrlPath() {
    const paths = [
      '/',
      '/about',
      '/contact',
      '/products',
      '/services',
      '/blog',
      '/pricing',
      '/features',
      '/docs',
      '/support',
      '/login',
      '/register',
    ];
    return this.randomElement(paths);
  }

  randomEventName() {
    const events = [
      'pageview',
      'click',
      'form_submit',
      'download',
      'video_play',
      'add_to_cart',
      'checkout_start',
      'purchase',
      'sign_up',
      'login',
    ];
    return this.randomElement(events);
  }

  async ensureWebsitesExist() {
    const result = await this.client.query('SELECT website_id, name FROM website LIMIT 5');

    if (result.rows.length === 0) {
      // console.log('📝 Creating sample websites...');
      const websites = [
        ['First8 Marketing Main Site', 'first8marketing.com'],
        ['First8 Blog', 'blog.first8marketing.com'],
        ['First8 E-commerce', 'shop.first8marketing.com'],
        ['First8 Documentation', 'docs.first8marketing.com'],
        ['First8 Support', 'support.first8marketing.com'],
      ];

      for (const [name, domain] of websites) {
        const websiteId = this.randomUUID();
        await this.client.query(
          'INSERT INTO website (website_id, name, domain, share_id, created_at, updated_at) VALUES ($1, $2, $3, $4, NOW(), NOW())',
          [websiteId, name, domain, this.randomString(16)],
        );
        this.websites.push({ website_id: websiteId, name });
      }
      // console.log('✅ Created 5 sample websites');
    } else {
      this.websites = result.rows;
      // console.log(`✅ Found ${this.websites.length} existing websites`);
    }
  }

  async generateSessions() {
    // console.log('🚀 Generating sessions...');
    const startDate = new Date('2023-01-01');
    const endDate = new Date('2025-12-31');
    const sessionCount = 50000; // Reduced for faster testing

    for (const website of this.websites) {
      // console.log(`   Generating sessions for ${website.name}...`);

      for (let i = 0; i < sessionCount / this.websites.length; i++) {
        const sessionId = this.randomUUID();
        const country = this.randomCountry();
        const createdAt = this.randomDate(startDate, endDate);

        const browser = this.randomBrowser();
        const os = this.randomOS();
        const device = this.randomDevice();
        const screen = this.randomScreen();
        const language = this.randomLanguage();
        const region = this.randomRegion(country);
        const city = this.randomCity(country);
        const distinctId = this.randomString(16);
        const userId = Math.random() < 0.3 ? this.randomString(36) : null;

        // Debug: Check field lengths
        // const fieldLengths = {
        //     browser: browser.length,
        //     os: os.length,
        //     device: device.length,
        //     screen: screen.length,
        //     language: language.length,
        //     region: region.length,
        //     city: city.length,
        //     distinctId: distinctId.length,
        //     userId: userId || 0
        // };

        // console.log('Field lengths:', fieldLengths);

        await this.client.query(
          `INSERT INTO session (
                        session_id, website_id, browser, os, device, screen, language,
                        country, region, city, created_at, distinct_id, user_id
                    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`,
          [
            sessionId,
            website.website_id,
            browser,
            os,
            device,
            screen,
            language,
            country,
            region,
            city,
            createdAt,
            distinctId,
            userId,
          ],
        );
      }
    }
    // console.log('✅ Sessions generated successfully');
  }

  async generateWebsiteEvents() {
    // console.log('🚀 Generating website events...');

    // Get all sessions
    const sessions = await this.client.query(
      'SELECT session_id, website_id, created_at FROM session',
    );

    for (const session of sessions.rows) {
      // Generate 1-5 events per session
      const eventCount = Math.floor(Math.random() * 5) + 1;

      for (let i = 0; i < eventCount; i++) {
        const eventId = this.randomUUID();
        const eventName = this.randomEventName();
        const eventTime = new Date(session.created_at.getTime() + Math.random() * 3600000); // Within 1 hour of session

        await this.client.query(
          `INSERT INTO website_event (
                        event_id, website_id, session_id, created_at, url_path, event_type, event_name,
                        visit_id, hostname, scroll_depth, time_on_page
                    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
          [
            eventId,
            session.website_id,
            session.session_id,
            eventTime,
            this.randomUrlPath(),
            eventName === 'pageview' ? 1 : 2,
            eventName,
            session.session_id,
            'first8marketing.com',
            Math.random() < 0.8 ? Math.floor(Math.random() * 100) : null,
            Math.random() < 0.7 ? Math.floor(Math.random() * 300) : null,
          ],
        );

        // Generate revenue for purchase events
        if (eventName === 'purchase' && Math.random() < 0.3) {
          await this.client.query(
            `INSERT INTO revenue (
                            revenue_id, website_id, session_id, event_id, event_name, currency, revenue, created_at
                        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
            [
              this.randomUUID(),
              session.website_id,
              session.session_id,
              eventId,
              eventName,
              'USD',
              (Math.random() * 500).toFixed(2),
              eventTime,
            ],
          );
        }
      }
    }
    // console.log('✅ Website events generated successfully');
  }

  async generateAggregatedMetrics() {
    // console.log('🚀 Generating aggregated metrics...');

    // Generate hourly metrics
    const hoursResult = await this.client.query(`
            SELECT 
                date_trunc('hour', created_at) as hour,
                website_id,
                COUNT(*) as pageviews,
                COUNT(DISTINCT session_id) as unique_sessions
            FROM website_event 
            WHERE created_at BETWEEN '2023-01-01' AND '2025-12-31'
            GROUP BY hour, website_id
        `);

    for (const row of hoursResult.rows) {
      await this.client.query(
        `INSERT INTO website_metrics_hourly (
                    time, website_id, pageviews, unique_sessions, unique_users,
                    avg_time_on_page, avg_scroll_depth, bounce_rate
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
        [
          row.hour,
          row.website_id,
          row.pageviews,
          row.unique_sessions,
          Math.floor(row.unique_sessions * 0.8), // Estimate unique users
          Math.floor(Math.random() * 180),
          Math.floor(Math.random() * 80),
          (Math.random() * 0.6).toFixed(4),
        ],
      );
    }
    // console.log('✅ Aggregated metrics generated successfully');
  }

  async verifyData() {
    // console.log('🔍 Verifying generated data...');

    const queries = [
      ['Sessions', 'SELECT COUNT(*) FROM session'],
      ['Website Events', 'SELECT COUNT(*) FROM website_event'],
      ['Revenue', 'SELECT COUNT(*) FROM revenue'],
      ['Hourly Metrics', 'SELECT COUNT(*) FROM website_metrics_hourly'],
      ['Websites', 'SELECT COUNT(*) FROM website'],
    ];

    for (const [, query] of queries) {
      await this.client.query(query);
      // console.log(`📊 ${name}: ${result.rows[0].count}`);
    }

    // console.log('✅ Data verification completed');
  }

  async run() {
    try {
      // Connect to database
      const connected = await this.connect();
      if (!connected) {
        process.exit(1);
      }

      // Ensure websites exist
      await this.ensureWebsitesExist();

      // Generate data
      await this.generateSessions();
      await this.generateWebsiteEvents();
      await this.generateAggregatedMetrics();

      // Verify data
      await this.verifyData();

      // console.log('\n🎉 Mock data generation completed successfully!');
      // console.log('================================================');
      // console.log('The analytics platform now contains realistic data including:');
      // console.log('• Sessions with geographic and device diversity');
      // console.log('• Website events with various interaction types');
      // console.log('• Revenue data for purchase events');
      // console.log('• Aggregated hourly metrics');
      // console.log('• 3 years of data (2023-2025)');
      // console.log('\n📊 You can now explore the data through the Umami dashboard!');
    } catch {
      // console.error('❌ Error during data generation:');
      // console.error(error);
    } finally {
      await this.disconnect();
    }
  }
}

// Run the generator if this script is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  const generator = new DirectMockDataGenerator();
  generator.run();
}

export default DirectMockDataGenerator;
