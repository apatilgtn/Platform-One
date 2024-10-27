// apps/frontend/src/features/services/ServiceDetails/ServiceDetails.tsx
import React from 'react';
import { useParams } from 'react-router-dom';
import { useQuery, useMutation } from '@tanstack/react-query';
import { serviceApi } from '@/services/api';
import { DeploymentHistory } from './DeploymentHistory';
import { ConfigEditor } from './ConfigEditor';
import { MetricsPanel } from './MetricsPanel';

export const ServiceDetails: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { data: service, isLoading } = useQuery(
    ['service', id],
    () => serviceApi.getServiceDetails(id!)
  );

  const deployMutation = useMutation(serviceApi.deployService);

  const handleDeploy = async () => {
    await deployMutation.mutateAsync(id!);
  };

  if (isLoading) return <ServiceDetailsSkeleton />;

  return (
    <div className="space-y-6">
      <header className="flex justify-between items-start">
        <div>
          <h1 className="text-2xl font-bold">{service?.name}</h1>
          <p className="text-gray-600">{service?.description}</p>
        </div>
        <div className="flex space-x-4">
          <Button
            variant="secondary"
            onClick={() => window.open(service?.repository)}
          >
            View Repository
          </Button>
          <Button
            variant="primary"
            onClick={handleDeploy}
            loading={deployMutation.isLoading}
          >
            Deploy
          </Button>
        </div>
      </header>

      <div className="grid grid-cols-3 gap-6">
        <Card className="col-span-2">
          <Tabs defaultValue="deployments">
            <TabsList>
              <TabsTrigger value="deployments">Deployments</TabsTrigger>
              <TabsTrigger value="config">Configuration</TabsTrigger>
              <TabsTrigger value="metrics">Metrics</TabsTrigger>
            </TabsList>
            <TabsContent value="deployments">
              <DeploymentHistory serviceId={id!} />
            </TabsContent>
            <TabsContent value="config">
              <ConfigEditor serviceId={id!} />
            </TabsContent>
            <TabsContent value="metrics">
              <MetricsPanel serviceId={id!} />
            </TabsContent>
          </Tabs>
        </Card>

        <div className="space-y-6">
          <ServiceInfoCard service={service!} />
          <DependenciesCard serviceId={id!} />
        </div>
      </div>
    </div>
  );
};