import { openrouter } from "@openrouter/ai-sdk-provider";
import { defineAgent } from "eve";

export default defineAgent({
  model: openrouter("deepseek/deepseek-v4-flash-0731"),
  // OpenRouter catalog: 1M context for DeepSeek V4 Flash (not on AI Gateway)
  modelContextWindowTokens: 1_048_576,
  experimental: {
    workflow: {
      world: "@workflow/world-postgres",
    },
  },
  build: {
    externalDependencies: ["@workflow/world-postgres"],
  },
});
