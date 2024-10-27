// apps/frontend/src/features/monitoring/Dashboard/MonitoringDashboard.tsx
import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { MetricsChart } from './MetricsChart';
import { AlertsList } from './AlertsList';
import { TimeRangeSelector } from './TimeRangeSelector';
import { useMetrics } from '@/hooks/useMetrics';
import { MetricsTimeRange } from '@/types';

export const MonitoringDashboard: React.FC = () => {
  const [timeRange, setTimeRange] = useState<MetricsTimeRange>('1h');
  const { metrics, isLoading, error } = useMetrics(timeRange);

  if (isLoading) return <DashboardSkeleton />;
  if (error) return <ErrorState error={error} />;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-semibold">System Monitoring</h1>
        <TimeRangeSelector value={timeRange} onChange={setTimeRange} />
      </div>

      <div className="grid grid-cols-2 gap-6">
        <MetricsCard
          title="CPU Usage"
          value={metrics.cpu.current}
          change={metrics.cpu.change}
          chart={metrics.cpu.history}
        />
        <MetricsCard
          title="Memory Usage"
          value={metrics.memory.current}
          change={metrics.memory.change}
          chart={metrics.memory.history}
        />
        <MetricsCard
          title="Request Rate"
          value={metrics.requests.current}
          change={metrics.requests.change}
          chart={metrics.requests.history}
        />
        <MetricsCard
          title="Error Rate"
          value={metrics.errors.current}
          change={metrics.errors.change}
          chart={metrics.errors.history}
          threshold={5}
        />
      </div>

      <AlertsList alerts={metrics.alerts} />
    </div>
  );
};
