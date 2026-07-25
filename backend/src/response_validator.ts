import {
  SaveDecisionResponseSchema,
  type SaveDecisionRequest,
  type SaveDecisionResponse,
} from "./contracts.js";

export function validateModelDecision(
  value: unknown,
  request: SaveDecisionRequest,
): SaveDecisionResponse | null {
  const parsed = SaveDecisionResponseSchema.safeParse(value);
  if (!parsed.success) {
    return null;
  }
  const response = parsed.data;
  if (!request.allowed_decisions.includes(response.decision)) {
    return null;
  }
  if (!request.allowed_targets.includes(response.target)) {
    return null;
  }
  if (
    response.mutations.some(
      (mutation) => !request.allowed_mutations.includes(mutation),
    )
  ) {
    return null;
  }
  if (response.dialogue.length > request.max_dialogue_lines) {
    return null;
  }
  if (
    response.dialogue.some(
      (line) =>
        Array.from(line).length > request.max_chars_per_line,
    )
  ) {
    return null;
  }
  return response;
}
