// apps/frontend/src/features/services/ServiceCard.tsx
import { Service } from '@/types';
import { Card } from '@/components/common/Card';

interface ServiceCardProps {
  service: Service;
}

export const ServiceCard: React.FC<ServiceCardProps> = ({ service }) => {
  return (
    <Card className="hover:shadow-lg transition-shadow">
      <div className="flex justify-between items-start">
        <div>
          <h4 className="text-lg font-medium">{service.name}</h4>
          <p className="text-sm text-gray-500 mt-1">{service.description}</p>
        </div>
        <StatusBadge status={service.status} />
      </div>
      <div className="mt-4 grid grid-cols-2 gap-4 text-sm">
        <div>
          <span className="text-gray-500">Owner:</span>
          <span className="ml-2">{service.owner}</span>
        </div>
        <div>
          <span className="text-gray-500">Repository:</span>
          <a
            href={service.repository}
            className="ml-2 text-blue-600 hover:underline"
            target="_blank"
            rel="noopener noreferrer"
          >
            View
          </a>
        </div>
      </div>
    </Card>
  );
};