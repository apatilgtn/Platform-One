// src/controllers/health.controller.ts
import { PrismaClient } from '@prisma/client';
import { Request, Response } from 'express';

const prisma = new PrismaClient();

export const healthCheck = async (req: Request, res: Response) => {
  try {
    // Check Database Connection
    await prisma.$queryRaw`SELECT 1`;
    
    // System Info
    const healthStatus = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      services: {
        database: 'connected',
        api: 'running',
      },
      environment: process.env.NODE_ENV,
      uptime: process.uptime(),
      memoryUsage: process.memoryUsage(),
    };

    res.json(healthStatus);
  } catch (error) {
    res.status(500).json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      services: {
        database: error instanceof Error ? error.message : 'database connection failed',
        api: 'running',
      },
      environment: process.env.NODE_ENV,
    });
  }
};

// Check specific components
export const checkComponents = async (req: Request, res: Response) => {
  const components = {
    database: await checkDatabase(),
    api: true,
    redis: await checkRedis(),
  };

  const isHealthy = Object.values(components).every(status => status);

  res.status(isHealthy ? 200 : 500).json({
    status: isHealthy ? 'healthy' : 'unhealthy',
    components,
    timestamp: new Date().toISOString(),
  });
};

async function checkDatabase() {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return true;
  } catch {
    return false;
  }
}

async function checkRedis() {
  // Implement Redis check if you're using Redis
  return true;
}