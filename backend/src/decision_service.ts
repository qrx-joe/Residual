import type {
  SaveDecisionRequest,
  SaveDecisionResponse,
} from "./contracts.js";

export interface DecisionService {
  decide(request: SaveDecisionRequest): Promise<SaveDecisionResponse>;
}
