import "dotenv/config";

import { buildServer } from "./app.js";
import { loadServerConfig } from "./config.js";
import { RouterBaseAdapter } from "./routerbase_adapter.js";

const config = loadServerConfig(process.env);
const routerBaseAdapter = config.ROUTERBASE_API_KEY.length > 0
  ? new RouterBaseAdapter({
      apiKey: config.ROUTERBASE_API_KEY,
      model: config.ROUTERBASE_MODEL,
      baseUrl: config.ROUTERBASE_BASE_URL,
      timeoutMs: config.ROUTERBASE_TIMEOUT_MS,
    })
  : undefined;
const server = buildServer({
  logger: {
    level: config.LOG_LEVEL,
    redact: [
      "req.headers.authorization",
      "req.headers.cookie",
    ],
  },
}, routerBaseAdapter);

try {
  await server.listen({
    host: config.HOST,
    port: config.PORT,
  });
} catch (error) {
  server.log.error(error);
  process.exitCode = 1;
}
