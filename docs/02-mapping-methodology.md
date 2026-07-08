# Mapping Methodology

## Purpose

This document defines the methodology for identifying, evaluating, validating, and documenting mappings between the legacy semantic model and the new Microsoft Fabric implementation.

Unlike many migration projects, the mappings in this repository are not fully known in advance.

One of the primary objectives of the migration is therefore to discover the correct correspondence between the existing semantic model and the new Fabric data model.

This document describes how that discovery should be performed.

---

# Objectives

The mapping process should achieve the following objectives:

- Preserve business meaning.
- Preserve report behaviour.
- Preserve business calculations.
- Minimize migration risk.
- Document every important decision.
- Make assumptions explicit.
- Provide traceability for future maintenance.

Mappings should always be supported by evidence.

Never present inferred mappings as confirmed facts.

---

# Mapping Philosophy

Mapping is a process of understanding business concepts rather than matching technical objects.

The objective is not to answer:

> Which new column has the same name?

The objective is to answer:

> Which object represents the same business concept?

Business meaning always takes precedence over technical similarity.

---

# Types of Mappings

Mappings may exist at several levels.

## Business Concept Mapping

Business concepts should be identified before individual objects.

Examples include:

- Production
- Emissions
- Chemicals
- Waste
- Water
- Energy
- Permits

Understanding the business concept provides context for every subsequent mapping.

---

## Table Mapping

Determine which Fabric table represents the same business entity as each legacy table.

A table mapping should never be based solely on table names.

---

## Column Mapping

Determine how attributes of the business entity correspond between implementations.

Columns frequently change names while preserving the same business meaning.

---

## Measure Mapping

Measures frequently contain the most important business logic.

Measure mappings should preserve:

- Business meaning
- Calculation logic
- Filter context
- Intended usage

---

## Relationship Mapping

Relationships represent business structure.

Relationship mappings should preserve:

- Cardinality
- Business meaning
- Filter propagation
- Navigation behaviour

---

# Sources of Evidence

Every proposed mapping should be supported by one or more sources of evidence.

Possible evidence includes:

- Business terminology
- Business documentation
- Business reference workbook
- Existing report behaviour
- Existing measures
- Existing calculations
- Relationships
- Keys
- Granularity
- Matching values
- Matching categories
- Matching dimensions
- Existing visual usage

No single source of evidence should be considered sufficient by itself.

Confidence increases as multiple sources support the same conclusion.

---

# Mapping Workflow

Mappings should be developed incrementally.

The recommended workflow is:

1. Understand the business concept.
2. Identify candidate Fabric tables.
3. Compare business meaning.
4. Compare structure.
5. Compare values.
6. Compare report usage.
7. Compare measures.
8. Assess confidence.
9. Document reasoning.
10. Validate with report behaviour.

Do not skip steps.

---

# Business Reference Workbook

The business workbook is one of the primary sources of information during mapping.

It is a copy of the workbook maintained by the business and is used to understand the intended business structure.

The workbook should be used to:

- Understand business terminology.
- Identify candidate entities.
- Compare reference values.
- Understand expected dimensions.
- Verify business definitions.

The workbook should not be treated as proof that a mapping is correct.

Instead, it should be considered one piece of supporting evidence.

---

# Fabric Model Analysis

Analyze the Fabric implementation independently from the legacy model.

Identify:

- Business entities
- Tables
- Columns
- Relationships
- Keys
- Granularity

Avoid attempting to force one-to-one mappings before understanding the Fabric design.

Sometimes a legacy table may correspond to:

- one Fabric table
- several Fabric tables

Likewise, several legacy tables may correspond to a single Fabric table.

---

# Discovering Candidate Mappings

The purpose of this phase is to identify the most likely correspondence between the legacy semantic model and the Fabric implementation.

Mapping should be treated as an investigation rather than a matching exercise.

Do not begin by asking:

> "Which table has the same name?"

Instead ask:

> "What business concept is this object trying to represent?"

The mapping process should progressively narrow the possible candidates until sufficient evidence exists to support a recommendation.

---

# Step 1 – Understand the Legacy Object

Before looking at the Fabric model, fully understand the legacy object.

For tables, determine:

- Business purpose
- Business owner (if known)
- Source system
- Granularity
- Primary keys
- Relationships
- Measures stored in the table
- Report usage
- Business terminology

For columns, determine:

- Business meaning
- Data type
- Whether it is a key
- Whether it is descriptive or transactional
- Whether it participates in relationships
- Whether it is used in measures
- Whether it is used in report filters

For measures, determine:

- Business question answered
- DAX calculation
- Referenced tables
- Referenced columns
- Filter context
- Business importance

The objective is to understand the object before attempting to replace it.

---

# Step 2 – Understand the Fabric Model

Only after understanding the legacy implementation should the Fabric model be analysed.

Identify:

- Business entities
- Fact tables
- Dimension tables
- Relationships
- Naming conventions
- Business terminology
- Keys
- Grain

Do not immediately attempt to match objects.

Instead, understand how the Fabric model has been designed.

---

# Step 3 – Identify Candidate Objects

For each legacy object, identify one or more candidate replacements.

Candidate identification should consider:

- Business purpose
- Similar terminology
- Matching values
- Relationships
- Grain
- Measures
- Report usage

Candidate mappings are hypotheses.

They are not yet confirmed.

---

# Step 4 – Compare Business Meaning

Business meaning should always be evaluated before technical implementation.

Questions to ask include:

- Do both objects describe the same business concept?
- Do users use these objects for the same purpose?
- Would replacing one with the other change business interpretation?
- Do report consumers expect the same behaviour?

If the business meaning differs, the mapping should be rejected regardless of technical similarity.

---

# Step 5 – Compare Structure

Compare the structural characteristics of each candidate.

Evaluate:

- Primary keys
- Foreign keys
- Cardinality
- Data types
- Number of rows
- Grain
- Relationships
- Required joins

Structural similarity increases confidence but does not prove correctness.

---

# Step 6 – Compare Values

Where possible, compare actual values.

Examples include:

- Categories
- Status values
- Codes
- Names
- Dates
- Counts

Look for:

- Missing values
- Additional values
- Different naming
- Different coding standards
- Different granularity

Value comparison frequently reveals hidden differences between apparently similar objects.

---

# Step 7 – Compare Report Usage

Reports often reveal the intended purpose of an object.

Inspect:

- Visuals
- Measures
- Filters
- Drillthrough
- Tooltips
- Bookmarks

Determine how users interact with the object.

Business usage frequently provides stronger evidence than object names.

---

# Step 8 – Compare Existing Measures

Measures often provide the strongest evidence for a mapping.

For every important measure:

Determine:

- Which tables it references.
- Which columns it aggregates.
- Which dimensions filter it.
- Which report pages use it.

If multiple measures consistently reference the same Fabric table, confidence increases.

---

# Step 9 – Evaluate Relationships

Relationships frequently reveal business structure.

Compare:

- Parent-child relationships
- Fact-dimension relationships
- Filter propagation
- Cardinality
- Business navigation

A correct mapping should preserve the intended business relationships whenever possible.

---

# Step 10 – Build the Mapping Hypothesis

After gathering evidence, propose the most likely mapping.

For each proposed mapping document:

- Legacy object
- Candidate Fabric object
- Supporting evidence
- Remaining uncertainties
- Confidence level
- Validation approach

The objective is to produce a defensible hypothesis rather than an assumption.

---

# Object Identity Mapping

A migration must preserve not only business logic, but also object identity throughout the semantic model and report.

When evaluating a mapping, distinguish between:

- Source object name
- Semantic model object name
- Display name (caption)
- Business concept

These are not necessarily identical.

For every migrated object document:

- Legacy source name
- Legacy semantic model name
- Legacy display name (if different)
- Candidate Fabric source name
- Candidate semantic model name
- Intended display name
- Business concept represented

The objective is to preserve the business identity of the object, even if its technical implementation changes.

Do not assume that matching names indicate matching business concepts.

Likewise, do not assume different names indicate different business concepts.


# Evaluating Mapping Confidence

Every proposed mapping should include a confidence assessment.

Confidence reflects the quality of the available evidence, not the certainty of the conclusion.

Confidence should increase as additional evidence is collected throughout the migration.

Confidence may decrease if conflicting evidence is discovered.

Always explain why a confidence level was assigned.

---

## High Confidence

A mapping may be considered High confidence when multiple independent sources support the same conclusion.

Typical indicators include:

- Matching business purpose
- Matching business terminology
- Matching report behaviour
- Matching relationships
- Matching keys
- Matching granularity
- Matching values
- Matching measures

High confidence does not eliminate the need for validation.

---

## Medium Confidence

A mapping should be considered Medium confidence when the evidence is generally supportive but some uncertainty remains.

Examples include:

- Similar business meaning
- Similar structure
- Limited report usage
- Partial value matching
- Incomplete documentation

Medium confidence mappings should receive additional validation before implementation.

---

## Low Confidence

Low confidence indicates that the available evidence is weak or contradictory.

Examples include:

- Similar names only
- Missing documentation
- Different granularity
- Conflicting report behaviour
- Missing relationships
- Unknown business purpose

Low confidence mappings should not be implemented without additional investigation or user approval.

---

# Supporting Evidence

Every mapping should include supporting evidence.

Possible evidence includes:

## Business Evidence

Examples:

- Business terminology
- Business documentation
- Business reference workbook
- Business owner feedback

---

## Structural Evidence

Examples:

- Keys
- Relationships
- Cardinality
- Granularity
- Data types

---

## Report Evidence

Examples:

- Visual usage
- Measures
- Filters
- Drillthrough
- Tooltips
- Field Parameters

---

## Data Evidence

Examples:

- Matching values
- Matching categories
- Matching counts
- Matching dimensions
- Matching dates

---

## Calculation Evidence

Examples:

- DAX references
- Aggregation logic
- Existing calculations
- Filter propagation

No single source of evidence should be considered conclusive.

Confidence should be based on the combined evidence.

---

# Common Mapping Patterns

The migration is unlikely to consist entirely of one-to-one mappings.

The following patterns should be considered.

---

## One Legacy Table → One Fabric Table

The simplest scenario.

The business entity remains unchanged.

Only technical implementation differs.

---

## One Legacy Table → Multiple Fabric Tables

The Fabric implementation may normalize the data model.

Examples include:

- Splitting dimensions
- Separating lookup tables
- Separating transactional data

The migration should preserve the original business behaviour.

---

## Multiple Legacy Tables → One Fabric Table

The Fabric implementation may consolidate business entities.

Examples include:

- Combined fact tables
- Unified dimensions
- Standardized business entities

Carefully verify granularity before migrating.

---

## One Legacy Column → Multiple Columns

Business information may have been separated.

Examples include:

- Date split into Year, Month and Day
- Codes separated from descriptions

Report behaviour should remain unchanged.

---

## Multiple Legacy Columns → One Column

Several legacy attributes may have been standardized into a single Fabric attribute.

Verify that business meaning has not changed.

---

## Measure Redesign

Measures may require redesign rather than direct replacement.

Examples include:

- Different table structure
- Different relationships
- New dimensions
- New aggregation paths

The objective is to preserve the business result rather than the implementation.

---



# Strategy Reassessment

Mapping Analysis may reveal evidence that materially changes the preferred migration strategy.

When this occurs:

- Reassess the approved migration strategy before implementation begins.
- Compare the existing approach with newly identified alternatives.
- Document the assessment objectively.
- Record the approved decision in `migration/decisions.md`.
- Update `migration/migration-plan.md` before implementation resumes.

Do not continue with an outdated migration strategy simply because it was approved earlier.

# Mapping Risks

Common migration risks include:

- Similar names with different meanings.
- Different grain.
- Hidden report dependencies.
- Changed relationships.
- Different filter propagation.
- Missing lookup values.
- Deprecated business concepts.
- Renamed business entities.

Every identified risk should be documented.

---

# Mapping Decision Checklist

Before confirming a mapping, verify:

- Does it represent the same business concept?
- Does it preserve report behaviour?
- Does it preserve calculations?
- Does it preserve relationships?
- Does it preserve filter context?
- Does it preserve business terminology?
- Has supporting evidence been documented?
- Has a confidence level been assigned?
- Has a validation strategy been defined?

If any answer is "No", continue the investigation.

---

# Deliverables

The mapping process should produce:

- Candidate mappings
- Confirmed mappings
- Rejected mappings
- Confidence assessments
- Supporting evidence
- Outstanding questions
- Validation requirements

All findings should be recorded in:

- `migration/field-mapping.md`
- `migration/decisions.md` (approved mapping decisions)
- `migration/migration-plan.md` (approved implementation approach)
- `migration/implementation-log.md` (implementation outcomes)

The mapping methodology is complete only when every important business object has either:

- A confirmed mapping,
- A documented candidate mapping awaiting validation, or
- A documented explanation of why no mapping exists.