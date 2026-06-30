# AGENTS.md — Rebuild M&I

## Repo purpose

This repository supports the **rebuild and comparison** of Power BI reports. Each project
contains an `old-model` folder (read-only reference) and a `new-model` folder (the rebuild
target). The goal is to inspect old-model reports, apply field mappings and structural
changes, and produce equivalent reports in the new-model connected to a new semantic model.

## Folder structure

```
PBI projects/
  <Project Name>/
    old-model/    ← read-only reference — never modified
    new-model/    ← rebuild target — may be modified
```

Current projects:

| Project folder | New semantic model | New Fabric workspace |
|---|---|---|
| `Maintenance & Integrity - SMART Planoppnåelse` | `maintenance_and_integrity_dev` | `c_ent_maintenance_and_integrity_dev` |
| `Vedlikeholdsporteføljen - Åpne Arbeidsordre og Kommende PM03er` | *(TBD)* | *(TBD)* |

Old-model reports connect to the original semantic models in `OAD Datasets`.

## Field mapping file

Location: `mappings/field-mapping.csv`

Columns: `Old column name`, `Old table name`, `New column name`, `New table name`

This file drives the field replacement workflow. Always read it before applying any
field changes to new-model report files.

### Mapping file scope and project applicability

The mapping file is currently scoped to the **Maintenance & Integrity (M&I)** data model.
It is also used as the source of truth when applying field replacements to
**Vedlikeholdsporteføljen**, subject to the project-specific exceptions below.

### Vedlikeholdsporteføljen — project-specific exceptions

When applying the mapping file to the Vedlikeholdsporteføljen project:

- **`factMaterialCost`**: This table does not exist in the Vedlikeholdsporteføljen model.
  Ignore all field references belonging to `factMaterialCost` completely. Do not replace,
  flag as errors, or attempt to map them.
- **`dbt_gold dim_dates`**: This table may differ between models. Only apply a mapping for
  `dbt_gold dim_dates` fields if an explicit entry exists in the mapping file. Do not
  infer or assume mappings for date fields.
- Apply no other assumptions. Only replace fields that have an explicit row in the mapping
  file.

## Workflows

### 1 — Compare reports
1. Read old-model and new-model PBIP/PBIR files
2. Identify visible pages: `page.json` must NOT have `"visibility": 1`
3. Compare visuals side by side — type, fields, filters, position
4. Report differences; do not modify anything in this workflow

### 2 — Apply field mapping to new-model
1. Read `mappings/field-mapping.csv`
2. Read old-model visible pages and collect all field references
   (fields in `"Property"`, `"queryRef"`, `"nativeQueryRef"` inside each `visual.json`)
3. For each field reference that matches a row in the mapping, locate the corresponding
   `visual.json` in new-model and replace:
   - `"Entity"` value with `New table name`
   - `"Property"` value with `New column name`
   - `"queryRef"` value with `<New table name>.<New column name>`
   - `"nativeQueryRef"` value with `New column name`
4. Only modify files under `new-model/` — never touch `old-model/`
5. Only process visuals on visible pages (skip pages where `"visibility": 1`)
6. Confirm the list of changes with the user before writing any file

### 3 — Structural comparison via MCP
1. Connect to each semantic model separately (read-only) using workspace and model name
2. Query measures, tables, relationships
3. Do not write, alter, or create any model object

## Guardrails (non-negotiable)

- **old-model is read-only.** Never modify, rename, or delete any file in `old-model/`
- **new-model may be modified** only to apply field mappings or structural report changes
- **Do not modify semantic models** — no new measures, columns, or relationships
- **Do not commit** changes without user review
- **Confirm before writing** — always show the list of planned changes first
- **No secrets in chat** — never include connection strings, GUIDs, passwords, or API keys

## MCP usage guidance

- Connect to each model separately using its workspace and model name
- old-model MCP: read-only — inspect only
- new-model MCP: read-only for model objects; report files under `new-model/` may be written
- Do not use MCP to write, alter, or create any model object (tables, measures, columns)

## Imported Power BI agent resources

Reference material under `powerbi-agent-resources/plugins/`:
- fabric-cli, pbi-desktop, pbip, reports, semantic-models, tabular-editor

Use as read-only reference and skill guidance only.

## Naming conventions

- Measures: PascalCase (e.g. TotalRevenue, ActiveUsers)
- Tables: Fact/Dim prefixes where relevant
- Columns: Clear business names

## Styling & Themes

All reports must use the shared theme: `themes/theme.json`

1. Import theme in Power BI Desktop
2. Validate colors and fonts
3. Do not override theme unless explicitly required