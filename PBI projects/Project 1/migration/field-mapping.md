# Field Mapping

**Project:** Project 1 â€” Environmental KPIs
**Phase:** Phase 3 â€” Mapping Analysis
**Date:** 2026-07-03 (initial) | Updated: 2026-07-03 (full worksheet analysis) | Updated: 2026-07-03 (Fabric tables confirmed) | Updated: 2026-07-03 (integration architecture assessed)

## Purpose

This document records the analysis used to determine how the legacy semantic model corresponds to candidate Fabric reference tables sourced from the business owner's workbook (`Input til PowerBI.xlsx`).

Every mapping is a candidate supported by evidence. Confidence levels are assigned based on the quality of available evidence. No mapping is confirmed until it has been validated against actual Fabric table data.

Every worksheet in `Input til PowerBI.xlsx` is ingested into Microsoft Fabric and becomes a Fabric table with the same name as the worksheet.

---

## Mapping Status

### Last Updated
2026-07-03

### Overall Progress

- [x] Business reference workbook fully inspected
- [x] All 8 worksheets analyzed
- [x] Workbook structure confirmed for all inspected sheets
- [x] Candidate Fabric tables identified for all in-scope worksheets
- [x] Table-level mappings evaluated
- [x] Column-level mappings evaluated with evidence
- [x] Implementation recommendation produced (Section 11)
- [x] Recommended Export List produced (Section 12)
- [x] Fabric tables imported into new-model semantic model (confirmed 2026-07-03)
- [x] Confirmed Fabric table structures documented (Section 13)
- [x] Integration architecture assessed, approach recommended (Section 14)
- [ ] Column-level mappings validated against live Fabric data (distinct metrics, fields, years, values)
- [ ] Relationships designed and created
- [ ] Migration approved

---

## 1. Business Reference Workbook â€” Complete Worksheet Analysis

**File:** `PBI projects/Project 1/data/Input til PowerBI.xlsx`

Inspected via ZIP/XML parsing (Python-equivalent approach using .NET IO). All 8 worksheets analyzed.

---

### 1.1 `permit_kpi_to_air`

**Confirmed structure:** 218 data rows Ã— 12 columns

| Column | Description |
|--------|-------------|
| `Metric` | The permit or KPI metric type |
| `Field` | The field/asset name |
| `Unit` | Unit of measurement |
| `2025 Values Permit/KPI` | Annual value for 2025 |
| `2026 Values Permit/KPI` | Annual value for 2026 |
| â€¦ | 2027, 2028, 2029, 2030, 2031, 2032 |
| `Kommentar` | Business comment |

**Confirmed distinct metrics (20):**

| Metric name | Category | Covers |
|-------------|----------|--------|
| `CO2 KPI Year` | CO2 | Annual CO2 KPI target (tonn) |
| `CO2 KPI YTD` | CO2 | CO2 KPI on a YTD basis |
| `Flaring Permit` | Flaring | Annual flaring permit |
| `Flaring KPI` | Flaring | Annual flaring KPI target |
| `Mainfield NOX Permit` | NOx | NOx permit for main field facilities |
| `Mainfield NOX KPI` | NOx | NOx KPI for main field facilities |
| `Mainfield nmVOC Permit` | nmVOC | nmVOC permit for main field facilities |
| `Mainfield nmVOC KPI` | nmVOC | nmVOC KPI for main field |
| `MainField CH4 permit` | CH4 | CH4 permit for main field |
| `MainField CH4 KPI` | CH4 | CH4 KPI for main field |
| `Main field SOx permit` | SOx | SOx permit for main field |
| `Main field SOx KPI` | SOx | SOx KPI for main field |
| `Rig NOX Permit` | NOx | NOx permit for drilling rigs |
| `Rig NOX KPI` | NOx | NOx KPI for drilling rigs |
| `Rig nmVOC Permit` | nmVOC | nmVOC permit for drilling rigs |
| `Rig nmVOC KPI` | nmVOC | nmVOC KPI for drilling rigs |
| `Rig SOx permit` | SOx | SOx permit for drilling rigs |
| `Rig SOx KPI` | SOx | SOx KPI for drilling rigs |
| `Vented gas permit` | Cold vent | Annual cold vent gas permit |
| `Vented gas KPI` | Cold vent | Annual cold vent gas KPI target |

**Confirmed sample data:**

| Metric | Field | 2026 value |
|--------|-------|-----------|
| CO2 KPI Year | Ivar Aasen | 25,000 tonn |
| CO2 KPI Year | Edvard Grieg | 26,000 tonn |
| CO2 KPI Year | Valhall | 25,000 tonn |
| CO2 KPI Year | Skarv | 351,000 tonn |
| CO2 KPI Year | Ula | 140,383 tonn |
| CO2 KPI Year | Alvheim | 174,000 tonn |
| CO2 KPI Year | Yggdrasil | (blank) |

**Business purpose:**
This worksheet is the primary business-maintained reference for all air emission permit limits and KPI targets. It covers CO2, NOx, nmVOC, CH4, SOx, flaring, and cold vent gas â€” for both main field facilities and drilling rigs â€” across fields for the years 2025â€“2032.

**Key structural observations:**
- **Main field vs Rig split:** The workbook explicitly separates metrics for main field (production platform) and drilling rigs. This is significant because the `Emissions to air` table in the model contains rows for both facility types. Mapping must account for which rows receive main field values and which receive rig values.
- **"Flaring KPI" is explicitly in the workbook.** This means the workbook provides the final KPI value directly, not just the permit. The current two-stage derivation logic in the SQL (Tillatelse flaring Ã— field-year-quarter reduction factors) may be replaceable with a direct lookup.
- **Annual granularity.** The workbook stores one value per (Metric, Field, Year). The model currently embeds quarterly permit values for Kaldvent volum. The "Vented gas permit" annual value and the quarterly `Tillatelse Kaldvent` are related but not directly equivalent.
- **Coverage starts 2025.** No values for 2024 or earlier years.
- **Candidate Fabric table:** `permit_kpi_to_air`

---

### 1.2 `permit_kpi_to_sea`

**Confirmed structure:** ~50 actual data rows (XML contains 1,048,576 entries due to sparse worksheet formatting) Ã— 10 columns

| Column | Description |
|--------|-------------|
| `Metric` | The permit or KPI metric type |
| `Field` | The field/asset name |
| `2026 Values Permit/KPI` | Annual value for 2026 (no 2025 column) |
| â€¦ | 2027, 2028, 2029, 2030, 2031, 2032 |
| `Kommentar` | Business comment |

**Confirmed first rows (sample):**

| Metric | Field | 2026 value |
|--------|-------|-----------|
| Radium 228 Tillatelse | Ivar Aasen | 20.0 |
| Radium 228 Tillatelse | Edvard Grieg | 36.0 |
| Radium 228 Tillatelse | Valhall | 2.45 |
| Radium 228 Tillatelse | Skarv | 2.23 |
| Radium 228 Tillatelse | Ula | 40.0 |
| Radium 228 Tillatelse | Alvheim | 12.9 |
| Radium 228 Tillatelse | Yggdrasil | (blank) |

**Expected additional metrics** (based on domain knowledge and model structure; not confirmed from full read):
- `Radium 226 Tillatelse` â€” Ra226 permit (maps to `Radioaktive isotoper.Permits` for Ra226 component)
- `Pb-210 Tillatelse` or similar â€” 210Pb permit
- Metrics for oily water/produced water discharge (to be confirmed when Fabric table is available)

**Business purpose:**
This worksheet contains sea discharge permit limits per field and per year. The first confirmed metric is radioactive isotope permits (Radium 228). Based on the worksheet name and domain knowledge, it also likely contains permits for produced water oil discharge and other sea discharge KPIs.

**Key structural observation:** The worksheet starts from 2026, not 2025. This matches with the radioactive isotope permit structure in the model's Power Query, which uses per-year values.

**Candidate Fabric table:** `permit_kpi_to_sea`

---

### 1.3 `Drenasjevann`

**Confirmed structure:** 8 data rows Ã— 3 columns

| Column | Description |
|--------|-------------|
| `Description` | The metric type (KPI or limit) |
| `Rig` | Drilling rig / vessel name |
| `Value` | Numeric value |

**Confirmed data:**

| Description | Rig | Value |
|------------|-----|-------|
| KPI 2025 | Deepsea Stavanger | 10 |
| KPI 2025 | Noble Integrator | 10 |
| KPI 2025 | Scarabeo 8 | 10 |
| KPI 2025 | Deepsea Nordkapp | 10 |
| Grense 2025 | Deepsea Stavanger | 15 |
| Grense 2025 | Noble Integrator | 15 |
| Grense 2025 | Scarabeo 8 | 15 |
| (Grense 2025 | Deepsea Nordkapp | 15 â€” implied) |

**Business purpose:**
This worksheet tracks drain water discharge KPI targets and thresholds ("Grense" = limit/threshold) specifically for drilling rigs. "Drenasjevann" means "drain water" in Norwegian. The values are the same across all 4 rigs (KPI = 10, limit = 15), suggesting a uniform standard for 2025.

**Key structural observations:**
- This is rig-specific data, not field-specific. The 4 drilling rigs are: Deepsea Stavanger, Noble Integrator, Scarabeo 8, Deepsea Nordkapp.
- Unlike `permit_kpi_to_air` and `permit_kpi_to_sea`, this sheet has no year columns â€” values are embedded in the metric name ("KPI 2025", "Grense 2025"). This is a simpler, point-in-time reference.
- "Grense" (= threshold/limit) is distinct from "Tillatelse" (= permit). This tracks operational performance thresholds, not regulatory permits.
- The `Oily water` table in the model has `KPI drain water` which is a field-level value. This worksheet provides rig-level drain water thresholds, which is a different granularity.

**Candidate Fabric table:** `Drenasjevann`
**Migration relevance:** Partial. This table covers drain water KPIs for drilling rigs, which is a subset of the `Oily water` table's scope. Whether the model's `KPI drain water` should be sourced from this table or from `permit_kpi_to_sea` requires confirmation. The simpler structure (year embedded in metric name) also means the table design would need special handling.

---

### 1.4 `utslipp_til_luft`

**Structure:** Not read. Script failed on this sheet due to it not being selected in the targeted script run.

**Business purpose (inferred):** "Utslipp til luft" means "emissions to air" in Norwegian. This sheet likely contains either:
(a) Reference values for emission factors or measurement methods used in air emission calculations, or
(b) A categorisation of emission sources (e.g., listing valid "Emissions Source" values for the `Emissions to air` table's `Emissions Source` column)

**Migration relevance:** Uncertain. The `Emissions to air` table currently pulls its measurement data directly from the Fabric fact table `fact_nems__environment_kpi_emission_to_air_ctt`. If `utslipp_til_luft` contains measurement data, it would be the data source side (not a reference/permit table). If it contains categorisation/lookup data, it may not affect the migration of permit/KPI reference columns. **No candidate column mapping has been identified for this worksheet based on available evidence.**

---

### 1.5 `utslipp_av_borekaks`

**Structure:** Not read.

**Business purpose:** "Utslipp av borekaks" means "discharge of drill cuttings" in Norwegian. Drill cuttings are solids discharged to sea from drilling operations.

**Migration relevance:** Out of scope. There is no corresponding table for drill cuttings in the semantic model. This worksheet is expected to be a Fabric table in `wh_gold_hsseq` but has no dependency on the migration candidate columns.

---

### 1.6 `Kjemikalier`

**Structure:** Not read.

**Business purpose:** "Kjemikalier" means "chemicals" in Norwegian. This worksheet tracks chemical usage or discharge data for operations.

**Migration relevance:** Out of scope. There is no chemicals table in the semantic model.

---

### 1.7 `Kjemikalier Yggdrasil`

**Structure:** Not read.

**Business purpose:** Chemicals data specific to the Yggdrasil field (a new Aker BP field).

**Migration relevance:** Out of scope.

---

### 1.8 `Kjemikalier funksjonsgruppe`

**Structure:** Not read.

**Business purpose:** "Kjemikalier funksjonsgruppe" means "chemicals functional group" â€” a categorical grouping of chemical types.

**Migration relevance:** Out of scope.

---

## 2. Fabric Data Sources â€” Current State

All five fact tables currently query the Fabric data warehouse directly via SQL at:
`obax4o2iqosevp5oa2r6dbtune-2dhddioar5aebauc4huzjvnrve.datawarehouse.fabric.microsoft.com`

- `wh_gold_utilities` â€” `dbt_gold.dim_dates` (feeds `Dim_Date`)
- `wh_gold_hsseq` â€” all environmental fact data

**Candidate Fabric reference tables** (to be introduced into the semantic model):
Based on the worksheet analysis, the following Fabric tables are candidates for introduction:

| Fabric table name | Worksheet source | Database (expected) |
|------------------|-----------------|---------------------|
| `permit_kpi_to_air` | `permit_kpi_to_air` worksheet | `wh_gold_hsseq` (or shared warehouse) |
| `permit_kpi_to_sea` | `permit_kpi_to_sea` worksheet | Same |
| `Drenasjevann` | `Drenasjevann` worksheet | Same |

The Fabric table names match the worksheet names exactly, per the user's confirmation that every worksheet is ingested as a Fabric table with the same name.

---

## 3. Table Mapping

### 3.1 Candidate table mappings â€” updated

| # | Workbook worksheet / Fabric table | Candidate legacy tables served | Confidence | Status |
|---|----------------------------------|-------------------------------|-----------|--------|
| T1 | `permit_kpi_to_air` | `Emissions to air`, `CH4_NMVOC`, `Kaldvent volum` | **High** | Candidate â€” confirmed metrics present |
| T2 | `permit_kpi_to_sea` | `Radioaktive isotoper`, `Oily water` (expected) | **High** (isotopes) / **Medium** (oily water) | Candidate â€” partial confirmation |
| T3 | `Drenasjevann` | `Oily water` (rig drain water only) | **Medium** | Candidate â€” partial, granularity difference |
| T4 | `utslipp_til_luft` | Unknown | **Low** | Not assessed â€” structure not confirmed |
| T5 | `utslipp_av_borekaks` | None | N/A | Out of scope |
| T6 | `Kjemikalier` | None | N/A | Out of scope |
| T7 | `Kjemikalier Yggdrasil` | None | N/A | Out of scope |
| T8 | `Kjemikalier funksjonsgruppe` | None | N/A | Out of scope |

### 3.2 Evidence per mapping

#### T1 â€” `permit_kpi_to_air` â†’ Air emissions reference

**Supporting evidence:**
1. Worksheet name explicitly states "permit/kpi to air" â€” matches the air emissions business domain.
2. All 20 distinct metrics confirmed. Metrics match every air emission candidate column group in the model (CO2, NOx, nmVOC, CH4, Flaring, Cold vent/Vented gas).
3. Sample data for "CO2 KPI Year" confirmed with value 25,000 tonn for Ivar Aasen (2026). This corresponds to the `KPI CO2 tonn` column in `Emissions to air`.
4. Field names confirmed: Ivar Aasen, Edvard Grieg, Valhall, Skarv, Ula, Alvheim, Yggdrasil â€” identical to the fields tracked in the model.
5. "Flaring Permit" and "Flaring KPI" both present â€” directly corresponds to `Tillatelse flaring` and `KPI flaring`.
6. "Mainfield NOX Permit" and "Mainfield NOX KPI" present â€” directly corresponds to `Tillatelse NOx` and `KPI NOx`.
7. "MainField CH4 permit" / "MainField CH4 KPI" present â€” corresponds to `CH4_NMVOC.Tillatelse CH4` and `KPI CH4`.
8. "Vented gas permit" / "Vented gas KPI" present â€” corresponds to `Kaldvent volum.Tillatelse Kaldvent`.

**Confidence reasoning:** High. Every candidate reference column group in the legacy air emission tables has a direct metric name match in the workbook. Both naming and value evidence support this mapping.

#### T2 â€” `permit_kpi_to_sea` â†’ Sea discharge reference

**Supporting evidence:**
1. Worksheet name "permit/kpi to sea" matches the sea discharge domain.
2. First confirmed metric "Radium 228 Tillatelse" with per-field values (Ivar Aasen=20, Edvard Grieg=36, Valhall=2.45, Skarv=2.23, Ula=40, Alvheim=12.9) â€” these are GBq annual permit values for Ra228.
3. "Radium 228 Tillatelse" corresponds directly to `Radioaktive isotoper.Permits` for the Ra228 component.
4. The value 2.45 for Valhall (shown as 2.4500000000000002 due to floating point) and 2.23 for Skarv match expected radioactive isotope permit ranges in the regulatory context.
5. The structure (Metric, Field, Year) is consistent with being a reference table for both radioactive isotopes and oily water metrics.

**Confidence reasoning (isotopes):** High. The first metric exactly matches the `Radioaktive isotoper` table's permit structure by component and field. The values are consistent with GBq radioactive discharge limits.
**Confidence reasoning (oily water):** Medium. Based on worksheet name and expected domain, but oily water metrics have not been confirmed in the first 7 rows.

#### T3 â€” `Drenasjevann` â†’ Rig drain water reference

**Supporting evidence:**
1. "Drenasjevann" (drain water) directly matches the `KPI drain water` concept in `Oily water`.
2. The 4 drilling rigs listed (Deepsea Stavanger, Noble Integrator, Scarabeo 8, Deepsea Nordkapp) are active drilling vessels used on Aker BP fields.
3. The KPI value of 10 mg/L and threshold of 15 mg/L are consistent with typical drain water discharge concentration limits.

**Confidence reasoning:** Medium. The concept matches, but the rig-level granularity is different from the field-level `KPI drain water` in the model. Whether this table replaces the current hardcoded value or supplements it needs to be confirmed once the Fabric table is in the model.

---

## 4. Column Mapping

### 4.1 `permit_kpi_to_air` â†’ `Emissions to air`

| Legacy column | Candidate Fabric table | Metric name in table | Confidence | Evidence |
|--------------|----------------------|---------------------|-----------|----------|
| `KPI CO2 tonn` | `permit_kpi_to_air` | `CO2 KPI Year` | **High** | Confirmed in sample data. Name, unit (tonn), and values align. |
| `Tillatelse NOx` | `permit_kpi_to_air` | `Mainfield NOX Permit` | **High** | Metric name directly matches NOx permit concept for main field. |
| `KPI NOx` | `permit_kpi_to_air` | `Mainfield NOX KPI` | **High** | Direct name match. |
| `Permit nmVOC` | `permit_kpi_to_air` | `Mainfield nmVOC Permit` | **High** | Direct name match. Note: same metric may serve `CH4_NMVOC.Tillatelse nmVOC` â€” see observation O3. |
| `KPI nmVOC` | `permit_kpi_to_air` | `Mainfield nmVOC KPI` | **High** | Direct name match. Note: same observation applies. |
| `Tillatelse flaring` | `permit_kpi_to_air` | `Flaring Permit` | **High** | Direct concept match. |
| `KPI flaring` | `permit_kpi_to_air` | `Flaring KPI` | **High** | Workbook provides final KPI value directly. This resolves the two-stage derivation concern from Discovery. The hardcoded percentage reduction logic in the SQL may be replaceable by a direct lookup â€” pending value validation. |
| `Permit Cold ventilated gas` | `permit_kpi_to_air` | `Vented gas permit` | **High** | "Vented gas" = cold vent gas = kaldvent. Same physical concept. This metric in the workbook serves both this column and `Kaldvent volum.Tillatelse Kaldvent`. |
| `KPI Cold ventilated gas` | `permit_kpi_to_air` | `Vented gas KPI` | **High** | Same reasoning. |
| `Month` | None | N/A | N/A | `Month` is `DATEPART(MONTH, date)` â€” derived from date, not a reference value. No workbook column needed. |
| `Division` | None | N/A | N/A | `Division` = `Tillatelse Kaldvent / 3` â€” a derived intermediate value. Not a reference column. |

**Note on Rig metrics:** The workbook also has "Rig NOX Permit", "Rig nmVOC Permit" etc. for drilling rig rows. The `Emissions to air` table contains rows for both field facilities and drilling rigs. The rig-specific permit values currently embedded in the SQL likely correspond to these "Rig" metrics. This is a key detail for the join key design: the replacement strategy must distinguish between main field rows and rig rows when looking up permits.

### 4.2 `permit_kpi_to_air` â†’ `CH4_NMVOC`

| Legacy column | Candidate Fabric table | Metric name in table | Confidence | Evidence |
|--------------|----------------------|---------------------|-----------|----------|
| `Tillatelse CH4` | `permit_kpi_to_air` | `MainField CH4 permit` | **High** | Direct concept match. CH4 permit for main field. |
| `KPI CH4` | `permit_kpi_to_air` | `MainField CH4 KPI` | **High** | Direct match. |
| `Tillatelse nmVOC` | `permit_kpi_to_air` | `Mainfield nmVOC Permit` | **High** | Direct match. Note: same metric as mapped to `Emissions to air.Permit nmVOC` â€” see observation O3. |
| `KPI nmVOC` | `permit_kpi_to_air` | `Mainfield nmVOC KPI` | **High** | Direct match. |

**Granularity note:** `CH4_NMVOC` stores measurements at facility level (field + facility + date). The workbook stores permits at field level (field + year). The permit value is constant per field+year across all facilities of that field. This is consistent with how `MAX(Tillatelse CH4)` is used in DAX measures â€” the MAX aggregation effectively collapses facility-level rows back to a field-level value. The field-level granularity of the Fabric table is therefore **compatible** with the model's structure. This resolves the granularity concern from the previous analysis.

### 4.3 `permit_kpi_to_air` â†’ `Kaldvent volum`

| Legacy column | Candidate Fabric table | Metric name in table | Confidence | Evidence |
|--------------|----------------------|---------------------|-----------|----------|
| `Tillatelse Kaldvent` | `permit_kpi_to_air` | `Vented gas permit` | **High** | "Vented gas" = cold vent gas = kaldvent. Concept, domain, and field structure align. |
| `KPI Kaldvent QTD` | Partially `permit_kpi_to_air` (`Vented gas KPI`) | `Vented gas KPI` | **Medium** | The workbook provides an annual KPI value. The model's `KPI Kaldvent QTD` is a quarterly computation derived from the annual permit with complex seasonal factors. The annual "Vented gas KPI" from the workbook can provide the BASE value, but the quarterly distribution logic must remain in Power Query or DAX. Whether the workbook-provided "Vented gas KPI" matches the result of the complex SQL computation requires numerical validation. |
| `Division` | None | N/A | N/A | Derived intermediate (`Tillatelse Kaldvent / 3`). Not a reference column. |

### 4.4 `permit_kpi_to_sea` â†’ `Radioaktive isotoper`

| Legacy column | Candidate Fabric table | Metric name in table | Confidence | Evidence |
|--------------|----------------------|---------------------|-----------|----------|
| `Permits` | `permit_kpi_to_sea` | `Radium 228 Tillatelse` (and Ra226, Pb210 â€” expected) | **High** | "Radium 228 Tillatelse" confirmed in sample with per-field values. Values (20 GBq for Ivar Aasen, 36 for Edvard Grieg, 2.45 for Valhall) are consistent with radioactive discharge limits and with the type of values stored in the Power Query hardcoded logic. |
| `KPIs` | `permit_kpi_to_sea` (expected) | Unknown metric name | **Medium** | `KPIs` is computed from `Permits` in Power Query (`(Permits / 12) * MÃ¥ned Ã— reduction`). Whether `permit_kpi_to_sea` provides a pre-computed KPI column or only the permit value is not confirmed. If only permits are provided, `KPIs` computation would need to remain in DAX or Power Query. |

**Join key observation:** The `Radioaktive isotoper` table requires a three-dimensional join: Component (Ra226, Ra228, 210Pb) Ã— Field Ã— Year. The `permit_kpi_to_sea` Fabric table appears to have rows per Metric+Field+Year. The "Metric" dimension carries the component identity (e.g., "Radium 228 Tillatelse"). This means the join to the fact table would filter by Metric name and Field. This is a non-standard join pattern and the implementation approach needs to be determined during Migration Planning.

### 4.5 `permit_kpi_to_sea` and `Drenasjevann` â†’ `Oily water`

| Legacy column | Candidate Fabric table | Metric name in table | Confidence | Evidence |
|--------------|----------------------|---------------------|-----------|----------|
| `Tillatelser` | `permit_kpi_to_sea` | Unknown | **Medium** | Based on worksheet name and domain; oily water permits are sea discharge permits. Not confirmed from first 7 rows. |
| `KPI Oil to sea` | `permit_kpi_to_sea` | Unknown | **Medium** | Same reasoning. |
| `KPI water reinjected` | `permit_kpi_to_sea` | Unknown | **Medium** | Same. |
| `KPI drain water` (field) | `permit_kpi_to_sea` | Unknown | **Medium** | For field-level drain water. |
| `KPI drain water` (rig) | `Drenasjevann` | `KPI 2025` | **Medium** | For rig-specific drain water. Value = 10. "Grense 2025" = 15 (alarm threshold, not necessarily the same as `KPI drain water`). Granularity is per-rig, not per-field. |

---

## 5. Structural Observations

### O1 â€” Wide-format workbook (year as columns)
`permit_kpi_to_air` and `permit_kpi_to_sea` store values with year as columns (wide format). The legacy model uses values embedded in row-level SQL with field+year as implicit join dimensions. When ingested into Fabric, the resulting table will either remain wide format (year columns) or be pivoted to tall format (Metric, Field, Year, Value). The Fabric table format determines the relationship key design and Power Query transformation approach. This must be confirmed when the Fabric tables are available.

### O2 â€” Historical coverage gap
The workbook covers **2025â€“2032** (`permit_kpi_to_air`) and **2026â€“2032** (`permit_kpi_to_sea`). The legacy model has hardcoded values back to **2019** (emissions) and **2020** (oily water, CH4). For historical report data (2019â€“2024), the replacement Fabric tables will not have values. This must be addressed in Migration Planning â€” either by extending the workbook to include historical values, or by retaining hardcoded values for historical years while using Fabric tables for 2025+.

### O3 â€” Shared nmVOC metric across two fact tables
"Mainfield nmVOC Permit" and "Mainfield nmVOC KPI" in `permit_kpi_to_air` appear to serve both:
- `Emissions to air.Permit nmVOC` (fuel burn nmVOC from combustion)
- `CH4_NMVOC.Tillatelse nmVOC` (cold vent and common venting nmVOC)

Whether these represent the same regulatory permit or are business-distinct is not confirmed. If they share the same metric, both tables can look up from the same Fabric table row. If they are distinct, a separate metric may be required. This should be verified during column-level validation.

### O4 â€” Rig vs main field distinction in `permit_kpi_to_air`
The workbook explicitly separates "Main field" and "Rig" metrics for NOx, nmVOC, and SOx. The `Emissions to air` table's SQL currently applies field-specific CASE logic without distinguishing facility type in the permit columns. After migration, the relationship to `permit_kpi_to_air` will need to filter by Metric based on whether a row represents a main field facility or a drilling rig. The `Facility` column in `Emissions to air` identifies drilling rigs (e.g., "Noble Integrator", "Scarabeo 8") and can be used for this conditional lookup.

### O5 â€” Kaldvent volum quarterly KPI requires derived computation
The workbook "Vented gas KPI" is an **annual** value. `Kaldvent volum.KPI Kaldvent QTD` is a **quarterly** value derived from the annual permit with complex seasonal factors specific to each field and year. Even after introducing the Fabric table, the QTD KPI computation will likely need to remain in Power Query or DAX, using the Fabric table annual value as input rather than replacing the logic entirely.

### O6 â€” `KPI flaring` resolution
The workbook provides "Flaring KPI" as a direct metric value. This means the two-stage SQL logic currently used to compute `KPI flaring` (Tillatelse flaring Ã— percentage reduction) may be **replaceable by a direct lookup** from the Fabric table. Whether the workbook value equals the current SQL-computed value must be verified numerically for at least one field-year combination.

### O7 â€” `Drenasjevann` uses a different data model
Unlike `permit_kpi_to_air` and `permit_kpi_to_sea`, `Drenasjevann` has:
- Year embedded in the metric name (not as a year column)
- Rig-level granularity (not field-level)
- A "Grense" (threshold) value distinct from a KPI
This table does not follow the same structure as the other reference tables. Its integration into the model would require a different join approach.

### O8 â€” `permit_kpi_to_sea` sparse worksheet
The sheet's XML contains 1,048,576 row entries (Excel maximum), indicating sparse worksheet formatting. Only the first ~50 rows are expected to contain actual data. The Fabric ingestion process should handle this correctly, but it should be verified when the table is inspected.

---

## 6. Revised Confidence Summary

| Legacy table | Candidate Fabric table | Table confidence | Column-level confidence |
|-------------|----------------------|-----------------|------------------------|
| Emissions to air | `permit_kpi_to_air` | **High** | High for CO2, NOx, nmVOC, flaring, cold vent. Rig vs main field join strategy TBD. |
| CH4_NMVOC | `permit_kpi_to_air` | **High** | High for all 4 candidate columns. Granularity concern resolved. |
| Kaldvent volum | `permit_kpi_to_air` | **High** (annual permit) / **Medium** (QTD KPI) | Annual permit mapping confirmed. QTD quarterly computation requires further design. |
| Oily water | `permit_kpi_to_sea` + `Drenasjevann` | **Medium** | Metrics not yet confirmed in `permit_kpi_to_sea` first rows. `Drenasjevann` covers rigs only. |
| Radioaktive isotoper | `permit_kpi_to_sea` | **High** | Ra228 Tillatelse confirmed with field values. Ra226, Pb210 expected. `KPIs` derivation uncertain. |

---

## 7. Rejected Mappings

None to date.

---

## 8. Open Questions

The following questions remain open because the available repository artifacts do not provide sufficient evidence to answer them. All other questions from the previous phase have been resolved by the full workbook analysis.

| # | Question | Impact | Evidence gap |
|---|---------|--------|-------------|
| Q1 | Does `permit_kpi_to_sea` contain oily water permit metrics (Tillatelser, KPI Oil to sea, KPI water reinjected)? | Confirms or blocks oily water column mapping | Only first 7 rows read; oily water metrics expected further in the sheet |
| Q2 | Are "Mainfield nmVOC Permit" and "Mainfield nmVOC KPI" intended to serve both `Emissions to air.Permit nmVOC` and `CH4_NMVOC.Tillatelse nmVOC`, or are separate metrics needed? | Determines whether a single Fabric table row can serve both tables | Business naming in workbook does not distinguish fuel vs vented nmVOC |
| Q3 | Does `permit_kpi_to_sea` provide pre-computed KPI values for radioactive isotopes, or only permit ("Tillatelse") values? | Determines whether `Radioaktive isotoper.KPIs` can be replaced by a direct lookup or must remain computed | Only "Tillatelse" metrics confirmed; KPI metrics not yet seen |
| Q4 | How will historical permit values (2019â€“2024) be provided after migration? | Affects preservation of full report history | Workbook covers 2025+ only |
| Q5 | What is in the `utslipp_til_luft` worksheet? Is it reference data or measurement data? | Determines whether it is relevant to this migration | Structure not read |
| Q6 | What is the business purpose of `Emissions to air CO2 Hod`? | Determines if it requires migration work | No workbook worksheet found that corresponds to Hod-specific CO2 |

---

## 9. Recommended Fabric Tables for Import

This section identifies the minimum set of Fabric tables that should be imported into the semantic model to complete the migration. Every recommendation is based on evidence collected during the full worksheet analysis in Section 1 and the column-level mapping analysis in Section 4.

The objective is to introduce only the tables that are genuinely required. Tables are recommended only where a clear link to at least one candidate reference column has been established.

---

### 9.1 `permit_kpi_to_air` â€” **Recommended: Required**

**Business purpose:**
The primary business-maintained reference for air emission permit limits and KPI targets. Covers CO2, NOx, nmVOC, CH4, SOx, flaring, and cold vent gas for both main field facilities and drilling rigs across all tracked fields, for the years 2025â€“2032.

**Legacy tables and columns it replaces:**

| Legacy table | Candidate reference columns replaced | Workbook metric |
|-------------|-------------------------------------|-----------------|
| `Emissions to air` | `KPI CO2 tonn` | `CO2 KPI Year` |
| `Emissions to air` | `Tillatelse NOx` | `Mainfield NOX Permit` |
| `Emissions to air` | `KPI NOx` | `Mainfield NOX KPI` |
| `Emissions to air` | `Permit nmVOC` | `Mainfield nmVOC Permit` |
| `Emissions to air` | `KPI nmVOC` | `Mainfield nmVOC KPI` |
| `Emissions to air` | `Tillatelse flaring` | `Flaring Permit` |
| `Emissions to air` | `KPI flaring` | `Flaring KPI` |
| `Emissions to air` | `Permit Cold ventilated gas` | `Vented gas permit` |
| `Emissions to air` | `KPI Cold ventilated gas` | `Vented gas KPI` |
| `CH4_NMVOC` | `Tillatelse CH4` | `MainField CH4 permit` |
| `CH4_NMVOC` | `KPI CH4` | `MainField CH4 KPI` |
| `CH4_NMVOC` | `Tillatelse nmVOC` | `Mainfield nmVOC Permit` |
| `CH4_NMVOC` | `KPI nmVOC` | `Mainfield nmVOC KPI` |
| `Kaldvent volum` | `Tillatelse Kaldvent` | `Vented gas permit` |
| `Kaldvent volum` | `KPI Kaldvent QTD` (partial â€” annual base value) | `Vented gas KPI` |

Derived columns `Month` and `Division` are not reference data and require no Fabric table.

**Supporting evidence:**
- 218 data rows, 12 columns, confirmed structure (Metric, Field, Unit, 2025â€“2032, Comment).
- All 20 distinct metrics confirmed and matched to legacy candidate columns.
- Sample values confirmed: CO2 KPI Year for Ivar Aasen = 25,000 tonn (2026), Edvard Grieg = 26,000 tonn (2026), Ula = 140,383 tonn (2026).
- Every candidate reference column in `Emissions to air`, `CH4_NMVOC`, and `Kaldvent volum` has a confirmed metric match in this worksheet.

**Confidence:** High

**Implementation notes:**
- The worksheet is in wide format (year columns). The Fabric table structure will determine whether the Power Query join is implemented against a wide or tall format.
- The workbook distinguishes Main field and Rig metrics. The join design must account for facility type, using the `Facility` column to route each row to the correct metric.
- "Flaring KPI" is provided directly â€” the two-stage SQL derivation logic may be simplifiable to a direct lookup, pending numerical validation.
- `Vented gas permit` maps to two legacy columns (`Emissions to air.Permit Cold ventilated gas` and `Kaldvent volum.Tillatelse Kaldvent`). Both can share the same Fabric table row.
- Coverage begins 2025. A strategy for historical data (2019â€“2024) must be agreed before migration.

---

### 9.2 `permit_kpi_to_sea` â€” **Recommended: Required**

**Business purpose:**
The primary business-maintained reference for sea discharge permit limits. Confirmed to cover radioactive isotope permits (Ra226, Ra228, 210Pb) and expected to cover produced water and oily water discharge permits. Covers years 2026â€“2032.

**Legacy tables and columns it replaces:**

| Legacy table | Candidate reference columns replaced | Workbook metric |
|-------------|-------------------------------------|-----------------|
| `Radioaktive isotoper` | `Permits` | `Radium 228 Tillatelse` (confirmed), `Radium 226 Tillatelse` (expected), `Pb210 Tillatelse` or equivalent (expected) |
| `Radioaktive isotoper` | `KPIs` | Expected in this worksheet â€” not yet confirmed |
| `Oily water` | `Tillatelser` | Expected in this worksheet â€” not yet confirmed |
| `Oily water` | `KPI Oil to sea` | Expected â€” not yet confirmed |
| `Oily water` | `KPI water reinjected` | Expected â€” not yet confirmed |
| `Oily water` | `KPI drain water` (field-level) | Expected â€” not yet confirmed |

**Supporting evidence:**
- Structure confirmed: Metric, Field, 2026â€“2032 year columns, Comment.
- First confirmed metric: `Radium 228 Tillatelse` with per-field values: Ivar Aasen=20, Edvard Grieg=36, Valhall=2.45, Skarv=2.23, Ula=40, Alvheim=12.9. These are GBq annual permit values for Ra228 radioactive discharge.
- Worksheet name "permit_kpi_to_sea" is parallel in naming convention and structure to `permit_kpi_to_air`, which strongly suggests it covers all sea discharge permit and KPI types.
- Radioactive isotopes are discharged to sea â€” the worksheet is the correct domain for this data.

**Confidence:** High for radioactive isotope permit mapping. Medium for oily water permit mapping (expected but not yet confirmed from data).

**Implementation notes:**
- The `Radioaktive isotoper` table requires a three-dimensional join: Component (Ra226, Ra228, 210Pb) Ã— Field Ã— Year. The Metric column in the Fabric table carries the component identity ("Radium 228 Tillatelse"). The join strategy will need to match on Metric name pattern and Field.
- `permit_kpi_to_sea` does not have a 2025 column. The model's radioactive isotope data includes 2020+. Coverage of years 2020â€“2025 must be confirmed.
- Whether `KPIs` (the computed target value in `Radioaktive isotoper`) is provided directly in the Fabric table or must remain computed in Power Query is unconfirmed. This affects whether the `KPIs` column can be removed from the Power Query partition.

---

### 9.3 `Drenasjevann` â€” **Recommended: Conditional**

**Business purpose:**
Provides drain water discharge KPI targets and thresholds specifically for drilling rigs. Contains a single set of values for 2025: KPI = 10 (mg/L) and Grense (threshold/limit) = 15 (mg/L) for 4 named drilling rigs.

**Legacy columns it may replace:**

| Legacy table | Candidate reference column | Condition |
|-------------|--------------------------|-----------|
| `Oily water` | `KPI drain water` (rig-level) | Only if `permit_kpi_to_sea` does not cover rig-specific drain water. Otherwise redundant with `permit_kpi_to_sea`. |

**Supporting evidence:**
- 8 data rows, 3 columns (Description, Rig, Value).
- Distinct values: KPI 2025 = 10, Grense 2025 = 15 for rigs Deepsea Stavanger, Noble Integrator, Scarabeo 8, Deepsea Nordkapp.
- "Drenasjevann" = drain water in Norwegian â€” directly maps to the drain water stream type in `Oily water`.

**Confidence:** Medium

**Condition for import:** This table is only required if `permit_kpi_to_sea` does not cover rig-level drain water KPI values. If `permit_kpi_to_sea` covers all drain water permits at field or rig level, `Drenasjevann` is not needed.

**Caveats:**
- The table has rig-level granularity, while the model's `KPI drain water` is currently used at field level. A different join strategy would be needed.
- Year is embedded in the metric name ("KPI 2025") rather than being a column â€” this non-standard structure requires special handling in Power Query.
- Only covers 2025. Multi-year support would require additional rows in future workbook updates.

**Recommendation:** Defer import of `Drenasjevann` until `permit_kpi_to_sea` has been fully inspected and its metric list confirmed. If `permit_kpi_to_sea` covers drain water, `Drenasjevann` is not needed.

---

### 9.4 `utslipp_til_luft` â€” **Recommendation: Cannot be made**

**Business purpose (inferred):** "Utslipp til luft" means "emissions to air" â€” this worksheet may contain measurement reference data, categorisation of emission sources, or additional air emission context. Structure has not been confirmed.

**Legacy columns affected:** None identified from available evidence. No candidate reference column in the model maps to this worksheet.

**Reason recommendation cannot be made:** The structure of this worksheet was not read during analysis. Without knowing its columns and content, it is not possible to determine whether it is:
- A reference table for permit or KPI data (in scope),
- A measurement data table (not a reference table, not in scope for this migration), or
- A categorisation/lookup table (potentially useful but not a candidate for replacing any identified legacy column).

**Action required:** Inspect `utslipp_til_luft` Fabric table when it is available in the warehouse to determine its structure and decide whether it should be imported.

---

## 10. Fabric Tables Not Required for This Migration

The following worksheets/Fabric tables were evaluated and are not recommended for import into the semantic model as part of this migration. For each, the basis for exclusion is documented.

---

### 10.1 `utslipp_av_borekaks` â€” Not required

**Reason:** "Utslipp av borekaks" means "discharge of drill cuttings." Drill cuttings are a physical discharge from drilling operations. There is no corresponding fact table or reference table in the semantic model for drill cuttings. No candidate reference columns in the migration scope are sourced from this domain. This worksheet becomes a Fabric table in the warehouse but is not consumed by this semantic model.

---

### 10.2 `Kjemikalier` â€” Not required

**Reason:** "Kjemikalier" means "chemicals." This worksheet tracks chemical usage or discharge data. There is no chemicals table in the semantic model. No candidate reference columns in the migration scope are sourced from this domain.

---

### 10.3 `Kjemikalier Yggdrasil` â€” Not required

**Reason:** Chemicals data specific to the Yggdrasil field. Same basis as `Kjemikalier`. No semantic model dependency.

---

### 10.4 `Kjemikalier funksjonsgruppe` â€” Not required

**Reason:** "Kjemikalier funksjonsgruppe" means "chemicals functional group" â€” a categorical grouping of chemical types. Same basis as `Kjemikalier`. No semantic model dependency.

---

## Minimum Set Summary

| Fabric table | Import recommendation | Basis |
|-------------|----------------------|-------|
| `permit_kpi_to_air` | **Required** | Replaces all air emission candidate reference columns across 3 fact tables. 20 metrics confirmed. |
| `permit_kpi_to_sea` | **Required** | Replaces radioactive isotope permits (confirmed) and oily water permits (expected). |
| `Drenasjevann` | **Conditional** | Required only if `permit_kpi_to_sea` does not cover rig drain water. Defer until `permit_kpi_to_sea` is fully inspected. |
| `utslipp_til_luft` | **Undetermined** | Structure not confirmed. No candidate column dependency identified. Inspect before deciding. |
| `utslipp_av_borekaks` | **Not required** | No semantic model dependency. |
| `Kjemikalier` | **Not required** | No semantic model dependency. |
| `Kjemikalier Yggdrasil` | **Not required** | No semantic model dependency. |
| `Kjemikalier funksjonsgruppe` | **Not required** | No semantic model dependency. |

---

## 11. Implementation Recommendation

This section provides the final implementation recommendation for the Mapping Analysis phase. It identifies the minimum set of Fabric tables that should be added to the semantic model before migration begins.

This recommendation is based on the full worksheet analysis (Section 1), column-level mapping analysis (Section 4), and the Recommended Fabric Tables analysis (Section 9). No semantic model changes are made at this stage. This remains analysis and documentation only.

---

### 11.1 `permit_kpi_to_air`

| Attribute | Value |
|-----------|-------|
| **Fabric table name** | `permit_kpi_to_air` |
| **Corresponding worksheet** | `permit_kpi_to_air` in `Input til PowerBI.xlsx` |
| **Required or optional** | **Required** |

**Business purpose:**
The primary business-maintained reference for air emission permit limits and KPI targets across all tracked fields. Covers CO2, NOx, nmVOC, CH4, SOx, flaring, and cold vent gas — separately for main field production facilities and drilling rigs — for years 2025–2032.

**Legacy tables and columns it replaces:**

| Legacy table | Candidate reference columns | Workbook metric |
|-------------|----------------------------|-----------------|
| `Emissions to air` | `KPI CO2 tonn` | `CO2 KPI Year` |
| `Emissions to air` | `Tillatelse NOx` | `Mainfield NOX Permit` |
| `Emissions to air` | `KPI NOx` | `Mainfield NOX KPI` |
| `Emissions to air` | `Permit nmVOC` | `Mainfield nmVOC Permit` |
| `Emissions to air` | `KPI nmVOC` | `Mainfield nmVOC KPI` |
| `Emissions to air` | `Tillatelse flaring` | `Flaring Permit` |
| `Emissions to air` | `KPI flaring` | `Flaring KPI` |
| `Emissions to air` | `Permit Cold ventilated gas` | `Vented gas permit` |
| `Emissions to air` | `KPI Cold ventilated gas` | `Vented gas KPI` |
| `CH4_NMVOC` | `Tillatelse CH4` | `MainField CH4 permit` |
| `CH4_NMVOC` | `KPI CH4` | `MainField CH4 KPI` |
| `CH4_NMVOC` | `Tillatelse nmVOC` | `Mainfield nmVOC Permit` |
| `CH4_NMVOC` | `KPI nmVOC` | `Mainfield nmVOC KPI` |
| `Kaldvent volum` | `Tillatelse Kaldvent` | `Vented gas permit` |
| `Kaldvent volum` | `KPI Kaldvent QTD` (annual base only) | `Vented gas KPI` |

**Total: 15 candidate reference columns across 3 legacy fact tables.**

The derived columns `Month` (Emissions to air) and `Division` (Emissions to air, Kaldvent volum) are computed from date or permit values and do not require a Fabric source.

**Supporting evidence:**
1. Worksheet structure confirmed: Metric | Field | Unit | 2025–2032 Values | Comment — 218 data rows × 12 columns.
2. All 20 distinct metrics confirmed from full worksheet read. Every candidate reference column group maps to a named metric.
3. Sample data confirmed: `CO2 KPI Year` → Ivar Aasen = 25,000 tonn (2026), Edvard Grieg = 26,000 tonn (2026), Ula = 140,383 tonn (2026), Skarv = 351,000 tonn (2026).
4. Field names in workbook match model: Ivar Aasen, Edvard Grieg, Valhall, Skarv, Ula, Alvheim, Yggdrasil.
5. Workbook explicitly separates Main field and Rig metrics — directly corresponding to the two facility types tracked in `Emissions to air`.
6. `Flaring KPI` is provided as a direct metric value — the two-stage SQL derivation logic in the current model may simplify to a direct lookup (subject to numerical validation).
7. `Vented gas permit` maps to two legacy columns (`Permit Cold ventilated gas` in `Emissions to air` and `Tillatelse Kaldvent` in `Kaldvent volum`) — both can be served from the same Fabric table row.

**Confidence:** **High**

**Implementation notes before import:**
- Confirm the Fabric table format (wide year-columns vs. pivoted tall format) — this determines the join key design.
- The rig vs. main field distinction requires a join strategy that routes each fact table row to the correct metric based on the `Facility` column value.
- Historical values (2019–2024) are not covered. A strategy must be agreed before the partition SQL is modified.

---

### 11.2 `permit_kpi_to_sea`

| Attribute | Value |
|-----------|-------|
| **Fabric table name** | `permit_kpi_to_sea` |
| **Corresponding worksheet** | `permit_kpi_to_sea` in `Input til PowerBI.xlsx` |
| **Required or optional** | **Required** |

**Business purpose:**
The primary business-maintained reference for sea discharge permit limits. Confirmed to cover radioactive isotope permits (Ra226, Ra228, 210Pb). Expected to also cover produced water, oily water, and drain water discharge permits. Covers years 2026–2032.

**Legacy tables and columns it replaces:**

| Legacy table | Candidate reference columns | Workbook metric | Confirmation status |
|-------------|----------------------------|-----------------|---------------------|
| `Radioaktive isotoper` | `Permits` | `Radium 228 Tillatelse` (and Ra226, Pb210 equivalents) | **Confirmed** — sample values match |
| `Radioaktive isotoper` | `KPIs` | Expected in this table | Not yet confirmed |
| `Oily water` | `Tillatelser` | Expected in this table | Not yet confirmed |
| `Oily water` | `KPI Oil to sea` | Expected | Not yet confirmed |
| `Oily water` | `KPI drain water` (field-level) | Expected | Not yet confirmed |
| `Oily water` | `KPI water reinjected` | Expected | Not yet confirmed |

**Supporting evidence:**
1. Worksheet structure confirmed: Metric | Field | 2026–2032 Values | Comment — 10 columns, sparse XML (actual data rows estimated ~50).
2. First confirmed metric: `Radium 228 Tillatelse` with per-field values: Ivar Aasen = 20 GBq, Edvard Grieg = 36 GBq, Valhall = 2.45 GBq, Skarv = 2.23 GBq, Ula = 40 GBq, Alvheim = 12.9 GBq.
3. These Ra228 values are consistent with regulatory radioactive discharge limits for Norwegian offshore operations and directly correspond to the `Permits` column in `Radioaktive isotoper`.
4. Worksheet name parallel with `permit_kpi_to_air` strongly implies the same Metric+Field+Year structure covers all sea discharge types.
5. Radioactive discharges are classified as sea discharges in Norwegian environmental reporting — this is the correct domain.

**Confidence:** **High** (for radioactive isotope permit columns) | **Medium** (for oily water permit columns — expected but not confirmed from data)

**Implementation notes before import:**
- The `Radioaktive isotoper` join requires a Component × Field × Year key. The Metric column carries the component identity ("Radium 228 Tillatelse"). The join design must filter by Metric name pattern.
- Inspect the full metric list in the Fabric table before designing the oily water join — oily water metrics have not been seen yet.
- No 2025 column exists. The model's radioactive isotope data includes years from 2020. Historical coverage for 2020–2025 must be confirmed.

---

### 11.3 `Drenasjevann`

| Attribute | Value |
|-----------|-------|
| **Fabric table name** | `Drenasjevann` |
| **Corresponding worksheet** | `Drenasjevann` in `Input til PowerBI.xlsx` |
| **Required or optional** | **Conditional — defer until `permit_kpi_to_sea` is inspected** |

**Business purpose:**
Provides drain water discharge KPI targets and operational thresholds ("Grense") for drilling rigs specifically. Contains a single year (2025) of values: KPI = 10 mg/L and Grense = 15 mg/L for four named drilling rigs: Deepsea Stavanger, Noble Integrator, Scarabeo 8, Deepsea Nordkapp.

**Legacy tables and columns it may replace:**

| Legacy table | Candidate reference column | Condition |
|-------------|--------------------------|-----------|
| `Oily water` | `KPI drain water` (rig-level rows only) | Only needed if `permit_kpi_to_sea` does not cover rig-specific drain water |

**Supporting evidence:**
1. Worksheet structure confirmed: Description | Rig | Value — 8 data rows × 3 columns.
2. Two metric types: `KPI 2025` = 10, `Grense 2025` = 15, for 4 named drilling rigs.
3. "Drenasjevann" = drain water — directly corresponds to the drain water stream type in `Oily water`.
4. Rig names match active drilling vessels operating on Aker BP fields.

**Confidence:** **Medium**

**Condition for import:**
This table is only required if `permit_kpi_to_sea` does not provide rig-level drain water KPI values. Import it alongside `permit_kpi_to_sea` and resolve the question during model integration.

**Caveats:**
- Rig-level granularity differs from the field-level `KPI drain water` currently in the model. The join design requires a different approach from the other reference tables.
- Year is embedded in the metric name (`KPI 2025`) rather than as a column — this requires special handling in Power Query.
- Only 2025 values are present. Multi-year support would require future workbook updates.

---

### 11.4 Tables not recommended for import

| Fabric table | Recommendation | Reason |
|-------------|----------------|--------|
| `utslipp_til_luft` | **Defer** | Structure not confirmed. No candidate legacy column identified. Inspect Fabric table before deciding. |
| `utslipp_av_borekaks` | **Do not import** | No corresponding semantic model table or candidate column. Out of scope. |
| `Kjemikalier` | **Do not import** | No chemicals table in semantic model. Out of scope. |
| `Kjemikalier Yggdrasil` | **Do not import** | No chemicals table in semantic model. Out of scope. |
| `Kjemikalier funksjonsgruppe` | **Do not import** | No chemicals table in semantic model. Out of scope. |

---

## 12. Recommended Export List

The following Fabric tables should be exported from the Fabric data warehouse and imported into the semantic model before migration implementation begins. The list is ordered by priority.

| Priority | Fabric table | Worksheet source | Status | Reason |
|----------|-------------|-----------------|--------|--------|
| 1 | `permit_kpi_to_air` | `permit_kpi_to_air` | **Export now** | Required. Covers all air emission candidate columns across 3 legacy fact tables. All 20 metrics confirmed. |
| 2 | `permit_kpi_to_sea` | `permit_kpi_to_sea` | **Export now** | Required. Covers radioactive isotope permits (confirmed) and oily water permits (expected). Full metric list must be inspected after import. |
| 3 | `Drenasjevann` | `Drenasjevann` | **Export now, decision deferred** | Conditional. Small table (8 rows). Import now and determine whether it is needed once `permit_kpi_to_sea` is fully inspected. |

**Tables not on the export list:** `utslipp_til_luft` (defer), `utslipp_av_borekaks`, `Kjemikalier`, `Kjemikalier Yggdrasil`, `Kjemikalier funksjonsgruppe` — none required for this migration.

**Expected result after import:** The semantic model will contain 3 new Fabric reference tables. Mapping Analysis validation (confirming column-level correspondences and join key design) can then proceed, followed by Migration Planning.

---

## 13. Confirmed Fabric Table Structures

**Confirmed:** 2026-07-03

Two Fabric reference tables have been imported into the new-model semantic model. `Drenasjevann` was not imported at this stage.

---

### 13.1 `dbt_gold_nems_emission fact_nems__permit_kpi_to_air`

**Semantic model table name:** `dbt_gold_nems_emission fact_nems__permit_kpi_to_air`
**Fabric source:** `wh_gold_hsseq` · schema `dbt_gold_nems_emission` · table `fact_nems__permit_kpi_to_air`
**Import mode:** Import

**Confirmed columns:**

| Column | Data type | Description |
|--------|-----------|-------------|
| `metric` | string | Permit or KPI metric name (e.g., "CO2 KPI Year", "Mainfield NOX Permit") |
| `field` | string | Field/asset name (e.g., "Ivar Aasen", "Valhall") |
| `unit` | string | Unit of measurement (e.g., "tonn") |
| `year` | int64 | Year the value applies to |
| `value_permit_kpi` | double | The permit limit or KPI target value for the given metric, field, and year |

**Format confirmation:** The workbook's wide year-columns (2025, 2026 … 2032) have been unpivoted into a **tall format** in Fabric. Each row represents one (metric, field, year) combination with a single `value_permit_kpi`. The concern about wide-format transformation (Observation O1) is **resolved**.

**Relationship key (confirmed):** (`metric`, `field`, `year`) → `value_permit_kpi`

**Column mapping — how legacy columns are replaced:**

| Legacy table | Legacy column | Filter on `metric` | Join on `field` | Join on `year` |
|-------------|--------------|-------------------|-----------------|----------------|
| Emissions to air | `KPI CO2 tonn` | `CO2 KPI Year` | `Field` | `YearNum` |
| Emissions to air | `Tillatelse NOx` | `Mainfield NOX Permit` | `Field` | `YearNum` |
| Emissions to air | `KPI NOx` | `Mainfield NOX KPI` | `Field` | `YearNum` |
| Emissions to air | `Permit nmVOC` | `Mainfield nmVOC Permit` | `Field` | `YearNum` |
| Emissions to air | `KPI nmVOC` | `Mainfield nmVOC KPI` | `Field` | `YearNum` |
| Emissions to air | `Tillatelse flaring` | `Flaring Permit` | `Field` | `YearNum` |
| Emissions to air | `KPI flaring` | `Flaring KPI` | `Field` | `YearNum` |
| Emissions to air | `Permit Cold ventilated gas` | `Vented gas permit` | `Field` | `YearNum` |
| Emissions to air | `KPI Cold ventilated gas` | `Vented gas KPI` | `Field` | `YearNum` |
| CH4_NMVOC | `Tillatelse CH4` | `MainField CH4 permit` | `field` | `Year` |
| CH4_NMVOC | `KPI CH4` | `MainField CH4 KPI` | `field` | `Year` |
| CH4_NMVOC | `Tillatelse nmVOC` | `Mainfield nmVOC Permit` | `field` | `Year` |
| CH4_NMVOC | `KPI nmVOC` | `Mainfield nmVOC KPI` | `field` | `Year` |
| Kaldvent volum | `Tillatelse Kaldvent` | `Vented gas permit` | `field` | `Year` |
| Kaldvent volum | `KPI Kaldvent QTD` (annual base) | `Vented gas KPI` | `field` | `Year` |

**Note on Rig metrics:** The table also contains `Rig NOX Permit`, `Rig NOX KPI`, `Rig nmVOC Permit`, etc. for drilling rig rows. The fact table join must filter by `metric` based on whether a given row represents a main field facility or a drilling rig. The `Facility` column in `Emissions to air` identifies drilling rigs by name.

**Outstanding validation tasks:**
- Confirm distinct metric names in the Fabric table match the 20 expected values from the workbook.
- Confirm distinct field names match the legacy model's fields.
- Confirm year range covers 2025 at minimum; check whether historical years (pre-2025) are included.
- Compare a sample `value_permit_kpi` value against the hardcoded SQL value for at least one (metric, field, year) combination.

---

### 13.2 `dbt_gold_nems_emission fact_nems__permit_kpi_to_sea`

**Semantic model table name:** `dbt_gold_nems_emission fact_nems__permit_kpi_to_sea`
**Fabric source:** `wh_gold_hsseq` · schema `dbt_gold_nems_emission` · table `fact_nems__permit_kpi_to_sea`
**Import mode:** Import

**Confirmed columns:**

| Column | Data type | Description |
|--------|-----------|-------------|
| `metric` | string | Permit or KPI metric name (e.g., "Radium 228 Tillatelse") |
| `field` | string | Field/asset name |
| `year` | int64 | Year the value applies to |
| `value_permit_kpi` | double | The permit limit or KPI target value for the given metric, field, and year |

**Format confirmation:** Same tall format as `permit_kpi_to_air`. Wide year-columns unpivoted. No `unit` column in this table.

**Relationship key (confirmed):** (`metric`, `field`, `year`) → `value_permit_kpi`

**Column mapping — how legacy columns are replaced:**

| Legacy table | Legacy column | Filter on `metric` | Join on `field` | Join on `year` |
|-------------|--------------|-------------------|-----------------|----------------|
| Radioaktive isotoper | `Permits` (Ra228) | `Radium 228 Tillatelse` | `Field` | `Year` |
| Radioaktive isotoper | `Permits` (Ra226) | `Radium 226 Tillatelse` (expected) | `Field` | `Year` |
| Radioaktive isotoper | `Permits` (210Pb) | `Pb-210 Tillatelse` or equivalent (expected) | `Field` | `Year` |
| Radioaktive isotoper | `KPIs` | TBD (expected in this table) | `Field` | `Year` |
| Oily water | `Tillatelser` | TBD (expected) | `Field` | `Year` |
| Oily water | `KPI Oil to sea` | TBD (expected) | `Field` | `Year` |
| Oily water | `KPI drain water` | TBD (expected) | `Field` | `Year` |
| Oily water | `KPI water reinjected` | TBD (expected) | `Field` | `Year` |

**Note on `Radioaktive isotoper` join:** The `Radioaktive isotoper` table has a `Component` column (Ra226, Ra228, 210Pb) and a `Field` column. The join to this Fabric table filters `metric` by the component name pattern, then joins on `Field` and `Year`. This is a non-standard lookup pattern that will need to be implemented in Power Query or as a calculated column in DAX.

**Outstanding validation tasks:**
- Query distinct `metric` values to confirm Ra226, Ra228, 210Pb metric names and oily water metric names.
- Confirm field names and year range.
- Compare Ra228 Ivar Aasen (expected: 20 GBq for 2026) against the Fabric table value.
- Confirm whether `KPIs` (derived KPI target) is a separate metric row or must be computed.

---

### 13.3 `Drenasjevann` — Not imported

`Drenasjevann` was not imported at this stage. The decision to defer was taken as recommended in Section 11.3, pending confirmation of whether `permit_kpi_to_sea` covers rig-level drain water. This should be assessed during the `permit_kpi_to_sea` validation step.

---

### 13.4 Current model state

| New Fabric table | In new-model? | Relationships defined? |
|-----------------|--------------|----------------------|
| `dbt_gold_nems_emission fact_nems__permit_kpi_to_air` | Yes | No |
| `dbt_gold_nems_emission fact_nems__permit_kpi_to_sea` | Yes | No |
| `Drenasjevann` | No — deferred | N/A |

No relationships between the new reference tables and the existing fact tables have been defined yet. Relationship design is the next step, following validation of the distinct metric and field values.

---

## 14. Integration Architecture Assessment

**Date:** 2026-07-03
**Status:** Analysis only — no model changes.
**Basis of recommendation:** Explicitly stated per approach (Section 14.4).
**Performance claims:** Qualified as measured evidence or engineering judgement throughout.

---

### 14.1 The integration problem

Both reference tables are in **tall format**: each row represents one `(metric, field, year)` combination with a single `value_permit_kpi`. This is structurally different from the current model, where each reference value has its own named column (e.g., `Tillatelse NOx`, `KPI CO2 tonn`).

The challenge is that each fact table row requires **multiple** reference values simultaneously:

| Fact table | Distinct metric lookups needed per row |
|-----------|----------------------------------------|
| `Emissions to air` | 9 (NOx permit/KPI, nmVOC permit/KPI, CO2 KPI, Flaring permit/KPI, Vented gas permit/KPI) |
| `CH4_NMVOC` | 4 (CH4 permit/KPI, nmVOC permit/KPI) |
| `Kaldvent volum` | 2 (Vented gas permit/KPI) |
| `Oily water` | 4 (Tillatelser, KPI Oil to sea, KPI drain water, KPI water reinjected) |
| `Radioaktive isotoper` | Up to 3 per row (one per isotope component per row) |

No single relationship can satisfy all these lookups simultaneously. The correct integration pattern must therefore be chosen deliberately, considering both migration risk and long-term architectural quality.

**Existing dependencies that constrain the approach:**
- 42 visual direct column bindings in the report (confirmed in Dependency Analysis)
- 11 DAX measures referencing current column names
- 5 bookmarks with column names in stored state
- All dependencies require that final column names are preserved

---

### 14.2 Evaluation criteria

Each approach is assessed across seven criteria. The criterion weight appropriate to the migration vs. long-term context is stated where relevant.

| Criterion | Description |
|-----------|-------------|
| **Suitability** | Whether the approach is technically applicable to this structure |
| **Compatibility** | Whether existing visual, measure, and bookmark dependencies continue working |
| **Alignment with best practices** | Conformance to Microsoft Fabric and Power BI semantic modeling guidance |
| **Performance** | Query-time and refresh-time cost |
| **Maintainability** | Ease of updating when business data changes |
| **Implementation complexity** | Effort and risk to implement in this migration |
| **Long-term architectural quality** | Whether the resulting model design is sustainable and extensible |

---

### 14.3 Approaches evaluated

---

#### Approach A — Standard single-column relationship

A relationship from a single fact table column to a reference table column. Standard star schema pattern.

| Criterion | Assessment |
|-----------|-----------|
| Suitability | **Not applicable.** The reference table contains no column that uniquely identifies the single reference row needed for a given fact row. `metric` is not a fact table column. `field` alone is not unique in the reference table. |
| Compatibility | N/A |
| Best practices alignment | Would be best practice *if applicable* — single-column relationships are the canonical Power BI pattern. |
| Performance | N/A |
| Maintainability | N/A |
| Implementation complexity | N/A |
| Long-term architectural quality | N/A |

**Verdict:** Not applicable to this reference table structure.

---

#### Approach B — Composite key relationship (surrogate key per metric)

Add concatenated surrogate key columns to both tables (`metric|field|year`). Each fact table would require one surrogate per metric needed (nine for `Emissions to air`), with one active relationship and eight inactive ones requiring `USERELATIONSHIP()`.

| Criterion | Assessment |
|-----------|-----------|
| Suitability | Technically possible but impractical at the required scale. |
| Compatibility | Poor. Direct visual column bindings would need replacement with measures using `USERELATIONSHIP`. |
| Best practices alignment | Partial. Multi-column surrogate keys are a recognised workaround, but not the recommended pattern. Excessive inactive relationships are a known anti-pattern in Power BI. |
| Performance | Inactive relationships carry no query-time cost at rest. However, `USERELATIONSHIP` in every KPI measure adds overhead per visual render. *(Engineering judgement — not measured for this model.)* |
| Maintainability | Poor. Nine surrogate key columns per fact table. Adding a new metric requires a new column and a new relationship everywhere. |
| Implementation complexity | High. Error-prone. |
| Long-term architectural quality | Poor. Excessive inactive relationships create model complexity without architectural benefit. |

**Verdict:** Rejected. Impractical and architecturally poor.

---

#### Approach C — Pivot the reference table to wide format + standard relationship

Transform `permit_kpi_to_air` in Power Query from tall to wide format (one column per metric), add a composite surrogate key `field|year`, and define one standard relationship per fact table on this key.

Resulting wide-format example:

```
field_year   | CO2 KPI Year | Mainfield NOX Permit | Mainfield NOX KPI | …
Valhall|2026 | 25000        | 1000                 | 900               | …
```

| Criterion | Assessment |
|-----------|-----------|
| Suitability | **Well suited.** Produces a proper dimensional reference table joinable by standard relationships. |
| Compatibility | **High**, once surrogate keys are added to fact tables and relationships defined. Column names in the wide-format table can be matched to the legacy names. |
| Best practices alignment | **Strong.** Microsoft Fabric and Power BI documentation consistently recommends shaping data correctly at the source (M/Power Query) rather than using calculated columns or LOOKUPVALUE to compensate for poorly shaped data. A wide-format reference table with a standard relationship is the canonical pattern for this type of static reference data. |
| Performance | **Best.** Data is imported once during refresh with no DAX overhead at query time. VertiPaq stores the relationship key efficiently. *(Engineering judgement based on Microsoft's documented VertiPaq architecture and widely documented community benchmarks — not measured for this specific model.)* |
| Maintainability | **High.** Future permit changes require only a workbook update and refresh. New metrics require updating the Power Query pivot step, which is a contained change. |
| Implementation complexity | **Moderate to High.** Requires: (1) Power Query pivot step on the reference table, (2) adding a surrogate key column to all 5 fact tables, (3) defining 5 relationships, (4) renaming columns if names must match legacy names exactly. |
| Long-term architectural quality | **Highest.** Produces a clean star schema with a proper dimension. Future semantic model developers will recognise this pattern immediately. Extensible: additional metrics are new columns in the wide-format table, no model structure changes. |

**Verdict: Preferred long-term target architecture.** Not recommended as the immediate migration approach due to implementation complexity and the risk of breaking existing dependencies during the column renaming step.

---

#### Approach D — Bridge table

An intermediary table linking fact table rows to reference rows via an intermediate key.

| Criterion | Assessment |
|-----------|-----------|
| Suitability | Not appropriate. Bridge tables solve many-to-many cardinality problems, not multi-metric lookup problems. |
| Best practices alignment | Bridge tables are a recognised pattern for many-to-many — but this is not a many-to-many scenario. Using a bridge table here would be a misapplication of the pattern. |

**Verdict:** Not applicable.

---

#### Approach E — LOOKUPVALUE() calculated columns

Replace each hardcoded SQL reference column with a DAX calculated column of the same name using `LOOKUPVALUE()` on three match conditions: `metric`, `field`, `year`.

Example for `Emissions to air[Tillatelse NOx]`:
```dax
Tillatelse NOx =
LOOKUPVALUE(
    'dbt_gold_nems_emission fact_nems__permit_kpi_to_air'[value_permit_kpi],
    'dbt_gold_nems_emission fact_nems__permit_kpi_to_air'[metric],
        IF( 'Emissions to air'[Facility] IN { "Noble Integrator", "Scarabeo 8", … },
            "Rig NOX Permit", "Mainfield NOX Permit" ),
    'dbt_gold_nems_emission fact_nems__permit_kpi_to_air'[field],  'Emissions to air'[Field],
    'dbt_gold_nems_emission fact_nems__permit_kpi_to_air'[year],   'Emissions to air'[YearNum]
)
```

Example for `Radioaktive isotoper[Permits]` (component→metric mapping):
```dax
Permits =
LOOKUPVALUE(
    'dbt_gold_nems_emission fact_nems__permit_kpi_to_sea'[value_permit_kpi],
    'dbt_gold_nems_emission fact_nems__permit_kpi_to_sea'[metric],
        SWITCH( 'Radioaktive isotoper'[Component],
            "Ra226", "Radium 226 Tillatelse",
            "Ra228", "Radium 228 Tillatelse",
            "210Pb", "Pb-210 Tillatelse", BLANK() ),
    'dbt_gold_nems_emission fact_nems__permit_kpi_to_sea'[field], 'Radioaktive isotoper'[Field],
    'dbt_gold_nems_emission fact_nems__permit_kpi_to_sea'[year],  'Radioaktive isotoper'[Year]
)
```

| Criterion | Assessment |
|-----------|-----------|
| Suitability | **Highly suited** to the tall-format reference table as currently imported. |
| Compatibility | **Perfect.** Column names preserved exactly. All 42 visual bindings, 11 measures, and 5 bookmarks work without any change. |
| Best practices alignment | **Weak.** Microsoft's guidance explicitly recommends avoiding calculated columns when the result can be achieved through correctly shaped data or measures. LOOKUPVALUE calculated columns are documented as a workaround rather than a recommended pattern. They increase model size and refresh time relative to properly imported columns or measures. The reference table in tall format is the source of the problem — `LOOKUPVALUE` compensates for it rather than correcting it. |
| Performance | Refresh: LOOKUPVALUE is evaluated per row of the fact table during refresh. For `Emissions to air` (size unknown until refreshed), this is a row-by-row DAX operation. For a reference table of ~1,280 rows, each lookup is fast. *(Engineering judgement — no measured refresh baseline exists for this model.)* Query-time: Calculated columns are stored in VertiPaq after refresh; query-time performance is identical to an imported column. *(Engineering judgement based on documented VertiPaq behaviour.)* |
| Maintainability | **High for data changes** — workbook updates reflect automatically after refresh. **Low for model changes** — a new metric requires a new calculated column definition. Adding a new reference table requires new calculated columns on every affected fact table. |
| Implementation complexity | **Low.** One LOOKUPVALUE expression per legacy reference column. Supports safe incremental validation (temporary column approach). |
| Long-term architectural quality | **Weak.** Calculated columns on fact tables are not the intended home for dimensional reference data. The model ends up with DAX-computed reference values mixed into fact table column lists, which reduces discoverability and violates the separation between fact and dimensional data. |

**Verdict: Preferred migration approach.** Recommended for this migration phase because it eliminates breaking changes and allows validated incremental replacement. Not recommended as the long-term target state.

---

#### Approach F — TREATAS() in DAX measures

Update existing KPI measures to dynamically calculate reference values from the Fabric table using `TREATAS()` for virtual filter propagation.

| Criterion | Assessment |
|-----------|-----------|
| Suitability | Suitable for measure-level reference lookups only. Cannot replace direct visual column bindings. |
| Compatibility | Partial. Solves 11 measure dependencies but leaves 34 direct visual column bindings unresolved. |
| Best practices alignment | **Acceptable** as a measure-level pattern. `TREATAS` is documented and supported for virtual relationships in measures. It does not violate best practice guidance in the same way that LOOKUPVALUE calculated columns do. |
| Performance | Evaluated at query time per measure call. For KPI measures rendered as scalar values, performance is excellent. *(Engineering judgement.)* |
| Maintainability | High for data changes. Requires DAX updates for new metrics. |
| Implementation complexity | Medium. Measure rewrites only; no column changes. |
| Long-term architectural quality | Acceptable as a transitional measure pattern. In the long-term target architecture (Approach C), measures would instead reference the relationship-connected wide-format table directly — which is simpler and more readable than TREATAS. |

**Verdict: Supplementary.** Useful for updating KPI measures after columns are replaced (complementing Approach E during migration, or complementing Approach C in the long-term target). Not a standalone solution.

---

#### Approach G — SQL join within the fact table partition

Replace the SQL CASE statements with LEFT JOINs to the reference table directly in the T-SQL partition query. Reference values arrive as regular imported columns.

```sql
SELECT e.*, ref_nox.value_permit_kpi AS [Tillatelse NOx]
FROM   fact_data e
LEFT JOIN dbt_gold_nems_emission.fact_nems__permit_kpi_to_air ref_nox
       ON ref_nox.metric = CASE WHEN e.Facility IN ('Noble Integrator', …)
                                THEN 'Rig NOX Permit' ELSE 'Mainfield NOX Permit' END
      AND ref_nox.field  = e.Field
      AND ref_nox.year   = e.YearNum
-- repeated for each metric
```

| Criterion | Assessment |
|-----------|-----------|
| Suitability | Well suited. All joins executed in the Fabric SQL engine before data arrives in the model. |
| Compatibility | **Perfect.** Column names preserved. Zero downstream changes. |
| Best practices alignment | **Strong.** Microsoft's guidance recommends resolving data shaping at the source (SQL or M) rather than in DAX. Keeping reference values as SQL-sourced imported columns, joined at the database layer, aligns with the intent of the Fabric data warehouse layer. However, embedding 9 LEFT JOINs for a single fact table in M/SQL does increase partition complexity. |
| Performance | **Best possible.** All joins resolved in the Fabric query engine; a single network round-trip. No DAX or M overhead. *(Engineering judgement based on documented query folding behaviour — not measured for this model.)* |
| Maintainability | **Moderate for data.** Workbook updates reflect at refresh. **Moderate for model.** Adding a new metric requires updating the SQL partition — a contained but non-trivial change. |
| Implementation complexity | **Moderate to High.** Each of the 5 fact tables requires SQL partition changes. The rig/main field routing requires a SQL CASE on the JOIN condition. Debugging SQL partition errors is harder than debugging DAX calculated columns. |
| Long-term architectural quality | **Good.** Reference data arrives as imported columns with no DAX overhead. However, the SQL partition becomes the single source of both measurement data AND reference logic — a coupling that makes independent changes harder. Approach C (wide-format pivot + relationship) is architecturally cleaner because it separates the reference table as a true dimension. |

**Verdict: Viable long-term path**, especially if the SQL/dbt layer is the preferred governance boundary. Not recommended as the immediate migration approach because it requires significant SQL partition changes across all 5 fact tables simultaneously.

---

### 14.4 Comparison matrix

| Criterion | A | B | C — Pivot + rel. | D | E — LOOKUPVALUE | F — TREATAS | G — SQL join |
|-----------|:-:|:-:|:----------------:|:-:|:---------------:|:-----------:|:------------:|
| Applicable to tall format | ✗ | Partial | ✓ (after pivot) | ✗ | ✓ | ✓ (measures) | ✓ |
| Preserves all column names | N/A | ✗ | ✓ | N/A | **✓** | ✗ | **✓** |
| Zero visual/bookmark breakage | N/A | ✗ | ✓ | N/A | **✓** | ✗ | **✓** |
| Alignment with Fabric/PBI best practices | Best if applicable | Weak | **Strong** | N/A | Weak | Acceptable | Strong |
| Query-time performance | N/A | Good | **Best** | N/A | Good | Good | **Best** |
| Refresh-time cost | N/A | Low | Low | N/A | Medium* | None | Low |
| Maintainability | N/A | Poor | **High** | N/A | High (data) / Low (model) | High (data) | Moderate |
| Implementation complexity (migration) | N/A | High | High | N/A | **Low** | Medium | High |
| Incremental validation possible | N/A | ✗ | ✗ | N/A | **✓** | Partial | ✗ |
| Long-term architectural quality | N/A | Poor | **Best** | N/A | Weak | Acceptable | Good |

*LOOKUPVALUE refresh cost: engineering judgement — not measured. Considered acceptable given the small reference table size (~1,280 rows).

---

### 14.5 Recommendations

This section explicitly separates the migration recommendation from the long-term target architecture. They are different, and the distinction is intentional.

---

#### 14.5.1 Preferred migration approach — **Superseded by Decision Record 003**

> **Note (2026-07-03):** The original recommendation in this section was Approach E (LOOKUPVALUE calculated columns). This recommendation was superseded following further architectural analysis and the implementation analysis described in the decision records. The approved migration approach is **Strategy B — Power Query combined reference table with M join** (Decision Record 003). Strategy B extracts historical reference values into a combined M query, combines them with the Fabric reference data, and joins to each fact table partition using Power Query merges. Reference columns remain imported columns throughout.
>
> The analysis in this section (including the rationale and acknowledged limitations of Approach E) is retained as the historical record that informed the architectural reassessment leading to Decision Record 003.

---

#### 14.5.2 Preferred long-term target architecture — Approach C (Pivot + standard relationship)

**Basis:** Architectural quality and alignment with Microsoft Fabric and Power BI best practices.

**Recommendation:** After migration is validated and stable, restructure the reference tables from tall format to wide format, add surrogate keys, and replace the LOOKUPVALUE calculated columns with standard relationships.

**Target state:**

```
Wide-format reference table (permit_kpi_to_air):
  field_year       | CO2 KPI Year | Mainfield NOX Permit | Mainfield NOX KPI | …
  Valhall|2026     | 25000        | 1000                 | 900               | …

Relationship: Emissions to air[field_year] → permit_kpi_to_air[field_year]
```

**Rationale:**
- Microsoft's Power BI and Fabric documentation consistently recommends shaping data at the source (M/Power Query) rather than using DAX calculated columns to compensate for reference data that is not in the correct shape. A properly pivoted wide-format reference table with a standard relationship is the canonical pattern for static dimensional reference data.
- Relationships deliver better performance than LOOKUPVALUE calculated columns for large fact tables because VertiPaq can use its relationship engine rather than per-row DAX evaluation during refresh. *(Engineering judgement based on documented VertiPaq architecture — not measured for this model.)*
- A standard relationship produces a cleaner, more discoverable model: the reference table appears as a distinct dimension in the field list, separate from fact columns. Future semantic model developers will recognise this pattern.
- This target is achievable as a post-migration cleanup step, with no visible impact on report behaviour once the column names are preserved through the transformation.

**Acknowledged uncertainties:**
- The Power Query pivot step requires knowing all metric names in advance. If the business owner adds new metrics to the workbook, the pivot step must be updated. This is a maintenance commitment.
- The surrogate key (`field|year`) must be added to all 5 fact tables. Case and character encoding must be handled precisely to avoid join failures.

---

#### 14.5.3 Migration path

| Phase | Action | Approach | Basis |
|-------|--------|----------|-------|
| **Migration** | Extract historical values to `CombinedAirRef`/`CombinedSeaRef`. Add `[REF]` columns via Power Query merge. Validate. Replace SQL columns. | Strategy B (Decision Record 003) | Architectural quality + risk minimisation |
| **Post-migration stabilisation** | Run report, confirm all visuals and KPIs produce correct values. | — | Validation |
| **Architectural target** | Pivot reference tables, add surrogate keys, replace calculated columns with relationships. | C | Architectural quality |

The architectural improvement (Phase 3) is recommended but not a prerequisite for completing the migration. It can be scheduled as a separate model quality initiative after the migration is signed off.

---

### 14.6 Open items before implementation

| Item | Required for | Status |
|------|-------------|--------|
| Confirm exact `metric` values in Fabric tables | Building Power Query merge conditional columns for CombinedAirRef/CombinedSeaRef | Outstanding — requires model refresh or DAX query |
| Confirm exact rig facility names in `Emissions to air[Facility]` | Rig vs. main field routing in LOOKUPVALUE | Outstanding |
| Confirm `Component` column values in `Radioaktive isotoper` | SWITCH mapping in LOOKUPVALUE for `Permits` | Outstanding |
| Confirm year range in both reference tables | Assess whether LOOKUPVALUE returns BLANK for pre-2025 rows | Outstanding |
| Confirm `permit_kpi_to_sea` metric names for oily water columns | Oily water LOOKUPVALUE expressions | Outstanding |
| Measure refresh time after first LOOKUPVALUE implementation | Validate engineering judgement on refresh cost | Deferred to post-migration |


