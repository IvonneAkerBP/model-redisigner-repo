# Vedlikeholdsporteføljen — Field Replacement Log

**Date:** Phase 2 execution completed  
**Scope:** Visible pages only — `Oversikt` and `Kost - Materiell`  
**Source of truth:** `mappings/field-mapping.csv`  
**Tool:** PowerShell context-aware regex, two passes (SourceRef + From-array)

---

## 1. Pages Processed

| Page folder | Display name | Visuals |
|---|---|---|
| `ReportSection609e04c6b131b2e80650` | Oversikt | 27 |
| `5dbb3299be6a6e7d837f` | Kost - Materiell | 26 |

Hidden pages were skipped (visibility = `"HiddenInViewMode"`).

---

## 2. Files Modified

### Pass 1 — SourceRef Entity + Property + queryRef + nativeQueryRef (29 files)

**Oversikt page** (18 files):  
`0a181d098e2d4c43e397`, `1eeca2a90c3ac8de69eb`, `1f19832c45750dc12d21`, `2d7b837ead39483e5440`, `326451f9263e4020da80`, `3e9c63c0e0c786d77b36`, `564ae750061aac3ad238`, `5d7524a27b4d1d67f242`, `63551a4637e027509007`, `68453f020321ac054159`, `72fdca849ceea28a0b85`, `8c23751cba01b9f17841`, `94faf6489fe6361fc9de`, `a2d224a0c054f3d845a2`, `abb7872171e53047a0a6`, `acab834f00fc6efb3eeb`, `c5a49f9cf64d8226025b`, `ccbdeee824d08c8d2429`

**Kost - Materiell page** (11 files):  
`1f68638c7b9e9b0a8df8`, `30b9b278e2f66b728394`, `472ad8000b783310a85f`, `47d86b04a33093040703`, `4da25a0830195cf5a64b`, `598863f5e08c19888ad0`, `6533651b4ec8a9d09b78`, `659d51c0d1c9a9d8259e`, `7c1bd970714ae2adc2a9`, `e16a62c741474b506183`, `e3a92b7f98adcc47df8b`

### Pass 2 — From-array filter Entity (8 additional files)

Additional files updated to fix `"Entity": "OldTable",` in filter `From` arrays:  
`68453f020321ac054159`, `a2d224a0c054f3d845a2`, `abb7872171e53047a0a6` (Oversikt)  
`30b9b278e2f66b728394`, `472ad8000b783310a85f`, `47d86b04a33093040703` (Kost — factActualFutureWorkSim)  
`2d7b837ead39483e5440` (Oversikt — dimAsset), `659d51c0d1c9a9d8259e` (Kost — dimAsset)

---

## 3. Table Rename Summary

| Old table | New table | Entity refs (new name) |
|---|---|---|
| `factActualFutureWorkSim` | `fact_maintenance_actual_future_work_sim` | 98 |
| `dimWorkorder` | `dim_maintenance_work_orders` | 12 |
| `dimMaintenanceItem` | `dim_maintenance_items` | 7 |
| `dimMaintenanceItemCycle` | `dim_maintenance_item_cycles` | 4 |
| `dimAsset` | `dim_maintenance_assets` | 6 |
| `dimMaintenancePlant` | `dim_maintenance_plants` | 8 |
| `dimOperationWorkcenter` / `dimMainWorkcenter` | `dim_maintenance_work_centers` | 6 |
| `dimWorkorderOperation` | `dim_maintenance_work_order_operations` | 2 |
| `dimFunctionalLocation` / `factFLOC` | `dim_lci__functional_locations` | 0 (not on visible pages) |
| `dimWorkcenterCapacity` | `dim_work_center_capacities` | 0 (not on visible pages) |
| `dimDateSelector` | `dim_date_ranges` | 0 (not on visible pages) |

**Total Entity references now using new table names: 163**

---

## 4. Fields Left Unchanged (Explicit Rules)

| Table | Column | Reason |
|---|---|---|
| `dbt_gold dim_dates` | `year_month_name`, `year_week`, `date` | Table exists with same name in new model — no rename needed |
| `dimDate` | `Date` | User confirmed: table name unchanged |
| `factMaterialCost` | *(all columns)* | **Project rule:** `factMaterialCost` does not exist in Vedlikeholdsporteføljen model — all references preserved as-is |

---

## 5. Fields Requiring Manual Review

The following fields have no entry in `mappings/field-mapping.csv` and could not be mapped automatically. Each visual still references the old table name.

| Visual ID | Old table | Old column | Page | Action needed |
|---|---|---|---|---|
| `0a181d098e2d4c43e397` | `factActualFutureWorkSim` | `#Future Workorders` | Oversikt | Locate measure or column in new model |
| `0a181d098e2d4c43e397` | `factActualFutureWorkSim` | `Sum Work On Date` | Oversikt | Locate measure or column in new model |
| `564ae750061aac3ad238` (×2) | `factActualFutureWorkSim` | `#Rows` | Oversikt | Locate measure or column in new model |
| `99a4533de47c066ca703` (×2) | `factActualFutureWorkSim` | `#Rows` | Oversikt | Locate measure or column in new model |
| `739d1e0c46195a1d5aca` | `dimAsset` | `AssetImgSwitch` | Oversikt | Confirm column name in `dim_maintenance_assets` |
| `5fde3535297d59728436` | `dimAsset` | `AssetImgSwitch` | Oversikt | Confirm column name in `dim_maintenance_assets` |
| `c3858104a2efa12f5c40` (×2) | `dimMaintenancePlant` | `Maintenance Plant Name Grouped Short` | Oversikt | **No equivalent column in `dim_maintenance_plants` TMDL** — needs model investigation |
| `factWorkorderHistory.*` | `factWorkorderHistory` | `Table Last Processed` | — | User confirmed: flag for manual review |

> **Note on `dimMaintenancePlant.Maintenance Plant Name Grouped Short`:** The new model `dim_maintenance_plants.tmdl` contains `manual_maintenance_mapping_plant_name_grouped` (the mapped equivalent of `Maintenance Plant Name Grouped`) but no "short" variant. This column either needs to be added to the model or the visual needs to be updated to use a different column.

---

## 6. New Columns Added to Mapping (no old equivalent)

These columns exist in the new model but have no old equivalent. They were added to `field-mapping.csv` for documentation. Visuals that need these fields must be configured manually.

| New column | New table | Notes |
|---|---|---|
| `date_period_granularity` | `dim_date_ranges` | New column, replaces dimDateSelector functionality |
| `date_period_sort_order` | `dim_date_ranges` | New column, replaces dimDateSelector functionality |

---

## 7. Patterns Applied

Two JSON patterns were handled:

**Pattern A — SourceRef (field projection and column filters):**
```json
"Entity": "OldTable"
},
"Property": "OldColumn"
```

**Pattern B — From-array filter source alias:**
```json
"Entity": "OldTable",
"Type": 0
```

Additionally updated: `"queryRef": "OldTable.OldColumn"`, aggregated queryRef `"Sum(OldTable.OldColumn)"`, and `"nativeQueryRef"` values.
