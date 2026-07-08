# Validation Guide

## Purpose

This document defines how the migration is validated.

Validation confirms that the migrated implementation preserves the existing business behaviour, produces the expected numerical results, and introduces no unintended changes to the semantic model or report.

Validation is performed throughout the migration, not only after implementation.

This is a living document and should be updated as the migration progresses.

---

# Validation Inputs

Validation should be based on all relevant migration artifacts.

Primary inputs:

- Legacy semantic model
- Target semantic model
- Business Reference Workbook (`Input til PowerBI.xlsx`)
- Fabric reference tables
- discovery.md
- dependencies.md
- field-mapping.md
- migration-plan.md
- implementation-log.md
- decisions.md

Validation should reference both the planned implementation (`migration-plan.md`) and the completed implementation (`implementation-log.md`) to ensure every planned change was executed and validated successfully.

---

# Validation Principles

Validation should confirm:

- Business behaviour is preserved.
- Numerical results are correct.
- Report behaviour is unchanged.
- No unintended dependencies are introduced.
- No existing functionality is broken.

Never assume a migration is correct because it refreshes successfully.

---

# Validation Types

## Structural Validation

Confirm:

- Expected tables exist.
- Expected columns exist.
- Expected data types are correct.
- Relationships are valid.
- Hidden columns remain hidden where appropriate.
- Display folders remain correct.

---

## Data Validation

Confirm:

- Row counts are as expected.
- Sample values match the legacy implementation.
- Business keys are unique where expected.
- No unexpected NULL or BLANK values exist.
- Historical data has been preserved.
- Fabric reference values are correctly incorporated.

---

## Semantic Model Validation

Confirm:

- Measures return expected values.
- Calculated objects evaluate correctly.
- Relationships filter correctly.
- No broken dependencies exist.

---

## Report Validation

Confirm:

- Visuals render correctly.
- Filters behave correctly.
- Slicers function correctly.
- Drillthrough works.
- Tooltips work.
- Bookmarks work.
- Conditional formatting behaves correctly.
- Titles, subtitles, axis labels, legends, data labels, and dynamic text remain correct after the migration.
- No visual contains broken field references.

---

## Performance Validation

Confirm:

- Model refresh completes successfully.
- Refresh duration remains acceptable.
- No unexpected increase in model size.
- No significant degradation in report performance.

---

# Implementation Unit Validation

Each implementation unit must define its own validation activities before implementation begins.

Implementation is complete only when all validation activities have passed.

---

# Unit 0 — Reference Data Foundation

## Objective

Validate the shared reference data architecture before any fact tables are modified.

### Structural Validation

Confirm:

- `CombinedAirRef` exists.
- `CombinedSeaRef` exists.
- Both queries refresh successfully.
- Expected schema exists:

  - metric
  - field
  - year
  - value_permit_kpi

- Data types match the migration plan.

### Data Validation

Confirm:

- Historical rows (2019–2025) are present.
- Fabric rows (2026 onward) are present.
- No duplicate `(field, year, metric)` combinations exist.
- Sample historical values match the existing SQL CASE and Power Query logic.
- Sample 2026 values match the Fabric reference tables.

### Power Query Validation

Confirm:

- Queries refresh without errors.
- Merge operations complete successfully.
- No unexpected null values are introduced.
- Row counts match expectations.

### Migration Validation

Confirm:

- No fact table queries have been modified.
- No SQL CASE expressions have been removed.
- No DAX measures have changed.
- No report objects have changed.

### Success Criteria

Unit 0 is complete only when:

- Combined reference queries are successfully created.
- Historical and Fabric reference data are correctly combined.
- Validation queries pass.
- Sample values match the legacy implementation.
- No semantic model objects have been modified.
- No report behaviour has changed.

---

# Final Migration Validation

Migration is complete only when:

- All implementation units have passed validation.
- All planned changes have been completed.
- All implementation units have corresponding completion reports.
- No broken report objects remain.
- Business behaviour matches the legacy implementation.
- Historical and current reference values are preserved.
- All decision records have been resolved.
- Documentation has been updated to reflect the final implementation.