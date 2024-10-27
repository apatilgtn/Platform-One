// apps/backend/src/services/AuditService.ts
import { PrismaClient } from '@prisma/client';
import { AuditEventType, AuditLogFilters } from '@/types';

export class AuditService {
  constructor(private prisma: PrismaClient) {}

  async logEvent(data: {
    type: AuditEventType;
    userId: string;
    resourceId?: string;
    details: Record<string, any>;
  }) {
    return this.prisma.auditLog.create({
      data: {
        type: data.type,
        userId: data.userId,
        resourceId: data.resourceId,
        details: data.details,
      },
    });
  }

  async getAuditLogs(filters: AuditLogFilters) {
    return this.prisma.auditLog.findMany({
      where: {
        createdAt: {
          gte: filters.startDate,
          lte: filters.endDate,
        },
        ...(filters.type !== 'all' && { type: filters.type }),
        ...(filters.user && { userId: filters.user }),
      },
      include: {
        user: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }
}