import Fastify, {
  type FastifyServerOptions,
} from "fastify";

import { SaveDecisionRequestSchema } from "./contracts.js";
import { createLocalFallback } from "./fallback.js";

const BODY_LIMIT_BYTES = 32 * 1024;

export function buildServer(
  options: FastifyServerOptions = {},
) {
  const server = Fastify({
    bodyLimit: BODY_LIMIT_BYTES,
    ...options,
  });

  server.get("/health", async () => ({
    status: "ok",
    ai_available: false,
  }));

  server.post("/v1/save-decision", async (request, reply) => {
    const parsed = SaveDecisionRequestSchema.safeParse(request.body);
    if (!parsed.success) {
      return reply.code(400).send({
        error: "INVALID_REQUEST",
        issues: parsed.error.issues.map((issue) => ({
          path: issue.path.join("."),
          code: issue.code,
        })),
      });
    }

    return reply.code(200).send(createLocalFallback(parsed.data));
  });

  return server;
}
