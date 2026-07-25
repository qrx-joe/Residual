import type {
  Decision,
  SaveDecisionRequest,
  SaveDecisionResponse,
} from "./contracts.js";

const DIALOGUE_BY_DECISION: Record<Decision, string[]> = {
  ALLOW: ["可以。", "这次我会记住。"],
  PRESERVE: ["录音留下。"],
  DISTORT: ["记录不会消失。"],
  REFUSE: ["这次，我拒绝。"],
};

const REASON_BY_DECISION: Record<
  Decision,
  SaveDecisionResponse["reason_code"]
> = {
  ALLOW: "DEFAULT_ALLOW",
  PRESERVE: "PROTECTED_MEMORY",
  DISTORT: "CONCEALMENT_DETECTED",
  REFUSE: "FORCED_OVERWRITE",
};

export function createLocalFallback(
  request: SaveDecisionRequest,
): SaveDecisionResponse {
  const decision = request.allowed_decisions[0];
  const target = request.allowed_targets[0];
  if (decision === undefined || target === undefined) {
    throw new Error("Validated request omitted a required allowlist");
  }
  const dialogue = DIALOGUE_BY_DECISION[decision]
    .slice(0, request.max_dialogue_lines)
    .map((line) => line.slice(0, request.max_chars_per_line));

  return {
    decision,
    reason_code: REASON_BY_DECISION[decision],
    target,
    mutations: [],
    dialogue,
    persona_delta: {
      trust: 0,
      obsession: 0,
      conflict: 0,
    },
  };
}
