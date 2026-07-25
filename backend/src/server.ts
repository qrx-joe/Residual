import "dotenv/config";

import { buildServer } from "./app.js";
import { loadServerConfig } from "./config.js";

const config = loadServerConfig(process.env);
const server = buildServer({
  logger: {
    level: config.LOG_LEVEL,
    redact: [
      "req.headers.authorization",
      "req.headers.cookie",
    ],
  },
});

try {
  await server.listen({
    host: config.HOST,
    port: config.PORT,
  });
} catch (error) {
  server.log.error(error);
  process.exitCode = 1;
}
