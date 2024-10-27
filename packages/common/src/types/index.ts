// packages/common/src/types/index.ts
export interface Service {
    id: string;
    name: string;
    description: string;
    repository: string;
    owner: string;
    status: ServiceStatus;
    createdAt: Date;
    updatedAt: Date;
  }
  
  export type ServiceStatus = 'pending' | 'running' | 'failed' | 'stopped';
  
  export interface CreateServiceDto {
    name: string;
    description: string;
    repository: string;
    ownerId: string;
  }