// apps/backend/src/core/monitoring/MetricsCollector.ts
import { PrometheusDriver } from '@/drivers/PrometheusDriver';
import { MetricsRepository } from '@/db/MetricsRepository';

export class MetricsCollector {
  constructor(
    private prometheus: PrometheusDriver,
    private metricsRepo: MetricsRepository
  ) {}

  async collectServiceMetrics(serviceId: string) {
    const metrics = await this.prometheus.queryRange({
      query: `container_cpu_usage_seconds_total{service="${serviceId}"}`,
      start: Date.now() - 3600000, // Last hour
      end: Date.now(),
      step: '15s',
    });

    await this.metricsRepo.saveMetrics(serviceId, metrics);
    return metrics;
  }
}