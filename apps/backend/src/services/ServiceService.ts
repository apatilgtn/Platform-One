// apps/backend/src/services/ServiceService.ts
import { PrismaClient } from '@prisma/client';
import { CreateServiceDto, UpdateServiceDto } from '@/types';

export class ServiceService {
  constructor(private prisma: PrismaClient) {}

  async createService(data: CreateServiceDto) {
    return this.prisma.service.create({
      data: {
        ...data,
        status: 'pending',
      },
    });
  }

  async getServices() {
    return this.prisma.service.findMany({
      include: {
        owner: true,
        deployments: true,
      },
    });
  }

  async getServiceById(id: string) {
    return this.prisma.service.findUnique({
      where: { id },
      include: {
        owner: true,
        deployments: true,
        metrics: true,
      },
    });
  }
}
