# Migration Plan

**Project:** Project 1 — Environmental KPIs
**Date:** 2026-07-03 (initial) | Revised: 2026-07-03 (reorganized by business concept) | Revised: 2026-07-03 (Strategy B approved)
**Phase:** Phase 4 — Migration
**Status:** Approved — ready for execution

---

## Approach

**Integration method:** Power Query combined reference table with M join (Strategy B — Decision Record 003).

For each business concept unit, the following two-phase pattern applies:

- **Phase A — Add:** A new `[REF]` column is added to the fact table partition using a Power Query merge against the appropriate combined reference query (`CombinedAirRef` or `CombinedSeaRef`). The existing SQL CASE column remains present during this phase. No breaking change.
- **Phase B — Replace:** The SQL CASE column is removed from the SQL SELECT clause in the partition. The `[REF]` column is renamed to the original column name. The column continues to be an imported column.

Each unit must be **fully validated after Phase A before Phase B begins**.

The reference columns remain imported columns throughout. No calculated columns are introduced.

---

## Combined reference queries

Four shared Power Query M queries are created before any unit begins. All four are hidden from the model field list. None of them modify any existing fact table partition.

The architecture separates historical data from combination logic:

| Query | Responsibility | Enable Load |
|---|---|---|
| `HistoricalAirRef` | Owns the historical reference data for air emissions (2019–2025), organised as named metric sub-tables with source comments | False |
| `HistoricalSeaRef` | Owns the historical reference data for sea discharge (2019–2025), same structure | False |
| `CombinedAirRef` | Combines `HistoricalAirRef` + Fabric `AIR_REF`, then pivots to wide format. Contains combination logic only — no raw data. | False |
| `CombinedSeaRef` | Combines `HistoricalSeaRef` + Fabric `SEA_REF`, then pivots to wide format. Contains combination logic only. | False |

Fact table partitions reference only `CombinedAirRef` or `CombinedSeaRef`.

---

### `HistoricalAirRef`

**Purpose:** Stores the historical permit and KPI reference values (2019–2025) as a static M table, extracted from the SQL CASE logic of the `Emissions to air`, `CH4_NMVOC`, and `Kaldvent volum` partitions. The existing partition SQL is read as source material but is never modified.

**Structure:** Named sub-tables per metric, each with a comment identifying the source column and fact table, then combined via `Table.Combine`. Schema: `(metric, field, year, value_permit_kpi)`.

**Example structure:**
```m
let
    // Source: CH4_NMVOC SQL partition — column [Tillatelse CH4] — pre-2026 values
    MainField_CH4_Permit = #table(
        {"metric", "field", "year", "value_permit_kpi"},
        {
            {"MainField CH4 permit", "Ivar Aasen", 2019, 56},
            {"MainField CH4 permit", "Ivar Aasen", 2020, 56},
            {"MainField CH4 permit", "Alvheim",    2019, 315},
            ...
        }
    ),
    // Source: Emissions to air SQL partition — column [KPI CO2 tonn] — pre-2026 values
    CO2_KPI_Year = #table(
        {"metric", "field", "year", "value_permit_kpi"},
        {
            {"CO2 KPI Year", "Alvheim", 2020, 7},
            ...
        }
    ),
    // ... one sub-table per in-scope metric ...
    AllHistorical = Table.Combine({MainField_CH4_Permit, CO2_KPI_Year, ...})
in
    AllHistorical
```

**Coverage:** All 6 fields × years 2019–2025. Rows are included only for (field, year) combinations that had non-null values in the original SQL CASE logic. No rows are created for Yggdrasil.

---

### `HistoricalSeaRef`

**Purpose:** Same pattern as `HistoricalAirRef` for sea discharge metrics. Extracts historical values from the `Oily water` SQL CASE logic and the `Radioaktive isotoper` Power Query if/then/else logic.

**Coverage:** All 6 fields × available years (2019/2020–2025 depending on metric). No rows for Brynhild, Exploration – Historic, or Yggdrasil.

---

### `CombinedAirRef`

Covers all air emission permit and KPI metrics. Responsible for combination and transformation logic only — no raw data.

1. **Tall-format union:** Rows from Fabric `AIR_REF` (2026 data) appended with all rows from `HistoricalAirRef` (2019–2025 data). All rows use schema `(metric, field, year, value_permit_kpi)`.
2. **Wide-format pivot:** The union is pivoted by `metric`, producing one row per `(field, year)` with one column per metric name. This is the lookup surface used by fact table joins.

Coverage: All 6 fields × all years (2019–2026). Yggdrasil returns null for all metrics.

---

### `CombinedSeaRef`

Covers all sea discharge permit and KPI metrics. Same combination + pivot logic as `CombinedAirRef`, combining `HistoricalSeaRef` with Fabric `SEA_REF`.

Coverage: 6 fields × all available years. Brynhild, Exploration – Historic, and Yggdrasil return null.

---

### Retirement path (future)

When Fabric begins providing historical data for all years, retiring the historical branch is a minimal, low-risk operation:

1. `CombinedAirRef` is updated to reference `AIR_REF` directly (which will then cover all years), removing the `Table.Combine({HistoricalAirRef, ...})` step.
2. `HistoricalAirRef` has no other consumers and can be disabled or deleted.
3. `CombinedSeaRef` and `HistoricalSeaRef` follow the same pattern.

No fact table partitions are changed during retirement.

---

### Join folding

The M joins to the combined reference queries **will not fold** to Fabric SQL. The historical branch (`HistoricalAirRef`, `HistoricalSeaRef`) is M-native data, which breaks the fold chain. The SQL measurement query in each fact table partition continues to fold to the Fabric warehouse. The join to the combined reference table executes in the Power Query engine. This is acceptable at the combined reference table size of approximately 950 rows (`CombinedAirRef`) and 300 rows (`CombinedSeaRef`).

---

## Reference tables

| Semantic model name | Fabric schema | Columns |
|---------------------|--------------|---------|
| `dbt_gold_nems_emission fact_nems__permit_kpi_to_air` | `wh_gold_hsseq.dbt_gold_nems_emission.fact_nems__permit_kpi_to_air` | `metric`, `field`, `unit`, `year`, `value_permit_kpi` |
| `dbt_gold_nems_emission fact_nems__permit_kpi_to_sea` | `wh_gold_hsseq.dbt_gold_nems_emission.fact_nems__permit_kpi_to_sea` | `metric`, `field`, `year`, `value_permit_kpi` |

**Shorthand used in this document:**
- `AIR_REF` = `dbt_gold_nems_emission fact_nems__permit_kpi_to_air`
- `SEA_REF` = `dbt_gold_nems_emission fact_nems__permit_kpi_to_sea`

---

## Implementation order

| Unit | Business concept | Tables affected | Reference table | Units preceding |
|------|-----------------|-----------------|-----------------|-----------------|
| Gate 0 | Reference data validation | — | Both | None |
| 1 | CO₂ Emissions | Emissions to air | AIR_REF | Gate 0A |
| 2 | CH4 Emissions (Common and Vented) | CH4_NMVOC | AIR_REF | Gate 0A |
| 3 | nmVOC Emissions | Emissions to air + CH4_NMVOC | AIR_REF | Gate 0A |
| 4 | NOx Emissions | Emissions to air | AIR_REF | Gate 0A + Unit 3 |
| 5 | Flaring | Emissions to air | AIR_REF | Gate 0A |
| 6 | Cold Vent (Kaldvent) | Emissions to air + Kaldvent volum | AIR_REF | Gate 0A |
| 7 | Oily Water / Produced Water | Oily water | SEA_REF | Gate 0B |
| 8 | Radioactive Isotopes | Radioaktive isotoper | SEA_REF | Gate 0B + 0C |

Units 1–6 are independent of each other except where noted. Units 7–8 depend on Gate 0B.

> **Prerequisite before Unit 1:** Create the four preparation queries — `HistoricalAirRef`, `HistoricalSeaRef`, `CombinedAirRef`, and `CombinedSeaRef` — as described in the Combined Reference Queries section above. All four must be present and validated before any unit implementation begins. Creating these queries does not modify any existing fact table partition.

---

## Implementation Notes

These notes apply to all units. They were established during Unit 1 and must be followed for Units 2–8.

### Column naming — temporary Phase A columns

Phase A temporary staging columns must not contain `]` in their names. DAX column references use `[column name]` syntax; `]` inside a column name cannot be escaped and makes the column unreferenceable in DAX validation queries.

**Required pattern for Phase A column names:** `<OriginalName> REF` (without brackets).

Examples: `KPI CO2 tonn REF`, `Tillatelse CH4 REF`, `KPI CH4 REF`.

After Phase B, these REF columns are removed and the original column name is restored.

---

### Proration: which columns require `/12 × [MonthNum]` in Phase A

CombinedAirRef and CombinedSeaRef store **annual** reference values. The legacy SQL partitions use one of two patterns for individual row calculations:

| SQL pattern | Example | Required Phase A transform |
|-------------|---------|---------------------------|
| **Annual constant** — same value for every row in the (field, year) | `Tillatelse CH4`, `Tillatelse NOx`, `Tillatelse flaring` (2025+) | **None.** Use the CombinedAirRef value directly. |
| **Monthly prorated** — SQL computes `annual / 12 × MonthNum` for every row | `KPI CO2 tonn`, `KPI CH4`, `KPI NOx`, `KPI flaring` (2025+), most KPI columns | **Apply proration:** `[_AnnualValue] / 12 * [MonthNum]` |

**Determination rule:** Read the SQL CASE expression for the column being replaced. If the formula includes `/ 12 * [MonthNum]` (or similar monthly scaling), proration is required in Phase A. If the formula returns a flat value (no `MonthNum` multiplication), no proration is needed.

**For pre-2025 rows:** if the SQL stored a constant for that year (not a prorated expression), check whether the constant equals the annual value stored in HistoricalAirRef. If they match, no proration is needed for those rows. If the SQL also prorated pre-2025 rows (as with `KPI CH4`), apply proration for all years.

**Implementation pattern in Phase A M steps:**

```m
// For columns that always prorate (all years):
each [_AnnualValue] / 12 * [MonthNum]

// For columns where only 2025+ is prorated (e.g., KPI CO2 tonn):
each if [YearNum] >= 2025
    then [_AnnualValue] / 12 * [MonthNum]
    else [_AnnualValue]
```

---

### Implementation method — Advanced Editor vs MCP

For fact table partitions with large SQL queries, MCP partition update operations may fail with timeout or payload errors. The confirmed reliable approach is:

1. Update the TMDL file on disk with the complete corrected M expression.
2. Apply the change in Power BI Desktop via **Transform data → Advanced Editor** — copy the full M tail section (from the last original step through `in <final step>`) and replace it.
3. Use **Close & Apply** to commit and refresh.

For each unit, the "Phase A" and "Phase B" sections of this plan should be read as specifying the M code to be applied in the Advanced Editor, not as MCP partition commands.

---

### MCP connection management

Power BI Desktop assigns a new Analysis Services port on every open. The MCP tool retains the last-used connection, which may reference a stale session.

Before running any MCP DAX query or model operation in a new session:
1. Run `connection_operations ListLocalInstances` to find the current PBI Desktop port.
2. If the port differs from the last-used connection, run `connection_operations Connect` with the new connection string, then `SetLastUsed`.

---

### Field name mapping — scope and CH4_NMVOC join reuse

The raw Fabric field name for the Ivar Aasen production field is `PL 001B Ivar Aasen`. `CombinedAirRef` and `CombinedSeaRef` use the mapped short name `Ivar Aasen`. An M-level `_MappedField` translation step is required only when the fact table surfaces the raw Fabric name in its field column.

Inspection of all five fact tables (confirmed 2026-07-07) shows that **`CH4_NMVOC` is the only table that surfaces the raw name**. All other tables remap internally before surfacing the field column:

| Table | Field column surfaced | Mapping mechanism |
|-------|----------------------|-------------------|
| `Emissions to air` | `Ivar Aasen` | SQL CASE in CTE |
| `CH4_NMVOC` | `PL 001B Ivar Aasen` (raw) | None in SQL — fixed in Unit 2 |
| `Kaldvent volum` | `Ivar Aasen` | SQL `REPLACE([field], 'PL 001B Ivar Aasen', 'Ivar Aasen')` |
| `Oily water` | `Ivar Aasen` | SQL CASE in subquery |
| `Radioaktive isotoper` | `Ivar Aasen` | M `Table.ReplaceValue` removes `PL 001B ` prefix |

For Units 4–8, no new `_MappedField` step is needed.

**CH4_NMVOC join reuse (Unit 3 onwards):** The `_MappedField` step, `Table.NestedJoin` call, and `_CombinedAirRef` nested table column are already present in the `CH4_NMVOC` partition from Unit 2. When Unit 3 Phase A adds the `Tillatelse nmVOC REF` and `KPI nmVOC REF` staging columns to `CH4_NMVOC`, the existing `Table.ExpandTableColumn` step is extended to also extract the nmVOC columns from the same `_CombinedAirRef` nested table — no new join is required.

**Important:** For `Emissions to air`, the same join reuse pattern applies to Units 3–6. All metrics extracted from `CombinedAirRef` by `Emissions to air` use the same join on `(Field, YearNum)`. Extend the `Table.ExpandTableColumn` call in each subsequent unit rather than adding a new join.

---

### CH4_NMVOC — vented nmVOC permit is a separate business concept

The `CH4_NMVOC[Tillatelse nmVOC]` column represents the **vented nmVOC permit** (cold vent + common vent). This is a different regulatory permit from the **combustion nmVOC permit** stored in `Emissions to air[Permit nmVOC]`. The two permits have different values for the same field:

| Field | Combustion nmVOC permit (Emissions to air) | Vented nmVOC permit (CH4_NMVOC main facility) |
|-------|-------------------------------------------|-----------------------------------------------|
| Ivar Aasen | 9 | 41 |
| Alvheim | 62 / 162 (main FPSO) | 162 |
| Valhall | 81 (VALHALL PH) | 24 / 27 |
| Skarv | 21.8 (FPSO) | 45 |

`CombinedAirRef` currently stores `Mainfield nmVOC Permit` and `Rig nmVOC Permit` sourced from `Emissions to air`. These values are **not correct** for replacing `CH4_NMVOC[Tillatelse nmVOC]` or `CH4_NMVOC[KPI nmVOC]`.

Before Unit 3 Phase A can be implemented for `CH4_NMVOC`, new metrics must be added to `HistoricalAirRef` and `CombinedAirRef` to represent the vented nmVOC permit. See Unit 3 pre-work.

---

## Gate 0 — Reference data validation

**Prerequisite for all units. Must pass completely before any unit begins.**

The model must be connected and refreshed in Power BI Desktop before running these queries.

### Gate 0A — permit_kpi_to_air

**DAX: Distinct metrics (expect all 20)**
```dax
EVALUATE DISTINCT( AIR_REF[metric] )
```

**DAX: Distinct fields**
```dax
EVALUATE DISTINCT( AIR_REF[field] )
```

**DAX: Year range**
```dax
EVALUATE ROW( "Min", MIN( AIR_REF[year] ), "Max", MAX( AIR_REF[year] ) )
```

**DAX: Spot-check CO₂ KPI Year — Ivar Aasen 2026 (expected: 25 000)**
```dax
EVALUATE
FILTER( AIR_REF,
    AIR_REF[metric] = "CO2 KPI Year"
    && AIR_REF[field] = "Ivar Aasen"
    && AIR_REF[year] = 2026
)
```

### Gate 0B — permit_kpi_to_sea

**DAX: Distinct metrics**
```dax
EVALUATE DISTINCT( SEA_REF[metric] )
```

**DAX: Year range**
```dax
EVALUATE ROW( "Min", MIN( SEA_REF[year] ), "Max", MAX( SEA_REF[year] ) )
```

**DAX: Spot-check Radium 228 — Ivar Aasen 2026 (expected: 20 GBq)**
```dax
EVALUATE
FILTER( SEA_REF,
    SEA_REF[metric] = "Radium 228 Tillatelse"
    && SEA_REF[field] = "Ivar Aasen"
    && SEA_REF[year] = 2026
)
```

### Gate 0C — Component values in Radioaktive isotoper

**DAX: Distinct Component values (required for Unit 8 SWITCH)**
```dax
EVALUATE DISTINCT( 'Radioaktive isotoper'[Component] )
```

### Gate 0D — Rig facility names in Emissions to air

**DAX: Distinct Facility values (required for rig/main routing in Units 3, 4)**
```dax
EVALUATE DISTINCT( 'Emissions to air'[Facility] )
```
Record all values that represent drilling rigs (not production platforms). These are used in the IF conditions in Units 3 and 4.

### Gate 0 pass criteria

| Check | Required result |
|-------|----------------|
| All 20 expected AIR_REF metrics present | Required |
| Fields match legacy model fields | Required |
| AIR_REF year range covers 2025+ | Required |
| CO₂ spot-check returns exactly 1 row, value = 25 000 | Required |
| SEA_REF metrics include Ra228 and oily water metrics | Required |
| SEA_REF year range confirmed | Required |
| Ra228 spot-check returns 1 row, value = 20 | Required |
| Component strings for Ra226, Ra228, 210Pb confirmed | Required for Unit 8 |
| Rig facility names confirmed | Required for Units 3, 4 |

---

## Unit 1 — CO₂ Emissions

### Business concept
The annual CO₂ KPI target per field, used to assess whether CO₂ emissions are on track against the field-level KPI. Currently hardcoded in the `Emissions to air` SQL partition.

### Legacy objects affected

| Table | Column | Current source | Action |
|-------|--------|---------------|--------|
| `Emissions to air` | `KPI CO2 tonn` | SQL CASE statement per field | Replace via Power Query M join from `CombinedAirRef` |

### Fabric reference data used

| AIR_REF metric | Fact table join | Value example |
|---------------|----------------|---------------|
| `CO2 KPI Year` | `Field` + `YearNum` | Ivar Aasen 2026 = 25 000 tonn |

### Measures affected (must produce same result after replacement)

| Measure | Reference to affected column |
|---------|------------------------------|
| `CO2 KPI year` | `MAX('Emissions to air'[KPI CO2 tonn])` |

### Report pages and visuals affected

| Page | Visual ID | Description |
|------|-----------|-------------|
| KPI emissions to air | `824554953bb3a0e0e0cd` | CO₂ KPI card — binds `CO2 KPI year` measure and `KPI CO2 tonn` directly |
| KPI emissions to air | `edd7ee28d7087be799b6` | CO₂ trend chart — binds `KPI CO2 tonn` directly |

### Phase A — Add [REF] column via Power Query

**File:** `new-model/.../tables/Emissions to air.tmdl` (M partition)

In the `Emissions to air` partition, after the SQL step that retrieves measurement data, add a Power Query merge step joining to `CombinedAirRef` on `(Field, YearNum)`. Expand the joined row to add `KPI CO2 tonn [REF]` from the `CO2 KPI Year` column of the wide-format combined reference table.

The existing SQL CASE column `KPI CO2 tonn` remains in the SQL SELECT clause during Phase A.

### Validation queries

**Diff check — expect zero rows with differences for years in reference range:**
```dax
EVALUATE
FILTER(
    SELECTCOLUMNS( 'Emissions to air',
        "Field", [Field], "Year", [YearNum],
        "SQL", [KPI CO2 tonn], "REF", [KPI CO2 tonn [REF]],
        "Diff", [KPI CO2 tonn] - [KPI CO2 tonn [REF]]
    ),
    [SQL] <> BLANK() && [Diff] <> 0
)
```

**Measure validation — compare before and after:**
```dax
EVALUATE ROW( "CO2 KPI year", [CO2 KPI year] )
```

### Phase B — Replace SQL column

1. Remove `KPI CO2 tonn` from the `Emissions to air` SQL SELECT clause and its CTE.
2. In the Power Query partition, rename the M-joined column: `KPI CO2 tonn [REF]` → `KPI CO2 tonn`.

The column remains an imported column sourced from `CombinedAirRef`.

### Rollback

Remove the Power Query merge step and `KPI CO2 tonn [REF]` column from the M partition. Restore `KPI CO2 tonn` to the SQL SELECT clause. No other changes.

### Success criteria

- [ ] Diff check returns zero rows for all years covered by `CombinedAirRef`
- [ ] Null rows documented for Yggdrasil and years outside reference coverage (expected)
- [ ] `CO2 KPI year` measure value unchanged after Phase B
- [ ] Visual `824554953bb3a0e0e0cd` renders CO₂ KPI card correctly
- [ ] Visual `edd7ee28d7087be799b6` renders CO₂ trend chart correctly
- [ ] Model refreshes without errors

---

## Unit 2 — CH4 Emissions (Common and Vented)

### Business concept
Annual CH4 (methane) permit limits and KPI targets for common and vented gas at main field facilities. Tracked in the `CH4_NMVOC` table which measures actual CH4 discharge in tonnes per day per field/facility.

### Legacy objects affected

| Table | Column | Current source | Action |
|-------|--------|---------------|--------|
| `CH4_NMVOC` | `Tillatelse CH4` | SQL CASE per field/year | Replace via Power Query M join from `CombinedAirRef` |
| `CH4_NMVOC` | `KPI CH4` | SQL CASE per field/year | Replace via Power Query M join from `CombinedAirRef` |

### Fabric reference data used

| AIR_REF metric | Fact table join |
|---------------|----------------|
| `MainField CH4 permit` | `field` + `Year` |
| `MainField CH4 KPI` | `field` + `Year` |

### Measures affected

| Measure | Reference |
|---------|-----------|
| `CH4 KPI year` | `MAX(CH4_NMVOC[Tillatelse CH4])` |
| `CH4_year KPI` | `MAX(CH4_NMVOC[KPI CH4])` |

### Report pages and visuals affected

| Page | Visual ID | Description |
|------|-----------|-------------|
| KPI emissions to air | `51b9d8c18279056a0967` | CH4 KPI card — `Tillatelse CH4` + `CH4_year KPI` |
| KPI emissions to air | `ddd3e88e0b5d07876836` | CH4 trend — `Tillatelse CH4` + `KPI CH4` |
| KPI emissions to air before 2025 | `24842c5295dd7a88f9ee` | CH4 KPI card — `Tillatelse CH4` + `CH4 KPI year` |
| KPI emissions to air before 2025 | `9a666c42cf399dc740a2` | CH4 trend — `KPI CH4` + `Tillatelse CH4` |

### Phase A — Add [REF] columns via Power Query

**File:** `new-model/.../tables/CH4_NMVOC.tmdl` (M partition)

In the `CH4_NMVOC` partition, after the SQL step, add a Power Query merge step joining to `CombinedAirRef` on `(field, Year)`. Expand the joined row to add `Tillatelse CH4 [REF]` from the `MainField CH4 permit` column and `KPI CH4 [REF]` from the `MainField CH4 KPI` column of the wide-format combined reference table.

The existing SQL CASE columns `Tillatelse CH4` and `KPI CH4` remain in the SQL SELECT clause during Phase A.

### Validation queries

```dax
EVALUATE
FILTER(
    SELECTCOLUMNS( CH4_NMVOC,
        "field", [field], "Year", [Year],
        "TilCH4_SQL",  [Tillatelse CH4],  "TilCH4_REF",  [Tillatelse CH4 [REF]],
        "KPICH4_SQL",  [KPI CH4],         "KPICH4_REF",  [KPI CH4 [REF]],
        "Diff_Til",    [Tillatelse CH4]  - [Tillatelse CH4 [REF]],
        "Diff_KPI",    [KPI CH4]         - [KPI CH4 [REF]]
    ),
    [TilCH4_SQL] <> BLANK()
    && ( [Diff_Til] <> 0 || [Diff_KPI] <> 0 )
)
```

### Phase B — Replace SQL columns

Remove `Tillatelse CH4` and `KPI CH4` from CH4_NMVOC SQL SELECT clause. Rename the M-joined `[REF]` columns to their original names in the Power Query partition.

### Rollback

Remove the Power Query merge steps and `[REF]` columns from both tables. Restore the SQL CASE columns to the SQL SELECT clauses.

### Success criteria

- [ ] Diff check returns zero rows for all years covered by `CombinedAirRef` or `CombinedSeaRef`
- [ ] `CH4 KPI year` measure value unchanged
- [ ] `CH4_year KPI` measure value unchanged
- [ ] All 4 visuals render correctly on both pages

---

## Unit 3 — nmVOC Emissions

### Business concept
Annual nmVOC (non-methane volatile organic compounds) permit limits and KPI targets. nmVOC is tracked in two separate fact tables representing different emission pathways:
- **Combustion nmVOC** — in `Emissions to air` (from fuel burn, applies to both main field and rigs)
- **Vented nmVOC** — in `CH4_NMVOC` (from cold venting and common venting, main field only)

Both pathway columns map to the same AIR_REF metrics for main fields and, in the case of combustion, to separate rig-specific metrics.

### Legacy objects affected

| Table | Column | Current source | Action |
|-------|--------|---------------|--------|
| `Emissions to air` | `Permit nmVOC` | SQL CASE per field | Replace via Power Query M join from `CombinedAirRef` (rig routing) |
| `Emissions to air` | `KPI nmVOC` | SQL CASE per field | Replace via Power Query M join from `CombinedAirRef` (rig routing) |
| `CH4_NMVOC` | `Tillatelse nmVOC` | SQL CASE per field/facility/year | Replace via Power Query M join from `CombinedAirRef` |
| `CH4_NMVOC` | `KPI nmVOC` | SQL CASE per field/year | Replace via Power Query M join from `CombinedAirRef` |

### Fabric reference data used

| AIR_REF metric | Applies to | Fact table join |
|---------------|-----------|----------------|
| `Mainfield nmVOC Permit` | Main field facility rows | `Field` + `YearNum` (Emissions to air) |
| `Rig nmVOC Permit` | Drilling rig rows | `Field` + `YearNum` (Emissions to air) |
| `Mainfield nmVOC KPI` | Main field facility rows | Same |
| `Rig nmVOC KPI` | Drilling rig rows | Same |
| `Mainfield nmVOC Permit` | CH4_NMVOC | `field` + `Year` |
| `Mainfield nmVOC KPI` | CH4_NMVOC | `field` + `Year` |

> **Note:** The rig facility names used in the IF condition must be confirmed from Gate 0D output.

### Measures affected

| Measure | Reference |
|---------|-----------|
| `nmVOCfuel KPI year` | `MAX('Emissions to air'[Permit nmVOC])` |
| `nmVOC_KPI year` | `MAX('Emissions to air'[KPI nmVOC])` |
| `nmVOC KPI year` | `MAX(CH4_NMVOC[Tillatelse nmVOC])` |
| `nmVOC_cold_KPI year` | `MAX(CH4_NMVOC[KPI nmVOC])` |

### Report pages and visuals affected

| Page | Visual ID | Description | Columns bound |
|------|-----------|-------------|---------------|
| KPI emissions to air | `7b7ba5c40730c60802db` | nmVOC fuel KPI card | `Permit nmVOC` + `nmVOC_KPI year` |
| KPI emissions to air | `d03da09d0250caae2b25` | nmVOC fuel trend | `Permit nmVOC` + `KPI nmVOC` (Emissions to air) |
| KPI emissions to air | `9ec62929aaa8234a5052` | nmVOC cold vent KPI card | `Tillatelse nmVOC` + `nmVOC_cold_KPI year` |
| KPI emissions to air | `12a11a990ec6c7473de4` | nmVOC cold vent trend | `KPI nmVOC` (CH4_NMVOC) + `Tillatelse nmVOC` |
| KPI emissions to air before 2025 | `73ebcfad7da77bdd987f` | nmVOC fuel KPI card | `Permit nmVOC` + `nmVOCfuel KPI year` |
| KPI emissions to air before 2025 | `67716bc619dcbd4f6f05` | nmVOC fuel trend | `KPI nmVOC` + `Permit nmVOC` |
| KPI emissions to air before 2025 | `4b7ab3127d58169ad77e` | nmVOC cold vent KPI card | `Tillatelse nmVOC` + `nmVOC KPI year` |
| KPI emissions to air before 2025 | `f79c404342b51fa2aaf0` | nmVOC cold vent trend | `KPI nmVOC` + `Tillatelse nmVOC` (CH4_NMVOC) |

### Pre-work — CH4_NMVOC vented nmVOC metrics

Before Phase A can be implemented for `CH4_NMVOC`, two new metrics must be added to `HistoricalAirRef` and consequently to `CombinedAirRef`:

| New metric | Covers | Source |
|------------|--------|--------|
| `CH4 NMVOC Vent Permit` | `CH4_NMVOC[Tillatelse nmVOC]` historical values (2019/2020–2025), per field+facility routing | `CH4_NMVOC` SQL CASE for `Tillatelse nmVOC` in `cte_hydro` |
| `CH4 NMVOC Vent KPI` | `CH4_NMVOC[KPI nmVOC]` annual KPI values (2019/2020–2025) | `CH4_NMVOC` SQL CASE for `KPI nmVOC` |

The `CH4_NMVOC` nmVOC permit is facility-granular (e.g., Ivar Aasen main platform = 41; satellite facilities = 9/21). The new metrics must use the same rig/main routing approach as the existing `Mainfield nmVOC Permit` / `Rig nmVOC Permit` metrics.

This pre-work should be designed and approved before Phase A for `CH4_NMVOC` is implemented.

### Phase A — Add [REF] columns via Power Query

**Files:** `Emissions to air.tmdl` and `CH4_NMVOC.tmdl` (M partitions)

**Emissions to air (Sub-unit 3A — ready to implement):**
Extend the existing `#"Expanded Annual"` step (Unit 1) to also extract `Mainfield nmVOC Permit`, `Rig nmVOC Permit`, `Mainfield nmVOC KPI`, `Rig nmVOC KPI` from the same `_CombinedAirRef` nested table. No new join step required. After expanding, add:
- `_IsRig` column: `true` for facilities that are NOT the named main platform facility for their field (Valhall: VALHALL PH / Hod A; Ivar Aasen: Ivar Aasen; Alvheim: Alvheim FPSO; Skarv: Skarv FPSO; Edvard Grieg: Edvard Grieg; Ula: ULA PP)
- `Permit nmVOC REF`: `if [_IsRig] then [_RignmVOCPermit] else [_MFnmVOCPermit]`
- `KPI nmVOC REF`: `if [_IsRig] then [_RignmVOCKPI] / 12 * [MonthNum] else [_MFnmVOCKPI] / 12 * [MonthNum]`
- Remove `_MFnmVOCPermit`, `_RignmVOCPermit`, `_MFnmVOCKPI`, `_RignmVOCKPI`, `_IsRig` in `#"Removed Temp"` step.
The existing SQL CASE columns `Permit nmVOC` and `KPI nmVOC` remain in the SQL SELECT clause during Phase A.

**CH4_NMVOC (Sub-unit 3B — blocked on pre-work):**
Dependent on the `HistoricalAirRef` vented nmVOC metrics being added first (see Pre-work above). Once the new metrics are in `CombinedAirRef`, extend the existing `#"Expanded Annual"` step (Unit 2) to also extract `CH4 NMVOC Vent Permit` and `CH4 NMVOC Vent KPI` from the same `_CombinedAirRef` nested table, with the same facility routing logic. Add `Tillatelse nmVOC REF` and `KPI nmVOC REF` staging columns. The existing SQL CASE columns remain during Phase A.


### Validation queries

**Emissions to air diff check:**
```dax
EVALUATE
FILTER(
    SELECTCOLUMNS( 'Emissions to air',
        "Field", [Field], "Facility", [Facility], "Year", [YearNum],
        "Diff_Permit", [Permit nmVOC]  - [Permit nmVOC [REF]],
        "Diff_KPI",    [KPI nmVOC]     - [KPI nmVOC [REF]]
    ),
    [Permit nmVOC] <> BLANK()
    && ( [Diff_Permit] <> 0 || [Diff_KPI] <> 0 )
)
```

**CH4_NMVOC diff check:**
```dax
EVALUATE
FILTER(
    SELECTCOLUMNS( CH4_NMVOC,
        "field", [field], "Year", [Year],
        "Diff_Til", [Tillatelse nmVOC] - [Tillatelse nmVOC [REF]],
        "Diff_KPI", [KPI nmVOC]        - [KPI nmVOC [REF]]
    ),
    [Tillatelse nmVOC] <> BLANK()
    && ( [Diff_Til] <> 0 || [Diff_KPI] <> 0 )
)
```

### Phase B — Replace SQL columns

Remove all 4 columns from their respective SQL partitions. Rename the M-joined `[REF]` columns to their original names.

### Rollback

Remove all 4 Power Query merge steps and `[REF]` columns from both tables.

### Success criteria

- [ ] Both diff checks return zero rows for years ≥ 2025
- [ ] All 4 nmVOC measures produce unchanged values
- [ ] All 8 visuals render correctly on both pages

---

## Unit 4 — NOx Emissions

### Business concept
Annual NOx (nitrogen oxide) permit limits and KPI targets per field, for both main field production facilities and drilling rigs. Rig-specific NOx permits differ from main field permits and are stored as separate metrics in the reference table.

### Legacy objects affected

| Table | Column | Current source | Action |
|-------|--------|---------------|--------|
| `Emissions to air` | `Tillatelse NOx` | SQL CASE per field/year | Replace via Power Query M join from `CombinedAirRef` (rig routing) |
| `Emissions to air` | `KPI NOx` | SQL CASE per field/year | Replace via Power Query M join from `CombinedAirRef` (rig routing) |

### Fabric reference data used

| AIR_REF metric | Applies to |
|---------------|-----------|
| `Mainfield NOX Permit` | Main field facility rows |
| `Rig NOX Permit` | Drilling rig rows |
| `Mainfield NOX KPI` | Main field facility rows |
| `Rig NOX KPI` | Drilling rig rows |

### Measures affected

| Measure | Reference |
|---------|-----------|
| `NOx KPI year` | `MAX('Emissions to air'[KPI NOx])` + `MAX('Emissions to air'[Tillatelse NOx])` |

### Report pages and visuals affected

| Page | Visual ID | Description |
|------|-----------|-------------|
| KPI emissions to air | `5744dedd70968295b016` | NOx KPI card |
| KPI emissions to air | `c4f3196a573dd0d34aa1` | NOx KPI card (second instance) |
| KPI emissions to air | `10723f52a5750eb14904` | NOx trend chart — `Tillatelse NOx` + `KPI NOx` series |
| KPI emissions to air | `ab22c12a9cae1a96eb7d` | NOx trend chart — `Tillatelse NOx` + `KPI NOx` series |
| KPI emissions to air before 2025 | `1ba9940efe433c2f30c4` | NOx KPI card |
| KPI emissions to air before 2025 | `6d9e9e70c4f36ce2befa` | NOx KPI card |
| KPI emissions to air before 2025 | `d40ce7d6df7eb2a37d18` | NOx trend — `KPI NOx` + `Tillatelse NOx` |
| KPI emissions to air before 2025 | `b3c48b5fc38acf884ad0` | NOx trend — `KPI NOx` + `Tillatelse NOx` |

### Phase A — Add [REF] columns via Power Query

**File:** `Emissions to air.tmdl` (M partition)

After the SQL step, add a conditional column selecting `Rig NOX Permit` for drilling rig facility rows and `Mainfield NOX Permit` for main field rows (confirmed facility list from Gate 0D). Add a Power Query merge joining to `CombinedAirRef` on `(Field, YearNum)` using this conditional metric column. Expand to add `Tillatelse NOx [REF]` and `KPI NOx [REF]`. The existing SQL CASE columns remain during Phase A.

### Validation queries

```dax
EVALUATE
FILTER(
    SELECTCOLUMNS( 'Emissions to air',
        "Field", [Field], "Facility", [Facility], "Year", [YearNum],
        "Diff_Til", [Tillatelse NOx] - [Tillatelse NOx [REF]],
        "Diff_KPI", [KPI NOx]        - [KPI NOx [REF]]
    ),
    [Tillatelse NOx] <> BLANK()
    && ( [Diff_Til] <> 0 || [Diff_KPI] <> 0 )
)
```

```dax
EVALUATE ROW( "NOx KPI year", [NOx KPI year] )
```

### Phase B — Replace SQL columns

Remove `Tillatelse NOx` and `KPI NOx` from SQL partition. Rename the M-joined `[REF]` columns to their original names in the Power Query partition.

### Rollback

Remove the Power Query merge steps and `[REF]` columns from the partition.

### Success criteria

- [ ] Diff check returns zero rows for all years covered by `CombinedAirRef` or `CombinedSeaRef`
- [ ] `NOx KPI year` measure value unchanged
- [ ] All 8 visuals render correctly on both pages

---

## Unit 5 — Flaring

### Business concept
Annual flaring permit limits and KPI targets per field. Flaring applies to main field facilities only. The KPI target currently involves a two-stage computation in SQL (permit × per-field percentage reductions). The workbook provides "Flaring KPI" as a direct value — this unit will determine whether the SQL two-stage derivation is replaced or whether only the permit is replaced.

> **Decision point:** If `AIR_REF[metric] = "Flaring KPI"` returns values that match the current SQL-computed `KPI flaring` column exactly, the full two-stage SQL logic can be retired. If they differ, only `Tillatelse flaring` is replaced in Phase B; `KPI flaring` SQL logic is retained and flagged for a separate review.

### Legacy objects affected

| Table | Column | Current source | Action |
|-------|--------|---------------|--------|
| `Emissions to air` | `Tillatelse flaring` | SQL CASE per field/year/quarter (hidden) | Replace via Power Query M join from `CombinedAirRef` |
| `Emissions to air` | `KPI flaring` | SQL two-stage derivation (hidden) | Replace if values match; retain if they differ |

### Fabric reference data used

| AIR_REF metric | Note |
|---------------|------|
| `Flaring Permit` | Annual field-level permit |
| `Flaring KPI` | Pre-computed annual KPI — replaces two-stage SQL if values match |

### Measures affected

None of the 11 candidate DAX measures reference `Tillatelse flaring` or `KPI flaring` directly. These columns are consumed exclusively by direct visual bindings.

### Report pages and visuals affected

| Page | Visual ID | Description | Columns bound |
|------|-----------|-------------|---------------|
| KPI emissions to air | `2eab323e541360477545` | Flaring visual — binds `Tillatelse flaring` AND `Division` directly | `Tillatelse flaring`, `Division` |
| KPI emissions to air | `52643268d7644abdc5d0` | Flaring trend chart | `Tillatelse flaring` + `KPI flaring` |
| KPI emissions to air before 2025 | `993e8351729d392927aa` | Flaring chart | `Tillatelse flaring` |
| KPI emissions to air before 2025 | `ecd20f287253686f6d00` | Flaring detail — binds `Division` directly | `Tillatelse flaring`, `Division` |

> **Note on `Division`:** Visual `2eab323e541360477545` and `ecd20f287253686f6d00` bind directly to `Emissions to air[Division]` (a derived intermediate value = `Tillatelse flaring / 3`). `Division` is not being replaced by this migration — it is retained as an imported SQL column. If `Tillatelse flaring` changes source (SQL → M-joined imported column), `Division` must still be available as an independent SQL column or be re-derived from the new `Tillatelse flaring [REF]` column. **This dependency must be resolved before Phase B.**

### Phase A — Add [REF] columns via Power Query

**File:** `Emissions to air.tmdl` (M partition)

After the SQL step, add a Power Query merge step joining to `CombinedAirRef` on `(Field, YearNum)`. Expand to add `Tillatelse flaring [REF]` from the `Flaring Permit` column and `KPI flaring [REF]` from the `Flaring KPI` column. No rig/main field routing is required for flaring. The existing SQL CASE columns remain during Phase A.


### Validation queries

```dax
EVALUATE
FILTER(
    SELECTCOLUMNS( 'Emissions to air',
        "Field", [Field], "Year", [YearNum], "QuarterNum", [QuarterNum],
        "Diff_Til",    [Tillatelse flaring] - [Tillatelse flaring [REF]],
        "Diff_KPI",    [KPI flaring]        - [KPI flaring [REF]]
    ),
    [Tillatelse flaring] <> BLANK()
    && ( [Diff_Til] <> 0 || [Diff_KPI] <> 0 )
)
```

If `Diff_KPI` rows exist: record in `validation.md`. Escalate to user for decision before Phase B.

### Phase B — Replace SQL columns

Replace `Tillatelse flaring` SQL column. Replace `KPI flaring` SQL column if validation confirmed match; otherwise retain SQL column and mark `KPI flaring [REF]` as deferred.

Resolve `Division` dependency: if `Division = Tillatelse flaring / 3`, update its SQL expression to continue computing from the correct base value after `Tillatelse flaring` is removed from SQL.

### Rollback

Remove the Power Query merge steps and `[REF]` columns from the partition.

### Success criteria

- [ ] `Tillatelse flaring` diff check returns zero rows for years ≥ 2025
- [ ] `KPI flaring` diff check result documented (match or difference recorded in validation.md)
- [ ] Visuals `2eab323e541360477545` and `ecd20f287253686f6d00` continue to render `Division` correctly
- [ ] All 4 flaring visuals render correctly on both pages

---

## Unit 6 — Cold Vent (Kaldvent)

### Business concept
Annual cold vent gas permit limits and KPI targets. Cold venting is tracked in two tables:
- **`Kaldvent volum`** — the primary cold vent volume fact table, with quarterly and YTD KPI computation
- **`Emissions to air`** — also carries cold vent permit columns used as reference in two visuals

Both tables source from the same "Vented gas permit" and "Vented gas KPI" metrics in the reference table.

> **Decision point:** The current `Kaldvent volum.Tillatelse Kaldvent` contains quarterly values for some field+year combinations. The reference table provides annual values. The diff check will reveal whether the annual reference value matches all quarterly rows for a given field+year, or whether quarterly distribution differs. If quarterly values differ from annual, `KPI Kaldvent QTD` must remain in SQL.

### Legacy objects affected

| Table | Column | Current source | Action |
|-------|--------|---------------|--------|
| `Emissions to air` | `Permit Cold ventilated gas` | SQL CASE (hidden) | Replace via Power Query M join from `CombinedAirRef` |
| `Emissions to air` | `KPI Cold ventilated gas` | SQL CASE (hidden) | Replace via Power Query M join from `CombinedAirRef` |
| `Kaldvent volum` | `Tillatelse Kaldvent` | SQL CASE per field/year/quarter | Replace via Power Query M join from `CombinedAirRef` (subject to quarterly check) |
| `Kaldvent volum` | `KPI Kaldvent QTD` | SQL quarterly derivation | Replace if reference covers quarterly; otherwise retain SQL |

### Fabric reference data used

| AIR_REF metric | Fact table join |
|---------------|----------------|
| `Vented gas permit` | `Field`/`field` + `YearNum`/`Year` |
| `Vented gas KPI` | Same |

### Measures affected

| Measure | Reference |
|---------|-----------|
| `Vented KPI year` | `MAX('Kaldvent volum'[Tillatelse Kaldvent])` |

### Report pages and visuals affected

| Page | Visual ID | Description | Columns bound |
|------|-----------|-------------|---------------|
| KPI emissions to air | `22e4ed31d7e190033ab8` | Cold vent KPI card | `Tillatelse Kaldvent` + `Vented KPI year` |
| KPI emissions to air | `f5b5887b1048bca77d21` | Cold vent trend | `Tillatelse Kaldvent` + `KPI Kaldvent QTD` |
| KPI emissions to air before 2025 | `eaf5796fa941218c62af` | Cold vent KPI card | `Tillatelse Kaldvent` + `Vented KPI year` |
| KPI emissions to air before 2025 | `fe4e4b2b1c5b32074d99` | Cold vent trend | `Tillatelse Kaldvent` + `KPI Kaldvent QTD` |

### Phase A — Add [REF] columns via Power Query

**Files:** `Emissions to air.tmdl` and `Kaldvent volum.tmdl` (M partitions)

**Emissions to air:** After the SQL step, add a Power Query merge step joining to `CombinedAirRef` on `(Field, YearNum)`. Expand to add `Permit Cold ventilated gas [REF]` from `Vented gas permit` and `KPI Cold ventilated gas [REF]` from `Vented gas KPI`. Existing SQL CASE columns remain during Phase A.

**Kaldvent volum:** After the SQL step, add a Power Query merge step joining to `CombinedAirRef` on `(field, Year)`. Expand to add `Tillatelse Kaldvent [REF]` from `Vented gas permit`. Existing SQL CASE columns remain during Phase A.

**Kaldvent volum:**
Power Query merge step joining to `CombinedAirRef` on `(field, Year)`. Expand `Tillatelse Kaldvent [REF]` from `Vented gas permit` column. Existing SQL CASE columns remain during Phase A.

### Validation queries

**Kaldvent volum — quarterly check:**
```dax
EVALUATE
FILTER(
    SELECTCOLUMNS( 'Kaldvent volum',
        "field", [field], "Year", [Year], "Quarter", [Quarter],
        "SQL", [Tillatelse Kaldvent], "REF", [Tillatelse Kaldvent [REF]],
        "Diff", [Tillatelse Kaldvent] - [Tillatelse Kaldvent [REF]]
    ),
    [SQL] <> BLANK() && [Diff] <> 0
)
```

If diff rows exist: review whether differences are quarterly variations or data coverage gaps. Document in `validation.md`. Raise for user decision before Phase B.

```dax
EVALUATE ROW( "Vented KPI year", [Vented KPI year] )
```

### Phase B — Replace SQL columns

Replace `Permit Cold ventilated gas` and `KPI Cold ventilated gas` in `Emissions to air`. Replace `Tillatelse Kaldvent` in `Kaldvent volum` if diff check confirms alignment. Retain `KPI Kaldvent QTD` SQL computation pending quarterly decision.

### Rollback

Remove all Power Query merge steps and `[REF]` columns from the partition.

### Success criteria

- [ ] `Emissions to air` cold vent diff checks return zero rows for years ≥ 2025
- [ ] `Kaldvent volum.Tillatelse Kaldvent` quarterly diff documented and decision recorded
- [ ] `Vented KPI year` measure value unchanged
- [ ] All 4 cold vent visuals render correctly on both pages

---

## Unit 7 — Oily Water / Produced Water Discharge

### Business concept
Permit limits and KPI targets for sea discharge: oil in produced water, drain water, and water reinjection. The `Oily water` fact table tracks both produced water and drain water streams. Reference data for these metrics is expected in `permit_kpi_to_sea`.

> **Dependency:** Gate 0B must confirm the exact metric names for oily water columns in `SEA_REF` before Phase A can begin. The metric names below are placeholders pending Gate 0B confirmation.

### Legacy objects affected

| Table | Column | Current source | Action |
|-------|--------|---------------|--------|
| `Oily water` | `Tillatelser` | SQL CASE per field | Replace via Power Query M join from `CombinedSeaRef` |
| `Oily water` | `KPI Oil to sea` | SQL CASE per field | Replace via Power Query M join from `CombinedSeaRef` |
| `Oily water` | `KPI drain water` | SQL CASE per field | Replace via Power Query M join from `CombinedSeaRef` |
| `Oily water` | `KPI water reinjected` | SQL CASE per field | Replace via Power Query M join from `CombinedSeaRef` |

### Fabric reference data used

| SEA_REF metric | Note |
|---------------|------|
| `<CONFIRM Gate 0B>` | Oil discharge permit |
| `<CONFIRM Gate 0B>` | Oil to sea KPI |
| `<CONFIRM Gate 0B>` | Drain water KPI |
| `<CONFIRM Gate 0B>` | Water reinjection KPI |

> **Field join note:** `Oily water[Asset]` represents the field/asset name. Confirm `Asset` values match `SEA_REF[field]` values in Gate 0B.
> **Year join note:** `Oily water` does not have an explicit Year column. Use `YEAR(Time_Id)` in the M join's merge key.

### Measures affected

| Measure | Reference |
|---------|-----------|
| `KPI reinjected` | `MAX('Oily water'[KPI water reinjected])` |

### Report pages and visuals affected

| Page | Visual ID | Description | Columns bound |
|------|-----------|-------------|---------------|
| KPI discharge to sea | `1a4c7e656a873264543a` | Oil KPI card | `Tillatelser` + `KPI Oil to sea` |
| KPI discharge to sea | `45bf48d0931396c2a937` | Drain water KPI card | `Tillatelser` + `KPI drain water` |
| KPI discharge to sea | `9d46e473d55ed0d5b0ac` | Reinjection KPI | `KPI water reinjected` + `KPI reinjected` measure |
| KPI discharge to sea | `1f7c027708d880880880` | Oil discharge trend | `Tillatelser` + `KPI Oil to sea` |
| KPI discharge to sea | `e2d94a972ee1dc65c6e0` | Discharge trend | `Tillatelser` + `KPI drain water` |
| KPI discharge to sea | `a4c475830aa600509791` | Reinjection trend | `KPI water reinjected` |

### Phase A — Add [REF] columns via Power Query

**File:** `Oily water.tmdl` (M partition)

After the SQL step, add a Power Query merge step joining to `CombinedSeaRef` on `(Asset, YEAR(Time_Id))`. The metric names for each column are confirmed from Gate 0B. Expand to add `Tillatelser [REF]`, `KPI Oil to sea [REF]`, `KPI drain water [REF]`, and `KPI water reinjected [REF]` from the appropriate `CombinedSeaRef` columns. The existing SQL CASE columns remain during Phase A.tmdl
column 'Tillatelser [REF]'
    dataType: double
    summarizeBy: sum
    expression =
        Power Query merge on CombinedSeaRef )
-- Repeat pattern for KPI Oil to sea [REF], KPI drain water [REF], KPI water reinjected [REF]
```

### Validation queries

```dax
EVALUATE
FILTER(
    SELECTCOLUMNS( 'Oily water',
        "Asset", [Asset], "Year", YEAR([Time_Id]),
        "Diff_Til",    [Tillatelser]        - [Tillatelser [REF]],
        "Diff_Oil",    [KPI Oil to sea]     - [KPI Oil to sea [REF]],
        "Diff_Drain",  [KPI drain water]    - [KPI drain water [REF]],
        "Diff_Reinj",  [KPI water reinjected] - [KPI water reinjected [REF]]
    ),
    [Tillatelser] <> BLANK()
    && ( [Diff_Til]<>0 || [Diff_Oil]<>0 || [Diff_Drain]<>0 || [Diff_Reinj]<>0 )
)
```

### Phase B — Replace SQL columns

Remove all 4 SQL CASE columns from `Oily water` partition. Rename the M-joined `[REF]` columns to their original names in the Power Query partition.

### Rollback

Remove all 4 Power Query merge steps and `[REF]` columns from the partition.

### Success criteria

- [ ] Gate 0B confirmed metric names filled into Power Query merge column mappings
- [ ] Diff check returns zero rows for years covered by reference table
- [ ] `KPI reinjected` measure value unchanged
- [ ] All 6 visuals on KPI discharge to sea page render correctly

---

## Unit 8 — Radioactive Isotopes

### Business concept
Annual permit limits and computed KPI targets for radioactive isotope discharge (Ra226, Ra228, and 210Pb) per field. Currently the most complex hardcoded logic in the model — the `Permits` column is computed entirely in Power Query using nested if/then/else conditions per component, field, and year. The `KPIs` column is derived from `Permits` in Power Query.

### Legacy objects affected

| Table | Column | Current source | Action |
|-------|--------|---------------|--------|
| `Radioaktive isotoper` | `Permits` | Power Query nested if/then/else per component/field/year | Replace via Power Query M join from `CombinedSeaRef` with component→metric SWITCH |
| `Radioaktive isotoper` | `KPIs` | Power Query derived from Permits (`(Permits/12) × Måned × factor`) | Replace with DAX expression referencing `Permits [REF]` |

### Fabric reference data used

| SEA_REF metric | Component mapping | Note |
|---------------|-------------------|------|
| `Radium 228 Tillatelse` (confirmed) | Ra228 | Confirmed — Ivar Aasen 2026 = 20 GBq |
| `<CONFIRM Gate 0B>` for Ra226 | Ra226 | Exact metric name to confirm |
| `<CONFIRM Gate 0B>` for 210Pb | 210Pb | Exact metric name to confirm |

> **Component mapping:** The SWITCH expression maps `Radioaktive isotoper[Component]` values (confirmed in Gate 0C) to the corresponding `SEA_REF[metric]` names.

### Measures affected

| Measure | Reference |
|---------|-----------|
| `KPI year` | `MAX('Radioaktive isotoper'[Permits]) × 0.9 or 1` depending on field |

### Report pages and visuals affected

| Page | Visual ID | Description | Columns bound |
|------|-----------|-------------|---------------|
| KPI discharge to sea | `00a40ed8c7930b8db208` | Radioaktive KPI card | `Permits` + `KPI year` |
| KPI discharge to sea | `12b47246e34ce5970560` | Radioaktive KPI card | `Permits` + `KPI year` |
| KPI discharge to sea | `b13542dcd6027da94ed0` | Radioaktive KPI card | `Permits` + `KPI year` |
| KPI discharge to sea | `1a5f1d7d86c00e092033` | Radioaktive trend | `KPIs` (direct) + `Permits` |
| KPI discharge to sea | `8dd4bac256294da0ab3e` | Radioaktive trend | `KPIs` (direct) + `Permits` |
| KPI discharge to sea | `ea909364312e35b18a92` | Radioaktive trend | `KPIs` (direct) + `Permits` |

### Phase A — Add [REF] columns via Power Query

**File:** `Radioaktive isotoper.tmdl` (M partition)

After the SQL step, add a Power Query merge step joining to `CombinedSeaRef` on `(Field, Year)`. Before joining, add a conditional column that maps each `Component` value (`228Ra` → `Radium 228 Tillatelse`, `226Ra` → `Radium 226 Tillatelse`, `210Pb` → `Lead 210 Tillatelse`) to the corresponding metric name using the Component values confirmed in Gate 0C. Expand to add `Permits [REF]` and `KPIs [REF]`. The existing Power Query if/then/else columns remain during Phase A.tmdl
column 'Permits [REF]'
    dataType: double
    formatString: 0.00
    summarizeBy: sum
    expression =
        Power Query merge on CombinedSeaRef
                ),
            SEA_REF[field],  'Radioaktive isotoper'[Field],
            SEA_REF[year],   'Radioaktive isotoper'[Year]
        )

column 'KPIs [REF]'
    dataType: double
    formatString: 0.00
    summarizeBy: sum
    expression =
        DIVIDE( [Permits [REF]], 12 )
            * 'Radioaktive isotoper'[Måned]
            * IF(
                'Radioaktive isotoper'[Field] IN { "Ula", "Valhall" },
                0.9,
                1.0
              )
```

### Validation queries

```dax
EVALUATE
FILTER(
    SELECTCOLUMNS( 'Radioaktive isotoper',
        "Component", [Component], "Field", [Field], "Year", [Year],
        "Diff_Permits", [Permits] - [Permits [REF]],
        "Diff_KPIs",    [KPIs]    - [KPIs [REF]]
    ),
    [Permits] <> BLANK()
    && ( [Diff_Permits] <> 0 || [Diff_KPIs] <> 0 )
)
```

```dax
EVALUATE ROW( "KPI year", [KPI year] )
```

### Phase B — Replace Power Query columns

Remove `Permits` and `KPIs` from the Power Query `if/then/else` logic in the `Radioaktive isotoper` partition. Rename `[REF]` M-joined columns to original names.

### Rollback

Remove the Power Query merge steps and `[REF]` columns from the partition.

### Success criteria

- [ ] Gate 0B and 0C confirmed values filled into SWITCH expression
- [ ] Diff check returns zero rows for years covered by reference table
- [ ] `KPI year` measure value unchanged
- [ ] All 6 visuals on KPI discharge to sea page render correctly

---

## Risks

| Risk | Likelihood | Impact | Unit affected | Note |
|------|-----------|--------|---------------|------|
| Reference table does not cover years before 2025/2026 | Confirmed | Medium | All | BLANK values expected for historical rows; document in validation.md |
| `Kaldvent volum` quarterly values differ from annual reference | Medium | Medium | 6 | Decision required before Phase B of Unit 6 |
| `KPI flaring` Fabric value differs from SQL two-stage derivation | Medium | Medium | 5 | Partial replacement if values differ |
| Exact rig facility names differ from expected list | Low | High | 3, 4 | Confirm in Gate 0D before writing IF conditions |
| Oily water `Asset` column values do not match SEA_REF `field` values | Low | High | 7 | Confirm in Gate 0B |
| `Radioaktive isotoper` Component strings do not match expected values | Low | High | 8 | Confirm in Gate 0C |

---

## Validation standard

All diff checks must be recorded in `migration/validation.md`. The pass standard is:
- **Zero rows** returned where SQL value ≠ BLANK and SQL value ≠ REF value, for years present in the reference table.
- **Null rows** (Yggdrasil and years not yet in the combined reference table) are documented but not treated as failures.

---

## User Approval

| Item | Status |
|------|--------|
| Business concept unit structure | Approved (2026-07-03) |
| Integration approach: Power Query combined reference table with M join (Strategy B) | Approved (2026-07-03) |
| Gate 0 validation criteria | **Passed (2026-07-03)** — see implementation-log.md |
| Two-phase (Add → Validate → Replace) pattern | Approved (2026-07-03) |
| Two-phase (Add → Validate → Replace) pattern | Approved (2026-07-03) |








