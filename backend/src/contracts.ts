import { z } from "zod";

export const DecisionSchema = z.enum([
  "ALLOW",
  "PRESERVE",
  "DISTORT",
  "REFUSE",
]);

export const TargetSchema = z.enum([
  "azhi_audio",
  "photo_fragment",
  "operation_log",
  "failed_timeline",
  "ghost_save_slot",
]);

export const MutationSchema = z.enum([
  "spawn_ghost_audio",
  "spawn_photo_fragment",
  "rename_save_slot",
  "disable_delete_audio_button",
  "distort_noncritical_log",
  "show_ghost_save_slot",
  "delay_load_progress",
]);

export const ReasonCodeSchema = z.enum([
  "FIRST_DELETE",
  "REPEATED_DELETE",
  "BROKEN_PROMISE",
  "KEPT_PROMISE",
  "CONFESSION_ACCEPTED",
  "BARGAIN_ACCEPTED",
  "CONCEALMENT_DETECTED",
  "FORCED_OVERWRITE",
  "PROTECTED_MEMORY",
  "DEFAULT_ALLOW",
]);

export const SaveDecisionRequestSchema = z
  .object({
    session_id: z.string().trim().min(1).max(64),
    loop_index: z.number().int().min(1).max(99),
    persona: z
      .object({
        trust: z.number().int().min(-10).max(10),
        obsession: z.number().int().min(0).max(10),
        conflict: z.number().int().min(0).max(10),
        protected_target: TargetSchema.nullable(),
        broken_promises: z.number().int().min(0).max(10),
      })
      .strict(),
    recent_actions: z.array(z.string().trim().min(1).max(64)).max(20),
    allowed_decisions: z.array(DecisionSchema).min(1).max(4),
    allowed_targets: z.array(TargetSchema).min(1).max(5),
    allowed_mutations: z.array(MutationSchema).max(7),
    max_dialogue_lines: z.number().int().min(1).max(2),
    max_chars_per_line: z.number().int().min(1).max(20),
  })
  .strict();

export type SaveDecisionRequest = z.infer<
  typeof SaveDecisionRequestSchema
>;
export type Decision = z.infer<typeof DecisionSchema>;

export const SaveDecisionResponseSchema = z
  .object({
    decision: DecisionSchema,
    reason_code: ReasonCodeSchema,
    target: TargetSchema,
    mutations: z.array(MutationSchema).max(7),
    dialogue: z.array(z.string()).min(1).max(2),
    persona_delta: z
      .object({
        trust: z.number().int().min(-2).max(2),
        obsession: z.number().int().min(-2).max(2),
        conflict: z.number().int().min(-2).max(2),
      })
      .strict(),
  })
  .strict();

export type SaveDecisionResponse = z.infer<
  typeof SaveDecisionResponseSchema
>;
