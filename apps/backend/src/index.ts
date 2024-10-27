// Usage example in your application:
// platform-one/apps/backend/src/index.ts
import { ConfigLoader } from '@platform-one/common';

const config = ConfigLoader.getInstance().getConfig();

console.log(`Starting ${config.app.name} in ${config.app.environment} mode`);