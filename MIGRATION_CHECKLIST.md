# MIGRATION_CHECKLIST.md

# Migration Status

This section is the working status of the current migration.

Treat this section as the source of truth for the migration progress.

This is a living document and must be updated continuously throughout the project.

At the beginning of every work session:

- Read this section first.
- Determine the current migration phase.
- Review the latest notes and outstanding items.
- Resume work from the recorded state instead of repeating completed work.

At the end of every work session:

- Update the current phase.
- Mark completed checklist items.
- Record important decisions.
- Document any unresolved questions.
- Record validation results.
- Record any risks or assumptions identified during the session.

Never delete historical notes.

Always append new notes in chronological order so the migration history is preserved.

---

## Project

Record the name of the active project.

Update this if the user switches to another project.

**Current Project:** Project 1 — Environmental KPIs

---

## Current Phase

Exactly one phase should represent the current state of the migration.

Only move to the next phase after the previous phase has been completed and validated.

- [x] Discovery (complete — see migration/discovery.md)
- [x] Dependency Analysis (complete — see migration/dependencies.md)
- [x] Schema Comparison / Mapping Analysis (complete — see migration/field-mapping.md)
- [x] Migration Planning (plan approved — see migration/migration-plan.md)
- [x] Migration — Gate 0 PASSED (2026-07-03 — see implementation-log.md)
- [x] Migration — Strategy B approved; migration-plan.md revised (2026-07-03)
- [x] Migration — Preparation COMPLETE: Created HistoricalAirRef, HistoricalSeaRef, CombinedAirRef, CombinedSeaRef — static + runtime validation PASSED (2026-07-06 — see implementation-log.md)
- [x] Migration — Unit 1 Phase A COMPLETE: Added `KPI CO2 tonn REF` column to `Emissions to air` — validation PASSED (2026-07-06 — see implementation-log.md)
- [x] Migration — Unit 1 Phase B COMPLETE: `KPI CO2 tonn` now sourced from CombinedAirRef; SQL CASE removed — validation PASSED (2026-07-06 — see implementation-log.md)
- [x] Migration — Unit 2 Phase B COMPLETE: `Tillatelse CH4` and `KPI CH4` sourced from CombinedAirRef; SQL CASE removed; field mapping fix applied; DR004 correction confirmed — validation PASSED (2026-07-07)
- [x] Migration — Unit 3 Sub-unit 3A COMPLETE: `Permit nmVOC` and `KPI nmVOC` in `Emissions to air` sourced from CombinedAirRef; SQL CASE removed; rig routing validated (104/105 exact match, Hod A NULL preserved); measures unchanged — validation PASSED (2026-07-07)
- [x] Migration — Unit 3 Sub-unit 3B Phase A COMPLETE: `Tillatelse nmVOC REF` and `KPI nmVOC REF` added to `CH4_NMVOC` via CombinedAirRef (two-metric DR005 design); combustion branch defect documented; DR005 satellite trade-off confirmed — validation PASSED (2026-07-08)
- [ ] Migration
- [ ] Validation
- [ ] Cleanup
- [ ] Completed

---

## Migration Inventory

Document: `migration/migration-inventory.md`

Confirmed candidate scope figures (updated after Dependency Analysis):

- 5 candidate fact tables
- 5 candidate reference table roles (hypothesis — Fabric names TBD)
- 11 candidate measures
- **42 visuals** containing migration candidates (corrected from 35 after Dependency Analysis)
- 0 page filters, 0 visual filters, 0 slicers affected
- 5 bookmarks with stale-state risk (no filter expression risk)
- `Emissions to air CO2 Hod` — confirmed not in scope for reference data migration
- 2 pre-existing broken visuals on KPI discharge to sea (Fact Target, Time — out of scope)
- Overall scope: **High**

---

## Phase Completion Reports

### Phase 1 — Discovery

**Completed:** 2026-07-03

**Deliverables produced:**
- `migration/discovery.md` — full model and report inventory
- `migration/migration-inventory.md` — candidate migration scope

**Key findings:**
- All 5 fact tables embed permit and KPI values as hardcoded SQL CASE statements or Power Query conditionals
- 5 distinct business domains of reference data identified (air emissions, CH4/NMVOC, cold vent, oily water, radioactive isotopes)
- 25 candidate reference columns identified across 5 tables
- 11 measures reference candidate columns in DAX
- Report has 3 in-scope pages and 5 bookmarks
- `Emissions to air CO2 Hod` — purpose unknown, confirmed no candidate reference data in Dependency Analysis
- 2 pre-existing broken visuals confirmed (Fact Target, Time) on in-scope page
- No Fabric replacement tables are present in the semantic model

**Outstanding questions carried to next phase:**
1. Business purpose of `Emissions to air CO2 Hod`
2. Source Fabric tables for CH4_NMVOC, Kaldvent volum, Radioaktive isotoper
3. Structure and content of `Input til PowerBI.xlsx`

---

### Phase 2 — Dependency Analysis

**Completed:** 2026-07-03

**Deliverables produced:**
- `migration/dependencies.md` — full dependency inventory
- `migration/migration-inventory.md` — visual count corrected from 35 to 42

**Key findings:**
- 0 page-level filters, 0 visual-level filters, 0 slicers reference candidate columns
- 42 visuals confirmed as migration candidates (7 additional found vs Discovery)
- `Radioaktive isotoper.KPIs` has confirmed direct visual bindings (3 visuals on KPI discharge to sea)
- `Division` direct bindings exhaustively confirmed: exactly 2 visuals (`2eab323e541360477545`, `ecd20f287253686f6d00`)
- All 5 bookmarks store visual query states referencing candidate column names; no bookmark filter expressions reference candidate columns
- `Emissions to air CO2 Hod` confirmed: contains no candidate reference columns
- `Tillatelse flaring QTD` — appears in cached metadata of 24 visual files but does not exist in the semantic model; no active dependency
- `Permit Cold ventilated gas`, `KPI Cold ventilated gas`, `Kaldvent volum.Division`, and `Month` — no confirmed direct visual bindings found

**Outstanding questions carried to next phase:**
1. Business purpose of `Emissions to air CO2 Hod` (carried forward)
2. Whether `Radioaktive isotoper.KPIs` will remain a column or move to DAX (affects 3 visual bindings)
3. Source Fabric tables for CH4_NMVOC, Kaldvent volum, Radioaktive isotoper (Mapping Analysis)
4. Structure and content of `Input til PowerBI.xlsx` (Mapping Analysis)

**No implementation changes were made during Phases 1 or 2.** All work was analysis and documentation.

---

### Phase 3 — Schema Comparison / Mapping Analysis

**Completed:** 2026-07-03

**Deliverables produced:**
- `migration/field-mapping.md` — full mapping analysis with evidence, confidence levels, and open questions

**Workbook inspection findings:**
- `Input til PowerBI.xlsx` contains 8 worksheets
- Two worksheets directly correspond to migration domains: `permit_kpi_to_air` (219 rows × 12 cols) and `permit_kpi_to_sea`
- `permit_kpi_to_air` confirmed structure: Metric | Field | Unit | 2025–2032 annual values | Comment
- Confirmed sample metric: “CO2 KPI Year” for Ivar Aasen (25,000 tonn 2026) and Edvard Grieg (26,000 tonn 2026) — maps to `KPI CO2 tonn` in model
- No worksheet found for radioactive isotope permits

**Table-level mappings:**
- T1 `permit_kpi_to_air` → air emissions reference (Emissions to air, CH4_NMVOC, Kaldvent volum) — **High confidence**
- T2 `permit_kpi_to_sea` → sea discharge reference (Oily water) — **High confidence**
- T3 `Drenasjevann` → drain water reference (Oily water partial) — **Medium confidence**
- T4 Radioaktive isotoper permits — **Low confidence, no candidate identified**

**Key structural risks identified:**
1. Wide-format workbook (year columns) vs. row-level model data — transformation approach unknown
2. Workbook covers 2025–2032 only; model has data from 2019 — historical gap
3. CH4_NMVOC uses facility-level granularity; workbook sample showed field-level only
4. Kaldvent volum requires quarterly values; workbook has annual columns
5. KPI flaring uses two-stage derivation; workbook coverage unknown
6. No Fabric reference tables exist in the model yet

**10 open questions** raised, all requiring user or business owner input before Migration Planning can begin. See `migration/field-mapping.md` Section 8.

**No implementation changes were made during Phase 3.** All work was analysis and documentation.

---

### Phase 3 — Schema Comparison / Mapping Analysis (Full Worksheet Analysis)

**Updated:** 2026-07-03

**Additional deliverable:**
- `migration/field-mapping.md` — completely updated with full worksheet analysis of all 8 workbook sheets

**Full workbook inspection findings:**

`permit_kpi_to_air` — 20 confirmed metrics:
CO2 KPI Year, CO2 KPI YTD, Flaring KPI, Flaring Permit, MainField CH4 KPI, MainField CH4 permit, Mainfield nmVOC KPI, Mainfield nmVOC Permit, Mainfield NOX KPI, Mainfield NOX Permit, Main field SOx KPI, Main field SOx permit, Rig NOX KPI, Rig NOX Permit, Rig nmVOC KPI, Rig nmVOC Permit, Rig SOx KPI, Rig SOx permit, Vented gas KPI, Vented gas permit

`permit_kpi_to_sea` — First confirmed metric: "Radium 228 Tillatelse" — resolves the radioactive isotope mapping (previously Low confidence, now High confidence)

`Drenasjevann` — 8 rows covering 4 drilling rigs, KPI=10 / Grense=15 for drain water discharge

**Key findings from full analysis:**
1. All candidate air emission columns have a confirmed metric match in `permit_kpi_to_air`
2. Radioactive isotope permits confirmed in `permit_kpi_to_sea` — "Radium 228 Tillatelse" with field values
3. "Flaring KPI" is directly in the workbook — the two-stage SQL derivation logic may be replaceable by a direct lookup
4. Granularity concern for CH4_NMVOC **resolved** — field-level permits are compatible with the DAX MAX pattern
5. Rig vs main field distinction identified — `Emissions to air` join strategy must handle both metric types
6. Historical gap confirmed — workbook covers 2025+, model has 2019+ data
7. Oily water metrics in `permit_kpi_to_sea` not yet confirmed (only first 7 rows read)
8. `utslipp_til_luft` structure still not read; cannot determine migration relevance

**Revised confidence levels:**
- Radioaktive isotoper: Low → **High** (permit confirmed in permit_kpi_to_sea)
- CH4_NMVOC granularity concern: Resolved — **High** confidence
- Kaldvent volum QTD KPI: **Medium** — annual permit maps directly but quarterly computation needs separate design
- Oily water: **Medium** — `permit_kpi_to_sea` candidate confirmed, but oily water metrics not yet seen

**Open questions reduced from 10 to 6.** See `migration/field-mapping.md` Section 8.

**No implementation changes were made.** All work was analysis and documentation.

---

### Phase 3 — Fabric Tables Imported into Semantic Model

**Confirmed:** 2026-07-03

Two Fabric reference tables were imported into the new-model semantic model:

| Semantic model table name | Fabric source | Columns |
|--------------------------|--------------|---------|
| `dbt_gold_nems_emission fact_nems__permit_kpi_to_air` | `wh_gold_hsseq.dbt_gold_nems_emission.fact_nems__permit_kpi_to_air` | `metric`, `field`, `unit`, `year`, `value_permit_kpi` |
| `dbt_gold_nems_emission fact_nems__permit_kpi_to_sea` | `wh_gold_hsseq.dbt_gold_nems_emission.fact_nems__permit_kpi_to_sea` | `metric`, `field`, `year`, `value_permit_kpi` |

**Key finding:** Both tables are in **tall format** (metric × field × year → value_permit_kpi). The wide-format concern from mapping analysis is resolved.

**`Drenasjevann` was not imported** — deferred pending confirmation that `permit_kpi_to_sea` covers rig drain water.

**No relationships have been defined yet.** The new tables are present in the model but not connected to any fact table.

**Next steps:**
1. Validate distinct metric and field names in both Fabric tables against expected values.
2. Compare sample values against hardcoded SQL values for numerical confirmation.
3. Confirm rig facility names, Component values, and metric names needed for Power Query merge column mappings.
4. Create `CombinedAirRef` and `CombinedSeaRef` Power Query queries (see `migration/migration-plan.md` Combined Reference Queries section).
5. Proceed to Unit 1.

---

## Migration Owner

Record who is responsible for approving migration decisions.

Unless specified otherwise:

User

---

## Session Summary

Briefly summarize what was completed during the latest work session.

Keep this concise (3–10 bullet points).

Include items such as:

- Objects analyzed
- Objects modified
- Validation completed
- Decisions made

---

## Outstanding Work

List everything that still needs to be completed before the migration can continue or finish.

Include:

- Remaining migration tasks
- Pending validations
- Open business questions
- Required user decisions

---

## Decisions Log

Record important migration decisions.

For each decision include:

- Date
- Decision
- Reason
- Approved by

Append new decisions to the end of the list.

Never overwrite previous decisions.

---

## Risks and Assumptions

Document any risks, assumptions or uncertainties identified during the migration.

Examples include:

- Possible data quality issues
- Missing mappings
- Unverified business logic
- Performance concerns
- Pending confirmations

Update this section whenever new risks are identified or existing risks are resolved.

---

## Validation Summary

Maintain a running summary of validation results.

Record:

- Measures validated
- Report pages tested
- Numerical comparisons completed
- Structural validation completed
- Outstanding validation work

If discrepancies are found:

- Describe the issue.
- Record the affected objects.
- Record the current status.
- Do not mark the migration as completed until the discrepancy has been resolved.

---

## Migration History

Maintain a chronological history of the migration.

Each entry should contain:

- Date
- Phase
- Summary of work completed

Example:

### 2026-07-02

**Phase:** Dependency Analysis

Completed:
- Identified all legacy reference tables.
- Located dependencies for Air KPI tables.
- Confirmed report pages affected.
- Proposed creation of a dedicated Measures table.

Next step:
Schema Comparison. 

# Power BI Semantic Model Migration Checklist

This document defines the required activities for every migration project.

The purpose is to ensure that no dependencies are overlooked and that every migration is validated before completion.

Complete each section before moving to the next.

---

# Phase 1 — Discovery

## Repository

- [ ] Identify the active project.
- [ ] Understand the repository structure.
- [ ] Locate the semantic model.
- [ ] Locate the report definition.
- [ ] Locate shared resources.
- [ ] Locate mapping documentation.
- [ ] Locate reference data sources.

---

## Semantic Model Assessment

Inventory:

- [ ] Tables
- [ ] Columns
- [ ] Measures
- [ ] Calculated Columns
- [ ] Calculated Tables
- [ ] Relationships
- [ ] Hierarchies
- [ ] Perspectives
- [ ] Roles (RLS)
- [ ] Object Level Security
- [ ] Display folders
- [ ] Hidden objects
- [ ] Data sources

---

## Report Assessment

Inventory:

- [ ] Pages
- [ ] Visuals
- [ ] Slicers
- [ ] Filters
- [ ] Tooltips
- [ ] Drillthrough pages
- [ ] Bookmarks
- [ ] Navigation
- [ ] Conditional formatting
- [ ] Field parameters
- [ ] Dynamic titles
- [ ] Dynamic subtitles

---

# Phase 2 — Legacy Table Assessment

For every table scheduled for replacement:

- [ ] Document purpose.
- [ ] Document business owner (if known).
- [ ] Document source.
- [ ] Document refresh process.
- [ ] Identify whether the table is:
  - Hardcoded
  - Imported
  - Calculated
  - Referenced
- [ ] Determine whether it can be removed.

---

# Phase 3 — New Fabric Table Assessment

For every replacement table verify:

- [ ] Business meaning
- [ ] Table grain
- [ ] Keys
- [ ] Cardinality
- [ ] Data types
- [ ] Null handling
- [ ] Duplicate rows
- [ ] Missing values
- [ ] Additional columns
- [ ] Missing columns

Document any differences.

---

# Phase 4 — Field Mapping

For every field document:

- [ ] Legacy field
- [ ] Replacement field
- [ ] Same business meaning
- [ ] Transformation required
- [ ] Data type differences
- [ ] Validation approach

Do not assume mappings.

---

# Phase 5 — Dependency Analysis

Verify whether the legacy objects are referenced by:

## Semantic Model

- [ ] Measures
- [ ] Calculated Columns
- [ ] Calculated Tables
- [ ] Relationships
- [ ] Hierarchies
- [ ] Perspectives
- [ ] Display folders
- [ ] Format strings
- [ ] Hidden objects
- [ ] RLS
- [ ] OLS

---

## Report

- [ ] Pages
- [ ] Visuals
- [ ] Visual filters
- [ ] Page filters
- [ ] Report filters
- [ ] Slicers
- [ ] Sync slicers
- [ ] Tooltips
- [ ] Drillthrough
- [ ] Conditional formatting
- [ ] Dynamic titles
- [ ] Dynamic subtitles
- [ ] Bookmarks
- [ ] Navigation buttons
- [ ] Field parameters
- [ ] Sort by columns
- [ ] Visual interactions

---

## External Dependencies

Verify whether the semantic model is used by:

- [ ] Dashboard tiles
- [ ] Power BI Apps
- [ ] Excel workbooks
- [ ] External reports
- [ ] Power Automate flows
- [ ] Subscriptions

---

# Phase 6 — Migration Planning

Before modifying anything:

- [ ] Identify affected tables.
- [ ] Identify affected measures.
- [ ] Identify affected relationships.
- [ ] Identify affected report pages.
- [ ] Identify affected visuals.
- [ ] Identify affected calculations.
- [ ] Identify migration risks.
- [ ] Define validation strategy.
- [ ] Obtain user approval.

---

# Phase 7 — Model Improvements

Evaluate whether the migration should include:

- [ ] Dedicated Measures table
- [ ] Display folders
- [ ] Hidden technical columns
- [ ] Better naming
- [ ] Star schema improvements
- [ ] Relationship simplification
- [ ] Removal of duplicated logic
- [ ] Removal of obsolete objects

These improvements should preserve business behaviour.

---

# Phase 8 — Migration Execution

Recommended order:

- [ ] Add new Fabric tables.
- [ ] Verify relationships.
- [ ] Create or update Measures table.
- [ ] Move measures if required.
- [ ] Update calculated columns.
- [ ] Update calculated tables.
- [ ] Update relationships.
- [ ] Update report bindings.
- [ ] Update filters.
- [ ] Update slicers.
- [ ] Update bookmarks.
- [ ] Update drillthrough.
- [ ] Update tooltips.

Do not remove legacy tables.

Rename them:

<TableName>_Deprecated

until validation is complete.

---

# Phase 9 — Validation

## Structural Validation

Verify:

- [ ] Relationships
- [ ] Cardinality
- [ ] Cross-filter direction
- [ ] Keys
- [ ] Data types
- [ ] Hidden objects
- [ ] Model integrity

---

## Numerical Validation

Compare old versus new:

- [ ] Row count
- [ ] Distinct rows
- [ ] SUM
- [ ] COUNT
- [ ] DISTINCTCOUNT
- [ ] MIN
- [ ] MAX
- [ ] AVERAGE

For every migrated measure verify:

- [ ] Same result
- [ ] Same formatting
- [ ] Same filter behaviour

---

## Report Validation

Verify every:

- [ ] Page
- [ ] Visual
- [ ] Slicer
- [ ] Tooltip
- [ ] Bookmark
- [ ] Drillthrough page
- [ ] Conditional formatting rule
- [ ] Navigation action

Verify:

- [ ] No broken references
- [ ] No missing fields
- [ ] No unexpected blanks
- [ ] No visual errors

---

## Performance Validation

Verify:

- [ ] Refresh succeeds
- [ ] Report loads correctly
- [ ] Visuals render correctly
- [ ] Relationships perform correctly
- [ ] No unnecessary model growth
- [ ] No unexpected performance degradation

---

# Phase 10 — Cleanup

Only after validation:

- [ ] Remove deprecated tables.
- [ ] Remove obsolete relationships.
- [ ] Remove obsolete columns.
- [ ] Remove obsolete expressions.
- [ ] Remove unused measures.
- [ ] Remove unused calculated columns.
- [ ] Remove unused calculated tables.
- [ ] Remove unused report objects.

---

# Phase 11 — Documentation

Update:

- [ ] Discovery Report
- [ ] Dependency Report
- [ ] Field Mapping
- [ ] Migration Assessment
- [ ] Migration Plan
- [ ] Validation Report
- [ ] Decisions Log

---

# Completion Criteria

A migration is complete only when:

- [ ] Every planned table has been migrated.
- [ ] Every dependency has been updated.
- [ ] Every measure has been validated.
- [ ] Every report page has been tested.
- [ ] No broken references remain.
- [ ] Legacy objects have been removed (or intentionally retained and documented).
- [ ] Documentation is complete.
- [ ] The user has approved the migration.

# Maintaining this document

This checklist is a living document.

Whenever work is completed, update this file to reflect the current migration status.

Do not wait until the migration is finished.

At the end of each work session:

- Update the current phase.
- Mark completed checklist items.
- Add relevant notes.
- Record any unresolved questions.
- Record decisions made during the session.

This document should always represent the current state of the migration.