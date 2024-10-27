// apps/frontend/src/features/monitoring/MetricsChart.tsx
import { LineChart, Line, XAxis, YAxis, Tooltip, CartesianGrid } from 'recharts';
import { Card } from '@/components/common/Card';

interface MetricsChartProps {
  data: Array<{
    timestamp: string;
    value: number;
  }>;
  title: string;
  color?: string;
}

export const MetricsChart: React.FC<MetricsChartProps> = ({
  data,
  title,
  color = '#2563eb',
}) => {
  return (
    <Card title={title}>
      <div className="h-64">
        <LineChart width={600} height={240} data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="timestamp" />
          <YAxis />
          <Tooltip />
          <Line type="monotone" dataKey="value" stroke={color} />
        </LineChart>
      </div>
    </Card>
  );
};