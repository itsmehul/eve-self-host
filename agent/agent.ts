import { defineAgent } from "eve";

export default defineAgent({
  model: "openai/gpt-5.6-luna-fast",
  experimental: {
    workflow: {
      world: "@workflow/world-postgres",
    },
  },
  build: {
    externalDependencies: ["@workflow/world-postgres"],
  },
});
