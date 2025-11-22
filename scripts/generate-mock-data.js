#!/usr/bin/env node

/**
 * First8 Marketing - Mock Data Generator
 *
 * This script generates comprehensive mock analytics data for the Umami platform
 * spanning 3 years (2023-2025) with realistic patterns and edge cases.
 */

import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { config } from 'dotenv';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
config({ path: path.join(__dirname, '..', '.env') });

class MockDataGenerator {
  constructor() {
    this.dbUrl = process.env.DATABASE_URL;
    this.migrationPath = path.join(
      __dirname,
      '..',
      'prisma',
      'migrations',
      '20251113_add_mock_analytics_tables',
      'migration.sql',
    );
    this.validateEnvironment();
  }

  validateEnvironment() {
    if (!this.dbUrl) {
      throw new Error('DATABASE_URL environment variable is required');
    }

    if (!fs.existsSync(this.migrationPath)) {
      throw new Error(`Migration file not found: ${this.migrationPath}`);
    }

    // console.log('✅ Environment validation passed');
  }

  async executeMigration() {
    // console.log('🚀 Executing mock data migration...');

    try {
      const command = `psql "${this.dbUrl}" -f "${this.migrationPath}"`;
      // console.log(`Executing: ${command}`);

      execSync(command, {
        encoding: 'utf-8',
        stdio: 'pipe',
      });

      // console.log('✅ Migration executed successfully');
      // console.log('📊 Generated comprehensive mock data including:');
      // console.log('   - 50,000+ sessions across 5 websites');
      // console.log('   - 150,000+ website events with various types');
      // console.log('   - Revenue data for purchase events');
      // console.log('   - Session and event metadata');
      // console.log('   - Hourly and daily aggregated metrics');
      // console.log('   - 3 years of data (2023-2025)');
      // console.log('   - Realistic geographic distribution');
      // console.log('   - Multiple device types and browsers');
      // console.log('   - UTM tracking parameters');
      // console.log('   - E-commerce conversion funnel data');

      return true;
    } catch {
      // console.error('❌ Migration failed:');
      // console.error(error.stdout || error.message);
      return false;
    }
  }

  async verifyData() {
    // console.log('\n🔍 Verifying generated data...');

    try {
      // Check if data was inserted successfully
      const checkQueries = [
        'SELECT COUNT(*) as session_count FROM session',
        'SELECT COUNT(*) as event_count FROM website_event',
        'SELECT COUNT(*) as revenue_count FROM revenue',
        'SELECT COUNT(DISTINCT website_id) as website_count FROM session',
        'SELECT MIN(created_at) as earliest, MAX(created_at) as latest FROM session',
      ];

      for (const query of checkQueries) {
        execSync(`psql "${this.dbUrl}" -c "${query}"`, {
          encoding: 'utf-8',
        });
        // console.log(`📈 ${query.split(' ')[2]}: ${result.trim()}`);
      }

      // console.log('✅ Data verification completed');
      return true;
    } catch {
      // console.error('❌ Data verification failed:');
      // console.error(error.message);
      return false;
    }
  }

  async generateSampleReports() {
    // console.log('\n📋 Generating sample analytics reports...');

    const reports = [
      {
        name: 'Traffic Overview - Last 30 Days',
        description:
          'Overview of website traffic including pageviews, unique visitors, and bounce rate',
        type: 'traffic',
      },
      {
        name: 'Conversion Funnel',
        description: 'E-commerce conversion funnel from pageview to purchase',
        type: 'funnel',
      },
      {
        name: 'Geographic Analysis',
        description: 'Traffic and conversion analysis by country and region',
        type: 'geography',
      },
      {
        name: 'Device Performance',
        description: 'Performance metrics across different device types',
        type: 'devices',
      },
      {
        name: 'Campaign Performance',
        description: 'UTM campaign performance and ROI analysis',
        type: 'campaigns',
      },
    ];

    // console.log('✅ Sample reports configured for the analytics dashboard');
    return reports;
  }

  async run() {
    // console.log('🎯 First8 Marketing - Mock Data Generator');
    // console.log('==========================================');
    // console.log('Generating 3 years of comprehensive analytics data...\n');

    try {
      // Execute the migration
      const migrationResult = await this.executeMigration();
      if (!migrationResult) {
        process.exit(1);
      }

      // Verify the data
      const verificationResult = await this.verifyData();
      if (!verificationResult) {
        process.exit(1);
      }

      // Generate sample reports
      await this.generateSampleReports();

      // console.log('\n🎉 Mock data generation completed successfully!');
      // console.log('==============================================');
      // console.log('The analytics platform now contains:');
      // console.log('• 3 years of realistic web analytics data');
      // console.log('• Multiple websites with diverse traffic patterns');
      // console.log('• Complete e-commerce conversion tracking');
      // console.log('• Geographic and device distribution data');
      // console.log('• UTM campaign tracking examples');
      // console.log('• Hourly and daily aggregated metrics');
      // console.log('\n📊 You can now explore the data through the Umami dashboard!');
    } catch {
      // console.error('❌ Fatal error during data generation:');
      // console.error(error);
      process.exit(1);
    }
  }
}

// Run the generator if this script is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  const generator = new MockDataGenerator();
  generator.run();
}

export default MockDataGenerator;
