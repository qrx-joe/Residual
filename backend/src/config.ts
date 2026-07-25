import { z } from "zod";

const ServerConfigSchema = z.object({
  HOST: z.string().trim().min(1).default("127.0.0.1"),
  PORT: z.coerce.number().int().min(1).max(65535).default(8787),
  LOG_LEVEL: z
    .enum(["fatal", "error", "warn", "info", "debug", "trace", "silent"])
    .default("info"),
  ROUTERBASE_API_KEY: z.string().trim().default(""),
  ROUTERBASE_MODEL: z
    .string()
    .trim()
    .min(1)
    .default("google/gemini-2.5-flash"),
  ROUTERBASE_BASE_URL: z
    .url()
    .default("https://routerbase.com/v1"),
  ROUTERBASE_TIMEOUT_MS: z.coerce
    .number()
    .int()
    .min(100)
    .max(5_000)
    .default(5_000),
});

export function loadServerConfig(environment: NodeJS.ProcessEnv) {
  return ServerConfigSchema.parse(environment);
}
