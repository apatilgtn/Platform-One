// packages/api-client/src/index.ts
import axios, { AxiosInstance } from 'axios';

export class ApiClient {
  private client: AxiosInstance;

  constructor(baseURL: string, token?: string) {
    this.client = axios.create({
      baseURL,
      headers: token ? { Authorization: `Bearer ${token}` } : {},
    });
  }

  async getServices() {
    const { data } = await this.client.get('/services');
    return data;
  }

  async createService(serviceData: CreateServiceDto) {
    const { data } = await this.client.post('/services', serviceData);
    return data;
  }

  async getServiceMetrics(serviceId: string) {
    const { data } = await this.client.get(`/services/${serviceId}/metrics`);
    return data;
  }
}