# Report Migration Guidelines

## Purpose

This document defines the engineering standards for migrating Power BI reports during semantic model migration projects.

The objective is to preserve report behaviour while replacing the underlying semantic model objects.

Migrating a semantic model is only part of the migration.

Every report that consumes the model must also be analyzed, updated, and validated.

The report should behave exactly as expected after the migration unless the user explicitly approves functional changes.

---

# General Principles

The report should be treated as an application built on top of the semantic model.

Changing the semantic model without understanding report dependencies may result in:

- Broken visuals
- Incorrect calculations
- Empty visuals
- Broken navigation
- Incorrect filtering
- Broken drillthrough
- Broken bookmarks
- Incorrect conditional formatting

Always analyze the report before modifying the semantic model.

---

# Report Discovery

Before making any modifications, inspect the report.

Identify:

- Pages
- Hidden pages
- Navigation
- Bookmarks
- Tooltips
- Drillthrough pages
- Field Parameters
- Visual interactions

Document the findings in the Discovery phase.

---

# Visual Analysis

Every visual should be inspected.

For each visual identify:

- Visual type
- Measures
- Dimensions
- Legend
- Tooltip fields
- Small multiples
- Axes
- Filters
- Conditional formatting
- Sort columns

Determine which semantic model objects are used.

Document both direct field bindings and indirect dependencies through measures.

---

# Report Dependencies

Before replacing any semantic model object determine where it is used.

Possible dependencies include:

- Visual fields
- Page filters
- Report filters
- Visual filters
- Slicers
- Tooltips
- Drillthrough
- Bookmarks
- Field Parameters
- Conditional formatting
- Dynamic titles
- Dynamic subtitles
- Visual interactions

No object should be removed until every dependency has been identified.

Dependencies should distinguish between:

- Direct visual bindings
- Measure dependencies
- Stored bookmark state
- Presentation references

---

# Page Analysis

For every report page document:

- Business purpose
- Target audience
- Important KPIs
- Critical visuals
- Navigation paths

Understanding the purpose of each page helps preserve report behaviour.

---

# Visual Migration

When replacing fields:

Replace one logical object at a time.

After each replacement verify:

- The visual still renders.
- Values remain correct.
- Formatting is preserved.
- Sorting is preserved.
- Interactions continue to work.

Avoid replacing many fields simultaneously.

---

# Presentation Validation

When migrating report objects, verify that business-facing presentation remains consistent.

Inspect and validate:

- Visual titles
- Visual subtitles
- Axis titles
- Legend titles
- Column headers
- Matrix headers
- Tooltip labels
- Card labels
- KPI labels
- Dynamic titles
- Dynamic subtitles
- Button text
- Navigation labels
- Page names
- Bookmark names (when user-facing)
- Drillthrough labels
- Field Parameter display names

Determine whether any of these reference:

- Legacy column names
- Legacy measure names
- Legacy table names

If presentation text changes as a result of the migration, document the reason and obtain user approval before implementing the change.

Business users should experience consistent terminology before and after migration unless a deliberate business terminology change has been approved.

---

# Filters

Inspect all filter levels.

Verify:

## Report Filters

Determine whether migrated fields participate.

---

## Page Filters

Verify all page-level filters.

---

## Visual Filters

Inspect every visual individually.

---

## Slicers

Verify:

- Selected fields
- Sync slicers
- Default selections
- Hierarchies

Filtering behaviour should remain unchanged.

---

# Bookmarks

Bookmarks frequently contain hidden dependencies.

Inspect:

- Visibility state
- Selected visuals
- Filters
- Navigation
- Data state

Remember that bookmark state may reference legacy field names internally.

If object names change during migration, determine whether affected bookmarks require re-saving.

Verify bookmarks after every migration step.

---

# Drillthrough

Inspect every drillthrough page.

Verify:

- Drillthrough fields
- Navigation
- Filters
- Expected behaviour

Replacing drillthrough fields without updating the drillthrough configuration will break navigation.

---

# Tooltips

Inspect:

- Tooltip pages
- Tooltip visuals
- Tooltip measures
- Tooltip filters

Tooltips frequently contain business logic that is easy to overlook.

---

# Field Parameters

Determine whether the report uses Field Parameters.

Inspect:

- Dynamic dimensions
- Dynamic measures
- Dynamic axes

When replacing fields, update the Field Parameter definitions accordingly.

---

# Conditional Formatting

Inspect every visual using:

- Background colors
- Font colors
- Icons
- Data bars
- Web URLs

Conditional formatting frequently references measures.

Ensure these references remain valid.

---

# Dynamic Text

Inspect:

- Titles
- Subtitles
- Buttons
- Text boxes

Determine whether dynamic measures or fields are referenced.

---

# Report Navigation

Verify:

- Buttons
- Page navigation
- Bookmark navigation
- Drillthrough navigation

Navigation should remain unchanged after migration.

---

# Validation

After each implementation unit verify:

- Visual renders successfully.
- Filters work correctly.
- Navigation works.
- Bookmarks work.
- Tooltips work.
- Drillthrough works.
- Conditional formatting works.
- Dynamic titles work.
- Numbers match expectations.
- No broken field references remain.
- No presentation text has unintentionally changed.

Never postpone report validation until the end of the migration.

Validate continuously.

---

# Common Report Migration Risks

Typical migration risks include:

- Hidden page dependencies
- Bookmark dependencies
- Conditional formatting references
- Field Parameter references
- Tooltip pages
- Dynamic titles
- Report filters
- Visual-level calculations
- Sort By columns
- Direct visual bindings to migrated columns
- Presentation text referencing legacy object names

These should always be investigated before removing legacy objects.

---

# Deliverables

Report migration should produce:

- Updated report definition
- Updated report bindings
- Updated migration documentation
- Validation evidence
- Implementation log entries

Every report implementation unit should be documented in:

- `migration-plan.md`
- `implementation-log.md`
- `validation.md`

A report migration is complete only when:

- All affected visuals have been validated.
- Report behaviour matches the legacy implementation.
- No broken bindings remain.
- User-facing presentation has been preserved unless explicitly approved otherwise.