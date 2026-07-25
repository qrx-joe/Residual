import { afterEach, describe, expect, it } from "vitest";

import { buildServer } from "../src/app.js";

const validRequest = {
  session_id: "t3-1-test",
  loop_index: 3,
  persona: {
    trust: 1,
    obsession: 5,
    conflict: 2,
    protected_target: "azhi_audio",
    broken_promises: 1,
  },
  recent_actions: [
    "PROMISE_PRESERVE_AUDIO",
    "DELETE_AZHI_AUDIO",
  ],
  allowed_decisions: ["PRESERVE", "DISTORT"],
  allowed_targets: ["azhi_audio", "operation_log"],
  allowed_mutations: [
    "spawn_ghost_audio",
    "distort_noncritical_log",
  ],
  max_dialogue_lines: 2,
  max_chars_per_line: 20,
};

const servers: ReturnType<typeof buildServer>[] = [];

afterEach(async () => {
  await Promise.all(servers.splice(0).map((server) => server.close()));
});

describe("backend skeleton", () => {
  it("reports healthy without claiming AI availability", async () => {
    const server = buildServer({ logger: false });
    servers.push(server);

    const response = await server.inject({
      method: "GET",
      url: "/health",
    });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toEqual({
      status: "ok",
      ai_available: false,
    });
  });

  it("returns a deterministic allowlisted fallback", async () => {
    const server = buildServer({ logger: false });
    servers.push(server);

    const response = await server.inject({
      method: "POST",
      url: "/v1/save-decision",
      payload: validRequest,
    });
    const body = response.json();

    expect(response.statusCode).toBe(200);
    expect(validRequest.allowed_decisions).toContain(body.decision);
    expect(validRequest.allowed_targets).toContain(body.target);
    expect(body.mutations).toEqual([]);
    expect(body.dialogue).toHaveLength(1);
  });

  it("returns 400 for a decision outside the whitelist", async () => {
    const server = buildServer({ logger: false });
    servers.push(server);

    const response = await server.inject({
      method: "POST",
      url: "/v1/save-decision",
      payload: {
        ...validRequest,
        allowed_decisions: ["DELETE_EVERYTHING"],
      },
    });

    expect(response.statusCode).toBe(400);
    expect(response.json().error).toBe("INVALID_REQUEST");
  });

  it("returns 400 when required request data is missing", async () => {
    const server = buildServer({ logger: false });
    servers.push(server);

    const response = await server.inject({
      method: "POST",
      url: "/v1/save-decision",
      payload: {
        session_id: "incomplete",
      },
    });

    expect(response.statusCode).toBe(400);
    expect(response.json().error).toBe("INVALID_REQUEST");
  });
});
