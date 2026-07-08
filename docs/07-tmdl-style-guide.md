# TMDL Style Guide

## Purpose

This document defines the standards for modifying Tabular Model Definition Language (TMDL) files during migration projects.

The objective is to produce clean, maintainable, and reviewable changes while preserving model integrity.

Changes should be easy to understand, easy to validate, and produce minimal Git diffs.

---

# General Principles

When modifying TMDL:

- Preserve readability.
- Preserve consistency.
- Preserve existing formatting where practical.
- Minimize unnecessary edits.
- Prefer modifying existing objects over recreating them.

Avoid cosmetic changes that do not improve the model.

---

# Planning Before Editing

Never modify TMDL files directly without an approved implementation plan.

Before editing:

- Confirm the migration unit being implemented.
- Review the approved Migration Plan.
- Review the Validation Plan.
- Review outstanding Decision Records.
- Understand all object dependencies.

Every TMDL modification should belong to a specific implementation unit.

---

# Editing Existing Objects

Whenever possible:

- Modify existing objects.
- Preserve object identity.
- Preserve ordering.
- Preserve descriptions.
- Preserve annotations.

Avoid deleting and recreating objects simply to make changes.

---

# Naming Standards

Use business terminology.

Names should:

- Be descriptive.
- Be consistent.
- Avoid unnecessary abbreviations.
- Reflect business meaning.

Prefer:

Customer

over

Cust

Avoid renaming existing business objects unless explicitly approved.

---

# Measures

Measures should:

- Use consistent formatting.
- Include descriptions when appropriate.
- Preserve formatting strings.
- Preserve display folders.

Avoid duplicate measures.

Move measures only when it improves maintainability.

Preserve existing measure names whenever practical to avoid unnecessary report changes.

---

# Tables

Tables should represent business entities.

Avoid:

- Temporary tables
- Duplicate tables
- Obsolete tables

During migration, deprecated tables may be retained until validation has completed.

---

# Columns

Columns should:

- Represent business attributes.
- Use meaningful names.
- Preserve business meaning.

Hide technical columns whenever appropriate.

When migrating imported columns:

- Preserve the existing column names whenever practical.
- Preserve imported column types whenever practical.
- Avoid replacing imported columns with calculated columns unless there is a documented technical reason.

---

# Relationships

Relationship definitions should remain simple and explicit.

Before modifying relationships verify:

- Keys
- Cardinality
- Cross-filter direction
- Active status
- Business purpose

Relationship changes should be validated immediately.

---

# Display Folders

Display folders should organize objects logically.

Examples include:

- KPIs
- Production
- Emissions
- Supporting Measures

Avoid unnecessary nesting.

---

# Descriptions

Descriptions should explain:

- Business meaning.
- Intended usage.
- Important assumptions.

Descriptions should not duplicate object names.

---

# Formatting

Maintain consistent formatting throughout the model.

Avoid reformatting files unnecessarily.

Large formatting-only changes make Git reviews difficult.

---

# Object Ordering

Preserve existing object ordering whenever practical.

Only reorder objects when there is a clear maintainability benefit.

Avoid generating large diffs caused solely by reordering.

---

# Metadata

Preserve existing metadata whenever possible.

Examples include:

- Descriptions
- Display folders
- Format strings
- Visibility
- Annotations

Do not remove metadata unless it is obsolete.

---

# Deprecated Objects

When replacing objects:

Prefer marking them as deprecated before removing them.

Examples:

Customer_Deprecated

Emission_Deprecated

Permanent removal should occur only after successful validation.

---

# Validation

After modifying TMDL files verify:

- Model compiles successfully.
- Relationships are valid.
- Measures compile.
- No broken references remain.
- Object names are correct.
- No unintended metadata changes have been introduced.

Every TMDL modification should be validated against both:

- `migration-plan.md`
- `validation.md`

---

# Git-Friendly Changes

TMDL changes should produce clean Git diffs.

Avoid:

- Reordering unrelated objects.
- Formatting-only commits.
- Large unrelated modifications.

Reviewers should be able to identify the business purpose of each change from the diff.

One implementation unit should ideally correspond to one logical set of TMDL changes.

---

# Documentation

Every TMDL modification should be reflected, where applicable, in:

- `migration-plan.md`
- `implementation-log.md`
- `validation.md`
- `decisions.md`

The implementation log should accurately describe what was modified, what was validated, and any deviations from the approved Migration Plan.

---

# Completion Checklist

Before completing TMDL modifications verify:

- Business behaviour preserved.
- Model structure remains valid.
- Metadata preserved.
- Documentation updated.
- Validation completed.
- Unit Completion Report completed.

The quality of a TMDL change is measured by its correctness, clarity, and maintainability rather than the number of objects modified.