---
name: ai-cost-optimizer
description: Use when reviewing or planning AI work for token/credit cost — in GitHub Copilot Chat or any agent that calls a model API. Returns the cost levers to apply, flags the ones missing, and gives a first-prompt checklist. Grounded in the GitHub Copilot and VS Code cost docs (verified 2026-06-04 — re-verify on use; prices change monthly).
---

# AI cost optimizer

Keep token/credit cost low without losing quality. Two surfaces: GitHub Copilot Chat (what AkerBP uses)
and raw model APIs (general agents). Full lesson: [keep AI cost low](../../../docs/how-to/optimize-ai-cost.md).

## Three levers (everywhere)

1. Cheapest capable model.
2. Fewer input tokens — reuse/front-load stable context.
3. Fewer output tokens — cap generation.

Two ratios decide most of it (verified): cached input ≈ **10%** of fresh input; output ≈ **5–8×** input.
Inline completions are unlimited and not billed — spend credits in chat.

## In GitHub Copilot Chat

- Match model to task by category: **Lightweight** (edits, Q&A) · **Versatile** · **Powerful** (only hard,
  multi-file reasoning). **Auto** routes for you; the picker hover shows a cost tier.
- Keep the **1M-token context window** and **higher reasoning** off by default; raise only for hard tasks.
- Plan with a strong model, implement with a cheap one.
- One task per chat; new chat on a topic switch; `/fork` to branch.
- Disable unused tools/MCP servers; exclude large/generated files (`.gitignore`, `files.exclude`).
- `/compact` long sessions.

## In a raw model API (general agents)

- Route by complexity; lower the effort/reasoning parameter on easy tasks (thinking bills as output).
- Cache stable context (a read ≈ 10% of fresh input). Put the cache breakpoint on the **last identical
  block** — never on a timestamp or the user message, or you pay a fresh write every call.
- Cap output.
- Batch non-urgent work (≈ **50%** off, stacks with caching).
- Trim agent context: auto-clear old tool results past a threshold; offload to a memory file.

## Measure — you cannot optimize what you cannot see

- Copilot status dashboard (Status Bar): % of monthly allowance used.
- Agent Debug Logs → Cache Explorer: cache hit rate + reused input tokens.
- `/chronicle:cost-tips`: personalized recommendations.
- API: read the usage block; watch the cache read-to-write ratio.

## Test it on ourselves before teaching it

1. Pick a repeated task. 2. Baseline it (model + dashboard delta). 3. Apply **one** lever. 4. Re-run;
compare tokens/credits **and** quality. 5. Keep or discard — dated, with the model name. Name one owner.

## First-prompt checklist

- [ ] Smallest capable model; extended context + higher reasoning off unless needed.
- [ ] One task per chat; `/fork` to branch.
- [ ] Only needed tools/MCP enabled; large/generated files excluded.
- [ ] Plan with a strong model, implement with a cheap one.
- [ ] (API) stable context cached behind a correct breakpoint; output capped; bulk batched.
- [ ] Watch the dashboard / Cache Explorer — confirm the saving.

## Sources (verified 2026-06-04 — re-verify; prices change monthly)

- [GitHub Copilot — Models and pricing](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing)
- [GitHub Copilot — Supported AI models (extended capabilities)](https://docs.github.com/en/copilot/reference/ai-models/supported-models)
- [VS Code — Optimize AI credit usage](https://code.visualstudio.com/docs/agents/guides/optimize-usage)
