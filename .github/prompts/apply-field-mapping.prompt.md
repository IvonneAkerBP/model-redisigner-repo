---
mode: agent
description: Apply the field mapping CSV to replace old-model field references in new-model visuals on visible pages. Read-only on old-model; writes only to new-model visual.json files. Always confirms changes before writing.
---

# Apply Field Mapping to New-Model Report

## Your task

Replace all field references in the new-model report that correspond to rows in the
field mapping file. Only process visuals on visible pages. Never touch old-model files.

## Step-by-step instructions

### Step 1 — Read the mapping file

Read `data references/Input til PowerBI.xlsx`. Each sheet corresponds to a Fabric table
and defines the columns available in the new model. Use this to identify:

| What to find | Where to look |
|---|---|
| New table names | Sheet names (each sheet = one Fabric table) |
| New column names | Column headers within each sheet |
| Old-to-new mapping | Compare old-model field names to the corresponding sheet columns |

Read all relevant sheets. Ignore sheets that do not correspond to tables used in the report.

### Step 2 — Identify the target project

Ask the user which project to process if not already specified, e.g.:
- `Maintenance & Integrity - SMART Planoppnåelse`
- `Vedlikeholdsporteføljen - Åpne Arbeidsordre og Kommende PM03er`

The paths are:
- Old-model: `PBI projects/<Project Name>/old-model/`
- New-model: `PBI projects/<Project Name>/new-model/`

### Step 3 — Find visible pages in old-model

Read each `page.json` under:
`PBI projects/<Project Name>/old-model/<Report>.Report/definition/pages/`

A page is **visible** if its `page.json` does NOT contain `"visibility": 1`.
Skip any page where `"visibility": 1` is present.

Collect the folder names of all visible pages.

### Step 4 — Scan old-model visuals for matching field references

For each visible page, read every `visual.json` under that page's `visuals/` folder.

In each visual, search for field references in these locations:
- `"Entity"` inside any `Column` or `Measure` expression — table name
- `"Property"` inside any `Column` or `Measure` expression — column/measure name
- `"queryRef"` — typically `"<Table>.<Column>"` format
- `"nativeQueryRef"` — typically just the column name

A field reference **matches** a mapping row when both:
- The `"Entity"` value equals `Old table name`, AND
- The `"Property"` value equals `Old column name`

Record every match: visual ID, page ID, JSON path to the field reference, and the
replacement values from the mapping row.

### Step 5 — Show the planned changes

Before writing anything, present a table of all planned replacements:

| Page | Visual ID | Old Entity | Old Property | New Entity | New Property |
|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | ... |

Ask the user: **"Confirm to apply these N changes to new-model?"**

Do not proceed until confirmed.

### Step 6 — Apply changes to new-model visuals

For each confirmed change, open the corresponding `visual.json` in new-model at the
same page ID and visual ID path:
`PBI projects/<Project Name>/new-model/<Report>.Report/definition/pages/<PageID>/visuals/<VisualID>/visual.json`

Apply these replacements in that file:
- `"Entity"` → `New table name`
- `"Property"` → `New column name`
- `"queryRef"` → `<New table name>.<New column name>`
- `"nativeQueryRef"` → `New column name`

Make all replacements for that visual in a single edit operation.

### Step 7 — Report results

After writing, list:
- Files modified (with paths)
- Total replacements made
- Any mapping rows that had no match in any visible-page visual (so the user knows
  what was not applied)

## Hard rules

- **Never modify any file in `old-model/`**
- **Never modify semantic model files** (TMDL, `.dataset`, model JSON)
- **Only process visuals on visible pages** — skip hidden pages entirely
- **Confirm before every write** — no silent changes
- **If `data references/Input til PowerBI.xlsx` is missing or unreadable**, stop and ask
  the user to verify the file is present before running this prompt
