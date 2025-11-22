'use client';
import { useState } from 'react';
import { ProductPerformanceTable } from '@/components/first8marketing/woocommerce/ProductPerformanceTable';
import { useNavigation } from '@/components/hooks/useNavigation';
import { DateFilter } from '@/components/input/DateFilter';

export default function ProductPerformancePage() {
  const { websiteId } = useNavigation();
  const [dateRange, setDateRange] = useState<{ startDate: Date; endDate: Date }>(() => {
    const now = new Date();
    const start = new Date(now);
    start.setDate(now.getDate() - 30);
    return { startDate: start, endDate: now };
  });

  if (!websiteId) {
    return (
      <div style={{ maxWidth: 400, margin: '2rem auto', textAlign: 'center' }}>
        <p style={{ fontSize: 18, marginBottom: 16 }}>Please select a website to view analytics.</p>
      </div>
    );
  }

  return (
    <main>
      <h1>Product Performance</h1>
      <DateFilter
        value={`range:${dateRange.startDate.getTime()}:${dateRange.endDate.getTime()}`}
        onChange={val => {
          const [, start, end] = val.split(':');
          setDateRange({
            startDate: new Date(Number(start)),
            endDate: new Date(Number(end)),
          });
        }}
        showAllTime
        renderDate
      />
      <ProductPerformanceTable
        websiteId={websiteId}
        startDate={dateRange.startDate}
        endDate={dateRange.endDate}
      />
    </main>
  );
}
