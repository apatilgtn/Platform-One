// apps/frontend/src/features/deployments/DeploymentPipeline/PipelineVisualizer.tsx
import React from 'react';
import { Pipeline, Stage, Step } from '@/types';
import { useDeploymentStatus } from '@/hooks/useDeploymentStatus';

interface PipelineVisualizerProps {
  pipelineId: string;
}

export const PipelineVisualizer: React.FC<PipelineVisualizerProps> = ({
  pipelineId,
}) => {
  const { status, stages } = useDeploymentStatus(pipelineId);

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-medium">Deployment Pipeline</h3>
        <PipelineStatus status={status} />
      </div>

      <div className="flex space-x-4">
        {stages.map((stage, index) => (
          <StageCard
            key={stage.id}
            stage={stage}
            isLast={index === stages.length - 1}
          />
        ))}
      </div>
    </div>
  );
};