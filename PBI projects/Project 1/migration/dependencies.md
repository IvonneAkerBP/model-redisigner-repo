# Dependency Analysis

**Project:** Project 1 — Environmental KPIs
**Date:** 2026-07-03
**Phase:** Phase 2 — Dependency Analysis

This document records every dependency on the candidate reference columns identified in `migration-inventory.md` Section 1. It covers page filters, visual-level filters, slicer bindings, direct visual column bindings, measure references, bookmarks, and cross-table dependencies. All findings are based on inspection of the report definition files and semantic model TMDL.

---

## Summary

| Dependency type | Count | Candidate columns involved | Notes |
|----------------|-------|---------------------------|-------|
| Page-level filters referencing candidate columns | 0 | — | None found on any in-scope page |
| Visual-level filters referencing candidate columns | 0 | — | None found |
| Slicers referencing candidate columns | 0 | — | All slicers use Location or Dim_Date |
| Visuals with direct column bindings to candidates | 42 | All 5 tables | Confirmed via visual.json queryRef inspection (35 previously listed in migration inventory; 7 additional found in this phase) |
| Measures referencing candidate columns | 11 | All 5 tables | No change from migration inventory |
| Bookmarks storing visual state with candidate column references | 5 | Emissions to air, CH4_NMVOC, Kaldvent volum, Oily water, Radioaktive isotoper | Stored query state; filter expressions do not reference candidate columns |
| Tables confirmed NOT to contain candidate reference data | 1 | Emissions to air CO2 Hod | Confirmed during this phase |
| Stale metadata references (no active dependency) | 24 visual files | `Tillatelse flaring QTD` | Column not in semantic model; appears only in cached visual metadata |

---

## 1. Page-Level Filter Dependencies

All three in-scope pages were inspected for page-level filter conditions referencing candidate reference columns.

| Page | Page-level filters found | References candidate columns? |
|------|--------------------------|-------------------------------|
| KPI emissions to air (ReportSectionfb30a317826482a24912) | `Dim_Date` date hierarchy | No |
| KPI discharge to sea (ReportSection8c1b620bd0d8c58c055c) | `Oily water.facility` | No |
| KPI emissions to air before 2025 (d81c48da7029c857a1ef) | `Dim_Date` date hierarchy | No |

**Finding:** No page-level filters reference candidate reference columns. Page-level filters will not be affected by the migration.

---

## 2. Visual-Level Filter and Slicer Dependencies

### 2.1 Slicers

All slicer visuals on the three in-scope pages were identified and inspected.

| Page | Visual ID | Field bound | References candidate columns? |
|------|-----------|-------------|-------------------------------|
| KPI emissions to air | `35abbab4d30cb5415914` | `Location.Location - Copy` | No |
| KPI emissions to air | `6c4ef2341b6a69a96d39` | `Dim_Date` date hierarchy | No |
| KPI emissions to air | `daaf05a393c41b349d2d` | `Location.Facility` | No |
| KPI emissions to air | `f55f72928a2abaa3b428` | `Dim_Date.MonthNameShort` | No |
| KPI discharge to sea | `0f2912ad536f7ed81b1a` | `Location.Facility` | No |
| KPI discharge to sea | `6653aed77397294e3956` | `Dim_Date` (slicer group) | No |
| KPI discharge to sea | `698b533789ddc015758e` | `Location.Location - Copy` | No |
| KPI discharge to sea | `a75bc7fe784484e6ada4` | `Dim_Date` | No |
| KPI before 2025 | `3fc6c4a9920a6806055d` | `Location.Facility` | No |
| KPI before 2025 | `61e6945770f19411c00d` | `Location.Location - Copy` | No |
| KPI before 2025 | `d07fa1f75871d1907c8d` | `Dim_Date` | No |
| KPI before 2025 | `e0eff0c2e9cec99d13fc` | `Dim_Date.MonthNameShort` | No |

**Finding:** No slicers on any in-scope page reference candidate reference columns. Slicers will not be affected by the migration.

### 2.2 Visual-level filters

No visual-level filter conditions referencing candidate reference columns were found during inspection of the visual JSON files on any in-scope page.

---

## 3. Visual Direct Column Binding Dependencies

This section records all visuals that bind **directly** to candidate reference columns via `queryRef` in their visual.json. These are in addition to the visuals identified through measure bindings.

### 3.1 Corrections to migration inventory

The migration inventory (Section 7) listed 35 visuals. Dependency Analysis identified **7 additional visuals** not previously captured, bringing the confirmed total to **42 visuals**.

**7 additional visuals identified:**

| Visual ID | Page | Candidate columns bound (direct queryRef) |
|-----------|------|-------------------------------------------|
| `9a666c42cf399dc740a2` | KPI emissions to air before 2025 | `CH4_NMVOC.KPI CH4`, `CH4_NMVOC.Tillatelse CH4` |
| `b3c48b5fc38acf884ad0` | KPI emissions to air before 2025 | `Emissions to air.KPI NOx`, `Emissions to air.Tillatelse NOx` |
| `f79c404342b51fa2aaf0` | KPI emissions to air before 2025 | `CH4_NMVOC.KPI nmVOC`, `CH4_NMVOC.Tillatelse nmVOC` |
| `1a5f1d7d86c00e092033` | KPI discharge to sea | `Radioaktive isotoper.KPIs`, `Radioaktive isotoper.Permits` |
| `8dd4bac256294da0ab3e` | KPI discharge to sea | `Radioaktive isotoper.KPIs`, `Radioaktive isotoper.Permits` |
| `a4c475830aa600509791` | KPI discharge to sea | `Oily water.KPI water reinjected` |
| `ea909364312e35b18a92` | KPI discharge to sea | `Radioaktive isotoper.KPIs`, `Radioaktive isotoper.Permits` |

**Note on `KPIs` column:** `Radioaktive isotoper.KPIs` has direct visual bindings confirmed in this phase. This column was listed as a candidate in the inventory (Section 1.5) but its direct binding nature was not previously confirmed.

### 3.2 `Division` — exhaustive binding check

Discovery noted that `Division` (Emissions to air) was bound directly in visuals. Dependency Analysis confirms exactly **2 visual files** contain a `queryRef` to `Emissions to air.Division`:

| Visual ID | Page | queryRef |
|-----------|------|----------|
| `2eab323e541360477545` | KPI emissions to air | `Sum(Emissions to air.Division)` |
| `ecd20f287253686f6d00` | KPI emissions to air before 2025 | `Sum(Emissions to air.Division)` |

No other visuals reference `Division` via queryRef. The 2 visuals above are the only direct consumers of this column.

---

## 4. Measure Dependencies

No changes from migration inventory. The 11 candidate measures and their column references are confirmed as documented in `migration-inventory.md` Section 4.1.

---

## 5. Bookmark Dependencies

All 5 bookmarks were inspected. The findings are as follows.

### 5.1 `Ivar_Aasen_ikke_slett` (96641c4200303450112a)

**Filter expressions:** The bookmark's `explorationState.filters` section contains filters on:
- `Location.loc_key`
- `Location.Facility`
- `Location.Location - Copy` → filtered to value `'Ivar Aasen'`

**Finding:** The filter expressions reference only `Location` dimension columns. None reference candidate reference columns. The filter behaviour of this bookmark is **not at risk** from changes to candidate columns.

**Stored visual state:** The bookmark captures the visual query state of its target visual (`35abbab4d30cb5415914`, the Location slicer). The stored state includes references to candidate columns such as `KPI CH4`, `KPI NOx`, `KPI nmVOC`, `KPI flaring`, `Permit nmVOC`, and `Division`. These are stored snapshots of what related visuals were displaying at the time the bookmark was created. If candidate column names change, this stored state will be stale and the bookmark may need to be re-saved.

### 5.2 Info on / Info off (Bookmarkc5cec6ed729854fed567, Bookmark9be424cbf1fa3cc034bc)

**Filter expressions:** None. These bookmarks use `applyOnlyToTargetVisuals: true` and only show or hide targeted visuals. They do not capture or restore filter state.

**Stored visual state:** Both bookmarks contain references to candidate columns (`KPI CH4`, `KPI NOx`, `KPI nmVOC`, `KPI flaring`, `Permit nmVOC`) in the stored visual query states of their target visuals. These are snapshots only. The show/hide behaviour of these bookmarks does not depend on column names.

**Finding:** The functional behaviour (show/hide info panel) is **not at risk**. Stored visual state would be stale if column names change.

### 5.3 Info sea on / Info sea off (Bookmark526d76398f618823302d, Bookmark2a91b4432b3a25546871)

**Filter expressions:** None. Same structure as Info on/off above.

**Stored visual state:** Both bookmarks contain references to `Oily water.Tillatelser` in the stored visual query states of their target visuals.

**Finding:** The functional behaviour (show/hide info panel) is **not at risk**. Stored visual state would be stale if `Tillatelser` column is renamed or removed.

### 5.4 Summary — bookmark risk

| Bookmark | Filter expressions use candidate columns? | Stored state uses candidate columns? | Risk to functional behaviour |
|----------|-------------------------------------------|--------------------------------------|------------------------------|
| `Ivar_Aasen_ikke_slett` | No — uses Location columns only | Yes — KPI CH4, KPI NOx, KPI nmVOC, KPI flaring, Permit nmVOC, Division | None to filter. Stored state stale if column names change. |
| Info on | No | Yes — KPI CH4, KPI NOx, KPI nmVOC, KPI flaring, Permit nmVOC | None — show/hide only |
| Info off | No | Yes — same as above | None — show/hide only |
| Info sea on | No | Yes — Tillatelser | None — show/hide only |
| Info sea off | No | Yes — Tillatelser | None — show/hide only |

---

## 6. `Emissions to air CO2 Hod` — Candidate Column Assessment

The full TMDL for `Emissions to air CO2 Hod` was inspected. Columns present:

`Time_Id`, `Field`, `Facility`, `Emissions Source`, `Stream Subtype`, `Source Details`, `CO2 Emissions`

**Finding:** `Emissions to air CO2 Hod` contains no candidate reference columns. It is a measurement-only table. It is **confirmed not a migration candidate** for reference data replacement.

The table's business purpose (filtered subset of Hod rows renamed to Valhall) remains an open question, but its absence of hardcoded reference data means it does not require changes as part of the reference data migration.

---

## 7. Stale Metadata References

Several visual JSON files contain `"metadata"` fields referencing candidate columns and a column that no longer exists.

### 7.1 `Tillatelse flaring QTD`

This column name appears in the `metadata` section of **24 visual files** across all pages (including out-of-scope pages). The column does **not exist** in the semantic model TMDL — it was not found in `Emissions to air.tmdl` or any other table definition.

**Finding:** `Tillatelse flaring QTD` is a stale cached reference from a previously deleted column. The `metadata` section in a visual JSON stores previously computed aggregation results that are refreshed on next report render. This is not an active structural dependency. No action is required to remove or update these metadata entries — they will be overwritten automatically when the report is refreshed.

### 7.2 Other candidate column references in `metadata`

Multiple trend chart visuals across all pages contain `metadata` references to active candidate columns such as `KPI flaring`, `Tillatelse flaring`, `Tillatelser`, `KPI Oil to sea`, and `Permits`. These are cached query snapshots, not live bindings. The same automatic refresh behaviour applies.

---

## 8. Relationship Dependencies

No changes from migration inventory Section 5. All existing relationships between fact tables, Location, and Dim_Date are unaffected by the candidate columns. The candidate reference columns are not relationship keys in any existing relationship.

---

## 9. Outstanding Questions from Dependency Analysis

1. **`Emissions to air CO2 Hod` business purpose** — Confirmed no candidate reference columns. The reason it exists as a separate table is still unknown. This should be confirmed before Migration Planning to determine whether it remains in the model as-is.

2. **`KPIs` direct bindings in 3 visuals on KPI discharge to sea** — Visuals `1a5f1d7d86c00e092033`, `8dd4bac256294da0ab3e`, `ea909364312e35b18a92` bind directly to `Radioaktive isotoper.KPIs`. This column is derived from `Permits` within Power Query. If the replacement strategy changes how `KPIs` is computed (e.g., moved to DAX), these direct column bindings would need to be updated to reference the new measure or column.

3. **Bookmark stored states and candidate column names** — All 5 bookmarks store visual query states that reference candidate column names (`KPI CH4`, `KPI NOx`, `KPI nmVOC`, `KPI flaring`, `Permit nmVOC`, `Division`, `Tillatelse CH4`, `Tillatelse NOx`, `Tillatelser`). If any of those column names change during migration, the stored visual states in the affected bookmarks will become stale. This is an observation for Migration Planning to carry forward when column naming decisions are made.

---

## 10. Dependency Matrix

This matrix cross-references every candidate reference column with its confirmed dependencies. It provides a single lookup view for Migration Planning.

**Page codes used in visual ID cells:**
- **[A]** = KPI emissions to air (ReportSectionfb30a317826482a24912)
- **[B]** = KPI emissions to air before 2025 (d81c48da7029c857a1ef)
- **[C]** = KPI discharge to sea (ReportSection8c1b620bd0d8c58c055c)

**Bookmark codes:**
- **I** = Ivar\_Aasen\_ikke\_slett
- **Io+** = Info on
- **Io−** = Info off
- **Is+** = Info sea on
- **Is−** = Info sea off

---

### 10.1 Emissions to air

| Candidate column | Direct visual bindings | Measure(s) that reference this column | Bookmark stored state |
|-----------------|----------------------|---------------------------------------|-----------------------|
| `Tillatelse NOx` | [A] `5744dedd`, `c4f3196a`, `10723f52`, `ab22c12a` · [B] `1ba9940e`, `6d9e9e70`, `d40ce7d6`, `b3c48b5f` **(8)** | `NOx KPI year` | I, Io+, Io− |
| `KPI NOx` | [A] `10723f52`, `ab22c12a` · [B] `d40ce7d6`, `b3c48b5f` **(4)** | `NOx KPI year` | I, Io+, Io− |
| `Permit nmVOC` | [A] `7b7ba5c4`, `d03da09d` · [B] `73ebcfad`, `67716bc6` **(4)** | `nmVOCfuel KPI year` | I, Io+, Io− |
| `KPI nmVOC` | [A] `d03da09d` · [B] `67716bc6` **(2)** | `nmVOC_KPI year` | I, Io+, Io− |
| `KPI CO2 tonn` | [A] `824554953`, `edd7ee28` **(2)** | `CO2 KPI year` | — |
| `Month` | None confirmed | `CO2 KPI year` | — |
| `Tillatelse flaring` | [A] `2eab323e`, `52643268` · [B] `993e8351`, `ecd20f28` **(4)** | — | I |
| `KPI flaring` | [A] `52643268` · [B] `993e8351` **(2)** | — | I, Io+, Io− |
| `Division` | [A] `2eab323e` · [B] `ecd20f28` **(2)** | — | I |
| `Permit Cold ventilated gas` | None confirmed | — | — |
| `KPI Cold ventilated gas` | None confirmed | — | — |

**Notes:**
- `KPI flaring` and `Tillatelse flaring` are not referenced by any of the 11 candidate measures. They are consumed by visuals directly.
- `Division` has no measure dependency. It is a direct visual binding only.
- `Month` has no direct visual binding. It is consumed only via `CO2 KPI year`.
- `Permit Cold ventilated gas` and `KPI Cold ventilated gas` — no direct visual bindings or measure dependencies confirmed during analysis. Their use should be verified against the full visual set before any replacement strategy is planned.

---

### 10.2 CH4\_NMVOC

| Candidate column | Direct visual bindings | Measure(s) that reference this column | Bookmark stored state |
|-----------------|----------------------|---------------------------------------|-----------------------|
| `Tillatelse CH4` | [A] `51b9d8c1`, `ddd3e88e` · [B] `24842c29`, `9a666c42` **(4)** | `CH4 KPI year` | I, Io+, Io− |
| `KPI CH4` | [A] `ddd3e88e` · [B] `9a666c42` **(2)** | `CH4_year KPI` | I, Io+, Io− |
| `Tillatelse nmVOC` | [A] `9ec62929`, `12a11a99` · [B] `4b7ab312`, `f79c4043` **(4)** | `nmVOC KPI year` | — |
| `KPI nmVOC` | [A] `12a11a99` · [B] `f79c4043` **(2)** | `nmVOC_cold_KPI year` | I, Io+, Io− |

---

### 10.3 Kaldvent volum

| Candidate column | Direct visual bindings | Measure(s) that reference this column | Bookmark stored state |
|-----------------|----------------------|---------------------------------------|-----------------------|
| `Tillatelse Kaldvent` | [A] `22e4ed31`, `f5b5887b` · [B] `eaf5796f`, `fe4e4b2b` **(4)** | `Vented KPI year` | — |
| `KPI Kaldvent QTD` | [A] `f5b5887b` · [B] `fe4e4b2b` **(2)** | — | — |
| `Division` | None confirmed | — | — |

**Note:** `Kaldvent volum.Division` had no confirmed direct visual bindings. The column is used internally in the SQL to compute `KPI Kaldvent QTD` but no visual binds to it directly.

---

### 10.4 Oily water

| Candidate column | Direct visual bindings | Measure(s) that reference this column | Bookmark stored state |
|-----------------|----------------------|---------------------------------------|-----------------------|
| `Tillatelser` | [C] `1a4c7e65`, `45bf48d0`, `1f7c0277`, `e2d94a97` **(4)** | — | Is+, Is− |
| `KPI Oil to sea` | [C] `1a4c7e65`, `1f7c0277` **(2)** | — | — |
| `KPI drain water` | [C] `45bf48d0`, `e2d94a97` **(2)** | — | — |
| `KPI water reinjected` | [C] `9d46e473`, `a4c475830` **(2)** | `KPI reinjected` | — |

**Note:** `Tillatelser`, `KPI Oil to sea`, and `KPI drain water` are bound directly in visuals. None of these three are referenced by any of the 11 candidate measures — they are consumed by visuals only.

---

### 10.5 Radioaktive isotoper

| Candidate column | Direct visual bindings | Measure(s) that reference this column | Bookmark stored state |
|-----------------|----------------------|---------------------------------------|-----------------------|
| `Permits` | [C] `00a40ed8`, `12b47246`, `b13542dc`, `1a5f1d7d`, `8dd4bac2`, `ea909364` **(6)** | `KPI year` | — |
| `KPIs` | [C] `1a5f1d7d`, `8dd4bac2`, `ea909364` **(3)** | — | — |

**Note:** `KPIs` is computed from `Permits` in Power Query (`(Permits / 12) * Måned` with 90% factor for Ula and Valhall). It has both direct visual bindings and is a candidate column in its own right. `KPI year` (the measure) references `Permits`, not `KPIs`. The 3 visuals binding `KPIs` directly would be affected if `KPIs` is moved to DAX or restructured.

---

### 10.6 Summary counts

| Table | Candidate columns | Columns with ≥1 direct visual binding | Columns with ≥1 measure dependency | Columns in bookmark stored state |
|-------|------------------|-----------------------------------------|-------------------------------------|----------------------------------|
| Emissions to air | 11 | 8 | 5 | 5 (Tillatelse NOx, KPI NOx, Permit nmVOC, KPI nmVOC, KPI flaring, Division — via I, Io+, Io−) |
| CH4\_NMVOC | 4 | 4 | 4 | 3 (Tillatelse CH4, KPI CH4, KPI nmVOC) |
| Kaldvent volum | 3 | 2 | 1 | 0 |
| Oily water | 4 | 4 | 1 | 1 (Tillatelser — via Is+, Is−) |
| Radioaktive isotoper | 2 | 2 | 1 | 0 |
| **Total** | **24** | **20** | **12\*** | **\-** |

\* The 12 measure-column dependencies map to 11 distinct measures because `NOx KPI year` references two candidate columns (`KPI NOx` and `Tillatelse NOx`).

---

## Next Steps

Dependency Analysis is complete. The confirmed dependency picture for Migration Planning is:

- 0 page filters, 0 visual filters, 0 slicers affected
- 42 visuals with direct or measure-based candidate column bindings
- 11 candidate measures
- 5 bookmarks with stored-state references to candidate column names (no filter expression risk; stale states would result from column name changes)
- `Emissions to air CO2 Hod` — not in scope for reference data migration

**Proceed to Phase 3 — Schema Comparison / Mapping Analysis** to identify the Fabric reference tables from `Input til PowerBI.xlsx` and map them to the candidate columns documented here.
