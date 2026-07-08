# Power BI Engineering Rules

## Purpose

This document defines the engineering rules that should be followed when modifying Power BI semantic models and reports during migration projects.

These rules promote consistency, reduce migration risk, simplify code reviews, and improve maintainability.

Unless explicitly instructed otherwise by the user, these rules should always be followed.

---

# Engineering Principles

Every modification should:

- Preserve business behaviour.
- Minimize unnecessary changes.
- Produce small, understandable diffs.
- Improve maintainability where practical.
- Preserve metadata whenever possible.

Engineering quality should never compromise business correctness.

---

# General Rules

Before modifying any object:

- Understand its business purpose.
- Identify all dependencies.
- Document important findings.
- Validate proposed changes.

Avoid modifying objects that are outside the approved migration scope.

---

# Incremental Changes

Prefer many small changes over one large change.

Each implementation unit should:

- Be understandable.
- Be independently testable.
- Be independently reversible.
- Produce a Unit Completion Report.

Validate after every significant change.

Do not begin the next implementation unit until the current one has been validated and approved.

---

# Preserve Existing Objects

Whenever practical:

- Modify existing objects instead of recreating them.
- Preserve object names.
- Preserve object identifiers.
- Preserve formatting.
- Preserve descriptions.
- Preserve display folders.

Avoid deleting and recreating objects unless necessary.

---

# Measures

Measures should:

- Preserve business calculations.
- Preserve formatting.
- Preserve descriptions.
- Preserve display folders.

Avoid changing measure names unless approved.

Where appropriate, consolidate measures into a dedicated Measures table.

---

# Columns

Business columns represent business contracts with reports.

Whenever practical:

- Preserve existing column names.
- Preserve imported column types.
- Avoid replacing imported columns with calculated columns when the values represent static reference data.
- Avoid creating duplicate business columns.

Hide technical columns when appropriate.

---

# Reference Data

Reference data should be treated as business data rather than embedded code.

When migrating hardcoded reference values:

- Prefer moving business rules into reusable reference tables.
- Prefer Power Query or Fabric transformations over DAX calculated columns for static reference values.
- Validate reference data independently before it is consumed by fact tables.
- Reuse shared reference queries whenever possible.

---

# Relationships

Before modifying relationships verify:

- Keys
- Cardinality
- Cross-filter direction
- Active status
- Business purpose

Relationship changes should be validated immediately.

---

# Tables

Do not delete tables until:

- Dependencies have been removed.
- Validation has completed.
- User approval has been received.

Deprecated tables may be temporarily retained during migration.

---

# Report Objects

When modifying reports:

- Preserve layout.
- Preserve formatting.
- Preserve interactions.
- Preserve navigation.
- Preserve bookmarks.
- Preserve user-facing terminology whenever practical.

Only modify report behaviour when explicitly requested.

---

# Documentation

Every significant engineering decision should be documented.

Update, where applicable:

- migration-plan.md
- implementation-log.md
- validation.md
- decisions.md

Engineering documentation should always reflect the currently approved migration strategy.

---

# Documentation Maintenance

Migration documentation should remain clean, consistent, and easy to review throughout the project.

When updating documentation:

- Maintain a single authoritative version of every section.
- Remove superseded content rather than leaving duplicate or obsolete versions in the document.
- Avoid appending revised versions of existing sections unless the document explicitly requires historical versions.
- Preserve the overall document structure and heading hierarchy.

If a document requires substantial restructuring, prefer a single controlled rewrite over many incremental replacements.

When replacing content:

- Identify the complete section to be replaced.
- Replace it in a single operation whenever practical.
- Avoid sequential partial replacements that may leave duplicated content or inconsistent state.

After significant documentation changes, verify that:

- No duplicated sections remain.
- Heading order is correct.
- Internal references remain valid.
- The document ends at the intended final section.
- No obsolete templates or superseded analysis remain.

Before completing the phase, include a Documentation Integrity Check in the Phase Completion Report confirming:

- Documentation structure is valid.
- No duplicate content exists.
- Superseded content has been removed.
- The document contains a single authoritative version of each section.

---

# Strategy Reassessment

New evidence discovered during analysis or implementation may change the preferred migration approach.

When this occurs:

- Pause implementation.
- Reassess the available implementation strategies.
- Compare advantages, disadvantages, risks, and alignment with engineering principles.
- Document the assessment.
- Record the approved decision in `decisions.md`.
- Update the Migration Plan before implementation resumes.

Do not continue implementing a superseded strategy simply because implementation has already begun.

---

# Version Control

Changes should produce clean Git history.

Prefer:

- Small commits.
- Logical commits.
- Clearly defined migration stages.

Never commit automatically.

The user reviews and commits all work.

---

# Quality Checklist

Before considering work complete, verify:

- Business behaviour preserved.
- No broken references.
- Validation completed.
- Documentation updated.
- Migration checklist updated.
- Implementation Log updated.
- Unit Completion Report completed.

Engineering quality is measured by correctness, maintainability, and traceability rather than the number of changes made.