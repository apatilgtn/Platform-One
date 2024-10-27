// platform-one/packages/common/src/config/loader.ts
import * as fs from 'fs';
import * as yaml from 'js-yaml';
import { ApplicationConfig } from './types';

export class ConfigLoader {
  private static instance: ConfigLoader;
  private config: ApplicationConfig;

  private constructor() {
    this.loadConfig();
  }

  public static getInstance(): ConfigLoader {
    if (!ConfigLoader.instance) {
      ConfigLoader.instance = new ConfigLoader();
    }
    return ConfigLoader.instance;
  }

  private loadConfig(): void {
    const env = process.env.NODE_ENV || 'development';
    const configPath = `${process.cwd()}/configs/${env}/app.yaml`;
    const secretsPath = `${process.cwd()}/configs/${env}/secrets.yaml`;

    try {
      const configFile = fs.readFileSync(configPath, 'utf8');
      const secretsFile = fs.readFileSync(secretsPath, 'utf8');

      const config = yaml.load(configFile) as any;
      const secrets = yaml.load(secretsFile) as any;

      this.config = this.parseConfig(config, secrets);
      this.validateConfig(this.config);
    } catch (error) {
      throw new Error(`Failed to load configuration: ${error.message}`);
    }
  }

  private parseConfig(config: any, secrets: any): ApplicationConfig {
    return {
      app: {
        name: config.data.APP_NAME,
        environment: config.data.ENVIRONMENT,
        logLevel: config.data.LOG_LEVEL,
      },
      frontend: {
        url: config.data.FRONTEND_URL,
        apiBaseUrl: config.data.API_BASE_URL,
        websocketUrl: config.data.WEBSOCKET_URL,
      },
      backend: {
        port: parseInt(config.data.PORT, 10),
        apiVersion: config.data.API_VERSION,
      },
      database: {
        host: config.data.DB_HOST,
        port: parseInt(config.data.DB_PORT, 10),
        name: config.data.DB_NAME,
        user: secrets.stringData.DB_USER,
        password: secrets.stringData.DB_PASSWORD,
      },
      features: {
        enableDebugMode: config.data.ENABLE_DEBUG_MODE === 'true',
        enableMockData: config.data.ENABLE_MOCK_DATA === 'true',
      },
    };
  }

  private validateConfig(config: ApplicationConfig): void {
    const requiredFields = [
      'app.name',
      'app.environment',
      'frontend.url',
      'frontend.apiBaseUrl',
      'backend.port',
      'database.host',
      'database.name',
    ];

    for (const field of requiredFields) {
      const value = field.split('.').reduce((obj, key) => obj[key], config as any);
      if (!value) {
        throw new Error(`Missing required configuration field: ${field}`);
      }
    }
  }

  public getConfig(): ApplicationConfig {
    return this.config;
  }
}