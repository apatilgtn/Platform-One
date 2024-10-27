// apps/backend/src/api/controllers/ServiceController.ts
import { Request, Response } from 'express';
import { ServiceService } from '@/services/ServiceService';
import { CreateServiceDto, UpdateServiceDto } from '@/types';

export class ServiceController {
  constructor(private serviceService: ServiceService) {}

  async createService(req: Request, res: Response) {
    try {
      const service = await this.serviceService.createService(
        req.body as CreateServiceDto
      );
      res.status(201).json(service);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }

  async getServices(req: Request, res: Response) {
    try {
      const services = await this.serviceService.getServices();
      res.json(services);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }

  async getServiceById(req: Request, res: Response) {
    try {
      const service = await this.serviceService.getServiceById(req.params.id);
      if (!service) {
        return res.status(404).json({ message: 'Service not found' });
      }
      res.json(service);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  }
}