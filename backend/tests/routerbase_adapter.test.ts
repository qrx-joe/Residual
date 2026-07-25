import { describe, expect, it, vi } from "vitest";

import type {
  SaveDecisionRequest,
  SaveDecisionResponse,
} from "../src/contracts.js";
import { createLocalFallback } from "../src/fallback.js";
import { RouterBaseAdapter } from "../src/routerbase_adapter.js";

const request: SaveDecisionRequest = {
  session_id: "routerbase-test",
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

const validModelDecision: SaveDecisionResponse = {
  decision: "PRESERVE",
  reason_code: "BROKEN_PROMISE",
  target: "azhi_audio",
  mutations: ["spawn_ghost_audio"],
  dialogue: ["你答应过我。", "这次，录音留下。"],
  persona_delta: {
    trust: -1,
    obsession: 1,
    conflict: 0,
  },
};

function chatResponse(content: string, status = 200): Response {
  return new Response(
    JSON.stringify({
      choices: [
        {
          message: {
            role: "assistant",
            content,
          },
        },
      ],
    }),
    {
      status,
      headers: { "Content-Type": "application/json" },
    },
  );
}

function createAdapter(
  fetchImplementation: typeof fetch,
  timeoutMs = 5_000,
): RouterBaseAdapter {
  return new RouterBaseAdapter({
    apiKey: "unit-test",
    model: "google/gemini-2.5-flash",
    timeoutMs,
    fetchImplementation,
  });
}

describe("RouterBaseAdapter", () => {
  it("sends JSON mode and accepts a fully allowlisted result", async () => {
    const fetchMock = vi.fn<typeof fetch>().mockResolvedValue(
      chatResponse(JSON.stringify(validModelDecision)),
    );
    const adapter = createAdapter(fetchMock);

    const result = await adapter.decide(request);

    expect(result).toEqual(validModelDecision);
    expect(fetchMock).toHaveBeenCalledTimes(1);
    const [url, options] = fetchMock.mock.calls[0] ?? [];
    expect(url).toBe(
      "https://routerbase.com/v1/chat/completions",
    );
    const body = JSON.parse(String(options?.body));
    expect(body.response_format).toEqual({ type: "json_object" });
    expect(body.stream).toBe(false);
    expect(body.model).toBe("google/gemini-2.5-flash");
    expect(options?.headers).toMatchObject({
      Authorization: "Bearer unit-test",
      "Content-Type": "application/json",
    });
  });

  it("retries one transient failure inside the total budget", async () => {
    const fetchMock = vi
      .fn<typeof fetch>()
      .mockResolvedValueOnce(new Response(null, { status: 455 }))
      .mockResolvedValueOnce(
        chatResponse(JSON.stringify(validModelDecision)),
      );
    const adapter = createAdapter(fetchMock);

    const result = await adapter.decide(request);

    expect(result).toEqual(validModelDecision);
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it("does not retry a non-retryable authentication failure", async () => {
    const fetchMock = vi
      .fn<typeof fetch>()
      .mockResolvedValue(new Response(null, { status: 401 }));
    const adapter = createAdapter(fetchMock);

    const result = await adapter.decide(request);

    expect(result).toEqual(createLocalFallback(request));
    expect(fetchMock).toHaveBeenCalledTimes(1);
  });

  it("falls back after invalid JSON and one retry", async () => {
    const fetchMock = vi
      .fn<typeof fetch>()
      .mockResolvedValue(chatResponse("not-json"));
    const adapter = createAdapter(fetchMock);

    const result = await adapter.decide(request);

    expect(result).toEqual(createLocalFallback(request));
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it("rejects a mutation outside the request allowlist", async () => {
    const illegalDecision = {
      ...validModelDecision,
      mutations: ["rename_save_slot"],
    };
    const fetchMock = vi.fn<typeof fetch>().mockResolvedValue(
      chatResponse(JSON.stringify(illegalDecision)),
    );
    const adapter = createAdapter(fetchMock);

    const result = await adapter.decide(request);

    expect(result).toEqual(createLocalFallback(request));
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it("rejects a decision outside the request allowlist", async () => {
    const illegalDecision = {
      ...validModelDecision,
      decision: "ALLOW",
      reason_code: "DEFAULT_ALLOW",
    };
    const fetchMock = vi.fn<typeof fetch>().mockResolvedValue(
      chatResponse(JSON.stringify(illegalDecision)),
    );
    const adapter = createAdapter(fetchMock);

    const result = await adapter.decide(request);

    expect(result).toEqual(createLocalFallback(request));
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it("uses one five-second-style total timeout budget", async () => {
    const fetchMock = vi.fn<typeof fetch>().mockImplementation(
      async (_input, options) =>
        new Promise<Response>((_resolve, reject) => {
          options?.signal?.addEventListener(
            "abort",
            () => reject(new Error("aborted")),
            { once: true },
          );
        }),
    );
    const adapter = createAdapter(fetchMock, 25);
    const startedAt = performance.now();

    const result = await adapter.decide(request);
    const elapsedMs = performance.now() - startedAt;

    expect(result).toEqual(createLocalFallback(request));
    expect(elapsedMs).toBeLessThan(250);
    expect(fetchMock.mock.calls.length).toBeGreaterThanOrEqual(1);
    expect(fetchMock.mock.calls.length).toBeLessThanOrEqual(2);
  });

  it("rejects dialogue over the caller's text budget", async () => {
    const overBudgetDecision = {
      ...validModelDecision,
      dialogue: ["这是一句明显超过本次允许长度的模型输出文本。"],
    };
    const fetchMock = vi.fn<typeof fetch>().mockResolvedValue(
      chatResponse(JSON.stringify(overBudgetDecision)),
    );
    const adapter = createAdapter(fetchMock);

    const result = await adapter.decide({
      ...request,
      max_chars_per_line: 8,
    });

    expect(result).toEqual(
      createLocalFallback({
        ...request,
        max_chars_per_line: 8,
      }),
    );
  });
});
