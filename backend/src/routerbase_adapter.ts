import { z } from "zod";

import type {
  SaveDecisionRequest,
  SaveDecisionResponse,
} from "./contracts.js";
import type { DecisionService } from "./decision_service.js";
import { createLocalFallback } from "./fallback.js";
import { validateModelDecision } from "./response_validator.js";

const SYSTEM_PROMPT = `你是游戏中的存档系统 SAVE_03。
你不是聊天助手，也不是故事作者。
你只能从请求给出的 allowed_decisions 中选择一项。
target 必须来自 allowed_targets。
mutations 必须来自 allowed_mutations。
不得创建新角色、新证据、新结局或新规则。
dialogue 不得超过请求给出的行数和每行字数。
只返回符合约定的 JSON 对象，不要返回 Markdown。`;

const ChatCompletionSchema = z.object({
  choices: z
    .array(
      z.object({
        message: z.object({
          content: z.string().min(1),
        }),
      }),
    )
    .min(1),
});

class RetryableAdapterError extends Error {}
class NonRetryableAdapterError extends Error {}

export interface RouterBaseAdapterOptions {
  apiKey: string;
  model: string;
  baseUrl?: string;
  timeoutMs?: number;
  fetchImplementation?: typeof fetch;
}

export class RouterBaseAdapter implements DecisionService {
  private readonly apiKey: string;
  private readonly model: string;
  private readonly endpoint: string;
  private readonly timeoutMs: number;
  private readonly fetchImplementation: typeof fetch;

  constructor(options: RouterBaseAdapterOptions) {
    this.apiKey = options.apiKey;
    this.model = options.model;
    this.endpoint = `${(
      options.baseUrl ?? "https://routerbase.com/v1"
    ).replace(/\/+$/, "")}/chat/completions`;
    this.timeoutMs = options.timeoutMs ?? 5_000;
    this.fetchImplementation = options.fetchImplementation ?? fetch;
  }

  async decide(
    request: SaveDecisionRequest,
  ): Promise<SaveDecisionResponse> {
    const deadline = Date.now() + this.timeoutMs;
    for (let attempt = 0; attempt < 2; attempt += 1) {
      const remainingMs = deadline - Date.now();
      if (remainingMs <= 0) {
        break;
      }
      try {
        return await this.requestDecision(request, remainingMs);
      } catch (error) {
        if (error instanceof NonRetryableAdapterError) {
          break;
        }
        if (!(error instanceof RetryableAdapterError)) {
          break;
        }
      }
    }
    return createLocalFallback(request);
  }

  private async requestDecision(
    request: SaveDecisionRequest,
    remainingMs: number,
  ): Promise<SaveDecisionResponse> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), remainingMs);
    try {
      const response = await this.fetchImplementation(this.endpoint, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: this.model,
          messages: [
            { role: "system", content: SYSTEM_PROMPT },
            {
              role: "user",
              content: JSON.stringify(request),
            },
          ],
          temperature: 0.2,
          max_tokens: 300,
          response_format: { type: "json_object" },
          stream: false,
        }),
        signal: controller.signal,
      });

      if (!response.ok) {
        if (
          response.status === 429
          || response.status === 455
          || response.status >= 500
        ) {
          throw new RetryableAdapterError(
            `RouterBase retryable status ${response.status}`,
          );
        }
        throw new NonRetryableAdapterError(
          `RouterBase status ${response.status}`,
        );
      }

      const envelope = ChatCompletionSchema.safeParse(
        await response.json(),
      );
      if (!envelope.success) {
        throw new RetryableAdapterError(
          "RouterBase response envelope invalid",
        );
      }
      const content = envelope.data.choices[0]?.message.content;
      if (content === undefined) {
        throw new RetryableAdapterError(
          "RouterBase response content missing",
        );
      }

      let modelValue: unknown;
      try {
        modelValue = JSON.parse(content);
      } catch {
        throw new RetryableAdapterError(
          "RouterBase model output was not JSON",
        );
      }
      const validated = validateModelDecision(modelValue, request);
      if (validated === null) {
        throw new RetryableAdapterError(
          "RouterBase model output violated the contract",
        );
      }
      return validated;
    } catch (error) {
      if (
        error instanceof RetryableAdapterError
        || error instanceof NonRetryableAdapterError
      ) {
        throw error;
      }
      throw new RetryableAdapterError("RouterBase request failed");
    } finally {
      clearTimeout(timeout);
    }
  }
}
