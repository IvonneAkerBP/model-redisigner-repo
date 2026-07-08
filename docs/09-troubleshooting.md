# Troubleshooting

## Purpose

This document records common migration issues, their root causes, the solutions applied, and the lessons learned during Power BI semantic model migration projects.

Its purpose is to:

- Reduce repeated investigation.
- Capture migration knowledge.
- Improve future migrations.
- Document recurring problems.
- Standardize successful solutions.

This is a living document.

Add new entries whenever a migration uncovers an issue that may be useful in future projects.

---

# Troubleshooting Methodology

When an issue is discovered:

1. Describe the problem.
2. Identify the symptoms.
3. Determine the root cause.
4. Document the solution.
5. Record any preventive actions.
6. Update migration documentation if required.

Avoid documenting only the solution.

Understanding the cause is often more valuable than the fix itself.

---

# Issue Template

For every issue record:

## Issue

Brief description.

## Symptoms

What was observed?

## Root Cause

Why did it happen?

## Resolution

How was it resolved?

## Prevention

How can similar issues be avoided in future migrations?

---

# Common Migration Issues

## Broken Visuals

### Symptoms

- Visual fails to render.
- "Couldn't load the data for this visual."
- Empty visual after migration.

### Possible Causes

- Missing field.
- Incorrect measure.
- Broken relationship.
- Incorrect filter.
- Field removed from model.

### Resolution

Verify:

- Visual bindings.
- Measures.
- Relationships.
- Filters.
- Field Parameters.

---

## Incorrect Numbers

### Symptoms

- Totals differ from the legacy report.
- Unexpected aggregations.
- Missing values.

### Possible Causes

- Incorrect relationship.
- Incorrect granularity.
- Incorrect filter context.
- Measure migration error.

### Resolution

Compare:

- Measures
- Relationships
- Filter context
- Source values

Validate numerically before continuing.

---

## Missing Data

### Symptoms

- Blank visuals.
- Missing categories.
- Missing records.

### Possible Causes

- Incorrect joins.
- Missing relationships.
- Filter propagation issues.
- Different business grain.

### Resolution

Verify:

- Relationships.
- Cardinality.
- Keys.
- Filters.

---

## Broken Bookmarks

### Symptoms

- Bookmark navigation no longer works.
- Incorrect visual state.
- Incorrect filters.

### Possible Causes

- Visual IDs changed.
- Removed visuals.
- Changed field names.
- Stored bookmark state references outdated object names.

### Resolution

Review bookmark configuration.

Determine whether bookmarks require re-saving after migration.

---

## Drillthrough No Longer Works

### Symptoms

- Drillthrough disabled.
- Incorrect destination.
- Empty drillthrough pages.

### Possible Causes

- Drillthrough field replaced.
- Missing relationship.
- Incorrect filter propagation.

### Resolution

Verify:

- Drillthrough fields.
- Relationships.
- Navigation.

---

## Conditional Formatting Failure

### Symptoms

- Colors disappear.
- Icons disappear.
- Incorrect formatting.

### Possible Causes

- Referenced measure removed.
- Measure renamed.
- Formatting rule broken.

### Resolution

Verify all referenced measures.

---

## Field Parameter Issues

### Symptoms

- Dynamic dimensions fail.
- Dynamic measures fail.
- Visual behaves unexpectedly.

### Possible Causes

- Parameter references outdated.
- Missing fields.
- Incorrect mapping.

### Resolution

Update Field Parameter definitions after migration.

---

## Relationship Problems

### Symptoms

- Incorrect totals.
- Duplicate values.
- Missing values.

### Possible Causes

- Incorrect cardinality.
- Wrong filter direction.
- Wrong key.

### Resolution

Review relationship definitions before investigating DAX.

---

## Performance Regression

### Symptoms

- Slower report.
- Slower visuals.
- Longer refresh times.

### Possible Causes

- Additional calculated columns.
- Complex DAX.
- Relationship changes.
- Larger model.

### Resolution

Compare with the original implementation.

Identify the specific change that introduced the regression.

---

## Duplicate Documentation

### Symptoms

- Multiple versions of the same section.
- Conflicting migration guidance.
- Old analysis remains after updates.

### Possible Causes

- Partial replacements.
- Incremental append operations.
- Failed cleanup after document edits.

### Resolution

Replace complete sections in one operation.

Perform a Documentation Integrity Check before completing the phase.

---

## Migration Strategy Changed Mid-Project

### Symptoms

- Original implementation plan no longer represents the preferred architecture.
- Documentation becomes inconsistent.
- Multiple implementation strategies coexist.

### Possible Causes

- New evidence discovered during analysis.
- Better architecture identified.
- Business requirements clarified.

### Resolution

Pause implementation.

Document the reassessment.

Update:

- migration-plan.md
- decisions.md
- implementation-log.md

Resume implementation only after the revised strategy has been approved.

---

## Historical Reference Data Missing

### Symptoms

- Historical report pages display BLANK values.
- Trend lines disappear after migration.
- Current year works correctly but historical years fail.

### Possible Causes

- New reference tables only contain current-year values.
- Historical values existed only in SQL CASE or Power Query logic.

### Resolution

Extract historical values into reusable reference tables before removing the existing implementation.

Validate historical behaviour before completing the migration.

---

# Lessons Learned

Record important lessons discovered during migration.

Example:

## Lesson

Updating the semantic model without first identifying every report dependency resulted in broken report behaviour.

### Recommendation

Always complete report dependency analysis before modifying semantic model objects.

---

# Best Practices Discovered

Document practices that consistently produce successful migrations.

Examples include:

- Validate after every implementation unit.
- Migrate one business concept at a time.
- Build the reference data foundation before replacing business logic.
- Preserve deprecated objects until validation completes.
- Update migration documentation continuously.
- Compare report behaviour frequently.
- Separate planning, implementation, validation, and decision records.

---

# Project-Specific Lessons

If a lesson applies only to a particular migration project:

- Record it in the project's `migration/decisions.md`.

If the lesson is broadly applicable to future migrations:

- Record it in this document.

---

# Continuous Improvement

This document should grow with every migration.

When a recurring issue is identified:

- Add it here.
- Improve the migration methodology if appropriate.
- Update the engineering documentation if the lesson applies generally.

The goal is to continuously improve the migration framework so that future migrations become more predictable, more efficient, and less error-prone.