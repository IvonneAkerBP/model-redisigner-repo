# Read xlsx as a ZIP and parse sheet XML
param([string]$XlsxPath = 'c:\repos\model redesigner\PBI projects\Project 1\data\Input til PowerBI.xlsx')

Add-Type -Assembly 'System.IO.Compression.FileSystem'

$zip = [System.IO.Compression.ZipFile]::OpenRead($XlsxPath)

# --- Load shared strings ---
$ssEntry = $zip.Entries | Where-Object FullName -eq 'xl/sharedStrings.xml'
$ssMap   = @{}
if ($ssEntry) {
    $sr   = [System.IO.StreamReader]::new($ssEntry.Open())
    $xml  = [xml]$sr.ReadToEnd()
    $sr.Close()
    $i = 0
    foreach ($si in $xml.sst.si) {
        $text = if ($si.t) { $si.t } elseif ($si.r) { ($si.r | ForEach-Object { $_.t }) -join '' } else { '' }
        $ssMap[$i] = [string]$text
        $i++
    }
}

# --- Load workbook to get sheet names in order ---
$wbEntry = $zip.Entries | Where-Object FullName -eq 'xl/workbook.xml'
$wbSr    = [System.IO.StreamReader]::new($wbEntry.Open())
$wbXml   = [xml]$wbSr.ReadToEnd()
$wbSr.Close()
$ns = @{ x = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main';
         r = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships' }
$sheetNodes = $wbXml.workbook.sheets.sheet

# --- Helper: resolve cell value ---
function Get-CellValue($cell, $ssMap) {
    $v = $cell.v
    if ($null -eq $v) { return '' }
    if ($cell.t -eq 's') { return $ssMap[[int]$v] }
    return [string]$v
}

# --- Process each sheet ---
foreach ($sNode in $sheetNodes) {
    $sheetName = $sNode.name
    $sheetId   = $sNode.GetAttribute('id', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships')

    # Find the entry for this sheet via rId -> sheet file
    $relsEntry = $zip.Entries | Where-Object FullName -eq 'xl/_rels/workbook.xml.rels'
    $relsSr    = [System.IO.StreamReader]::new($relsEntry.Open())
    $relsXml   = [xml]$relsSr.ReadToEnd()
    $relsSr.Close()
    $rel    = $relsXml.Relationships.Relationship | Where-Object Id -eq $sheetId
    $target = 'xl/' + $rel.Target

    $shEntry = $zip.Entries | Where-Object FullName -eq $target
    if (-not $shEntry) { continue }

    $shSr  = [System.IO.StreamReader]::new($shEntry.Open())
    $shXml = [xml]$shSr.ReadToEnd()
    $shSr.Close()

    $rows = $shXml.worksheet.sheetData.row
    $rowCount = if ($rows) { @($rows).Count } else { 0 }

    Write-Host ""
    Write-Host "======================================================"
    Write-Host "SHEET: $sheetName   (data rows incl header: $rowCount)"
    Write-Host "======================================================"

    if ($rowCount -eq 0) { Write-Host "  (empty)"; continue }

    # Row 1 = headers
    $headerRow = @($rows)[0]
    $headers   = @()
    foreach ($cell in $headerRow.c) {
        $headers += Get-CellValue $cell $ssMap
    }
    Write-Host "COLUMNS ($($headers.Count)): $($headers -join ' | ')"

    # Rows 2..min(8, rowCount) = sample
    $maxSample = [Math]::Min(7, $rowCount - 1)
    Write-Host "SAMPLE ROWS (up to $maxSample):"
    for ($ri = 1; $ri -le $maxSample; $ri++) {
        $row  = @($rows)[$ri]
        $vals = @()
        foreach ($cell in $row.c) {
            $vals += Get-CellValue $cell $ssMap
        }
        Write-Host "  [$ri] $($vals -join ' | ')"
    }

    # Distinct values in column 1 (Metric / first column)
    $col1 = [System.Collections.Generic.HashSet[string]]::new()
    for ($ri = 1; $ri -lt $rowCount; $ri++) {
        $row = @($rows)[$ri]
        if ($row.c -and @($row.c).Count -gt 0) {
            $v = Get-CellValue (@($row.c)[0]) $ssMap
            if ($v) { $col1.Add($v) | Out-Null }
        }
    }
    $sorted = $col1 | Sort-Object
    Write-Host "DISTINCT COL-1 VALUES ($($col1.Count)): $($sorted -join ' | ')"
}

$zip.Dispose()
Write-Host ""
Write-Host "Done."
