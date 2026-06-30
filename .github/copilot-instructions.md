# Rebuild M&I — GitHub Copilot context

This repo supports the **rebuild and comparison** of Power BI reports. Each project has an
`old-model` folder (read-only reference) and a `new-model` folder (rebuild target).
The full workflow is defined in [`AGENTS.md`](../AGENTS.md) — read that first.

## Repo purpose (non-negotiable)

- **old-model is read-only.** Never modify, rename, or delete any file in `old-model/`.
- **new-model may be modified** to apply field mappings and structural report changes.
- **Do not modify semantic models** — no new measures, columns, or relationships.
- **Do not commit** changes without user review.
- **Confirm before writing** — always show the list of planned changes first.

## Folder structure

```
PBI projects/
  <Project Name>/
    old-model/    ← read-only reference
    new-model/    ← rebuild target
```

Current projects:

| Project | New semantic model | New Fabric workspace |
|---|---|---|
| `Maintenance & Integrity - SMART Planoppnåelse` | `maintenance_and_integrity_dev` | `c_ent_maintenance_and_integrity_dev` |
| `Vedlikeholdsporteføljen - Åpne Arbeidsordre og Kommende PM03er` | *(TBD)* | *(TBD)* |

## Field mapping file

Location: `mappings/field-mapping.csv`

Columns: `Old column name`, `Old table name`, `New column name`, `New table name`

Always read this file before applying any field changes to new-model reports.

## Safety rules (non-negotiable)

- **No secrets in chat.** Never ask for or accept connection strings, workspace GUIDs,
  passwords, or API keys.
- **Read before you modify.** Inspect the actual PBIP/PBIR files before making changes.
- **Default Approvals mode.** Do not suggest Bypass Approvals or Autopilot.
- **Verify Fabric features against current docs.** Use `microsoft_learn` MCP to confirm
  behavior before asserting it.

## MCP usage guidance

- old-model MCP: **read-only** — inspect tables, measures, and relationships only
- new-model MCP: **read-only for model objects**; report files under `new-model/` may be written
- Do not use MCP to write, alter, or create any model object (tables, measures, columns)

## When unsure

- Use `microsoft_learn` to fetch current docs before asserting Power BI or Fabric behavior.
- Ask the user to verify results in the live workspace before proceeding.
- If a feature is geography-limited (for example, a US-only preview), say so explicitly.