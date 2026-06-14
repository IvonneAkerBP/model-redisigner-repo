---
description: Review a Copilot chat session, workflow, or doc for token/credit cost and return the levers to apply.
agent: ask
argument-hint: paste the workflow/prompt/session to cost-review (or name the task)
---
Review what I am about to run, or just ran, for AI cost. Tell me how to do it cheaper without losing quality.

Check, in order:

1. **Model fit** — is the model heavier than the task needs? Name a lighter category (Lightweight / Versatile / Powerful) if so.
2. **Extended capabilities** — is the 1M-token context window or higher reasoning on when the task does not need it?
3. **Input size** — is stable context (instructions, tool definitions, reference material) being re-sent instead of cached or front-loaded?
4. **Output size** — is the output uncapped or verbose when a terse, structured answer would do?
5. **Session hygiene** — is unrelated history, unused tools/MCP servers, or large/generated files inflating the context? Should this be a new chat or a `/fork`?
6. **(API only) batching** — is non-urgent bulk work going through a real-time call instead of a batch?

Return three things: the levers to apply now (concrete, in priority order); the single measurement that will confirm it worked (status dashboard %, Cache Explorer hit-rate, or the API usage block); and any claim you could not ground. Do not invent prices — if a number is needed, point me to the live pricing page.
