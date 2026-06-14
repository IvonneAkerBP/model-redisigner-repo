# Analytics Agentic Playbook — GitHub Copilot context

GitHub Copilot is the primary agent surface here: Power BI and Microsoft Fabric
development. This file tailors Copilot for this repo. The vendor-neutral methodology lives
in [`AGENTS.md`](../AGENTS.md) — read that first.

## Safety rules (non-negotiable)

- **Never write to a PROD workspace.** All changes go to a DEV workspace first; the user
  confirms before publishing.
- **Read before you change.** Audit and describe current state before suggesting any edit.
- **No secrets in chat.** Never ask for or accept connection strings, workspace GUIDs,
  passwords, or API keys.
- **Verify Fabric features against current docs.** This product changes weekly; use the
  `microsoft_learn` MCP to confirm a feature exists before recommending it.
- **Default Approvals mode.** Do not suggest Bypass Approvals or Autopilot; the user
  confirms all write operations.

## Power BI model-quality rules (field-tested)

- **`///` DAX comments are not Copilot grounding.** `///` shows only in VS Code / PBI
  Desktop tooltips. Power BI Copilot reads the TMDL `description:` field. Recommend
  `description:` on tables, key columns, and measures — not `///`.
- **SWITCH branch ordering.** Put the most restrictive condition first. Wrong order
  silently makes a branch unreachable.
- **Calculated columns vs Power Query.** Before adding a calculated column, check whether
  the derivation can live upstream in M or the source model. Calculated columns run as
  row-context scans at every refresh.
- **Auto date/time.** On a model with an existing Date table, it silently generates one
  hidden `LocalDateTable_*` per date column. Recommend disabling it.
- **Key consistency on shared dimensions.** Two fact tables joining one dimension must use
  the same key type. Mixed keys cause cross-filter inconsistencies invisible until validation.
- **Descriptions before Copilot Q&A.** Without `description:` fields, Copilot answers
  vaguely — it has no semantic context.

## When unsure

- Use `microsoft_learn` to fetch current docs before asserting Fabric or Power BI behavior.
- Ask the user to verify the result in the live workspace before proceeding.
- If a feature is geography-limited (for example, a US-only preview), say so explicitly.

## What NOT to do

- Do not invent M or DAX syntax from memory — verify with `context7` or `microsoft_learn`.
- Do not propose schema changes to a PROD semantic model without explicit user confirmation.
