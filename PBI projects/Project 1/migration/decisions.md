# Decision Record 001

## Topic

Migration strategy for replacing hardcoded permit and KPI reference data.

## Previous Recommendation

Strategy A — DAX calculated columns using LOOKUPVALUE.

## Reassessment

Following Gate 0 and the analysis of the existing implementation, it was determined that both migration strategies require extraction of the historical reference values.

Given this, Strategy B provides a simpler and more maintainable solution.

## Approved Decision

Use Power Query to:

- Extract the historical reference values into tabular form.
- Combine them with the Fabric reference tables.
- Join the combined reference data into the fact table queries during refresh.

The resulting permit and KPI columns remain imported columns, preserving the current report behaviour while removing hardcoded SQL and M logic.

## Reason

- Preserves existing business behaviour.
- Requires fewer implementation changes.
- Keeps reference data in tabular form.
- Aligns more closely with Microsoft Power BI and Fabric data preparation practices.
- Provides a cleaner path toward future architectural improvements.

## Status

Approved (2026-07-03).

> **Note:** The original recommendation under this decision record was Strategy A — LOOKUPVALUE() calculated columns. That recommendation was superseded following Gate 0, current implementation analysis, and the architectural reassessment documented in Decision Record 003. Strategy B (Power Query combined reference table with M join) was approved in its place. See Decision Record 003 for the full reasoning.

---

# Decision Record 002

## Topic

Historical permit and KPI reference values in reports showing years prior to 2026.

## Context

Gate 0 confirmed that both Fabric reference tables (`permit_kpi_to_air` and `permit_kpi_to_sea`) currently contain data for **2026 only**. The fact tables in the semantic model contain data from:

| Fact table | Data from year |
|-----------|----------------|
| `Emissions to air` | 2019 |
| `CH4_NMVOC` | 2019 |
| `Kaldvent volum` | 2020 |
| `Radioaktive isotoper` | 2021 |
| `Oily water` | est. 2020 |

The legacy implementation uses hardcoded SQL CASE statements that provide permit and KPI reference values for every year going back to 2019. These values are currently displayed in all historical report views.

If the hardcoded SQL columns are replaced with LOOKUPVALUE against the 2026-only Fabric tables (Phase B of each unit), rows for years 2019–2025 will return BLANK for all reference columns. This will affect:

- KPI cards and trend charts on the **KPI emissions to air** page
- KPI cards and trend charts on the **KPI emissions to air before 2025** page
- KPI cards and trend charts on the **KPI discharge to sea** page

## Decision required

Before Phase B of any implementation unit begins, the following question must be answered:

> **For reports showing years prior to 2026, should permit and KPI reference values also reflect those historical years?**

### Option A — Backfill historical years into the Fabric reference tables

`permit_kpi_to_air` and `permit_kpi_to_sea` should be extended to include rows for 2019–2025. The `Input til PowerBI.xlsx` workbook would need to be updated to include historical years and re-ingested into Fabric.

**Effect:** Historical reports display the correct per-year permit and KPI values, as they do today.

**Implication for migration:** Phase B is delayed until backfill is confirmed. All Phase A validation work remains valid and does not need to be repeated.

### Option B — Use 2026 values as a proxy for all historical years

The LOOKUPVALUE expression is wrapped in an `IFERROR` or uses a fixed-year override (`COALESCE`) to return the 2026 value when no historical row exists.

**Effect:** Historical rows display the 2026 permit/KPI value as a proxy. This is factually imprecise for years where different permits applied, but may be acceptable if historical views serve trend comparison rather than compliance verification.

**Implication for migration:** The LOOKUPVALUE expression template in all units must be updated before Phase B begins. The change is contained within each calculated column expression.

### Option C — Historical views no longer require permit and KPI reference values

Pre-2026 data does not need permit or KPI reference lines. Pages showing historical data will display measurements only.

**Effect:** Historical report views lose the KPI target lines and permit reference columns. Post-2026 views are unaffected. The **KPI emissions to air before 2025** page would show measurement trends without reference lines.

**Implication for migration:** Phase B may proceed as currently planned. BLANK values for pre-2026 years are accepted as the intended behaviour.

## Status

**Resolved (2026-07-03) — superseded by Decision Record 003.**

The question of how to handle historical values (2019–2025) was resolved by adopting Strategy B (Power Query combined reference table). Strategy B explicitly extracts the historical reference values from the existing SQL CASE and M if/then/else logic and combines them with the Fabric reference data in a single M query. Because the historical data is included from the start, the Phase B blocker that motivated this decision record no longer applies. All years are covered by the combined reference tables from the moment the M queries are created.

The options A, B, and C listed in this decision record are superseded by the Strategy B implementation described in Decision Record 003.

## Impact on migration plan

| Decision | Effect on Phase B |
|----------|-------------------|
| Option A | Superseded by Strategy B |
| Option B | Superseded by Strategy B |
| Option C | Superseded by Strategy B |

---

## Historical behaviour preservation assessment

**Date:** 2026-07-03
**Status:** Assessment complete — recommendation provided below.

### Confirmed business requirement

Historical reports must continue to display permit and KPI reference values in the same way they do today. BLANK values for pre-2026 years are not acceptable.

### Why a proxy (Option B) is not viable

A query against the live model confirmed that permit and KPI values change substantially year over year. Using the 2026 value as a proxy for all historical years would be factually incorrect:

| Field | Column | 2024 value | 2025 value | 2026 value |
|-------|--------|-----------|-----------|-----------|
| Alvheim | KPI CO2 tonn | 7.6 | 171,000 | 87,000 |
| Edvard Grieg | KPI CO2 tonn | 1.14 | 45,000 | 26,000 |
| Alvheim | Tillatelse NOx | 662 | 662 | 360 |
| Ivar Aasen | Tillatelse NOx | 293 | 293 | 352 |

The differences are material (some values change by orders of magnitude between years). Option B is therefore ruled out as incompatible with the business requirement.

### Key architectural constraint

The historical permit and KPI values for 2019–2025 **already exist** in the current semantic model, embedded as SQL CASE statements in the five fact table partitions. This data is not lost — it is only inaccessible if the SQL columns are removed before an equivalent source is in place.

This means no new data needs to be sourced or recreated. The question is entirely about where the historical values will live after migration.

---

### Strategy evaluations

---

#### Strategy 1 — Backfill the Fabric reference tables with historical data

**How it preserves behaviour:** `permit_kpi_to_air` and `permit_kpi_to_sea` are extended to include rows for 2019–2025. LOOKUPVALUE succeeds for all years. Full parity with current behaviour.

**Requires changes to Fabric data:** Yes — the `Input til PowerBI.xlsx` workbook must be updated to include historical year columns, and the Fabric dbt transformation must be re-run to include those rows in the Fabric tables.

**Advantages:**
- Architecturally cleanest — Fabric becomes the single source of truth for all reference data, all years.
- No additional tables or logic in the semantic model.
- Aligns perfectly with the target architecture (Approach C pivot + relationship from field-mapping.md).
- Once done, the migration proceeds exactly as planned.

**Disadvantages:**
- External dependency — requires Fabric data engineering work before Phase B can begin.
- The business owner must confirm which historical values should apply (the current SQL values, or values from the workbook if it is updated).
- Timeline is unknown.

**Long-term maintainability:** Best. All reference data lives in the Fabric layer. Future permit changes require only a workbook update and Fabric re-ingestion.

**Alignment with migration strategy:** Fully aligned. Phase A proceeds as planned. Phase B is delayed until Fabric is backfilled.

---

#### Strategy 2 — Create a local historical reference table in Power Query

**Description:** Extract the existing SQL CASE values (2019–2025) into a new Power Query table in the semantic model. The table uses the same schema as the Fabric tables (`metric`, `field`, `year`, `value_permit_kpi`) and covers only the historical years. LOOKUPVALUE expressions use `COALESCE` to check the Fabric table first (2026+), then the local historical table (pre-2026).

```dax
KPI CO2 tonn [REF] =
COALESCE(
    LOOKUPVALUE( AIR_REF[value_permit_kpi], ..., AIR_REF[year], [YearNum] ),   -- 2026+ Fabric
    LOOKUPVALUE( HistRef[value_permit_kpi], ..., HistRef[year], [YearNum] )    -- pre-2026 local
)
```

**How it preserves behaviour:** Full historical parity — the local table contains the same values as the current SQL CASE logic, covering every field × year × metric combination.

**Requires changes to Fabric data:** No. Self-contained within the semantic model.

**Advantages:**
- No external dependency — can be implemented immediately.
- Accurate — uses the actual historical values, not proxies.
- Clean separation between Fabric-sourced data (current/future) and statically maintained data (historical).
- The local table is an explicit, inspectable record of historical permits — more discoverable than SQL CASE logic.

**Disadvantages:**
- Adds a new table to the semantic model that must be maintained manually.
- The historical values must be carefully extracted from the SQL CASE statements (effort, but no data is lost).
- If historical permit corrections are needed, the local table must be updated rather than re-ingesting a workbook.
- The COALESCE LOOKUPVALUE pattern adds a small amount of complexity to each calculated column expression.

**Long-term maintainability:** Moderate. The local table is a temporary artefact — once the Fabric tables are backfilled (Strategy 1), the local table and the COALESCE fallback can be retired. In the interim it is maintainable.

**Alignment with migration strategy:** Compatible. The LOOKUPVALUE approach is preserved. The local table is an additional component alongside the Fabric tables.

---

#### Strategy 3 — Modify Phase B: retain SQL for pre-2026 years, use LOOKUPVALUE for 2026+

**Description:** Instead of removing the SQL CASE columns entirely in Phase B, modify the SQL partition to retain the historical calculation for years prior to 2026 only. A new SQL column is introduced per reference value (e.g., `KPI CO2 tonn historical`) that returns the pre-2026 SQL value or NULL for 2026+. The DAX calculated column uses COALESCE to combine Fabric (2026+) with SQL historical (pre-2026).

```sql
-- Modified SQL for Emissions to air partition:
CASE WHEN YearNum < 2026 AND Field = 'Alvheim' THEN 171000  -- 2025
     WHEN YearNum < 2026 AND Field = 'Alvheim' THEN ...      -- 2024, etc.
     ELSE NULL   -- LOOKUPVALUE handles 2026+
END AS [KPI CO2 tonn historical]
```

```dax
KPI CO2 tonn [REF] =
COALESCE(
    LOOKUPVALUE( AIR_REF[value_permit_kpi], ..., AIR_REF[year], [YearNum] ),
    'Emissions to air'[KPI CO2 tonn historical]   -- SQL historical column still present
)
```

**How it preserves behaviour:** Full parity — the SQL historical column retains the pre-2026 values; the Fabric LOOKUPVALUE handles 2026+.

**Requires changes to Fabric data:** No. SQL historical clause is retained in the partition.

**Advantages:**
- No external dependency.
- No new tables in the model.
- Progressive retirement: as the Fabric table is extended year by year, the corresponding year is removed from the SQL CASE clause. Eventually the SQL clause is empty and can be dropped.

**Disadvantages:**
- The SQL partition becomes more complex — it now contains both measurement columns and a conditional historical reference column.
- This partially defeats the purpose of the migration (eliminating hardcoded SQL logic) — the SQL still has hardcoded values, just conditioned on year.
- More difficult to validate: the SQL CASE logic is still present and could diverge from the Fabric data over time.
- Phase B is now per-year rather than a single clean replacement.

**Long-term maintainability:** Weak during the transition. The SQL CASE clause must be maintained until Fabric backfill is complete. Risk of partial maintenance (some years updated in Fabric, some still in SQL).

**Alignment with migration strategy:** Partially aligned. Preserves the migration direction (Fabric as the target) but leaves hardcoded SQL logic in place longer than intended.

---

#### Strategy 4 — COALESCE with existing SQL column during Phase A (transition bridge only)

**Description:** During Phase A, use the existing SQL column as the COALESCE fallback. The `[REF]` calculated column references the existing SQL column:

```dax
KPI CO2 tonn [REF] =
COALESCE(
    LOOKUPVALUE( AIR_REF[value_permit_kpi], ..., AIR_REF[year], [YearNum] ),
    [KPI CO2 tonn]    -- existing SQL column, still present during Phase A
)
```

This is already the natural Phase A expression and provides complete historical coverage at zero cost during validation. However, Phase B (removing the SQL column) removes the fallback — so this strategy alone only defers the problem rather than solving it.

**How it preserves behaviour:** Complete parity during Phase A. Problem reappears at Phase B unless combined with Strategy 1 or 2.

**Requires changes to Fabric data:** No.

**Role in the migration:** This is the correct Phase A implementation for all strategies. It is not an independent solution to the historical gap — it is the natural bridge expression to use while the permanent historical solution is being prepared.

---

### Recommendation

**Mandatory requirement:** Preserve historical report behaviour for all years.

**Recommended approach: Strategy 2 (local historical reference table) as the immediate solution, with Strategy 1 (Fabric backfill) as the long-term target.**

#### Rationale

1. **Strategy 2 is immediately self-sufficient.** It requires no external dependencies, no Fabric data engineering, and no changes to the ingestion pipeline. Implementation can begin now.

2. **The historical data already exists.** The SQL CASE logic contains all the values that need to be in the local table. No data needs to be sourced, estimated, or invented — it must only be extracted and reformatted.

3. **Strategy 2 is compatible with the approved migration architecture.** The LOOKUPVALUE approach is preserved exactly. The COALESCE fallback is a contained addition to each calculated column expression. The rest of the migration plan (Phase A, Phase B, validation pattern) is unchanged.

4. **Strategy 2 produces an explicit, auditable historical record.** The historical permit values are currently invisible inside SQL CASE logic. Extracting them into a named Power Query table makes them visible, inspectable, and version-controlled. This is a quality improvement over the current state.

5. **Strategy 2 enables a clean long-term migration to Strategy 1.** When the Fabric tables are eventually backfilled with historical data, the local table is simply retired and the COALESCE expression simplified to a single LOOKUPVALUE. No other changes are needed.

6. **Strategy 3 (SQL retention) is rejected** because it continues to embed hardcoded values in the SQL partition — the very problem this migration is designed to eliminate. It creates a complex, partially-migrated state that is harder to validate and maintain.

7. **Strategy 1 (Fabric backfill) alone is rejected as an immediate solution** because it has an unknown external timeline. Phase B cannot be scheduled around an external dependency.

#### Implementation impact

Adopting this recommendation requires the following adjustments to the migration plan:

| Change | Detail |
|--------|--------|
| New model object | Add a Power Query table `Historical Reference` (or similar name) covering 2019–2025 for all reference metrics |
| Phase A expression change | All 19 `[REF]` calculated column expressions use `COALESCE(LOOKUPVALUE(AIR_REF/SEA_REF...), LOOKUPVALUE(HistRef...))` |
| Phase B unchanged | Phase B removes the SQL CASE columns as planned — the local historical table (not the SQL column) provides the pre-2026 fallback |
| Validation unchanged | Diff checks are unchanged — the [REF] column must equal the SQL column for all years, which it will via the COALESCE |
| Future cleanup | When Fabric tables are extended to cover historical years, retire the `Historical Reference` table and simplify each calculated column expression |

#### Decision Record 002 resolution

This assessment proposes to close Option B (proxy — rejected as factually incorrect) and proceed with the following:

- **Immediate:** Strategy 2 — local historical reference table
- **Long-term target:** Strategy 1 — Fabric backfill (to be scheduled separately, after migration is complete)

**Phase B is unblocked by this recommendation**, provided the local historical reference table is created and validated before Phase B begins.

---

# Current Implementation Analysis

**Date:** 2026-07-03
**Purpose:** Factual description of how hardcoded permit and KPI reference values currently enter the semantic model. This section does not recommend a migration strategy. It provides the evidence base for future strategy decisions.

---

## Question 1 — Where do the hardcoded permit and KPI values exist?

The values exist in two distinct locations within the semantic model, depending on the table.

### Mechanism A — T-SQL CASE expressions (4 tables)

Applies to: `Emissions to air`, `CH4_NMVOC`, `Kaldvent volum`, `Oily water`

The reference values are computed by SQL CASE expressions embedded directly inside the T-SQL query string that Power Query sends to the Fabric warehouse. The CASE expression is written as part of the SQL SELECT statement and given an alias matching the final column name.

Example from `CH4_NMVOC`:
```sql
CASE
    WHEN [field] = 'PL 001B Ivar Aasen' THEN 56
    WHEN [field] = 'Skarv'              THEN 80
    WHEN ([field] = 'Alvheim' AND YEAR([date]) < 2026) THEN 315
    WHEN ([field] = 'Alvheim' AND YEAR([date]) >= 2026) THEN 200
    ...
END AS [Tillatelse CH4]
```

Example from `Oily water`:
```sql
[Tillatelser] = CASE
    WHEN b.[Field] IN ('Valhall','Skarv') AND b.[Stream Type] = 'Drainage Water'
         AND YEAR(b.[Time_Id]) = 2026 THEN 15
    WHEN b.[Field] IN ('Valhall','Skarv') AND b.[Stream Type] = 'Drainage Water'
         AND YEAR(b.[Time_Id]) <> 2026 THEN 30
    ...
END
```

The CASE expression is evaluated by the Fabric SQL engine during query execution, not by Power Query or DAX.

### Mechanism B — Power Query Table.AddColumn (1 table)

Applies to: `Radioaktive isotoper`

The measurement data is retrieved by a simpler SQL query (no CASE statements in the SQL). After the SQL result is received by Power Query, two `Table.AddColumn` steps add the reference columns using nested if/then/else logic written in M:

```powerquery
#"Egendefinert lagt til" = Table.AddColumn(
    #"Kolonner med nye navn1",
    "Permits",
    each if ([Component] = "226Ra") then
        if ([Field] = "Ivar Aasen" and [Year] < 2021) then (10)
        else if ([Field] = "Ivar Aasen" and [Year] > 2020) then (70)
        else if ([Field] = "Skarv") then (2.676)
        ...
    else if ([Component] = "228Ra") then (...)
    else null
)
```

A second step adds `KPIs` as a derivation of `Permits`:
```powerquery
#"Egendefinert lagt til1" = Table.AddColumn(
    ..., "KPIs",
    each if [Field] = "Ula" or [Field] = "Valhall"
         then ([Permits]/12) * [Måned] * 0.9
         else ([Permits]/12) * [Måned]
)
```

The if/then/else logic is evaluated by the Power Query (M) engine on the client side, not by the Fabric SQL engine.

### What the values are after import

In both mechanisms, the reference values arrive in the semantic model as **regular imported columns**. After the model refreshes:

- The CASE/if-then logic has already been fully evaluated.
- The resulting scalar values are stored in the VertiPaq in-memory store.
- The TMDL column definitions use `sourceColumn: Tillatelse CH4` (etc.), indicating that the column maps to the named SQL result column.
- The columns are indistinguishable from any other imported column — there is no runtime evaluation of the CASE logic at query time.

---

## Question 2 — How do the values enter the semantic model?

### Mechanism A (SQL CASE) — Step by step

```
Step 1  Power Query calls Sql.Database() with a multi-line T-SQL query string.

Step 2  The Fabric warehouse receives and executes the T-SQL.
        The query reads from Fabric fact tables AND computes reference columns:
        — Measurement data: SELECT [co2_emissions_tonnes], [nox_emissions_tonnes] ...
        — Reference data:   SELECT CASE WHEN field='Alvheim' THEN 315 ... END AS [Tillatelse CH4]
        Both are computed in the same query pass over the same rows.

Step 3  The Fabric warehouse returns a flat result set.
        Measurement columns and reference columns appear together in the same row.
        There is no structural distinction between them at this point.

Step 4  Power Query receives the flat result set.
        No further transformation of the reference columns occurs.
        Power Query applies only column type conversions and sorting.

Step 5  Power Query materializes the complete table into VertiPaq.
        All columns — measurement and reference — are stored as imported columns.
        Compression and indexing are applied by VertiPaq equally to all columns.
```

### Mechanism B (Power Query Table.AddColumn) — Step by step

```
Step 1  Power Query calls Sql.Database() with a simpler T-SQL query.
        The SQL reads measurement data only. No CASE expressions.
        Affected table: fact_nems__discharged_produced_water_analysis_radioactive_ctt

Step 2  The Fabric warehouse returns measurement-only rows.

Step 3  Power Query receives the measurement rows.

Step 4  Power Query evaluates Table.AddColumn("Permits", each if [Component]="226Ra" then ...).
        This runs row by row in the Power Query (M) engine on the client machine.
        The if/then/else logic is evaluated entirely in M, not in SQL.

Step 5  Power Query evaluates Table.AddColumn("KPIs", each ([Permits]/12)*[Måned]*...).
        This runs row by row, referencing the Permits column added in Step 4.

Step 6  Power Query materializes the complete table (SQL columns + M-added columns) into VertiPaq.
```

---

## Question 3 — Is there already a tabular structure that could be extended?

**No.** The reference values do not exist as a table anywhere in the current implementation.

| Location | Exists? | Notes |
|----------|---------|-------|
| Separate Fabric table for historical permits | No | The Fabric reference tables (`permit_kpi_to_air`, `permit_kpi_to_sea`) exist but contain only 2026 data |
| Separate Power Query query for reference data | No | There is no M query named "permits" or "reference" in the model |
| Intermediate staging table | No | No staging table or CTE that separates reference values from measurement values before they reach Power Query |
| DAX calculated table | No | All reference values are imported columns, not calculated tables |
| Static M table (hard-coded as rows) | No | The values are computed inline per row, not stored as a pre-defined row set |

The reference values exist only as **scalar computations within partition expressions** — either T-SQL CASE expressions (4 tables) or M if/then/else expressions (1 table). They are computed per fact row at refresh time and have no separate existence before or after that computation.

To create a tabular structure for the reference values, one must explicitly extract them from the CASE/if-then logic and place them into a dedicated table. This is not an extension of an existing structure; it is the creation of a new one.

---

## Question 4 — Data flow diagrams

### Mechanism A — SQL CASE (Emissions to air, CH4_NMVOC, Kaldvent volum, Oily water)

```
Fabric Warehouse  (wh_gold_hsseq)
│
├── fact_nems__hydrocarbon_gas_emissions_ctt   (measurement source)
│
└── T-SQL query  ◄─── embedded as a string inside the Power Query M partition
    │
    ├── SELECT [date], [field], [facility],
    │          [common_and_vented_ch4_kg]/1000        AS [CH4 Emissions (tonne)],
    │          [common_and_vented_nmvoc_kg]/1000       AS [nmVOC Emissions (tonne)],
    │          ...
    │          CASE WHEN [field]='Alvheim' THEN 315    ← HARDCODED VALUE
    │               WHEN [field]='Skarv'  THEN 80     ← HARDCODED VALUE
    │               ...
    │          END                                     AS [Tillatelse CH4],
    │          ...
    │   FROM fact_nems__hydrocarbon_gas_emissions_ctt
    │
    └── Result set  (flat table: measurement + reference columns together)
          │
          ▼
Power Query M partition  (Sql.Database call)
    │
    ├── Receives flat result set
    ├── Applies column type conversions  (no reference column transformation)
    └── Passes complete table to VertiPaq
          │
          ▼
VertiPaq  (in-memory column store)
    │
    ├── CH4 Emissions (tonne)    ← measurement
    ├── nmVOC Emissions (tonne)  ← measurement
    ├── Tillatelse CH4           ← reference value, stored identically to measurement
    ├── Tillatelse nmVOC         ← reference value
    ├── KPI CH4                  ← reference value
    ├── KPI nmVOC                ← reference value
    └── ...
          │
          ▼
DAX Measures  (reference the imported columns)
    │
    └── CH4 KPI year = CALCULATE(MAX(CH4_NMVOC[Tillatelse CH4])*0.9, ...)
          │
          ▼
Report Visuals
    └── KPI card, trend chart (bind to measure or column directly)
```

---

### Mechanism B — Power Query Table.AddColumn (Radioaktive isotoper)

```
Fabric Warehouse  (wh_gold_hsseq)
│
├── fact_nems__discharged_produced_water_analysis_radioactive_ctt
│
└── T-SQL query  (measurement only — no CASE expressions)
    │
    ├── SELECT [date], [component_activity_bq], [field], [component], ...
    │   FROM fact_nems__discharged_produced_water_analysis_radioactive_ctt
    │
    └── Result set  (measurement columns only)
          │
          ▼
Power Query M partition
    │
    ├── Receives measurement-only result
    │
    ├── Table.AddColumn("Permits", each              ← HARDCODED VALUES IN M
    │       if [Component] = "226Ra" then
    │           if [Field] = "Ivar Aasen" and [Year] < 2021 then (10)
    │           else if [Field] = "Ivar Aasen" and [Year] > 2020 then (70)
    │           else if [Field] = "Skarv" then (2.676)
    │           ...
    │       else if [Component] = "228Ra" then (...)
    │       else null
    │   )
    │   ↑ Evaluated row-by-row in the M engine (client side)
    │
    ├── Table.AddColumn("KPIs", each                 ← DERIVED FROM Permits
    │       if [Field] IN {"Ula","Valhall"}
    │       then ([Permits]/12) * [Måned] * 0.9
    │       else ([Permits]/12) * [Måned]
    │   )
    │
    └── Passes complete table to VertiPaq
          │
          ▼
VertiPaq  (in-memory column store)
    │
    ├── Component Activity (Bq)   ← measurement
    ├── Component                 ← measurement
    ├── Field                     ← measurement
    ├── Year                      ← derived from Date
    ├── Permits                   ← reference value added by Power Query
    └── KPIs                      ← derived reference value added by Power Query
          │
          ▼
DAX Measures
    └── KPI year = CALCULATE(MAX('Radioaktive isotoper'[Permits])*0.9, ...)
          │
          ▼
Report Visuals
    └── KPI cards, trend charts
```

---

## Summary of structural findings

| Table | Mechanism | Where logic lives | Engine that evaluates | Tabular structure exists? |
|-------|-----------|------------------|----------------------|--------------------------|
| `Emissions to air` | SQL CASE | T-SQL string inside M partition | Fabric SQL engine (server) | No |
| `CH4_NMVOC` | SQL CASE | T-SQL string inside M partition | Fabric SQL engine (server) | No |
| `Kaldvent volum` | SQL CASE | T-SQL string inside M partition | Fabric SQL engine (server) | No |
| `Oily water` | SQL CASE | T-SQL string inside M partition | Fabric SQL engine (server) | No |
| `Radioaktive isotoper` | M Table.AddColumn | M if/then/else after SQL step | Power Query engine (client) | No |

In all five cases, the reference values have no separate tabular existence. They are computed inline at refresh time from logic that is fully contained within the partition expression. A tabular structure for these values does not currently exist and would need to be created.

The historical values for 2019–2025 that are embedded in the SQL CASE and M if/then/else expressions represent the entire dataset that must be preserved. This dataset exists nowhere else — not in Fabric, not in a separate query, not in the workbook for those years. It exists only as code.

---

# Decision Record 003

## Topic

Migration strategy reassessment: LOOKUPVALUE calculated columns versus Power Query combined reference table.

## Evidence base

This decision uses evidence from all completed phases:

- **Discovery:** 5 fact tables identified as containing hardcoded reference data
- **Dependency Analysis:** 42 visuals with direct column bindings; 11 measures; 5 bookmarks — all requiring column name preservation
- **Mapping Analysis / Gate 0:** Fabric reference tables confirmed (AIR_REF 114 rows, SEA_REF 63 rows; 2026 only; tall format: metric, field, year, value_permit_kpi)
- **Current Implementation Analysis:** Reference values exist only as SQL CASE (4 tables) or M Table.AddColumn if/then/else (1 table); no existing tabular structure
- **Fact table row counts:** Emissions to air 127,918; CH4_NMVOC 189,413; Kaldvent volum 8,873; Oily water 130,250; Radioaktive isotoper 35,811

---

## Strategy definitions

### Strategy A — LOOKUPVALUE calculated columns (current Migration Plan)

Each hardcoded reference column in a fact table is replaced by a DAX calculated column using `LOOKUPVALUE`. A local Power Query table is created from the existing CASE logic to cover historical years (2019–2025). Each calculated column uses `COALESCE` to prefer Fabric data (2026+) and fall back to the local historical table (pre-2026).

```
SQL CASE removed from partition.
DAX calculated column:
  COALESCE(
    LOOKUPVALUE(Fabric_Ref, metric, "...", field, [Field], year, [YearNum]),
    LOOKUPVALUE(Historical_Ref, metric, "...", field, [Field], year, [YearNum])
  )
Column type changes: imported → calculated column.
```

Model additions: 19 calculated column definitions; 1–2 local historical M tables visible in field list.

### Strategy B — Power Query combined reference table with M join

Historical reference values are extracted from the CASE logic into a Power Query M table in tall format (`metric`, `field`, `year`, `value`). This is UNIONed with the Fabric reference data to produce a single combined reference table, then pivoted to wide format. Each fact table partition joins to this combined wide-format table to receive all reference columns as imported columns.

```
SQL CASE removed from partition.
Power Query partition:
  1. Load measurement data from Fabric (SQL — no CASE).
  2. Join to CombinedAirRef[wide] on (field, year).
  3. Expand joined columns → reference values arrive as imported columns.
Column type unchanged: imported → imported.
```

Model additions: 1–2 combined M reference tables (can be hidden from field list). No calculated columns.

---

## Objective comparison

### 1. Semantic model design

| Criterion | Strategy A | Strategy B |
|-----------|-----------|-----------|
| Post-migration column type | Calculated column (DAX) | Imported column (M) |
| Calculated columns added | 19 | 0 |
| New model tables | 1–2 visible historical tables | 1–2 combined tables (can be hidden) |
| Alignment with Power BI best practice | **Weak** — Microsoft guidance recommends against calculated columns when data can be correctly shaped in M | **Strong** — reference values shaped in M at source; no DAX compensation required |
| Alignment with Approach C (long-term target) | Indirect — requires further steps to convert to relationship | **Direct** — combined wide-format M table is structurally equivalent to Approach C's pivoted reference table |

### 2. DAX measures

| Criterion | Strategy A | Strategy B |
|-----------|-----------|-----------|
| Changes to existing 11 DAX measures | None | None |
| New DAX complexity | 19 COALESCE + 2×LOOKUPVALUE expressions to maintain | None |
| Refresh-time DAX cost | Per-row LOOKUPVALUE evaluation across 492,000+ total rows | None — M join pre-computed before VertiPaq storage |

### 3. Report bindings

Both strategies preserve all 42 visual direct column bindings, 11 measure references, and 5 bookmark stored states. Neither requires report changes. The comparison is equivalent on this criterion.

### 4. Relationships

Neither strategy requires new model relationships. Both are equivalent.

### 5. Implementation effort

| Criterion | Strategy A | Strategy B |
|-----------|-----------|-----------|
| Historical value extraction | Required — extract CASE values as M rows | Required — same extraction |
| Distinct model changes | ~43 (19 add + 5 partition + 19 rename) | ~12 (2 combined tables + 5 partition changes + 5 renames) |
| Per-change complexity | Low — DAX LOOKUPVALUE is simple; each column independent | Medium — M join per partition is more involved; affects whole table, not individual columns |
| Phase A / Phase B validation pattern | Retained — per-column, per-unit | Retained — per-table, per-unit |
| Rollback granularity | Per column (fine-grained) | Per table (coarser) |
| Join performance at scale | N/A — LOOKUPVALUE evaluated at query time | Power Query join: 189,413 CH4 rows × small reference (~950 rows) is feasible; Power Query buffers small lookup tables efficiently |

### 6. Maintainability and future migration

| Criterion | Strategy A | Strategy B |
|-----------|-----------|-----------|
| Cleanup when Fabric backfilled | 19 LOOKUPVALUE expressions to update (remove COALESCE); 19 changes | Remove historical rows from combined table; 1 change |
| Steps to reach Approach C (target architecture) | Convert 19 calculated columns to imported + add relationship | Replace M join with model relationship; 1 step per table |
| Code transparency | 19 separate DAX expressions scattered across 5 tables | Logic concentrated in 2 combined M tables |

---

## Recommendation

**The Migration Plan should be revised. Strategy B is recommended.**

### Rationale

**1. Reference column type.** After Strategy A, 19 reference columns change from imported to calculated. This is a permanent regression in model quality. After Strategy B, all columns remain imported — identical to today. Given that both strategies require the same foundational extraction work, there is no reason to accept the type regression.

**2. Fewer total changes.** Strategy B produces 12 distinct model changes against 43 for Strategy A. With 492,000+ total rows across 5 tables, fewer changes reduce compounding risk.

**3. No COALESCE complexity.** The COALESCE of two LOOKUPVALUE calls required in Strategy A is eliminated. Strategy B combines the historical and Fabric data before it reaches the fact table — no per-column fallback logic to maintain.

**4. Direct path to target architecture.** The combined wide-format M reference table is structurally equivalent to Approach C's pivoted dimension. The gap between Strategy B and the final target architecture is one step: replace the M join with a model relationship. From Strategy A the path is longer.

**5. Long-term cleanup.** When Fabric tables are backfilled, Strategy B cleanup is one change (remove historical rows); Strategy A cleanup is 19 changes.

### Where Strategy A remains preferable

- If M debugging expertise is limited. M partition errors affect an entire table; DAX calculated column errors are column-scoped. For teams more comfortable in DAX, the per-column independence of Strategy A reduces risk.
- If per-column rollback granularity is required. Strategy A allows rolling back a single column; Strategy B rollback affects the entire partition.

---

## Revised migration — high-level description

If this decision is approved, the following changes are made to the Migration Plan. The business concept unit structure, Gate 0, and Phase A/Phase B validation pattern are all **retained**. Only the implementation pattern changes.

### New foundational objects (before Unit 1)

**`CombinedAirRef`** — Power Query M query, hidden from field list.

Structure: tall format (`metric`, `field`, `year`, `value_permit_kpi`), then pivoted to wide format (`field`, `year`, `CO2 KPI Year`, `Mainfield NOX Permit`, `Flaring Permit`, …).

Sources:
- Rows from Fabric `permit_kpi_to_air` (2026 data — already imported)
- Rows extracted from the current SQL CASE logic of Emissions to air, CH4_NMVOC, Kaldvent volum partitions (2019–2025 data)

**`CombinedSeaRef`** — Power Query M query, hidden from field list.

Same structure, sourcing from Fabric `permit_kpi_to_sea` (2026) and extracted Oily water SQL CASE and Radioaktive isotoper M if/then/else logic (2019–2025).

### Revised per-unit pattern

**Phase A — Add [REF] columns (no breaking change)**

In the affected fact table's M partition:
1. Keep all existing SQL CASE columns in the SQL query unchanged.
2. Add a Power Query merge step: join to `CombinedAirRef` or `CombinedSeaRef` on (`field`, `year`).
3. Expand the joined columns with `[REF]` suffix.

The `[REF]` columns co-exist with the SQL CASE columns during validation.

**Validate** — same DAX diff queries as currently planned.

**Phase B — Replace**
1. Remove SQL CASE column aliases from the SQL SELECT clause.
2. Remove `[REF]` suffix from M-joined columns.
3. Reference columns are now M-joined imported columns.

### What is unchanged

| Element | Status |
|---------|--------|
| Gate 0 (all 4 checks) | Retained unchanged |
| Business concept units 1–8 | Retained: same concepts, same order, same dependencies |
| Validation DAX diff queries | Retained unchanged |
| Column names in the model | Unchanged |
| DAX measures, report bindings, bookmarks | Unchanged |
| Phase A / Phase B safety pattern | Retained |

| Element | Status |
|---------|--------|
| Decision Record 001 (LOOKUPVALUE approach) | **Superseded** by this decision |
| Migration Plan implementation pattern section | **Revised — see migration-plan.md** |

## Status

**Approved (2026-07-03).**

Strategy B replaces the previously proposed LOOKUPVALUE approach (Decision Record 001). The Migration Plan has been revised accordingly. Historical reference values (2019–2025) will be extracted from the existing SQL CASE and M if/then/else logic and combined with the Fabric reference data before being joined to each fact table partition. The reference columns will remain imported columns throughout.

---

## Implementation Refinement — Four-query architecture

**Date:** 2026-07-06
**Status:** Approved — incorporated into migration-plan.md

### Decision

Before implementation began, the preparation step was refined from a two-query architecture to a four-query architecture. This refinement does not change the approved migration strategy, the implementation order, the business behaviour of the semantic model, or the Phase A / Phase B validation pattern. It is a structural improvement to the implementation of Strategy B.

### Original design (two queries)

The original plan described two queries: `CombinedAirRef` and `CombinedSeaRef`. Each would contain both the historical M table literal and the combination logic (union + pivot) in a single query.

### Revised design (four queries)

The approved architecture separates historical data from combination logic:

| Query | Responsibility | Enable Load |
|---|---|---|
| `HistoricalAirRef` | Owns the historical reference data for air emissions (2019–2025) as static M table literals, organised into named metric sub-tables with source comments. No combination logic. | False |
| `HistoricalSeaRef` | Same pattern for sea discharge metrics. | False |
| `CombinedAirRef` | Owns the combination and pivot logic only — no raw data. Unions `HistoricalAirRef` with Fabric `AIR_REF` and pivots to wide format. | False |
| `CombinedSeaRef` | Same pattern for sea discharge. Unions `HistoricalSeaRef` with Fabric `SEA_REF` and pivots to wide format. | False |

Fact table partitions continue to reference only `CombinedAirRef` or `CombinedSeaRef`.

### Reasons for adopting the four-query architecture

**1. Separation of responsibilities.** Each query has a single, unambiguous purpose. `HistoricalAirRef` is a data file; `CombinedAirRef` is a transformation. Embedding both concerns in one query conflates data ownership with combination logic.

**2. Maintainability.** A correction to a historical value requires editing only `HistoricalAirRef`. `CombinedAirRef` is untouched. A change to the combination logic requires editing only `CombinedAirRef`. `HistoricalAirRef` is untouched. Changes are always isolated to the query whose single concern is affected. With the embedded approach, both types of change require editing the same large query.

**3. Independent validation.** `HistoricalAirRef` can be validated independently in the Power Query editor — row counts, field coverage, and year ranges can be confirmed at the data layer before the combination logic is applied. `CombinedAirRef` can then be validated separately for the pivot output. The two-level validation is an improvement over the embedded approach, where data correctness and transformation correctness cannot be independently verified.

**4. Simplified retirement once Fabric contains historical years.** When Fabric begins providing historical data for all years, the retirement path is a minimal, low-risk operation: `CombinedAirRef` is updated to reference `AIR_REF` directly (which will then cover all years), removing the `Table.Combine` step. `HistoricalAirRef` has no other consumers and is then disabled or deleted. `CombinedSeaRef` and `HistoricalSeaRef` follow the same pattern. No fact table partitions are changed during retirement. With the embedded approach, retirement requires editing a large query to surgically remove table literal blocks while preserving the pivot logic — a higher-risk operation.

### Confirmation of scope

This refinement is an implementation detail only. The following remain unchanged:
- The approved migration strategy (Strategy B — Power Query combined reference table with M join)
- The implementation order (Preparation → Units 1–8)
- The Phase A / Phase B validation pattern
- The diff-check validation approach
- The business behaviour of the semantic model — column names, data types, report bindings, and measures are unaffected

---

## Technical Architecture Note — Power Query implementation (conceptual)

This note answers the five questions raised before approving Decision Record 003. No implementation code is provided. The objective is to establish conceptual clarity about the proposed architecture.

---

### 1. How the combined reference data will be represented

The combined reference data will be represented as two shared Power Query queries within the semantic model — one for air emissions (`CombinedAirRef`) and one for sea discharge (`CombinedSeaRef`). These queries are constructed in two steps.

**Step 1 — Tall-format union**

The combined reference query assembles all reference values into a single tall-format table with four columns: `metric`, `field`, `year`, `value_permit_kpi`.

It has two source branches:

- **Fabric branch:** Reads rows from the existing Fabric reference table (`permit_kpi_to_air` or `permit_kpi_to_sea`), which already uses this schema and covers 2026.
- **Historical branch:** Contains the same four columns, but rows are defined within M itself by extracting the values that are currently written as SQL CASE conditions and Power Query if/then/else expressions. These rows cover 2019–2025. The data is the same data — only the storage format changes from code to rows.

The two branches are appended (UNIONed) to produce a single table covering all available years.

**Step 2 — Wide-format pivot**

The tall-format union is pivoted by metric name. The result has one row per (`field`, `year`) combination and one column per metric. This is the lookup key used by the fact table joins.

Conceptually:

```
Before pivot (tall):
metric                | field   | year | value_permit_kpi
MainField NOX Permit  | Alvheim | 2019 | 662
Flaring Permit        | Alvheim | 2019 | 1800000
MainField NOX Permit  | Alvheim | 2026 | 360
Flaring Permit        | Alvheim | 2026 | 2246000

After pivot (wide):
field   | year | MainField NOX Permit | Flaring Permit | CO2 KPI Year | …
Alvheim | 2019 | 662                  | 1800000        | (blank)      | …
Alvheim | 2026 | 360                  | 2246000        | 87000        | …
```

This wide-format table is the reference table used by the fact table joins. It is a small table (~12 rows per metric group × 6 fields × 8 years ≈ a few hundred rows). It is not loaded into the model as a visible table; it exists as an internal shared query referenced by the fact table partitions.

---

### 2. How the reference data will be joined to each fact table

Each fact table partition currently sends a SQL query to Fabric that returns both measurement data and inline CASE-computed reference values in the same result set. Under the revised approach:

**The SQL query is simplified.** It returns measurement data only. All CASE expressions and their aliases are removed from the SQL SELECT clause. The SQL result contains only the columns that come from the Fabric source tables.

**A Power Query merge step is added after the SQL step.** The measurement table is joined to the wide-format combined reference table using `Table.NestedJoin` on the keys `field` and `year`. This is a left outer join — every measurement row finds its reference row, or returns null if no reference data exists for that field+year combination (which covers Yggdrasil and years outside the reference range).

**The joined columns are expanded.** The reference columns are expanded from the nested join result into individual flat columns with the same names as before. The partition ends with the same column set it had before the migration.

Conceptually:

```
Measurement data (from SQL, no CASE):
field   | year | CH4 Emissions | …

                    ↓  join on (field, year)

CombinedAirRef (wide, from M):
field   | year | Tillatelse CH4 | KPI CH4 | Tillatelse nmVOC | …

                    ↓

Result (flat, after expand):
field | year | CH4 Emissions | Tillatelse CH4 | KPI CH4 | Tillatelse nmVOC | …
```

For tables with rig/main field routing (`Emissions to air`, `CH4_NMVOC`), the metric columns in the wide-format reference table capture both `Mainfield NOX Permit` and `Rig NOX Permit` as separate columns. An additional step conditionally selects the appropriate value based on facility type — producing a single `Tillatelse NOx` column from the two metric columns using a conditional expression.

---

### 3. Whether the joins are expected to fold

**The joins will not fold.** This is a known and deliberate trade-off.

Query folding means that Power Query translates M operations back into SQL and submits them to the source database for execution. For the joins to fold, both sides of the join would need to be foldable SQL sources from the same connection context.

The historical branch of the combined reference table is M-native data — defined as rows within M itself, not sourced from a database. M-native tables break the fold chain. As soon as M-native data participates in a join, Power Query cannot translate that join into SQL.

**The practical consequence:** The SQL measurement query continues to fold to the Fabric warehouse (measurement data is fetched efficiently in one server-side pass). After Power Query receives the measurement data, the join to the combined reference table executes in the Power Query engine on the client machine.

**Why this is acceptable:**
The combined reference table is a small lookup table — approximately 950 rows covering 20 metrics × 6 fields × 8 years, with some entries absent. Power Query is designed to handle small lookup tables efficiently. For a 950-row reference table joined against 190,000 measurement rows, the join completes in seconds rather than minutes. The reference table is read once and buffered in memory for all join operations in that refresh session.

This is materially different from folding a 190,000-row join entirely on the server. The measurement retrieval (the expensive part) still folds. The reference join (the small part) executes locally. This is the same pattern used throughout the model today for Power Query transformations.

**The unfolded join is preferable to the alternative.** If the historical data were not present (i.e., if only the Fabric table were used), the join could fold to the Fabric warehouse. The historical data makes complete folding impossible under this strategy. The alternative — not extracting historical data and accepting BLANK values for pre-2026 years — would be worse for the business.

---

### 4. Whether the reference columns will remain imported columns after refresh

**Yes. The reference columns will be imported columns after refresh, identical in type and behaviour to all other imported columns in the model.**

The distinction between how a column was produced (SQL, M join, M conditional expression) does not affect how VertiPaq stores it. When Power Query completes its execution — including the client-side M joins — it passes a single flat table to VertiPaq. VertiPaq receives this table and imports all columns using its standard columnar compression and indexing mechanisms. The origin of each value is not recorded.

This is materially different from DAX calculated columns (Strategy A), which are stored with a DAX expression attached. Calculated columns are re-evaluated on every model refresh, consuming DAX engine resources. Imported columns from Power Query are static — they have no expression attached after import; they are values, not formulas.

After a model refresh under Strategy B:
- A visual binding to `Tillatelse CH4` reads from an imported column in VertiPaq — the same as reading any other column.
- A DAX measure referencing `Tillatelse CH4` accesses an imported column — no difference from the current implementation.
- There is no ongoing computational cost for these columns at query time.

The column type remains consistent with the current model — and this is the property that aligns with the business requirement to preserve current report behaviour.

---

### 5. Why this approach aligns with Microsoft Power BI and Fabric modeling guidance

The proposed architecture respects the division of responsibilities that Microsoft defines for the Power BI and Fabric stack.

**The M layer is the designated data shaping layer.** Microsoft's Power BI guidance documentation explicitly states that data shaping should be performed in Power Query (M) wherever possible, rather than in DAX. The rationale is that M transformations run once at refresh time and their results are stored as static imported values. DAX expressions run at query time (or at the end of each refresh for calculated columns) and represent ongoing computational overhead.

Joining a reference table to a fact table during import is precisely the kind of operation Power Query is designed for. It is equivalent in concept to joining a dimension table to a fact table in the source SQL — the standard relational pattern for introducing reference data.

**Calculated columns on fact tables are explicitly discouraged.** Microsoft's performance guidance for Power BI semantic models states that calculated columns should be avoided when the same result can be achieved by importing correctly shaped data. Large fact tables with calculated columns consume significantly more memory than equivalent imported columns, because calculated column values are stored separately from the base imported data, with less compression efficiency.

Strategy B eliminates 19 calculated columns on large fact tables. This is a direct application of the guidance.

**The model layer is reserved for analytical computation.** The DAX engine is optimized for aggregation, filtering, and time intelligence — the analytical operations users perform via visuals and measures. Using DAX calculated columns to retrieve static reference values per row is a misapplication of the DAX layer. Power Query is the correct layer for this work.

**The architecture mirrors the Fabric data platform model.** In the Fabric data platform, the standard pattern for combining historical reference data with current operational data is to perform the combination in the transformation layer (dataflows, pipelines, or dbt models) before the data reaches the semantic layer. The M partition in a Power BI semantic model is the semantic layer's equivalent of that transformation layer. Strategy B places the combination in the correct layer.

**The path to the long-term target architecture is direct.** Microsoft's documented best practice for static reference data in a Power BI model is a separate imported reference table connected to fact tables via a model relationship (star schema). Strategy B produces a structure that is one step away from this pattern: the combined reference table, currently joined in M, becomes a visible model table connected via a relationship when the Fabric tables are backfilled and the historical branch is retired. No column type changes, no measure rewrites, and no report changes are needed for that final step.

---

# Decision Record 002

## Topic

Historical permit and KPI reference values in reports showing years prior to 2026.

## Context

Gate 0 confirmed that both Fabric reference tables (`permit_kpi_to_air` and `permit_kpi_to_sea`) currently contain data for **2026 only**. The fact tables in the semantic model contain data from:

| Fact table | Data from year |
|-----------|----------------|
| `Emissions to air` | 2019 |
| `CH4_NMVOC` | 2019 |
| `Kaldvent volum` | 2020 |
| `Radioaktive isotoper` | 2021 |
| `Oily water` | est. 2020 |

The legacy implementation uses hardcoded SQL CASE statements that provide permit and KPI reference values for every year going back to at least 2019. These values are currently displayed in all historical report views.

If the hardcoded SQL columns are replaced with LOOKUPVALUE against the 2026-only Fabric tables (Phase B of each unit), rows for years 2019–2025 will return BLANK for all reference columns. This will affect:

- KPI cards and trend charts on **KPI emissions to air** and **KPI emissions to air before 2025** pages
- KPI cards and trend charts on **KPI discharge to sea** page
- Any visual that displays a permit limit or KPI target line for historical years

## Decision required

Before Phase B of any implementation unit begins, the following question must be answered:

> **For reports showing years prior to 2026, should permit and KPI reference values also reflect those historical years?**

The three possible business behaviours are:

### Option A — Backfill historical years into the Fabric reference tables

The Fabric tables (`permit_kpi_to_air`, `permit_kpi_to_sea`) should be extended to include rows for 2019–2025 with the correct permit and KPI values for each year. The `Input til PowerBI.xlsx` workbook would need to be updated to include those years and re-ingested into Fabric.

**Effect:** Historical reports display the correct per-year permit and KPI reference values, as they do today.

**Implication:** The Fabric tables must be populated with historical data before Phase B begins. This is a prerequisite for Phase B, not an action taken by this migration.

### Option B — Use 2026 values for all historical years (static lookup)

The LOOKUPVALUE expression is modified to fall back to year 2026 when no row exists for the requested year (using `COALESCE` or a `LOOKUPVALUE` with `IFERROR` wrapper).

**Effect:** Historical rows display the 2026 permit/KPI value as a proxy. This is factually incorrect for years where different permits applied but may be acceptable if the business purpose of historical views is trend comparison rather than compliance verification.

**Implication:** Calculated column expressions must be modified to implement the fallback. This is a deliberate business choice, not a data quality issue.

### Option C — Historical views no longer require permit and KPI reference values

The business has decided that pre-2026 data does not need permit or KPI reference lines. Pages showing historical data will display measurements only, without reference values.

**Effect:** Historical report views lose the KPI target lines and permit reference columns. Post-2026 views are unaffected.

**Implication:** Phase B may proceed as planned. BLANK values for pre-2026 years are accepted. The **KPI emissions to air before 2025** page would no longer show permit/KPI reference visuals for historical years.

## Status

**Open — pending business owner decision.**

Phase B of all implementation units is **blocked** until this decision is confirmed.

Phase A (adding `[REF]` calculated columns alongside existing SQL columns) is **not blocked** and may proceed. Phase A introduces no breaking change.

## Impact on migration plan

- If **Option A**: Phase B is delayed until Fabric tables are backfilled. All Phase A validation work remains valid.
- If **Option B**: The LOOKUPVALUE expression template in all units must be updated to use a year fallback before Phase B begins.
- If **Option C**: Phase B may proceed as currently planned. Gate 0 Observation 0A-5 is resolved.

---

# Decision Record 004

## Topic

Classification of the `CH4_NMVOC` combustion branch `Tillatelse CH4 = 56` as a legacy implementation defect.

## Date

2026-07-07

## Context

Unit 2 Phase A validation revealed that the `CH4_NMVOC` partition contains two source branches — a hydro branch and a combustion branch — that apply different `Tillatelse CH4` values to the same fields and facilities:

- **Hydro branch** (`fact_nems__hydrocarbon_gas_emissions_ctt`): field-specific permits from a SQL CASE expression — correctly 20 (Valhall pre-2025), 49 (Valhall 2025+), 56 (Ivar Aasen), 80 (Skarv), etc.
- **Combustion branch** (`fact_nems__environment_kpi_combustion_ctt`): `CAST(56 AS int) AS [Tillatelse CH4]` — a hardcoded constant applied to ALL records regardless of field.

Because `CH4 KPI year = MAX(Tillatelse CH4)` and 56 > 20, the combustion branch currently inflates the reported CH4 KPI for Valhall (and potentially other fields where 56 > the correct field permit).

## Assessment

### Permit values confirmed

Business documentation confirms:
- Ivar Aasen CH4 permit = **56 t/year** (effective January 2020)
- Valhall CH4 permit = **49 t/year** from 2025 (prior years: 20 t/year)

The value 56 is exclusively the Ivar Aasen permit. It is not a shared licence-level permit applicable to Valhall.

### Data model analysis

Data model inspection confirmed that the combustion source table is **field-granular** — it contains records attributed to facilities at specific fields, not licence-wide records:

| field | facility | Rows with Tillatelse CH4 = 56 |
|-------|----------|-------------------------------|
| PL 001B Ivar Aasen | Ivar Aasen | 21,389 |
| Valhall | VALHALL PH | 4,631 |
| Valhall | Noble Integrator, Noble Invincible, Island Patriot, others | 2,272 |
| Alvheim | Alvheim FPSO | 11,565 |
| Skarv | Skarv FPSO, others | 17,414 |
| Ula | ULA PP, others | 14,673 |
| Edvard Grieg | Edvard Grieg, others | 12,640 |

`VALHALL PH` is the Valhall production platform. It appears in **both** the hydro branch (with correct permit 20/49) and the combustion branch (with incorrect permit 56). The facility is the same physical asset, subject to the same permit authority. The hydro branch applies the correct Valhall permit; the combustion branch does not.

### Why a licence-based interpretation is not supported

A licence-based interpretation would require that all combustion records belong to the Ivar Aasen licence regardless of the `field` column. This is contradicted by:
1. The presence of `VALHALL PH` and Valhall drilling rigs (Noble Integrator, Noble Invincible, Island Patriot) in the combustion table — these are Valhall-specific infrastructure.
2. The fact that the source SQL itself applies a `REPLACE([field], 'PL 001B Ivar Aasen', 'Ivar Aasen')` transformation in the combustion branch loc_key — confirming the developer intended field-granular attribution.
3. The combustion table contains data for all six in-scope fields plus dozens of exploration wells — clearly not limited to a single licence.

### Root cause

The combustion CTE developer hardcoded `CAST(56 AS int)` for `Tillatelse CH4` — the value that is correct for Ivar Aasen records — without implementing field-specific logic equivalent to the hydro branch's SQL CASE expression. This is a coding omission.

## Decision

**The combustion branch `Tillatelse CH4 = 56` for non-Ivar Aasen fields is a legacy implementation defect.** It is not an intentional business rule.

## Resolution

The migration corrects this defect by replacing the SQL-derived `Tillatelse CH4` column with the authoritative field-specific value from `CombinedAirRef`. After Phase B of Unit 2, all CH4_NMVOC rows — whether from the hydro or combustion branch — will receive the correct field-specific permit from `CombinedAirRef`, which matches the hydro branch CASE logic and is consistent with the confirmed permit documentation.

## Business impact

The correction changes the reported CH4 KPI for **Valhall only** (the only field where the combustion 56 > the correct hydro permit):

| Measure | Year range | Current value | Corrected value |
|---------|-----------|--------------|----------------|
| `CH4_year KPI` for Valhall | 2021–2024 | 56 | 20 |
| `CH4_year KPI` for Valhall | 2025–2026 | 56 | 44.1 |

All other in-scope fields are unaffected (their hydro permits are higher than 56, so MAX is already the correct hydro value).

**This is an intentional business correction, not a migration regression.** The change aligns the reported Valhall CH4 KPI with the confirmed permit value (Valhall = 20/49 t/year) and eliminates the incorrect Ivar Aasen value (56 t/year) from Valhall-attributed rows.

---

# Decision Record 005

## Topic

Architectural principle for regulatory category separation in `HistoricalAirRef`, and metric count decision for Sub-unit 3B (`CH4_NMVOC` vented nmVOC).

## Date

2026-07-07

## Context

Unit 3 analysis established that `CombinedAirRef` already contains `Mainfield nmVOC Permit`, `Rig nmVOC Permit`, `Mainfield nmVOC KPI`, and `Rig nmVOC KPI`. These four metrics were sourced from `Emissions to air` SQL and represent the **combustion nmVOC permit** — the regulatory limit for nmVOC produced by fuel combustion.

`CH4_NMVOC[Tillatelse nmVOC]` and `CH4_NMVOC[KPI nmVOC]` represent the **vented nmVOC permit** — the regulatory limit for nmVOC released during crude oil handling (cold venting, storage, loading). This is a separate regulatory category governed by a different permit, issued under a different legal instrument, covering a different physical emission pathway.

The numerical values confirm non-interchangeability — they are not derivable from each other by any arithmetic or routing transformation:

| Field | Combustion nmVOC permit (Emissions to air) | Vented nmVOC permit (CH4_NMVOC main facility) |
|-------|-------------------------------------------|-----------------------------------------------|
| Ivar Aasen | 9 | 41 |
| Valhall | 81 | 24 / 27 |
| Skarv FPSO | 21.8 | 45 |
| Alvheim | 62 / 162 | 162 |
| Edvard Grieg | 127 | 127 |
| Ula | 195 | 60 / 139 |

The direction of difference is not consistent; no constant factor exists; for Valhall the combustion permit (81) exceeds the vented permit (24/27), while for Ivar Aasen the combustion permit (9) is far below the vented permit (41). Reusing the existing metrics for `CH4_NMVOC` would cause compliance reporting against the wrong regulatory limit.

## Architectural principle established

> **When the same physical quantity (e.g., nmVOC) is regulated under different frameworks that produce different permit values for the same field, those frameworks must be stored as separate named metrics in `HistoricalAirRef`. Metric names must uniquely identify both the substance and its regulatory category. Reference data must not be shared between categories on the basis of physical quantity alone.**

This principle applies to all future migration units. Concrete test: if two columns in different fact tables are both labelled "nmVOC permit" but track different regulatory obligations, they require different metric names in `HistoricalAirRef`.

## Metric count decision: two metrics (revised after report consumption analysis)

The extension of `HistoricalAirRef` for Sub-unit 3B will use **two metrics**:

| Metric name | Covers | Source |
|-------------|--------|--------|
| `CH4 NMVOC Vent Permit` | `CH4_NMVOC[Tillatelse nmVOC]` — one annual permit value per (field, year), representing the main facility permit | `CH4_NMVOC` SQL `cte_hydro` CASE — main facility branch |
| `CH4 NMVOC Vent KPI` | `CH4_NMVOC[KPI nmVOC]` annual KPI value per (field, year), representing the main facility KPI | `CH4_NMVOC` SQL `KPI nmVOC` CASE — main facility branch |

All rows in `CH4_NMVOC` — both main platform and satellite/sub-sea facility rows — receive the same value per (field, year). No conditional routing step (`_VentIsMain`) is required in the M partition.

This decision was reached by applying the Architectural Decision Making principle from AGENTS.md. See full justification below.

## Architectural Decision Making — full trace

### AGENTS.md principle applied

> "When evaluating alternative migration designs, recommendations should be based on both the target data model architecture and the way the report consumes the data. Do not recommend a design solely because it is technically cleaner or more normalized. Prefer the simplest architecture that preserves business correctness while satisfying actual downstream consumption. Introduce additional model complexity only when it provides a clear business or reporting benefit."

### Dependency trace: `CH4_NMVOC[Tillatelse nmVOC]` and `CH4_NMVOC[KPI nmVOC]`

**Measures:**

| Measure | DAX | Aggregation used |
|---------|-----|-----------------|
| `nmVOC KPI year` | `CALCULATE(MAX(CH4_NMVOC[Tillatelse nmVOC])*0.9, field IN {"Ula"}) + CALCULATE(MAX(CH4_NMVOC[Tillatelse nmVOC]), NOT field IN {"Ula"})` | **MAX** — explicit |
| `nmVOC_cold_KPI year` | `MAX(CH4_NMVOC[KPI nmVOC])*12/MONTH(LASTDATE(CH4_NMVOC[Date]))` | **MAX** — explicit |

**Report visual bindings (confirmed from report JSON, 2026-07-07):**

| Visual ID | Type | Column | JSON Function code | Meaning |
|-----------|------|--------|-------------------|---------|
| `9ec62929aaa8234a5052` | KPI card — Goal | `Tillatelse nmVOC` (CH4_NMVOC) | 4 | **MAX** |
| `f79c404342b51fa2aaf0` | Trend chart — Y2 | `KPI nmVOC` (CH4_NMVOC) | 4 | **MAX** |
| `f79c404342b51fa2aaf0` | Trend chart — Y2 | `Tillatelse nmVOC` (CH4_NMVOC) | 4 | **MAX** |
| `4b7ab3127d58169ad77e` | KPI card — Goal | `Tillatelse nmVOC` (CH4_NMVOC) | 4 | **MAX** |

Note: JSON `Function: 0` = Sum (used for additive measurement columns such as `nmVOC Emissions`). JSON `Function: 4` = Max (used for permit and KPI reference columns). The `queryRef` strings say "Sum(...)" as a stored display artifact; the actual function applied is Max.

**Bookmarks:** Three bookmarks store filter states on the `Location` table (Facility/loc_key cross-filter). None apply facility-type filters directly to `CH4_NMVOC`.

**Field Parameters:** None referencing `CH4_NMVOC[Tillatelse nmVOC]` or `CH4_NMVOC[KPI nmVOC]`.

**Filters:** Page-level filters are date-based only (`Dim_Date.År`). No direct CH4_NMVOC facility-type filters exist.

**Drillthrough:** No drillthrough pages for CH4_NMVOC facility-level nmVOC detail.

### Is Main vs Satellite a distinct business concept downstream?

**No.** Every path from `CH4_NMVOC[Tillatelse nmVOC]` and `CH4_NMVOC[KPI nmVOC]` to the report uses MAX aggregation — either explicitly in measures or via JSON Function 4 in direct visual bindings.

With MAX, the main facility value always dominates because the main facility permit is always ≥ the satellite permit for every field:

| Field | Main permit | Sat permit | MAX result |
|-------|-------------|------------|------------|
| Ivar Aasen | 41 | 9 / 21 | 41 |
| Edvard Grieg | 127 | 19 | 127 |
| Skarv | 45 | 45 | 45 (equal) |
| Alvheim | 162 | 162 | 162 (equal) |
| Valhall | 24 / 27 | 24 / 27 | 24 / 27 (equal) |

For four of the six fields, main and satellite values are identical. For Ivar Aasen and Edvard Grieg, the main facility value dominates MAX. In no case does the satellite value change the MAX result.

The Main/Satellite distinction is therefore an **internal routing mechanism** — it exists to provide per-row correctness, but since the entire consumption chain uses MAX, satellite values are invisible to all downstream report output.

### Comparison: two metrics vs four metrics for report consumption

| Criterion | Two metrics | Four metrics |
|-----------|-------------|--------------|
| Measure results | Identical — MAX gives same value | Identical |
| Direct column bindings (MAX) | Identical output | Identical output |
| Bookmark filter states | Unaffected | Unaffected |
| Facility-level drill-down (select single satellite facility via Location slicer) | Shows main permit (41 for IA rig rows) — technically incorrect per-facility value, but not a designed report use case | Shows satellite permit (21 for IA rigs) |
| M partition complexity | No conditional routing; direct column expand | Requires `_VentIsMain` routing column and conditional formula |
| HistoricalAirRef sub-tables | 2 | 4 |
| Retirement path | Straightforward — add 2 metric rows to AIR_REF | Also straightforward — add 4 rows |

**The facility drill-down edge case:** A user could select a drilling rig (e.g., "Maersk Integrator") in the Location slicer, which cross-filters `CH4_NMVOC` to show only that facility's rows. In this context, MAX of a single satellite row = the satellite's permit value. With two metrics, that value would be 41 (main permit) instead of 21 (correct satellite permit for 2023+). This is incorrect at the facility level but represents an edge case not designed into the report — no visual or drillthrough page exists to surface facility-specific nmVOC cold vent permits.

### Conclusion

The two-metric approach satisfies all **actual downstream consumption** as designed:
- All measures produce identical results
- All visual bindings produce identical results
- No additional complexity (no conditional M routing; no `_VentIsMain` column)

The four-metric approach provides per-row facility-level accuracy that is not consumed by any measure, visual, filter, bookmark, or field parameter in the current report design.

Applying AGENTS.md: the Main vs Satellite distinction for `CH4_NMVOC` vented nmVOC is an internal implementation detail, not a genuine business concept consumed downstream. Introducing four metrics instead of two provides implementation completeness at the row level but zero business or reporting benefit for this model. Two metrics is the simplest architecture that preserves business correctness while satisfying actual downstream consumption.

## Scope Assumption

The decision to implement two metrics rests on an explicit scope assumption: **the semantic model is designed for field-level environmental KPI reporting, not as a general-purpose facility-level environmental reference model.**

This assumption was validated against the complete downstream dependency chain on 2026-07-07:

| Component | Validation finding |
|-----------|-------------------|
| **Measures** | `nmVOC KPI year` and `nmVOC_cold_KPI year` both use explicit `MAX(CH4_NMVOC[Tillatelse nmVOC])` and `MAX(CH4_NMVOC[KPI nmVOC])`. No measure performs facility-level permit analysis or sub-field aggregation. |
| **Report visuals** | All direct bindings of `CH4_NMVOC[Tillatelse nmVOC]` and `CH4_NMVOC[KPI nmVOC]` use JSON `Function: 4` (Max). The report contains KPI cards and trend charts designed for field-level KPI comparison. No visual surfaces facility-level vented nmVOC permit values as a distinct display element. |
| **Filters** | Page-level filters are date-based only (`Dim_Date.År`). Report-level filters operate on the `Location` table. No filter restricts `CH4_NMVOC` to a specific facility type for permit analysis. |
| **Bookmarks** | Three bookmarks store `Location`-based filter states. None apply facility-type conditions to `CH4_NMVOC[Tillatelse nmVOC]` or `CH4_NMVOC[KPI nmVOC]`. |
| **Field Parameters** | None referencing `CH4_NMVOC[Tillatelse nmVOC]` or `CH4_NMVOC[KPI nmVOC]`. |
| **Intended report behaviour** | The report is structured around field-level environmental KPIs (one KPI card and one trend chart per business concept per field). Facility-level regulatory analysis is not part of the report's intended function. |

**Limitation accepted:** Users who query `CH4_NMVOC[Tillatelse nmVOC]` filtered to a specific satellite facility (e.g., `Facility = "Maersk Integrator"`) will receive the main platform permit value (41 for Ivar Aasen) rather than the satellite permit value (21 for Ivar Aasen 2023+). This limitation is documented and accepted because the field-level scope is confirmed and the satellite permit distinction was never a designed business capability in the legacy model.

**Future scope change:** If the semantic model's scope expands to support facility-level regulatory analysis — for example, to answer "what is the specific cold-vent permit for a drilling satellite at Ivar Aasen?" as a distinct business requirement — DR005 must be revisited. At that point the two-metric design should be re-evaluated and extended with `CH4 NMVOC Vent Sat Permit` and `CH4 NMVOC Vent Sat KPI` following the established Mainfield/Rig routing pattern.

## Status

**Approved — 2026-07-07 (revised from initial four-metric recommendation after report consumption analysis)**

The regulatory category separation principle remains in full effect. The revision affects only the metric count within that category (two instead of four).

`HistoricalAirRef` extension implemented 2026-07-08. Sub-unit 3B Phase A complete.

---

# Decision Record 006

## Topic

Classification of the `CH4_NMVOC` combustion branch `Tillatelse nmVOC = 41` as a legacy implementation defect.

## Date

2026-07-08

## Context

Sub-unit 3B Phase A validation revealed that the `cte_combustion` branch in `CH4_NMVOC` contains:

```sql
CAST(41 AS int) AS [Tillatelse nmVOC] -- NMVOC tillatelse
```

This hardcodes 41 for ALL combustion rows regardless of field. 41 is exclusively the Ivar Aasen cold-vent nmVOC permit — confirmed by both the hydro branch SQL (`WHEN [field] = 'PL 001B Ivar Aasen' AND [facility] = 'Ivar Aasen' THEN 41`) and by `HistoricalAirRef[CH4 NMVOC Vent Permit | Ivar Aasen = 41]`.

The combustion branch sources from `fact_nems__environment_kpi_combustion_ctt`. VALHALL PH appears in both branches: hydro → `Tillatelse nmVOC = 24` (correct Valhall cold-vent permit); combustion → `Tillatelse nmVOC = 41` (IA placeholder).

## Relationship to DR004

This defect is structurally identical to DR004 (`CAST(56 AS int) AS [Tillatelse CH4]`), written by the same developer in the same combustion CTE, one line adjacent to the CH4 defect. The pattern is: Ivar Aasen's field-specific permit applied unconditionally to all combustion rows for all fields.

## Assessment

### Hydro branch confirms field-specific values

The hydro branch has correct field-specific `Tillatelse nmVOC` values for all six main fields. For the in-scope fields, hydro branch values match `HistoricalAirRef` exactly.

### Combustion 41 affects measure output for Valhall only

For fields where the combustion placeholder (41) is **larger than the hydro permit**, the `MAX(KPI nmVOC)` aggregation picks up the combustion value, inflating the KPI measures:

| Field | Hydro permit (pre-2025) | Combustion placeholder | Combustion dominates? |
|-------|------------------------|------------------------|----------------------|
| Valhall | 24 | 41 | **YES** → inflates KPI |
| Ivar Aasen | 41 | 41 | No (equal) |
| Skarv | 45 | 41 | No (hydro larger) |
| Edvard Grieg | 127 | 41 | No (hydro larger) |
| Alvheim | 162 | 41 | No (hydro larger) |
| Ula (2023+) | 60/139 | 41 | No (hydro larger) |

### Ula 2021–2022: correct absence of data

For Ula 2021–2022, the hydro branch also produces **NULL** for `Tillatelse nmVOC` (consistent with `Tillatelse CH4` which was accepted in DR004). This was verified against all authoritative sources:

| Source | Ula cold-vent nmVOC permit 2021–2022 |
|--------|---------------------------------------|
| Hydro branch SQL | **NULL** — `YEAR([date]) > 2022` is the explicit lower bound |
| HistoricalAirRef | No entry — starts Ula from 2023 (consistent with CH4) |
| Business workbook (`permit_kpi_to_air`) | Not applicable (covers 2025+) |
| AIR_REF | Not applicable (covers 2026+) |

No authoritative source contains a cold-vent nmVOC permit for Ula before 2023. BLANK is the correct representation — it reflects the absence of permit tracking for those years, not missing data. The combustion 41 is a placeholder that should not have been applied. This is the same classification as DR004 for Ula CH4 pre-2023.

## Decision

**The combustion branch `Tillatelse nmVOC = 41` for non-Ivar-Aasen fields is a legacy implementation defect.** It is not an intentional business rule.

The defect is corrected in Sub-unit 3B Phase B by replacing the SQL-derived `Tillatelse nmVOC` and `KPI nmVOC` columns with values from `CombinedAirRef[CH4 NMVOC Vent Permit]` and `CombinedAirRef[CH4 NMVOC Vent KPI]`.

## Business impact

The correction changes the following report outputs:

| Field | Years | Measure | Current (defective) | Corrected |
|-------|-------|---------|---------------------|-----------|
| Valhall | 2021–2024 | `nmVOC_cold_KPI year` | **41** | **24** |
| Valhall | 2025 | `nmVOC_cold_KPI year` | **41** | **24.3** |
| Valhall | 2021–2024 | `nmVOC KPI year` | **41** | **24** |
| Valhall | 2025 | `nmVOC KPI year` | **41** | **27** |
| Ula | 2021–2022 | `nmVOC_cold_KPI year` | **41** (placeholder) | **BLANK** (correct absence) |
| Ula | 2021–2022 | `nmVOC KPI year` | **36.9** (=41×0.9) | **BLANK** (correct absence) |

All other fields are unaffected (hydro permit ≥ 41, so hydro dominates MAX for those fields).

Visuals affected when filtered to Valhall: `9ec62929aaa8234a5052`, `f79c404342b51fa2aaf0`, `4b7ab3127d58169ad77e`.

## Status

**Approved — 2026-07-08**

Phase B of Sub-unit 3B may proceed. No business confirmation is required. The Ula 2021–2022 BLANK outcome is the correct representation, consistent with the hydro branch design and DR004 precedent.

## Why business owner confirmation was not requested

This decision was resolved entirely from authoritative technical evidence. No business ambiguity remained after the evidence review.

The four pillars of the evidence are:

1. **The hydro SQL establishes the intended lower bound.** The `Tillatelse nmVOC` CASE in `cte_hydro` uses `YEAR([date]) > 2022` as an explicit condition — not `>= 2019` or any other broader range. This is a deliberate design choice by the original developer. The condition is present for both `Tillatelse nmVOC` (this defect) and `Tillatelse CH4` (DR004), written in adjacent lines of the same CTE. The developer intended Ula cold-vent permits to start from 2023.

2. **HistoricalAirRef was derived from the same authoritative source.** During the preparation phase, both `CH4 NMVOC Vent Permit` and `MainField CH4 permit` were extracted from the hydro SQL CASE logic. Neither metric contains a Ula entry before 2023, precisely because the SQL source did not contain one. HistoricalAirRef independently confirms the same lower bound.

3. **DR004 already established the same precedent for CH4.** The absence of a Ula CH4 cold-vent permit before 2023 was examined and accepted without business escalation in DR004. `Tillatelse CH4` also produces NULL for Ula 2021–2022 in the hydro branch. Since both CH4 and nmVOC share the same Ula lower bound of 2023, the nmVOC classification follows directly from the already-approved DR004 precedent. No new evidence has emerged to contradict it.

4. **No authoritative business source contradicts the absence.** The business reference workbook (`permit_kpi_to_air`) covers 2025+. `AIR_REF` covers 2026+. Neither source contains a Ula cold-vent nmVOC permit for any historical year. There is no source in scope that asserts a permit existed for 2021–2022. An absence across all available authoritative sources is not ambiguity — it is evidence.

Where a DR004-equivalent situation was referred to the business owner, it was because the technical evidence showed a *wrong value* (Valhall CH4 permit 56 → confirmed correct value 20/49). In this case, for Ula 2021–2022, the technical evidence shows a *placeholder value with no corresponding correct value* — the correct state is the absence of data. That determination is within the migration team's authority and does not require business input.