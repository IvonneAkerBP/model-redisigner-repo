# Performance Guidelines

## Purpose

This document defines the performance principles that should be considered during semantic model and report migrations.

The primary objective is to preserve or improve report performance while maintaining correct business behaviour.

Performance optimization should never compromise business correctness.

During migration, prioritize correctness first and optimization second.

---

# General Principles

Every migration should aim to:

- Preserve report responsiveness.
- Preserve query performance.
- Minimize unnecessary calculations.
- Minimize model complexity.
- Reduce maintenance effort.

Avoid introducing performance regressions.

Performance decisions should be based on evidence whenever practical.

---

# Performance Assessment

Before making structural changes, understand the existing model.

Assess:

- Model size
- Table cardinality
- Relationship complexity
- Number of measures
- Report complexity
- Visual complexity
- Refresh duration
- Model refresh frequency

Document significant observations when they may influence migration decisions.

---

# Engineering Judgement

Not every performance statement can be measured during a migration project.

Clearly distinguish between:

- Measured observations
- Documented platform behaviour
- Engineering judgement

Avoid presenting engineering judgement as measured fact.

Where performance has not been measured, state this explicitly.

---

# Semantic Model Performance

Prefer solutions that:

- Reduce unnecessary calculations.
- Reuse existing business logic.
- Avoid duplicated calculations.
- Minimize unnecessary calculated columns.
- Keep the model easy to understand.

Complexity should only increase when there is a clear business justification.

---

# Reference Data

For static business reference data, prefer refresh-time transformations over query-time calculations whenever practical.

When migrating hardcoded reference values, consider the performance implications of:

- Fabric transformations
- Power Query transformations
- Imported columns
- Calculated columns
- Relationships

Select the approach that best balances:

- Business correctness
- Maintainability
- Performance
- Migration risk

---

# Relationships

Relationships directly influence query performance.

When modifying relationships:

- Verify cardinality.
- Avoid unnecessary bidirectional filtering.
- Avoid ambiguous filter paths.
- Preserve business logic.

Relationship changes should always be validated.

---

# Measures

Measures should be:

- Reusable.
- Efficient.
- Easy to understand.

Avoid:

- Duplicate measures.
- Unnecessarily complex DAX.
- Repeated calculations.

Where appropriate, reuse existing measures instead of creating new ones.

---

# Calculated Columns

Calculated columns increase model size and refresh work.

Before creating one, consider whether the logic belongs in:

- Fabric transformations
- Power Query
- A measure

Only create calculated columns when there is a clear functional requirement.

Avoid using calculated columns solely to retrieve static reference values when equivalent imported data can be produced during refresh.

---

# Calculated Tables

Calculated tables should be used sparingly.

Before creating one, determine whether the same result can be achieved using:

- Existing tables
- Relationships
- Measures
- Data preparation

---

# Report Performance

Complex reports may perform poorly even when the semantic model is well designed.

When modifying reports:

- Avoid unnecessary visuals.
- Avoid duplicate visuals.
- Minimize unnecessary interactions.
- Preserve efficient navigation.

Large report changes should be validated incrementally.

---

# Refresh Performance

Migration changes should consider refresh behaviour as well as report query performance.

Assess where practical:

- Refresh duration
- Query folding
- Power Query transformations
- Incremental refresh compatibility
- Data movement between engines

Refresh performance should remain acceptable for the operational requirements of the solution.

---

# Validation

After significant migration steps verify:

- Report loads successfully.
- Visuals load within acceptable time.
- Filters respond correctly.
- Navigation remains responsive.
- Refresh completes successfully.

Where possible compare performance with the original implementation.

Document whether conclusions are:

- Measured
- Estimated
- Engineering judgement

---

# Performance Regression

If performance becomes noticeably worse after migration:

- Stop further optimization work.
- Identify the cause.
- Document the issue.
- Correct the regression.
- Revalidate the solution.

Avoid introducing additional migration changes until the regression has been understood.

---

# Engineering Principles

Prefer:

- Simple solutions.
- Readable models.
- Reusable logic.
- Incremental improvements.

Avoid optimization that makes the model significantly harder to understand.

Maintainability is part of performance.

---

# Completion Checklist

Before completing a migration verify:

- No significant performance regression has been introduced.
- Business behaviour remains correct.
- Performance observations have been documented where appropriate.
- Validation has been completed.
- Performance conclusions clearly distinguish between measured evidence and engineering judgement.

Performance improvements are desirable, but preserving business correctness remains the highest priority.