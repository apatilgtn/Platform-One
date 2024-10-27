// platform-one/packages/common/src/config/types.ts
export interface ApplicationConfig {
    app: {
      name: string;
      environment: 'development' | 'staging' | 'production';
      logLevel: string;
    };
    frontend: {
      url: string;
      apiBaseUrl: string;
      websocketUrl: string;
    };
    backend: {
      port: number;
      apiVersion: string;
    };
    database: {
      host: string;
      port: number;
      name: string;
      user: string;
      password: string;
    };
    features: {
      enableDebugMode: boolean;
      enableMockData: boolean;
    };
  }