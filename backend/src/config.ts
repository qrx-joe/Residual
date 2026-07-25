import { z } from "zod";

const ServerConfigSchema = z.object({
  HOST: z.string().trim().min(1).default("127.0.0.1"),
  PORT: z.coerce.number().int().min(1).max(65535).default(8787),
  LOG_LEVEL: z
    .enum(["fatal", "error", "warn", "info", "debug", "trace", "silent"])
    .default("info"),
});

export function loadServerConfig(environment: NodeJS.ProcessEnv) {
  return ServerConfigSchema.parse(environment);
}
