# Validation Guide

## Purpose

This document defines the methodology for validating Power BI semantic model and report migrations.

The purpose of validation is to confirm that the migrated solution behaves as expected from both a technical and business perspective.

A migration is not considered complete until it has been successfully validated.

Validation should occur continuously throughout the migration rather than only at the end.

---

# Validation Principles

Validation should:

- Confirm business behaviour.
- Confirm technical correctness.
- Detect migration defects early.
- Reduce migration risk.
- Build confidence before cleanup.

Validation is evidence-based.

Never assume a migration is correct simply because the report renders successfully.

Every validation activity should produce evidence.

---

# Validation Strategy

Validation should be performed incrementally.

After every implementation unit:

1. Validate the semantic model.
2. Validate the affected report objects.
3. Compare business results.
4. Compare with the Migration Plan.
5. Record findings in the Implementation Log.

Avoid making multiple structural changes before validating.

Do not begin the next implementation unit until the current unit has passed validation.

---

# Validation Inputs

Validation should be based on all relevant migration artifacts.

The primary inputs are:

- Legacy semantic model
- Target semantic model
- Migration Plan (`migration-plan.md`)
- Implementation Log (`implementation-log.md`)
- Business Reference Workbook (`Input til PowerBI.xlsx`)
- Mapping documentation (`field-mapping.md`)
- Decisions (`decisions.md`)

Validation should reference both the planned implementation (`migration-plan.md`) and the completed implementation (`implementation-log.md`) to ensure every planned change was executed and validated successfully.

---

# Types of Validation

Every migration should include multiple validation perspectives.

## Structural Validation

Verify the integrity of the semantic model.

Examples include:

- Tables exist.
- Relationships are correct.
- Data types are correct.
- Keys are correct.
- Cardinality is correct.
- Measures compile successfully.
- No broken references remain.

Structural validation confirms that the model is technically valid.

---

## Business Validation

Business validation confirms that the migrated implementation represents the same business concepts as the original solution.

Verify:

- Business entities
- Business terminology
- KPIs
- Calculations
- Expected report behaviour

Business validation should take precedence over technical similarity.

---

## Numerical Validation

Compare numerical results between the legacy and migrated solutions.

Where possible compare:

- Row counts
- SUM
- COUNT
- DISTINCTCOUNT
- MIN
- MAX
- AVERAGE

For important measures compare:

- Total values
- Filtered values
- Edge cases
- Historical periods

Any unexpected differences should be investigated.

---

## Measure Validation

Every migrated measure should be validated.

Verify:

- DAX logic
- Referenced tables
- Referenced columns
- Filter context
- Numerical output

Measures containing complex business logic should receive additional attention.

---

## Relationship Validation

Relationships influence filter propagation throughout the model.

Verify:

- Active relationships
- Inactive relationships
- Cross-filter direction
- Cardinality
- Keys

Incorrect relationships frequently produce valid-looking but incorrect results.

---

## Report Validation

The report should behave exactly as expected.

Inspect:

- Pages
- Visuals
- Slicers
- Filters
- Tooltips
- Drillthrough
- Bookmarks
- Navigation
- Conditional formatting
- Dynamic titles

Verify both functionality and numerical output.

---

## Presentation Validation

Validate that the migrated report preserves the expected business presentation.

Verify:

- Page names
- Visual titles
- Dynamic titles
- Dynamic subtitles
- Card labels
- KPI labels
- Axis titles
- Legend titles
- Tooltip labels
- Matrix and table headers
- Field Parameter display names
- Navigation labels
- Button text
- Drillthrough labels

Confirm that business terminology presented to users remains consistent with the original report unless an approved terminology change has been implemented.

Presentation consistency should be validated independently from numerical correctness.

---

## Visual Validation

For every modified visual verify:

- Visual loads correctly.
- Correct fields are used.
- Values match expectations.
- Formatting is preserved.
- Sorting is preserved.
- Interactions work correctly.
- No broken field bindings remain.

---

## Filter Validation

Verify:

- Report filters
- Page filters
- Visual filters
- Sync slicers
- Default selections

Filtering behaviour should remain unchanged.

---

## Bookmark Validation

Verify:

- Bookmark navigation
- Bookmark state
- Stored filters
- Stored visual states

If object names have changed, verify that affected bookmarks have been updated or re-saved where required.

---

## Navigation Validation

Verify:

- Buttons
- Drillthrough
- Bookmarks
- Page navigation

Users should experience the same navigation flow after migration.

---

## Performance Validation

Migration should not significantly degrade report performance.

Where practical compare:

- Visual load times
- Query duration
- DAX execution
- Model refresh
- Overall responsiveness

If performance degrades significantly, investigate before completing the migration.

---

# Regression Testing

Migration should include regression testing.

Regression testing verifies that previously working functionality still behaves correctly.

Typical regression tests include:

- Opening every report page.
- Refreshing visuals.
- Testing slicers.
- Testing drillthrough.
- Testing bookmarks.
- Testing navigation.

Regression testing should be repeated after every major implementation unit.

---

# Validation Documentation

Record all validation activities.

Document:

- Validation performed
- Expected results
- Actual results
- Differences identified
- Root cause
- Resolution
- Evidence collected

Validation documentation should provide sufficient evidence that the migration has been verified.

---

# Validation Failure

If validation identifies unexpected behaviour:

Do not continue the migration.

Instead:

- Document the issue.
- Identify affected objects.
- Investigate the root cause.
- Recommend corrective actions.
- Revalidate after changes.

Avoid introducing additional migration changes before resolving validation failures.

---

# Unit Completion Validation

Every implementation unit must conclude with a Unit Completion Report.

The report should confirm:

- Planned implementation completed.
- Validation activities completed.
- Success criteria satisfied.
- Outstanding issues documented.
- Deviations from the Migration Plan documented.
- Recommendation for the next implementation unit.

A new implementation unit must not begin until the current Unit Completion Report has been reviewed and approved.

---

# Completion Criteria

Validation is complete when:

- Structural validation has passed.
- Business validation has passed.
- Numerical validation has passed.
- Report validation has passed.
- Performance is acceptable.
- Outstanding issues have been resolved or documented.
- Every implementation unit has a completed Unit Completion Report.
- The user has approved the migration results.

Validation results should be recorded in:

- `migration/validation.md`
- `migration/implementation-log.md`

A migration should not proceed to cleanup until validation has been successfully completed.