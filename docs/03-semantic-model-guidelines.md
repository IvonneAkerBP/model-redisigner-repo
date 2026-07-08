# Semantic Model Guidelines

## Purpose

This document defines the engineering standards for designing, modifying, and maintaining Power BI semantic models during migration projects.

The objective is to improve the maintainability, readability, and quality of the semantic model while preserving business behaviour.

Whenever there is a conflict between architectural improvements and preserving business behaviour, preserving business behaviour takes precedence unless the user explicitly approves the change.

---

# General Principles

A semantic model should:

- Represent business concepts clearly.
- Be easy to understand.
- Minimize duplicated logic.
- Support report development.
- Support future maintenance.
- Support future extension.

Prefer simple solutions over clever solutions.

---

# Star Schema

Whenever practical, semantic models should follow a star schema.

Characteristics include:

- Fact tables contain transactional data.
- Dimension tables contain descriptive attributes.
- Relationships are simple and predictable.
- Business entities are clearly separated.

Avoid unnecessary snowflake designs unless required by the business model.

---

# Fact Tables

Fact tables should:

- Contain measurable business events.
- Be stored at the appropriate granularity.
- Contain foreign keys to dimensions.
- Minimize descriptive attributes.

Examples include:

- Production
- Emissions
- Waste
- Water
- Chemicals

---

# Dimension Tables

Dimension tables should:

- Describe business entities.
- Be reusable.
- Support filtering.
- Contain business attributes rather than calculations.

Examples include:

- Date
- Installation
- Company
- Permit
- Area

---

# Measures

Business calculations should be implemented as measures whenever possible.

Measures should:

- Represent business logic.
- Be reusable.
- Be independent of report layout.
- Be documented.

Avoid embedding business calculations directly in report visuals.

---

# Measures Table

When practical, maintain a dedicated Measures table.

Advantages include:

- Easier navigation.
- Easier maintenance.
- Separation of business logic from data.
- Reduced migration impact.

Moving measures should never change their calculations.

---

# Calculated Columns

Use calculated columns only when necessary.

Before creating a calculated column, consider whether the logic can be implemented as:

- A measure
- A Power Query transformation
- A Fabric transformation

Avoid calculated columns that duplicate existing data.

---

# Imported Columns vs Calculated Columns

When migrating existing imported columns, preserve the column type whenever practical.

Prefer:

- Power Query transformations
- Fabric transformations
- Imported columns

over calculated columns when the values represent static reference data.

Calculated columns should primarily be used when the value must be computed within the semantic model.

Avoid replacing imported business reference columns with calculated columns unless there is a documented technical reason.

---

# Calculated Tables

Calculated tables should be used only when there is a clear business or technical requirement.

Document the reason for every calculated table.

---

# Relationships

Relationships should accurately represent business relationships.

Before creating or modifying a relationship verify:

- Keys
- Cardinality
- Cross-filter direction
- Active or inactive status
- Business purpose

Avoid ambiguous relationships.

---

# Reference Data

Business reference data should be modeled separately from transactional data whenever practical.

When migrating hardcoded reference values:

- Prefer moving business rules from code into data.
- Store reference values in reusable reference tables.
- Keep reference data independent of report implementation.
- Reuse the same reference data across multiple fact tables where appropriate.

Reference data should be validated independently before it is used by the semantic model.

---

# Naming Conventions

Object names should:

- Reflect business terminology.
- Be easy to understand.
- Avoid unnecessary abbreviations.
- Be consistent across the model.

Prefer business names over technical names.

---

# Display Folders

Use display folders to organize measures logically.

Possible organization includes:

- KPIs
- Production
- Emissions
- Water
- Chemicals
- Financial
- Supporting Measures

Display folders should improve navigation rather than mirror table structure.

---

# Hidden Objects

Hide technical objects that should not be used by report developers.

Examples include:

- Technical keys
- Helper columns
- Intermediate calculations

Do not hide objects that users are expected to use.

---

# Descriptions

Important model objects should include descriptions.

Descriptions should explain:

- Business meaning.
- Intended usage.
- Important assumptions.

Descriptions should not duplicate object names.

---

# Migration Considerations

During migration:

- Preserve business behaviour.
- Preserve measure calculations.
- Preserve report compatibility.
- Preserve imported column types whenever practical.
- Prefer incremental implementation units.
- Validate after every significant modification.
- Separate business logic from reference data whenever practical.

Avoid large structural changes until mappings have been validated.

When new evidence significantly changes the preferred implementation approach, reassess the migration strategy before implementation continues.

---

# Deliverables

Changes to the semantic model should be reflected in:

- The semantic model files.
- `migration-plan.md`
- `implementation-log.md`
- `validation.md`
- `decisions.md`

Every structural change should have a documented business or technical justification.

Every implementation unit affecting the semantic model should include:

- Planned change
- Implemented change
- Validation performed
- Validation result
- Rollback strategy