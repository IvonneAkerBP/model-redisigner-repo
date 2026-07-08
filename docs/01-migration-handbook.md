

# Migration Handbook

## Purpose

This handbook defines the standard methodology for migrating Power BI semantic models and reports within this repository.

It describes the engineering process to be followed for every migration project, regardless of business domain or report complexity.

The objective is to perform migrations in a controlled, repeatable, and well-documented manner while preserving:

- Business logic
- Data integrity
- Report behaviour
- Performance
- Maintainability

This handbook complements:

- `AGENTS.md`, which defines how the AI agent should operate.
- `MIGRATION_CHECKLIST.md`, which tracks migration progress.
- The project-specific migration documents, which record the implementation of each migration.

---

# Scope

This handbook describes the complete migration lifecycle.

It explains:

- What should happen during each migration phase.
- Why each phase exists.
- What deliverables should be produced.
- What risks should be considered.
- When implementation should begin.
- How a migration is validated before completion.

This document defines **how migrations are performed**.

It does not describe project-specific business logic.

---

# Migration Philosophy

A migration is not a technical replacement exercise.

The objective is not simply to replace tables, columns or measures.

The objective is to preserve the business solution while improving the underlying implementation.

Every migration should increase confidence in the solution.

Whenever possible, the migrated implementation should be:

- Easier to understand
- Easier to maintain
- Easier to extend
- Easier to validate

without changing business behaviour.

---

# Guiding Principles

Every migration should follow these principles.

## Understand Before Changing

Never modify a semantic model before understanding:

- What the object represents.
- Why it exists.
- How it is used.
- What depends on it.

Understanding always precedes implementation.

---

## Preserve Business Behaviour

The migrated solution should produce the same business results as the original solution.

Users should experience the same report behaviour unless a business change has been explicitly approved.

---

## Prefer Evidence Over Assumptions

Migration decisions should be supported by evidence.

Evidence may include:

- Business terminology
- Existing values
- Report usage
- Relationships
- Existing calculations
- Business documentation
- Business reference workbook

When evidence is insufficient, document the uncertainty and seek clarification.

---

## Migrate Incrementally

Large migrations should be divided into manageable units.

Examples include:

- Reference Data Foundation (when applicable)
- One business concept (preferred)
- One subject area
- One report page
- One functional area

Each unit should be validated before proceeding.

---

## Validate Continuously

Validation is not a final activity.

Every migration step should be validated before additional changes are introduced.

Continuous validation reduces migration risk and simplifies troubleshooting.

---

## Document Everything

Migration documentation is part of the deliverable.

Important discoveries, assumptions, decisions and validation results should be recorded as the migration progresses.

Do not rely on memory.

---

# Standard Migration Lifecycle

Every migration follows the same lifecycle.

1. Discovery
2. Dependency Analysis
3. Mapping Analysis
4. Migration Assessment
5. Migration Planning
6. Reference Data Foundation (when applicable)
7. Migration Execution
8. Validation
9. Cleanup

Each phase has a defined objective and expected deliverables.

Do not skip phases.

Do not implement changes before completing the analysis phases.

---

# Roles During a Migration

Every migration consists of several complementary activities.

These activities may be performed by one person or multiple people, but they should always be considered separately.

The primary roles are:

- Migration Analyst
- Semantic Model Architect
- Power BI Developer
- Report Migration Specialist
- Technical Reviewer

Each role contributes different perspectives to the migration.

Maintaining this separation helps reduce mistakes caused by implementing solutions before fully understanding the problem.

---

# Migration Deliverables

Every migration project should produce and maintain the following documents.

- `discovery.md`
- `dependencies.md`
- `field-mapping.md`
- `migration-plan.md`
- `implementation-log.md`
- `validation.md`
- `decisions.md`

These documents are living documents.

They should be updated throughout the migration and should always represent the current understanding of the project.

---

# Implementation Logging

Migration execution is recorded separately from migration planning.

The Migration Plan describes the intended implementation.

The Implementation Log records the implementation that actually occurred.

Every implementation unit should produce a Unit Completion Report in `implementation-log.md`.

Each report should include:

- Status
- Scope
- Objects created
- Objects modified
- Objects removed
- Validation performed
- Validation results
- Issues encountered
- Deviations from the Migration Plan
- Rollback (if any)
- Success criteria
- Recommendation for the next implementation unit

Implementation units should be executed one at a time.

Do not begin the next implementation unit until the current unit has been validated and approved.

---

# Success Criteria

A migration is considered successful when:

- Business behaviour has been preserved.
- Mappings have been validated.
- Report behaviour matches expectations.
- Documentation is complete.
- Validation has been completed successfully.
- Technical debt has not increased.
- The solution is easier to maintain than the original implementation.

The following chapters describe each migration phase in detail.

# Chapter 1 — Discovery

## Objective

The purpose of Discovery is to build a complete understanding of the existing solution before proposing or implementing any changes.

Discovery is the foundation of the migration.

Every decision made during later phases depends on the quality of the Discovery phase.

Never begin implementation before Discovery has been completed.

---

## Questions to Answer

Discovery should answer the following questions:

- What problem does this report solve?
- Which business processes does it support?
- What are the primary business entities?
- Which tables are business data?
- Which tables are reference data?
- Which tables are technical?
- Which tables are candidates for replacement?
- Which objects are likely to remain unchanged?

The goal is to understand the solution rather than the implementation.

---

## Discover the Semantic Model

Inspect the semantic model without making modifications.

Document:

### Tables

For each table identify:

- Business purpose
- Source
- Storage mode
- Number of columns
- Number of measures
- Whether the table is imported, calculated or referenced
- Whether it is likely to remain in the new implementation

---

### Columns

For important columns identify:

- Business meaning
- Data type
- Keys
- Hierarchies
- Sort By columns
- Hidden status

---

### Measures

Document:

- Business purpose
- DAX complexity
- Source tables
- Dependencies
- Candidate migration impact

Measures often reveal business logic that is not obvious from the data model.

---

### Relationships

Document:

- Active relationships
- Inactive relationships
- Cardinality
- Cross-filter direction
- Relationship purpose

Relationships often indicate how business entities interact.

---

## Discover the Report

Inspect every report page.

Do not modify visuals during Discovery.

For every page identify:

- Purpose
- Main audience
- Key business metrics
- Important visuals
- Navigation

---

### Visual Inventory

Document:

- Visual type
- Measures used
- Tables used
- Filters
- Tooltips
- Conditional formatting
- Drillthrough
- Bookmarks

Understanding report usage often helps identify the correct migration strategy.

---

### Filters

Inspect:

- Report filters
- Page filters
- Visual filters
- Slicers
- Sync slicers

Document any filters that depend on objects scheduled for replacement.

---

## Discover the Business Reference Workbook

Inspect the business-maintained workbook (`Input til PowerBI.xlsx`).

This workbook is a copy of the workbook maintained by the business owner.

Each worksheet in the workbook is ingested into Microsoft Fabric, where it becomes a Fabric table with the same name as the worksheet.

The workbook therefore represents the business definition of the Fabric reference tables and should be used as the primary reference when identifying candidate mappings.

During Mapping Analysis:

- Treat each worksheet as the expected source for a corresponding Fabric table.
- Use the worksheet name as the initial candidate Fabric table name.
- Compare the worksheet contents with the legacy semantic model to determine which business concepts and hardcoded reference data it replaces.
- Do not assume that every worksheet needs to be added to the semantic model.
- Recommend only the minimum set of Fabric tables required to replace the legacy implementation, supporting each recommendation with documented evidence.

The workbook should be used to understand:

- Business terminology
- Reference values
- Lookup tables
- Expected business entities
- Candidate Fabric reference tables

The workbook is a business reference used for analysis and validation. It is not the production data source.

## Initial Observations

Record:

- Objects that appear obsolete.
- Objects that appear duplicated.
- Objects that may require redesign.
- Missing documentation.
- Potential migration risks.
- Areas requiring further investigation.

These observations are preliminary.

They should not be interpreted as migration decisions.

---

## Discovery Deliverable

Update:

`migration/discovery.md`

The Discovery document should describe the current solution.

It should not propose implementation changes.

Its purpose is to establish a shared understanding of the existing implementation before analysis begins.

---

## Exit Criteria

The Discovery phase is complete when:

- The semantic model has been inspected.
- The report has been inspected.
- The business workbook has been reviewed.
- Major business entities have been identified.
- Candidate migration areas have been identified.
- Initial risks have been documented.
- Outstanding questions have been recorded.

Only then should the migration proceed to Dependency Analysis.

---

# Chapter 2 — Dependency Analysis

## Objective

The purpose of Dependency Analysis is to understand the complete impact of every proposed migration.

Before replacing any table, column, measure, relationship, or calculation, identify everything that depends on it.

A successful migration depends on understanding not only the objects being replaced, but also every object that references them.

Dependency Analysis reduces the risk of introducing broken reports, incorrect calculations, or incomplete migrations.

---

## Questions to Answer

Dependency Analysis should answer the following questions:

- Which objects depend on this table?
- Which measures reference this column?
- Which visuals use these measures?
- Which filters depend on these fields?
- Which calculations will break if this object is removed?
- Which report pages will be affected?
- Which objects require migration?
- Which objects can remain unchanged?

---

# Dependency Types

Every object may have multiple types of dependencies.

Dependencies should be analyzed from several perspectives.

---

## Semantic Model Dependencies

Inspect dependencies between model objects.

Identify:

### Tables

Determine whether tables are referenced by:

- Measures
- Calculated Columns
- Calculated Tables
- Relationships
- Hierarchies
- Perspectives
- RLS
- OLS

---

### Columns

Determine whether columns are referenced by:

- Measures
- Relationships
- Calculated Columns
- Calculated Tables
- Hierarchies
- Sort By Columns
- Filters

---

### Measures

Determine whether measures are referenced by:

- Other measures
- Calculated Tables
- Visuals
- Tooltips
- Conditional formatting
- Dynamic titles
- Dynamic subtitles

Measures frequently become hidden dependencies.

---

### Relationships

Determine whether relationships support:

- Measure calculations
- Filter propagation
- Report navigation
- Drillthrough behaviour

Relationship changes should always be validated carefully.

---

# Report Dependencies

Every report should be inspected before replacing fields.

Identify dependencies within:

---

## Report Pages

Document:

- Business purpose
- Primary visuals
- Business metrics

---

## Visuals

Inspect every visual.

Document:

- Visual type
- Tables used
- Measures used
- Columns used
- Filters
- Tooltips
- Conditional formatting

---

## Filters

Inspect:

- Report filters
- Page filters
- Visual filters
- Slicers
- Sync slicers

Determine whether migrated objects participate in filtering.

---

## Bookmarks

Identify bookmarks that depend on:

- Specific visuals
- Filters
- Selection state
- Navigation

Bookmarks frequently contain hidden dependencies.

---

## Drillthrough

Inspect:

- Drillthrough pages
- Drillthrough fields
- Navigation paths

Replacing drillthrough fields without updating navigation will break the report.

---

## Tooltips

Inspect:

- Tooltip pages
- Tooltip measures
- Tooltip filters

Tooltips frequently contain hidden business logic.

---

## Field Parameters

Determine whether migrated fields participate in:

- Dynamic dimensions
- Dynamic measures
- Dynamic axes

Field Parameters often require special attention during migration.

---

# External Dependencies

Where applicable, identify dependencies outside the report.

Examples include:

- Dashboard tiles
- Power BI Apps
- Excel workbooks
- Power Automate flows
- Paginated Reports
- Other semantic models

External dependencies should be documented even when they are outside the migration scope.

---

# Dependency Classification

Classify dependencies according to migration impact.

### Critical

Migration cannot proceed until dependency has been addressed.

Examples:

- Measures
- Relationships
- Report visuals

---

### High

Migration likely requires modifications.

Examples:

- Filters
- Drillthrough
- Tooltips

---

### Medium

Migration may require updates.

Examples:

- Display folders
- Hierarchies
- Perspectives

---

### Low

Migration unlikely to affect behaviour.

Examples:

- Descriptions
- Formatting
- Object organization

---

# Dependency Risk Assessment

Assess the migration risk for each dependency.

Consider:

- Number of affected objects
- Business importance
- Complexity
- Validation effort
- Probability of introducing errors

Document significant risks.

---

# Dependency Deliverable

Update:

`migration/dependencies.md`

The document should record:

- Dependencies discovered
- Objects affected
- Migration impact
- Risk assessment
- Outstanding questions

This document becomes the reference for Migration Planning.

---

# Exit Criteria

Dependency Analysis is complete when:

- All affected objects have been identified.
- Hidden dependencies have been investigated.
- Report dependencies have been documented.
- Migration impact has been assessed.
- Outstanding questions have been recorded.

Only then should the migration proceed to Schema Comparison.

# Remaining Phases

The remaining migration phases are described in the engineering guides within the `docs` folder.

## Mapping Analysis

See:

`02-mapping-methodology.md`

This document describes how to:

- Discover mappings
- Assess mapping confidence
- Validate mappings
- Document mapping decisions

---

## Semantic Model Engineering

See:

`03-semantic-model-guidelines.md`

This document describes:

- Model organization
- Relationships
- Measures
- Naming
- Best practices
- Technical standards

---

## Report Migration

See:

`04-report-migration-guidelines.md`

This document describes:

- Visual bindings
- Filters
- Bookmarks
- Tooltips
- Drillthrough
- Field Parameters
- Report validation

---

## Validation

See:

`05-validation-guide.md`

This document describes:

- Structural validation
- Numerical validation
- Report validation
- Performance validation

---

## Engineering Standards

See:

- `06-powerbi-engineering-rules.md`
- `07-tmdl-style-guide.md`
- `08-performance-guidelines.md`

These documents define implementation standards for the migration.

---

## Troubleshooting

See:

`09-troubleshooting.md`

This document records lessons learned, common issues, and recommended solutions.

---

# Summary

The migration process should always follow this sequence:

1. Discovery
2. Dependency Analysis
3. Mapping Analysis
4. Migration Planning
5. Migration
6. Validation
7. Cleanup

Do not skip phases.

Do not modify before understanding.

Do not delete before validation.

Do not complete a migration until business behaviour has been verified.

---

# Phase Completion Requirements

Every migration phase concludes with a mandatory Phase Completion Report before proceeding to the next phase.

The purpose of this report is to:

- Confirm that the objectives of the current phase have been achieved.
- Provide traceability of all changes made during the phase.
- Distinguish between documentation work and implementation work.
- Confirm whether the phase exit criteria have been satisfied.
- Determine whether user approval is required before continuing.

The report must include the following sections.

## Phase Status

Summarize:

- Phase completed
- Objectives achieved
- Outstanding questions
- Recommended next phase

---

## Files Modified

Clearly separate documentation changes from implementation changes.

### Documentation Files

List every documentation file that was created or modified during the phase.

For each file include:

- File path
- Purpose of the update
- Summary of the changes

### Implementation Files

List every implementation file that was modified.

Implementation files include, but are not limited to:

- Semantic model (.tmdl)
- Report definition (.json)
- PBIP files
- DAX measures
- Power Query expressions
- Relationships
- Tables
- Columns

For each file include:

- File path
- Objects modified
- Reason for the modification

If no implementation files were modified, explicitly state:

> No implementation files were modified during this phase.
>
> This phase consisted only of analysis and documentation.

---

## Documentation Integrity Check

Confirm that:

- No duplicated sections exist.
- Superseded content has been removed.
- Only one authoritative version of each section remains.
- Cross-references are still valid.
- The documentation reflects the currently approved migration strategy.

Documentation integrity should be verified before the phase is considered complete.

---

## Deliverables

Summarize the work products produced during the phase.

Examples include:

- Discovery documentation completed
- Dependencies identified
- Candidate mappings documented
- Migration plan prepared
- Validation completed

---

## Exit Criteria

Explicitly confirm whether the exit criteria for the current phase have been satisfied.

For each criterion indicate:

- ✔ Met
- ✖ Not met
- ⚠ Partially met

If any criterion has not been met, explain why and recommend the next action.

---

## Approval Gate

Before proceeding to the next phase, explicitly state whether user approval is required.

If approval is required, stop and wait for the user's confirmation before continuing.

Do not automatically proceed to the next migration phase.

A migration phase is complete only when:

- Activities have been completed.
- Documentation has been updated.
- Documentation integrity has been verified.
- Required validation has been performed.
- User approval has been obtained where required.

Do not begin the next phase until these conditions have been satisfied.
