# Migration Inventory

**Project:** Project 1 — Environmental KPIs
**Date:** 2026-07-03
**Purpose:** Establish a traceable candidate migration scope based on Discovery findings, for use as a reference throughout the project.

This document describes the objects identified during Discovery as candidates for migration. Every object listed here is a **candidate**, not a confirmed implementation target. The actual replacement strategy will only be determined after the Fabric reference tables have been identified and analyzed during Mapping Analysis, and after a Migration Plan has been reviewed and approved.

This document should be updated as the project progresses and understanding improves.

---

## Migration Summary

Discovery identified that five fact tables in the semantic model currently embed permit limits and KPI thresholds directly as SQL CASE statements or Power Query conditionals. These values appear to correspond to reference data maintained by the business owner in the workbook `Input til PowerBI.xlsx`, which is ingested into Fabric.

The candidate migration approach is to replace the hardcoded values with relationships to Fabric reference tables. The Fabric replacement tables have not yet been introduced into the semantic model. Their identification is a **Mapping Analysis** activity.

All conclusions in this document are based on Discovery findings. Decisions on implementation will be made in the Mapping Analysis and Migration Planning phases.

---

## 1. Candidate Fact Tables — Objects Identified During Discovery

The following tables were identified during Discovery as containing hardcoded reference data. Each table has two categories of columns:

- **Columns not identified as reference data** — these originate from the Fabric measurement source and are not candidates for replacement.
- **Candidate reference columns** — these contain permit limits or KPI thresholds currently hardcoded in SQL or Power Query. These are candidates for replacement by Fabric reference tables, subject to validation during Mapping Analysis.

No implementation decisions have been made for any of these tables. The column categorisation below reflects current understanding based on Discovery inspection of the TMDL source and Power Query partitions.

### 1.1 Emissions to air

**Fabric source:** `wh_gold_hsseq` · `dbt_gold_nems_environment_kpi.fact_nems__environment_kpi_emission_to_air_ctt`

**Columns not identified as reference data (measurement / structural):**
CO2 Emissions, NOx Emissions, CH4 Emissions, NMVOC Emissions, SOx Emissions, Volume, Energy, Cold ventilated gas, Time_Id, Field, Facility, Emissions Source, Stream Subtype, Source Details, QuarterNum, YearNum, MonthNum

**Candidate reference columns — identified for potential replacement:**

| Column | Type | Description | Scope |
|--------|------|-------------|-------|
| `Tillatelse flaring` | Permit | Quarterly flaring permit per field, 2019–2026 | Per-field, per-year, per-quarter |
| `KPI flaring` | KPI | Computed from Tillatelse flaring with field-specific % reductions | Per-field, per-year, per-quarter |
| `Division` | Intermediate | Intermediate calc for KPI annualisation (used in visuals) | Per-quarter |
| `Tillatelse NOx` | Permit | Annual NOx permit | Per-field, per-year |
| `KPI NOx` | KPI | Monthly NOx KPI | Per-field, per-year |
| `Permit Cold ventilated gas` | Permit | Cold vent gas permit | Per-field, per-year |
| `KPI Cold ventilated gas` | KPI | Cold vent gas KPI | Per-field, per-year |
| `Permit nmVOC` | Permit | Annual nmVOC permit | Per-field |
| `KPI nmVOC` | KPI | Monthly nmVOC KPI | Per-field, per-year |
| `KPI CO2 tonn` | KPI | CO2 KPI in tonnes | Per-field |
| `Month` | Helper | Month number used in KPI annualisation | Derived |

**Notes:**
- `KPI flaring` applies a second layer of field-year-quarter percentage reductions on top of `Tillatelse flaring`. This two-stage logic must be fully understood before any replacement is planned. It is unclear whether a Fabric reference table will cover this derived computation or whether it will remain in DAX.
- `Division` is bound directly in at least one visual (not only via a measure). Any replacement strategy must account for this direct binding.
- `Cold ventilated gas` originates from the Fabric measurement source and is therefore **not** a candidate reference column.

---

### 1.2 CH4_NMVOC

**Fabric source:** `wh_gold_hsseq` (source table to be confirmed in Mapping Analysis)

**Columns not identified as reference data:**
Date, field, facility, CH4 Emissions (tonne), nmVOC Emissions (tonne), loc_key, Year, Month

**Candidate reference columns — identified for potential replacement:**

| Column | Type | Description | Scope |
|--------|------|-------------|-------|
| `Tillatelse CH4` | Permit | Annual CH4 permit (values: 56, 80, 315, 200, 20, 49, 132, 195, 260 tonnes) | Per-field, per-year |
| `Tillatelse nmVOC` | Permit | Annual nmVOC permit | Per-field, per-facility, per-year |
| `KPI CH4` | KPI | Monthly CH4 KPI | Per-field, per-year |
| `KPI nmVOC` | KPI | Monthly nmVOC KPI | Per-field, per-year |

---

### 1.3 Kaldvent volum

**Fabric source:** `wh_gold_hsseq` (source table to be confirmed in Mapping Analysis)

**Columns not identified as reference data:**
Date, field, facility, Volume (1000 m3), loc_key, Year, Quarter

**Candidate reference columns — identified for potential replacement:**

| Column | Type | Description | Scope |
|--------|------|-------------|-------|
| `Tillatelse Kaldvent` | Permit | Quarterly cold vent permit per field, 2020–2026 | Per-field, per-year, per-quarter |
| `Division` | Intermediate | Tillatelse Kaldvent / 3 (used in KPI QTD calc) | Per-field, per-quarter |
| `KPI Kaldvent QTD` | KPI | QTD KPI target — complex seasonal logic with field-year-quarter conditions | Per-field, per-year, per-quarter |

**Notes:**
- `KPI Kaldvent QTD` is the most complex column in this table. Its current logic incorporates `Tillatelse Kaldvent` and `Division` with special seasonal handling per field and year. Whether a Fabric reference table can replicate this derived quarterly computation requires validation during Mapping Analysis.
- `Division` is bound directly in at least one visual.

---

### 1.4 Oily water

**Fabric source:** `wh_gold_hsseq` · `dbt_gold_nems_environment_kpi.fact_nems__environment_kpi_oily_water_ctt`

**Columns not identified as reference data:**
Asset, facility, Stream Type, Discharged Oil Concentration ISO, Production Volume, Injected Volume, Discharged Volume (L), Discharged Oil Mass ISO (mg), loc_key

**Candidate reference columns — identified for potential replacement:**

| Column | Type | Description | Scope |
|--------|------|-------------|-------|
| `Tillatelser` | Permit | Oil discharge permit | Per-field |
| `KPI Oil to sea` | KPI | Oil-to-sea KPI | Per-field |
| `KPI drain water` | KPI | Drain water KPI | Per-field |
| `KPI water reinjected` | KPI | Water reinjection KPI | Per-field |

---

### 1.5 Radioaktive isotoper

**Fabric source:** `wh_gold_hsseq` (source table to be confirmed in Mapping Analysis)

**Columns not identified as reference data:**
Date, Update Date, Field, Facility, Stream Type, Stream Subtype, Stream, Component, Samples, loc_key, Year, Måned, Component Activity (Bq)

**Candidate reference columns — identified for potential replacement:**

| Column | Type | Description | Scope |
|--------|------|-------------|-------|
| `Permits` | Permit | Per-component (Ra226, Ra228, 210Pb), per-field, per-year — computed in Power Query using nested if/then/else | Per-component, per-field, per-year |
| `KPIs` | KPI | `(Permits / 12) * Month` with 0.9 factor for Ula and Valhall | Per-component, per-field, per-year |

**Notes:**
- `Permits` is the most complex reference data identified in the model. The Power Query logic covers at least 3 isotope components (Ra226, Ra228, 210Pb) across 7+ fields with multi-year conditions. Whether a Fabric reference table exists at this granularity is unknown and is a key question for Mapping Analysis.
- Any replacement strategy will need to account for the Component, Field, and Year dimensions — a more granular relationship key than is required by any other candidate table.

---

## 2. Tables Not Identified as Migration Candidates at This Stage

The following tables were inspected during Discovery and were not found to contain hardcoded reference data. They are not currently identified as candidates for migration.

| Table | Basis for assessment |
|-------|---------------------|
| `Dim_Date` | Queries Fabric directly via `wh_gold_utilities.dbt_gold.dim_dates`. No hardcoded permit or KPI values identified. |
| `Location` | Computed Power Query dimension built from `Emissions to air`, `Location (2)`, and `Location3`. No hardcoded reference data identified. If field normalisation logic in candidate Fabric reference tables differs from the current logic, this table may need to be reassessed. |
| `Location3` | Supplementary source for `Location`. Same assessment as above. |

**Status unclear — pending confirmation:**

| Table | Basis for assessment |
|-------|---------------------|
| `Emissions to air CO2 Hod` | Filtered subset of `Emissions to air` (Hod rows only, Field renamed to Valhall). Business reason unknown. Whether this table uses any of the candidate reference columns from `Emissions to air` has not been confirmed. Its migration scope cannot be assessed until its purpose is established. |

---

## 3. Candidate Fabric Reference Table Roles — Working Hypothesis

The following reference table roles are required by the migration. The corresponding Fabric table names are **not yet known** and will be identified during Mapping Analysis.

| Reference table role | Granularity | Source (expected) | Tables it will serve |
|---------------------|-------------|-------------------|--------------------|
| Air emissions permits / KPIs | Field, Year (NOx, nmVOC, CO2, flaring, cold vent) | Input til PowerBI.xlsx worksheet(s) | Emissions to air |
| CH4 / nmVOC permits | Field, Facility, Year | Input til PowerBI.xlsx | CH4_NMVOC |
| Cold vent permits / KPI | Field, Year, Quarter | Input til PowerBI.xlsx | Kaldvent volum |
| Oily water permits / KPIs | Field | Input til PowerBI.xlsx | Oily water |
| Radioactive isotope permits | Component, Field, Year | Input til PowerBI.xlsx | Radioaktive isotoper |

Multiple physical Fabric tables may cover more than one role, or a single table may cover multiple. This will be determined during Mapping Analysis.

---

## 4. Measures Identified as Migration Candidates

The following measures are identified as migration candidates because their DAX expressions reference one or more of the candidate reference columns identified in Section 1.

For each measure, the specific column references that cause it to be included are shown below.

### 4.1 Measures referencing candidate columns (11 identified)

**Traceability basis:** Each entry below shows the exact column reference found in the measure's DAX expression during Discovery. The column referenced appears in the candidate reference columns list for its table in Section 1.

| # | Measure | Table | Candidate columns referenced in DAX | DAX evidence |
|---|---------|-------|--------------------------------------|--------------|
| 1 | `NOx KPI year` | Emissions to air | `KPI NOx`, `Tillatelse NOx` | `CALCULATE(MAX([KPI NOx]),...)` + `CALCULATE(MAX([KPI NOx])*12/...,...)` + `CALCULATE(MAX([Tillatelse NOx]),...)` |
| 2 | `nmVOCfuel KPI year` | Emissions to air | `Permit nmVOC` | `CALCULATE(MAX([Permit nmVOC])*0.9,...)` + `CALCULATE(MAX([Permit nmVOC]),...)` |
| 3 | `nmVOC_KPI year` | Emissions to air | `KPI nmVOC` | `MAX([KPI nmVOC])*12/MONTH(LASTDATE([Time_Id]))` |
| 4 | `CO2 KPI year` | Emissions to air | `KPI CO2 tonn`, `Month` | `DIVIDE(MAX([KPI CO2 tonn]), MAX([Month]))*12` |
| 5 | `CH4 KPI year` | CH4_NMVOC | `Tillatelse CH4` | `CALCULATE(MAX([Tillatelse CH4])*0.9,(field IN {"Ula"}))` + `CALCULATE(MAX([Tillatelse CH4]), NOT (...))` |
| 6 | `nmVOC KPI year` | CH4_NMVOC | `Tillatelse nmVOC` | `CALCULATE(MAX([Tillatelse nmVOC])*0.9,(field IN {"Ula"}))` + `CALCULATE(MAX([Tillatelse nmVOC]), NOT (...))` |
| 7 | `nmVOC_cold_KPI year` | CH4_NMVOC | `KPI nmVOC` | `MAX([KPI nmVOC])*12/MONTH(LASTDATE([Date]))` |
| 8 | `CH4_year KPI` | CH4_NMVOC | `KPI CH4` | `MAX([KPI CH4])*12/MONTH(LASTDATE([Date]))` |
| 9 | `Vented KPI year` | Kaldvent volum | `Tillatelse Kaldvent` | `CALCULATE(MAX([Tillatelse Kaldvent])*0.9,(Field IN {"Valhall","Ula","Hod"}))` + `CALCULATE(MAX([Tillatelse Kaldvent]), NOT (...))` |
| 10 | `KPI reinjected` | Oily water | `KPI water reinjected` | `MAX([KPI water reinjected])` |
| 11 | `KPI year` | Radioaktive isotoper | `Permits` | `CALCULATE(MAX([Permits])*0.9,(Field IN {"Valhall","Ula","Alvheim","Skarv"}))` + `CALCULATE(MAX([Permits]), NOT (...))` |

### 4.2 Measures not identified as migration candidates

The following measures reference only measurement columns (columns not identified as reference data in Section 1). They are not currently identified as migration candidates. They may require reassessment if the migration changes the column structure of the tables they reference.

| Measure | Table | Basis for exclusion |
|---------|-------|--------------------|
| `Volume QTD` | Emissions to air | References `Volume` (measurement column) via `TOTALQTD` |
| `Volume YTD` | Emissions to air | References `Volume` (measurement column) via `TOTALYTD` |
| `Volume divided by Count of DayOfMonth` | Emissions to air | References `Volume` and `DayNo` (measurement / date columns) |
| `Volume average per Date` | Emissions to air | References `Volume` (measurement column) |
| `CO2 Emissions Ton` | Emissions to air | References `CO2 Emissions` (measurement column) ÷ 1000 |
| `CO2 Emissions YTD` | Emissions to air | References `CO2 Emissions` (measurement column) via `TOTALYTD` ÷ 1000 |
| `CO2 Emissions QTD` | Emissions to air | References `CO2 Emissions` (measurement column) via `TOTALQTD` |
| `CO2 in tonne` | Emissions to air | Alias for `[CO2 Emissions YTD]` |
| `NOx Emissions YTD` | Emissions to air | References `NOx Emissions` (measurement column) via `TOTALYTD` |
| `Cold ventilated gas YTD` | Emissions to air | References `Cold ventilated gas` (measurement column) via `TOTALYTD` |
| `CH4 Emissions YTD` | Emissions to air | References `CH4 Emissions` (measurement column) via `TOTALYTD` |
| `NMVOC Emissions YTD` | Emissions to air | References `NMVOC Emissions` (measurement column) via `TOTALYTD` |
| `Average of Volume QTD` | Emissions to air | References `Volume` (measurement column) via `TOTALQTD(AVERAGE(...))` |
| `yaxis_co2` | Emissions to air | References `[CO2 Emissions YTD]` (measurement-based measure) + 3000 |
| `Common And Vented CH4 (kg) YTD` | CH4_NMVOC | References `CH4 Emissions (tonne)` (measurement column) via `TOTALYTD` |
| `Common And Vented NMVOC (tonne) YTD` | CH4_NMVOC | References `nmVOC Emissions (tonne)` (measurement column) via `TOTALYTD` |
| `Volume (1000 m3) QTD` | Kaldvent volum | References `Volume (1000 m3)` (measurement column) via `TOTALQTD` |
| `Volume (1000 m3) YTD` | Kaldvent volum | References `Volume (1000 m3)` (measurement column) via `TOTALYTD` |
| `Reinjectiongrade` | Oily water | References `Injected Volume` and `Production Volume` (measurement columns) |
| `Discharged Oil Mass ISO (mg) divided by Discharged Volume (L)` | Oily water | References measurement columns only |
| `Discharged Oil Mass ISO (mg) YTD` | Oily water | References measurement column via `TOTALYTD` |
| `Discharged Oil Mass ISO (mg) divided by Discharged Volume (L) YTD` | Oily water | References measurement-based ratio measure via `TOTALYTD` |
| `Discharged Volume (L) YTD` | Oily water | References measurement column via `TOTALYTD` |
| `Component Activity (Bq) MTD` | Radioaktive isotoper | References `Component Activity (Bq)` (measurement column) via `TOTALMTD` ÷ 1e9 |
| `Component Activity (Bq) YTD` | Radioaktive isotoper | References `Component Activity (Bq)` (measurement column) via `TOTALYTD` ÷ 1e9 |

---

## 5. Candidate Relationship Changes

### Existing relationships — not identified as candidates for change

All current relationships between fact tables, `Location`, and `Dim_Date` were identified during Discovery. None are currently candidates for removal or modification as a result of this migration. See `discovery.md` for the full relationship list.

### Candidate new relationships — working hypothesis

If candidate reference columns are replaced by Fabric reference tables (see Section 3), each affected fact table would require at least one new relationship to its corresponding reference table. The join key and cardinality cannot be determined until the Fabric reference table structure is known.

The following observations were made during Discovery about the likely join dimensions based on the granularity of the current hardcoded data. These are **observations**, not design decisions.

| Candidate fact table | Observed granularity of current reference data | Potential join dimensions (hypothesis only) |
|---------------------|-----------------------------------------------|---------------------------------------------|
| Emissions to air | Field, Year | Field, Year (or via `loc_key`) |
| CH4_NMVOC | Field, Facility, Year | Field, Facility, Year (higher granularity than other tables) |
| Kaldvent volum | Field, Year, Quarter | Field, Year, Quarter |
| Oily water | Field | Field (simplest observed granularity) |
| Radioaktive isotoper | Component, Field, Year | Component, Field, Year (three observed dimensions) |

Actual relationship keys, cardinality, and filter direction will be determined and approved during Mapping Analysis and Migration Planning.

---

## 6. Report Pages Containing Migration Candidates

The following classification is based on whether Discovery found visuals on each page that bind to candidate reference columns (Section 1) or to measures identified as migration candidates (Section 4).

| Page | Page ID | Assessment | Basis |
|------|---------|------------|-------|
| KPI emissions to air | ReportSectionfb30a317826482a24912 | **Contains migration candidates.** | 16 visuals identified with direct or measure-based bindings to candidate columns from `Emissions to air`, `CH4_NMVOC`, and `Kaldvent volum`. |
| KPI discharge to sea | ReportSection8c1b620bd0d8c58c055c | **Contains migration candidates.** Also contains 2 pre-existing broken visual references (Section 8). | 8 visuals identified with bindings to candidate columns from `Oily water` and `Radioaktive isotoper`. |
| KPI emissions to air before 2025 | d81c48da7029c857a1ef | **Contains migration candidates.** | 11 visuals identified with direct or measure-based bindings to candidate columns from `Emissions to air`, `CH4_NMVOC`, and `Kaldvent volum`. |
| INFO | ReportSectionb36fb0f63033135e01d7 | Not identified as a migration candidate. | Static page. No data bindings found during Discovery. |
| Page 1 | ReportSection6ef73c275f726438b745 | Not identified as a migration candidate for this migration. | All visuals on this page reference `ResultAll`, a table that does not exist in the semantic model. See Section 8. |

---

## 7. Visuals Containing Migration Candidates

Visuals bound to hardcoded reference columns or KPI measures that reference them.

### KPI emissions to air (ReportSectionfb30a317826482a24912)

| Visual ID | Columns / Measures Bound | Subject |
|-----------|--------------------------|---------|
| `5744dedd70968295b016` | Tillatelse NOx, NOx KPI year, NOx Emissions | NOx KPI card |
| `c4f3196a573dd0d34aa1` | Tillatelse NOx, NOx KPI year, NOx Emissions | NOx KPI card (duplicate?) |
| `7b7ba5c40730c60802db` | Permit nmVOC, nmVOC_KPI year, NMVOC Emissions YTD | nmVOC KPI card |
| `824554953bb3a0e0e0cd` | CO2 KPI year, KPI CO2 tonn, CO2 Emissions YTD | CO2 KPI card |
| `51b9d8c18279056a0967` | Tillatelse CH4, CH4_year KPI, CH4 Emissions YTD | CH4 KPI card |
| `9ec62929aaa8234a5052` | Tillatelse nmVOC, nmVOC_cold_KPI year | nmVOC cold vent KPI card |
| `22e4ed31d7e190033ab8` | Tillatelse Kaldvent, Vented KPI year, Volume (1000 m3) QTD | Cold vent KPI card |
| `2eab323e541360477545` | Tillatelse flaring, Emissions to air measures | Flaring visual |
| `10723f52a5750eb14904` | Tillatelse NOx (+ trend data) | NOx trend chart |
| `12a11a990ec6c7473de4` | Tillatelse nmVOC (+ trend data) | nmVOC trend chart |
| `ab22c12a9cae1a96eb7d` | Tillatelse NOx (+ trend data) | NOx trend chart |
| `d03da09d0250caae2b25` | Permit nmVOC (+ trend data) | nmVOC trend chart |
| `52643268d7644abdc5d0` | Tillatelse flaring (+ trend data) | Flaring trend chart |
| `edd7ee28d7087be799b6` | KPI CO2 tonn (+ trend data) | CO2 trend chart |
| `ddd3e88e0b5d07876836` | Tillatelse CH4 (+ trend data) | CH4 trend chart |
| `f5b5887b1048bca77d21` | Tillatelse Kaldvent, KPI Kaldvent QTD (+ trend) | Kaldvent trend chart |

### KPI emissions to air before 2025 (d81c48da7029c857a1ef)

| Visual ID | Columns / Measures Bound | Subject |
|-----------|--------------------------|---------|
| `1ba9940efe433c2f30c4` | Tillatelse NOx, NOx KPI year, NOx Emissions | NOx KPI card |
| `6d9e9e70c4f36ce2befa` | Tillatelse NOx, NOx KPI year, NOx Emissions | NOx KPI card |
| `73ebcfad7da77bdd987f` | Permit nmVOC, nmVOCfuel KPI year | nmVOC KPI card |
| `24842c5295dd7a88f9ee` | Tillatelse CH4, CH4 KPI year | CH4 KPI card |
| `4b7ab3127d58169ad77e` | Tillatelse nmVOC, nmVOC KPI year | nmVOC cold vent KPI card |
| `eaf5796fa941218c62af` | Tillatelse Kaldvent, Vented KPI year, KPI reinjected | Kaldvent + reinjection KPI |
| `993e8351729d392927aa` | Tillatelse flaring, Volume YTD, Volume QTD | Flaring chart |
| `d40ce7d6df7eb2a37d18` | NOx Emissions YTD, KPI NOx, Tillatelse NOx | NOx trend chart |
| `67716bc619dcbd4f6f05` | KPI nmVOC, Permit nmVOC | nmVOC trend chart |
| `fe4e4b2b1c5b32074d99` | Tillatelse Kaldvent, KPI Kaldvent QTD, Volume (1000 m3) QTD | Kaldvent trend chart |
| `ecd20f287253686f6d00` | Tillatelse flaring, Division | Flaring detail |

### KPI discharge to sea (ReportSection8c1b620bd0d8c58c055c)

| Visual ID | Columns / Measures Bound | Subject |
|-----------|--------------------------|---------|
| `1a4c7e656a873264543a` | Tillatelser, KPI Oil to sea, Discharged Oil Mass ISO (mg) | Oil KPI card |
| `45bf48d0931396c2a937` | Tillatelser, KPI drain water | Drain water KPI card |
| `9d46e473d55ed0d5b0ac` | KPI water reinjected, KPI reinjected, Reinjectiongrade | Reinjection KPI |
| `00a40ed8c7930b8db208` | Permits, KPI year (Radioaktive isotoper) | Radioaktive KPI card |
| `12b47246e34ce5970560` | Permits, KPI year (Radioaktive isotoper) | Radioaktive KPI card |
| `b13542dcd6027da94ed0` | Permits, KPI year (Radioaktive isotoper) | Radioaktive KPI card |
| `1f7c027708d880880880` | Tillatelser, KPI Oil to sea (+ trend) | Oil discharge trend |
| `e2d94a972ee1dc65c6e0` | Tillatelser (+ trend data) | Discharge trend chart |

---

## 8. Pre-existing Broken References (Not In Scope)

Three tables are referenced in the report but do not exist in the semantic model. These are not caused by this migration and are not part of the current migration scope. They should be noted and addressed separately.

| Table | Page | Visuals | Notes |
|-------|------|---------|-------|
| `ResultAll` | Page 1 | 8 visuals with columns TillatelseRa228, TillatelseRa226, Tillatelse Pb210, KPI Ra228, KPI Ra226, PB210 KPI year, GBq226_ny, GBq228_ny | This table does not exist in the semantic model. Page 1 is out of scope for this migration. |
| `Fact Target` | KPI discharge to sea | `805d1bf01bda91e10bd9` | Column: Target Oil In Produced Water Discharges. Table does not exist in the semantic model. This visual will be broken at report load. |
| `Time` | KPI discharge to sea | `f83919dde004ee5d526b` | Year-Month-Date hierarchy. Table does not exist in the semantic model. This visual will be broken. |

**Risk:** The two broken visuals on KPI discharge to sea (`Fact Target`, `Time`) are on an active, in-scope page. They may be visible to users as empty or erroring visuals. Resolution is outside the scope of this migration but should be communicated to the business owner.

---

## 9. Candidate Scope Indicators

The following figures summarise the candidate migration scope identified during Discovery. All counts reflect objects currently identified as candidates. Final counts will be confirmed during Dependency Analysis and Mapping Analysis.

| Indicator | Current count | Basis |
|-----------|--------------|-------|
| Candidate fact tables | 5 | Tables found to contain hardcoded permit or KPI columns during TMDL and Power Query inspection (Section 1) |
| Candidate reference table roles | 5 (hypothesis) | One per business domain identified. Actual number of Fabric tables unknown — see Section 3 |
| Candidate new relationships | 5 minimum (hypothesis) | One per candidate fact table → reference table pair, subject to Mapping Analysis |
| Measures identified as candidates | 11 | Measures whose DAX was confirmed to reference a candidate reference column — see Section 4.1 |
| Visuals identified as candidates | 42 | Visuals confirmed to bind (directly or via measure) to candidate reference columns — 35 identified in Discovery, 7 additional confirmed in Dependency Analysis. See dependencies.md Section 3.1 |
| Pages containing candidates | 3 | KPI emissions to air, KPI discharge to sea, KPI emissions to air before 2025 |
| Bookmarks referencing candidate objects | 4 | Info on/off (KPI emissions to air), Info sea on/off (KPI discharge to sea). Bookmarks target specific visual IDs; visual IDs are not expected to change but bookmark state includes filter expressions that reference candidate columns |
| Candidate reference columns across all tables | 25 | Total distinct columns identified in Section 1 (11 in Emissions to air, 4 in CH4_NMVOC, 3 in Kaldvent volum, 4 in Oily water, 2 in Radioaktive isotoper, plus Division appears in 2 tables) |
| Tables with status unclear | 1 | `Emissions to air CO2 Hod` — business purpose not confirmed |
| Pre-existing broken visual references | 3 | 2 on KPI discharge to sea (Fact Target, Time), 1 page fully broken (Page 1 / ResultAll) |
| Overall scope assessment | High | Driven by the volume of candidate columns, number of affected visuals, complexity of `Tillatelse flaring` and `Radioaktive isotoper`, and the unknown structure of the Fabric reference tables |

---

## 10. Risks Identified During Discovery

The following risks were identified during Discovery based on the findings above. They are documented to inform the Mapping Analysis and Migration Planning phases. No mitigations have been committed to at this stage.

| Risk | Likelihood | Impact | Observation |
|------|-----------|--------|-------------|
| **Fabric reference table granularity mismatch** — the Fabric tables ingested from `Input til PowerBI.xlsx` may not provide data at the granularity required by the current model (e.g., quarterly for Kaldvent volum, per-component for Radioaktive isotoper) | Medium | High | Required granularity was inferred from the current hardcoded data. Actual Fabric table granularity is unknown and must be confirmed during Mapping Analysis. |
| **`Radioaktive isotoper` Permits logic is the most complex** — Power Query conditionals cover 3+ isotope components across 7+ fields with multi-year logic | Medium | High | If no Fabric reference table provides data at Component, Field, Year granularity, the candidate replacement strategy will need to be reconsidered. |
| **`KPI flaring` two-stage percentage logic** — depends on `Tillatelse flaring` with a second layer of field-year-quarter percentage reductions applied in SQL | Medium | High | It is not known whether a Fabric reference table will supply derived KPI values or whether this logic will need to be retained elsewhere. |
| **`Division` is bound directly in visuals** — direct column bindings confirmed in visuals `ecd20f287253686f6d00` (Flaring detail) and `22e4ed31d7e190033ab8` (Cold vent KPI) | High | Medium | Confirmed during visual inspection. Any strategy that removes this column must account for direct visual bindings, not only measure dependencies. |
| **Pre-existing broken visuals on an in-scope page** — `Fact Target` (visual `805d1bf01bda91e10bd9`) and `Time` (visual `f83919dde004ee5d526b`) on KPI discharge to sea reference tables that do not exist | Confirmed | Medium | Pre-existing issues unrelated to this migration. Should be distinguished from any breakage caused by migration changes. |
| **`loc_key` composite key consistency** — the key is constructed in both T-SQL and Power Query across multiple tables; casing or spacing differences could silently break future relationships | Low | High | Observed during TMDL and Power Query inspection. Must be validated before any new relationship is created using `loc_key`. |
| **`Emissions to air CO2 Hod` scope unclear** — the business purpose of this table is unknown; its migration scope cannot be assessed | Low | Medium | Business reason should be established early in Mapping Analysis before deciding whether this table is in scope. |
| **Bookmark filter expressions reference candidate column names** — all 4 info-panel bookmarks and `Ivar_Aasen_ikke_slett` contain filter expressions referencing column names directly | Medium | Medium | Confirmed by inspection of bookmark JSON files. Column name changes could break bookmark filter state silently. |
