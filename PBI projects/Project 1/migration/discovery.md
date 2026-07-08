# Discovery

## Project

**Project 1 — Environmental KPIs**

Discovery performed: 2026-07-03
Last updated: 2026-07-03

---

## Migration Objective

The purpose of this migration is to **replace hardcoded reference data** currently embedded in SQL CASE statements and Power Query conditionals within the semantic model with **corresponding Fabric tables** that are maintained by the business owner.

The business owner maintains a workbook (`Input til PowerBI.xlsx`) that defines permit limits and KPI thresholds per field, facility, year, and component. This workbook is ingested into Microsoft Fabric, where each worksheet becomes one or more Fabric tables. These Fabric tables are the planned replacement for the currently hardcoded values.

The Fabric replacement tables have not yet been introduced into the semantic model. Identifying the correct Fabric table mapping is part of the **Mapping Analysis** phase, which will follow once the new tables have been added.

This discovery phase focuses on understanding the existing solution — particularly where reference data is currently hardcoded — so that the migration can be planned accurately.

---

## Semantic Model Overview

The semantic model tracks environmental KPIs for offshore oil and gas assets operated by Aker BP.
It monitors emissions to air, discharge to sea, cold vent volumes, CH4/NMVOC emissions, and radioactive isotopes.

The model is already connected to Microsoft Fabric data sources.
All fact tables query the Fabric data warehouse directly via SQL.
No legacy flat-file or SharePoint sources were observed.

**Model culture:** nb-NO (Norwegian)
**Query source culture:** en-US
**Import mode:** All tables use Import mode

**Fabric endpoint:**
`obax4o2iqosevp5oa2r6dbtune-2dhddioar5aebauc4huzjvnrve.datawarehouse.fabric.microsoft.com`

**Fabric databases used:**
- `wh_gold_utilities` — date dimension
- `wh_gold_hsseq` — all environmental fact data

**Key Fabric schemas/tables:**
- `dbt_gold.dim_dates` → feeds `Dim_Date`
- `dbt_gold_nems_environment_kpi.fact_nems__environment_kpi_emission_to_air_ctt` → feeds `Emissions to air` and `Emissions to air CO2 Hod`
- `dbt_gold_nems_environment_kpi.fact_nems__environment_kpi_oily_water_ctt` → feeds `Oily water` and `Location3`
- Direct SQL in `wh_gold_hsseq` → feeds `CH4_NMVOC` and `Kaldvent volum`

---

## Report Overview

The report contains **5 pages** (1 hidden, 4 visible):

| Order | Page ID | Display Name | Notes |
|-------|---------|--------------|-------|
| 1 | ReportSectionfb30a317826482a24912 | KPI emissions to air | Active/landing page. Filtered on Dim_Date date hierarchy |
| 2 | ReportSection8c1b620bd0d8c58c055c | KPI discharge to sea | Filtered on Oily water.facility |
| 3 | d81c48da7029c857a1ef | KPI emissions to air before 2025 | Historical variant of page 1. Filtered on Dim_Date |
| 4 | ReportSectionb36fb0f63033135e01d7 | INFO | Static information page (720×1280). No data bindings |
| 5 | ReportSection6ef73c275f726438b745 | Page 1 | Filtered on Dim_Date date hierarchy |

The report has **5 bookmarks**.

---

## Tables

| Table | Purpose | Fabric Source | Notes |
|-------|---------|---------------|-------|
| `Dim_Date` | Date dimension | `wh_gold_utilities` · `dbt_gold.dim_dates` | Rows from 2020 to today. Two date columns: `Time_Id` (datetime) and `Date` (date). Query group: Date |
| `Emissions to air` | Main air emissions fact | `wh_gold_hsseq` · `fact_nems__environment_kpi_emission_to_air_ctt` | Most columns are hidden. Contains KPI threshold columns (permit values) stored alongside measurements. Primary location source for the `Location` dimension |
| `Emissions to air CO2 Hod` | CO2 emissions for Hod field only | Same Fabric table as above | Filtered subset of `Emissions to air` — only Hod rows, with Field renamed to Valhall. Likely a workaround for a Hod/Valhall split |
| `CH4_NMVOC` | Methane and NMVOC emissions (common and vented) | `wh_gold_hsseq` · direct SQL | Units in tonnes. Contains permit thresholds (`Tillatelse CH4`, `Tillatelse nmVOC`) and monthly KPI values |
| `Kaldvent volum` | Cold vented gas volumes | `wh_gold_hsseq` · direct SQL | Volume in 1000 m³. Contains complex quarterly KPI logic embedded in the SQL query itself |
| `Oily water` | Produced water and discharge to sea | `wh_gold_hsseq` · `fact_nems__environment_kpi_oily_water_ctt` | Stream types: Produced water, drain water. Contains KPI thresholds (`KPI Oil to sea`, `KPI drain water`, `Tillatelser`) |
| `Location` | Location dimension | Derived via Power Query from `Emissions to air` + `Location (2)` + `Location3` | Highly computed. Built by combining asset names from multiple fact tables. Contains `loc_key` (composite key: Location_Facility_Year in lowercase, spaces removed) |
| `Location3` | Supplementary location rows | `wh_gold_hsseq` · `fact_nems__environment_kpi_oily_water_ctt` | Feeds into `Location` table via append. Handles Fenris, Hod, HANZ field normalizations |
| `Radioaktive isotoper` | Radioactive isotopes in discharge | `wh_gold_hsseq` · direct SQL (source table to be confirmed in Mapping Analysis) | Units in Bq. Has `Date` and `Update Date` columns. `Permits` and `KPIs` columns are computed entirely in Power Query using field/component/year conditionals — this is the primary hardcoded reference data target for this table |

**Hidden / system tables:**
- `DateTableTemplate_0c67aad8` — auto-generated Power BI date template
- `LocalDateTable_*` (×4) — auto-generated date tables for date column variations on Time_Id, Date, Update Date

---

## Business Reference Workbook

**File:** `PBI projects/Project 1/data/Input til PowerBI.xlsx`

This workbook is maintained by the business owner. It defines permit limits, KPI thresholds, and other reference values per field, facility, year, and emission component. The business owner edits this workbook, and its contents are ingested into Microsoft Fabric, where each worksheet becomes one or more Fabric tables.

The workbook serves as the **business source of truth** for the reference values that are currently hardcoded in the semantic model. It is used during this migration to:

- Understand what reference values exist and how they are structured.
- Validate proposed mappings between legacy hardcoded values and candidate Fabric tables.
- Confirm that migrated calculations produce the same results as the original.

The workbook is a reference tool for this migration. It is not the production data source used by the semantic model after migration.

Detailed inspection of the workbook content will be performed during the Mapping Analysis phase.

---

## Relationships

| From Table | From Column | To Table | To Column | Notes |
|------------|-------------|----------|-----------|-------|
| CH4_NMVOC | loc_key | Location | loc_key | Many-to-one |
| CH4_NMVOC | Date | Dim_Date | Date | Many-to-one |
| Kaldvent volum | loc_key | Location | loc_key | Many-to-one |
| Kaldvent volum | Date | Dim_Date | Date | Many-to-one |
| Oily water | loc_key | Location | loc_key | Many-to-one |
| Oily water | Time_Id | Dim_Date | Date | Many-to-one |
| Emissions to air | Time_Id | Dim_Date | Date | Many-to-one |
| Emissions to air | loc_key | Location | loc_key | Many-to-one (AutoDetected) |
| Emissions to air CO2 Hod | Time_Id | LocalDateTable_8d0aa2be | Date | Date variation only (datePartOnly) |
| Radioaktive isotoper | loc_key | Location | loc_key | Many-to-one |
| Radioaktive isotoper | Date | Dim_Date | Date | Many-to-one |
| Radioaktive isotoper | Update Date | LocalDateTable_343e897d | Date | Date variation only (datePartOnly) |
| Location | År | Dim_Date | Year | **Many-to-many** — unusual. Relates year text across tables |
| Dim_Date | Time_Id | LocalDateTable_310cc86e | Date | Date variation (datePartOnly) |
| Dim_Date | Date | LocalDateTable_c9eb5cc9 | Date | Date variation (datePartOnly) |

---

## Hardcoded Reference Data

This section identifies all locations where business reference values (permit limits, KPI thresholds) are currently hardcoded in the semantic model. These are the primary targets for replacement by Fabric tables during migration.

### Emissions to air — SQL CASE statements

The Power Query partition for `Emissions to air` embeds field-specific permit and KPI columns directly in T-SQL. The following columns are computed from hardcoded CASE expressions:

| Column | Description | Hardcoding Pattern |
|--------|-------------|-------------------|
| `KPI NOx` | Monthly NOx KPI target | Per-field, per-year CASE |
| `Tillatelse NOx` | Annual NOx permit limit | Per-field, per-year CASE |
| `Permit nmVOC` | Annual nmVOC permit limit | Per-field, per-year CASE |
| `KPI nmVOC` | Monthly nmVOC KPI target | Per-field, per-year CASE |
| `KPI CO2 tonn` | CO2 KPI target in tonnes | Per-field CASE |
| `Month` | Month number (used in KPI annualisation) | Derived |

### CH4_NMVOC — SQL CASE statements

| Column | Description | Hardcoding Pattern |
|--------|-------------|-------------------|
| `Tillatelse CH4` | Annual CH4 permit limit (tonnes) | Per-field, per-year CASE (values: 56, 80, 315, 200, 20, 49, 132, 195, 260) |
| `Tillatelse nmVOC` | Annual nmVOC permit limit (tonnes) | Per-field, per-facility, per-year CASE |
| `KPI CH4` | Monthly CH4 KPI target | Per-field, per-year CASE |
| `KPI nmVOC` | Monthly nmVOC KPI target | Per-field, per-year CASE |

### Kaldvent volum — SQL CASE statements

| Column | Description | Hardcoding Pattern |
|--------|-------------|-------------------|
| `Tillatelse Kaldvent` | Quarterly cold vent permit (1000 m³) | Per-field, per-year, per-quarter CASE |
| `KPI Kaldvent QTD` | QTD KPI target | Per-field, per-year, per-quarter CASE (complex logic including 90% factor for Valhall/Ula/Hod) |

### Oily water — SQL CASE statements

| Column | Description | Hardcoding Pattern |
|--------|-------------|-------------------|
| `Tillatelser` | Discharge permit limit | Per-field CASE |
| `KPI Oil to sea` | Oil-to-sea KPI | Per-field CASE |
| `KPI drain water` | Drain water KPI | Per-field CASE |
| `KPI water reinjected` | Water reinjection KPI | Per-field CASE (column name from measure reference) |

### Radioaktive isotoper — Power Query conditionals

The `Permits` and `KPIs` columns in `Radioaktive isotoper` are computed entirely in Power Query using nested `if/then/else` expressions. The logic is per-component (Ra226, Ra228, 210Pb, etc.), per-field, and per-year. This is the most complex example of hardcoded reference data in the model.

| Column | Description | Hardcoding Pattern |
|--------|-------------|-------------------|
| `Permits` | Per-component, per-field, per-year permit limit | Power Query nested if/then/else |
| `KPIs` | Computed as `(Permits / 12) * Month` with 90% factor for Ula and Valhall | Power Query |

### Summary

All permit limits and KPI thresholds are hardcoded in SQL or Power Query. There are no Fabric reference tables currently loaded into the semantic model for this purpose. The `Input til PowerBI.xlsx` workbook contains the business-maintained version of this data. The Mapping Analysis phase will identify the corresponding Fabric tables and plan their introduction.

---

## Measures

### Emissions to air (14 measures, all hidden)

| Measure | DAX Summary |
|---------|-------------|
| `Volume QTD` | TOTALQTD(SUM(Volume), Dim_Date[Date]) |
| `Volume YTD` | TOTALYTD(SUM(Volume), Dim_Date[Date]) |
| `Volume divided by Count of DayOfMonth` | DIVIDE(SUM(Volume), COUNTA(DayNo)) |
| `Volume average per Date` | AVERAGEX per date |
| `CO2 Emissions Ton` | SUM(CO2 Emissions) / 1000 |
| `CO2 Emissions YTD` | TOTALYTD(SUM(CO2 Emissions), Dim_Date[Date]) / 1000 — result in **tonnes** |
| `CO2 Emissions QTD` | TOTALQTD(SUM(CO2 Emissions)) |
| `CO2 in tonne` | = [CO2 Emissions YTD] (duplicate alias) |
| `NOx Emissions YTD` | TOTALYTD(SUM(NOx Emissions)) |
| `Cold ventilated gas YTD` | TOTALYTD(SUM(Cold ventilated gas)) |
| `CH4 Emissions YTD` | TOTALYTD(SUM(CH4 Emissions)) |
| `NMVOC Emissions YTD` | TOTALYTD(SUM(NMVOC Emissions)) |
| `Average of Volume QTD` | TOTALQTD(AVERAGE(Volume)) |
| `NOx KPI year` | Complex: field-specific MAX(KPI NOx) * 12/MONTH logic |
| `nmVOCfuel KPI year` | MAX(Permit nmVOC) with Valhall = 90% |
| `CO2 KPI year` | DIVIDE(MAX(KPI CO2 tonn), MAX(Month)) * 12 |
| `nmVOC_KPI year` | MAX(KPI nmVOC) * 12 / MONTH(LASTDATE(Time_Id)) |
| `yaxis_co2` | [CO2 Emissions YTD] + 3000 (chart axis offset) |

### CH4_NMVOC (6 measures)

| Measure | DAX Summary |
|---------|-------------|
| `Common And Vented CH4 (kg) YTD` | TOTALYTD(SUM(CH4 Emissions (tonne)), Dim_Date[Date]) |
| `Common And Vented NMVOC (tonne) YTD` | TOTALYTD(SUM(nmVOC Emissions (tonne)), Dim_Date[Date]) |
| `nmVOC KPI year` | MAX(Tillatelse nmVOC) with Ula = 90% |
| `CH4 KPI year` | MAX(Tillatelse CH4) with Ula = 90% |
| `nmVOC_cold_KPI year` | MAX(KPI nmVOC) * 12 / MONTH(LASTDATE(Date)) |
| `CH4_year KPI` | MAX(KPI CH4) * 12 / MONTH(LASTDATE(Date)) |

### Kaldvent volum (3 measures)

| Measure | DAX Summary |
|---------|-------------|
| `Volume (1000 m3) QTD` | TOTALQTD(SUM(Volume (1000 m3)), Dim_Date[Date]) |
| `Volume (1000 m3) YTD` | TOTALYTD(SUM(Volume (1000 m3)), Dim_Date[Date]) |
| `Vented KPI year` | MAX(Tillatelse Kaldvent) with Valhall/Ula/Hod = 90% |

### Oily water (6 measures)

| Measure | DAX Summary |
|---------|-------------|
| `Reinjectiongrade` | DIVIDE(SUM(Injected Volume), SUM(Production Volume)) filtered to Stream Type = "Produced water". Format: % |
| `KPI reinjected` | MAX(KPI water reinjected). Format: % |
| `Discharged Oil Mass ISO (mg) divided by Discharged Volume (L)` | DIVIDE(SUM(Discharged Oil Mass ISO (mg)), SUM(Discharged Volume (L))). Format: 0 |
| `Discharged Oil Mass ISO (mg) YTD` | TOTALYTD(SUM(Discharged Oil Mass ISO (mg))) |
| `Discharged Oil Mass ISO (mg) divided by Discharged Volume (L) YTD` | TOTALYTD of the ratio above |
| `Discharged Volume (L) YTD` | TOTALYTD(SUM(Discharged Volume (L))) |

### Radioaktive isotoper (3 measures)

| Measure | DAX Summary |
|---------|-------------|
| `Component Activity (Bq) MTD` | TOTALMTD(SUM(Component Activity (Bq))) / 1,000,000,000. Format: 0.000 |
| `Component Activity (Bq) YTD` | TOTALYTD(SUM(Component Activity (Bq))) / 1,000,000,000 |
| `KPI year` | MAX(Permits) * 0.9 for Valhall/Ula/Alvheim/Skarv, else MAX(Permits). Format: 0.00 |

---

## Calculated Columns

None confirmed. KPI thresholds and permit values are embedded as numeric columns in the fact table SQL queries.

---

## Calculated Tables

None. `Location (2)` is a named expression (shared Power Query query), not a calculated table.

---

## Data Sources — Summary

All data is sourced from Microsoft Fabric via DirectSQL (Import mode).

| Table | Database | Schema / Object |
|-------|----------|-----------------|
| Dim_Date | wh_gold_utilities | dbt_gold.dim_dates |
| Emissions to air | wh_gold_hsseq | dbt_gold_nems_environment_kpi.fact_nems__environment_kpi_emission_to_air_ctt |
| Emissions to air CO2 Hod | wh_gold_hsseq | dbt_gold_nems_environment_kpi.fact_nems__environment_kpi_emission_to_air_ctt (filtered: Hod → Valhall) |
| CH4_NMVOC | wh_gold_hsseq | Direct SQL (source table to be confirmed) |
| Kaldvent volum | wh_gold_hsseq | Direct SQL (source table to be confirmed) |
| Oily water | wh_gold_hsseq | dbt_gold_nems_environment_kpi.fact_nems__environment_kpi_oily_water_ctt |
| Location3 | wh_gold_hsseq | dbt_gold_nems_environment_kpi.fact_nems__environment_kpi_oily_water_ctt |
| Location | Derived | Built from Emissions to air + Location (2) + Location3 via Power Query |

---

## Report Pages — Detail

| Page | Key Tables Used | Page-level Filters | Migration Relevance |
|------|----------------|-------------------|--------------------|
| KPI emissions to air | Emissions to air, Dim_Date, Location | Dim_Date date hierarchy | In scope |
| KPI discharge to sea | Oily water, Dim_Date, Location | Oily water.facility | In scope |
| KPI emissions to air before 2025 | Emissions to air, Dim_Date | Dim_Date date hierarchy | In scope |
| INFO | None | None | Static — low migration risk |
| Page 1 | Unknown | Dim_Date date hierarchy | Not relevant to migration unless dependencies are identified |

**Bookmarks:** 5 bookmarks exist.

| Bookmark | Display Name | Purpose | Target Page |
|----------|--------------|---------|-------------|
| Bookmarkc5cec6ed729854fed567 | Info on | Shows info/tooltip visuals — targets ~24 visual IDs | KPI emissions to air |
| Bookmark9be424cbf1fa3cc034bc | Info off | Hides info/tooltip visuals (inverse of Info on) | KPI emissions to air |
| Bookmark526d76398f618823302d | Info sea on | Shows info/tooltip visuals | KPI discharge to sea |
| Bookmark2a91b4432b3a25546871 | Info sea off | Hides info/tooltip visuals (inverse of Info sea on) | KPI discharge to sea |
| 96641c4200303450112a | Ivar_Aasen_ikke_slett | Applies a filter for Ivar Aasen field. Name suggests it must not be deleted | KPI emissions to air |

All bookmarks use `applyOnlyToTargetVisuals: true` and target specific visual IDs. They do not capture filter state globally, reducing migration risk. The fifth bookmark (`Ivar_Aasen_ikke_slett` — Norwegian: "Ivar Aasen do not delete") has a name suggesting it is a dependency required by another object. This should be investigated during the dependency analysis phase.

---

## Initial Observations

### Structural observations

1. **No dedicated Measures table.** All measures are scattered across fact tables. This reduces discoverability and maintainability. This is an improvement opportunity but not the primary migration objective.

2. **`Emissions to air CO2 Hod` is a filtered duplicate of `Emissions to air`.** It contains only Hod rows, with Field renamed to Valhall. The business reason for maintaining this as a separate table is not yet known. Documented as an open question.

3. **`Location` is a highly computed Power Query dimension.** Built by combining `Emissions to air[Field]`, `Location (2)` (from Oily water), and `Location3` (from the oily water Fabric table). Fragile — changes to underlying fact tables could break this dimension.

4. **Permit limits and KPI thresholds are hardcoded throughout the model.** This is the primary target of this migration. All five fact tables embed reference values as SQL CASE statements or Power Query conditionals. See the Hardcoded Reference Data section above for full detail.

5. **`Location.År → Dim_Date.Year` is a many-to-many relationship.** The reason is currently unknown. This is documented as an observation. It will not be modified unless analysis shows it affects the migration.

6. **Many columns in `Emissions to air` are hidden.** Intentional. Hidden columns participate in measure calculations and relationship filters. This is expected behaviour for this model design.

7. **KPI measures use field-name hardcoding in DAX.** Field names ("Valhall", "Ula", "Hod", "Skarv", "Alvheim", "Edvard Grieg", "Ivar Aasen") appear repeatedly in CALCULATE filters across multiple measures. When reference tables are introduced, these DAX patterns will likely need to be updated to filter against the new Fabric reference tables.

8. **Unit conversions are applied inconsistently.** CO2 Emissions: stored as kg, divided by 1000 to tonnes in DAX. CH4 Emissions: converted to tonnes in SQL. Component Activity (Bq): divided by 1,000,000,000 in DAX. This should be documented during mapping analysis to avoid double-conversion when reference tables are introduced.

9. **`loc_key` composite key is constructed in multiple places.** Pattern: `field_facility_year` (lowercase, spaces removed). Built in T-SQL (CH4_NMVOC, Kaldvent volum) and Power Query (Location, Location3). Any casing or spacing inconsistency could silently break joins.

10. **`Radioaktive isotoper` Fabric source table not yet confirmed.** The partition queries `wh_gold_hsseq` but the source table name was not captured. This will be confirmed during Mapping Analysis when the Fabric replacement tables are introduced.

11. **Bookmark `Ivar_Aasen_ikke_slett` ("do not delete") is a named dependency signal.** The Norwegian name explicitly warns against deletion. This bookmark applies an Ivar Aasen filter on the KPI emissions to air page and must be preserved.

### Business observations

11. **Fields tracked:** Valhall, Ula, Hod, Skarv, Alvheim, Edvard Grieg, Ivar Aasen (= PL 001B Ivar Aasen), Fenris (= Valhall), HANZ (= Ivar Aasen). Field normalization is applied in multiple places.

12. **KPI logic varies by field.** Some fields use 90% of permit (e.g., Valhall for nmVOC), others use 100%. Some use annual permits; others use quarterly limits. This logic is currently split between SQL and DAX.

13. **Date range:** 2020 to current date.

---

## Questions and Observations

### Open questions

1. **What is the business reason for `Emissions to air CO2 Hod` being a separate table?** It is a filtered subset of `Emissions to air` (Hod only, renamed to Valhall). The business justification is not yet known. Do not consolidate or remove this table until the reason is confirmed.

2. **What are the exact Fabric source tables for `CH4_NMVOC`, `Kaldvent volum`, and `Radioaktive isotoper`?** The SQL queries reference `wh_gold_hsseq` but the specific Fabric table names were not captured in full. These will be confirmed during Mapping Analysis when the replacement tables are identified.

3. **What does `Page 1` display?** Its content was not inspected. It is not expected to be relevant to this migration unless dependencies are discovered.

4. **Why does the `Ivar_Aasen_ikke_slett` bookmark exist?** The name suggests it is a hard dependency that must not be removed. The specific scenario it supports should be confirmed.

### Resolved observations

- **Business reference workbook** — `Input til PowerBI.xlsx` is the business owner's workbook, ingested into Fabric. Its worksheets correspond to Fabric tables that will replace the hardcoded reference data. Workbook content will be inspected during Mapping Analysis.
- **Page 1** — Not relevant to this migration. Documented. No further investigation required unless dependencies emerge.
- **`Location.År → Dim_Date.Year` many-to-many relationship** — Reason unknown. Documented as an observation. No redesign at this stage.
- **Bookmarks** — All 5 bookmarks confirmed. Four are info panel show/hide toggles (low migration risk). One (`Ivar_Aasen_ikke_slett`) applies a field filter and is named as a preserved dependency.
- **`Radioaktive isotoper` source** — Confirmed to query `wh_gold_hsseq` via Fabric. Exact source table to be confirmed during Mapping Analysis. `Permits` and `KPIs` columns are the most complex example of hardcoded reference data in the model.

---

## Next Steps

Discovery is substantially complete. The following items remain open and will be addressed in later phases:

1. **Inspect `Input til PowerBI.xlsx`** — Confirm worksheet names and structure. Identify which worksheets correspond to which hardcoded reference data in the model. This is a Mapping Analysis activity.

2. **Confirm Fabric source tables** for `CH4_NMVOC`, `Kaldvent volum`, and `Radioaktive isotoper` during Mapping Analysis.

3. **Confirm the business reason for `Emissions to air CO2 Hod`** before deciding whether to retain or consolidate it.

4. **Proceed to Phase 2 — Dependency Analysis.** Identify all objects (measures, visuals, filters, bookmarks, slicers) that depend on the tables and columns containing hardcoded reference data, since these will be affected by the migration.
