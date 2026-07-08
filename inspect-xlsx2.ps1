# Read just the first sheet and specific targeted sheets
param([string]$XlsxPath = 'c:\repos\model redesigner\PBI projects\Project 1\data\Input til PowerBI.xlsx',
      [string]$TargetSheet = '')

Add-Type -Assembly 'System.IO.Compression.FileSystem'
$zip = [System.IO.Compression.ZipFile]::OpenRead($XlsxPath)

$ssEntry = $zip.Entries | Where-Object FullName -eq 'xl/sharedStrings.xml'
$ssMap   = @{}
if ($ssEntry) {
    $sr  = [System.IO.StreamReader]::new($ssEntry.Open())
    $xml = [xml]$sr.ReadToEnd(); $sr.Close()
    $i = 0
    foreach ($si in $xml.sst.si) {
        $text = if ($si.t) { $si.t } elseif ($si.r) { ($si.r | ForEach-Object { $_.t }) -join '' } else { '' }
        $ssMap[$i] = [string]$text; $i++
    }
}
function GCV($cell, $m) {
    $v = $cell.v
    if ($null -eq $v) { return '' }
    if ($cell.t -eq 's') { return $m[[int]$v] }
    return [string]$v
}

$relsEntry = $zip.Entries | Where-Object FullName -eq 'xl/_rels/workbook.xml.rels'
$relsSr    = [System.IO.StreamReader]::new($relsEntry.Open())
$relsXml   = [xml]$relsSr.ReadToEnd(); $relsSr.Close()

$wbEntry = $zip.Entries | Where-Object FullName -eq 'xl/workbook.xml'
$wbSr    = [System.IO.StreamReader]::new($wbEntry.Open())
$wbXml   = [xml]$wbSr.ReadToEnd(); $wbSr.Close()
$sheetNodes = $wbXml.workbook.sheets.sheet

foreach ($sNode in $sheetNodes) {
    $sheetName = $sNode.name
    if ($TargetSheet -and $sheetName -ne $TargetSheet) { continue }
    $rId    = $sNode.GetAttribute('id', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships')
    $rel    = $relsXml.Relationships.Relationship | Where-Object Id -eq $rId
    $target = 'xl/' + $rel.Target
    $shEntry = $zip.Entries | Where-Object FullName -eq $target
    if (-not $shEntry) { continue }

    # Use XmlReader for sparse/large sheets
    $stream  = $shEntry.Open()
    $reader  = [System.Xml.XmlReader]::Create($stream)
    $rowNum  = 0
    $colVal  = @{}
    $col1Vals = [System.Collections.Generic.HashSet[string]]::new()
    $headers  = @()
    $samples  = [System.Collections.Generic.List[string]]::new()
    $dataRows = 0

    while ($reader.Read()) {
        if ($reader.NodeType -eq [System.Xml.XmlNodeType]::Element -and $reader.LocalName -eq 'row') {
            $rowNum++
            $colIdx = 0
            $rowVals = @{}
            $subReader = $reader.ReadSubtree()
            while ($subReader.Read()) {
                if ($subReader.NodeType -eq [System.Xml.XmlNodeType]::Element -and $subReader.LocalName -eq 'c') {
                    $cellRef = $subReader.GetAttribute('r')
                    $cellType = $subReader.GetAttribute('t')
                    $colLetter = $cellRef -replace '\d+', ''
                    # Read value
                    $cellVal = ''
                    $vRead = $subReader.ReadSubtree()
                    while ($vRead.Read()) {
                        if ($vRead.LocalName -eq 'v' -and $vRead.NodeType -eq [System.Xml.XmlNodeType]::Element) {
                            $rawV = $vRead.ReadElementContentAsString()
                            if ($cellType -eq 's') { $cellVal = $ssMap[[int]$rawV] }
                            else { $cellVal = $rawV }
                            break
                        }
                    }
                    $vRead.Close()
                    $rowVals[$colLetter] = $cellVal
                }
            }
            $subReader.Close()

            if ($rowNum -eq 1) { 
                $headers = $rowVals.GetEnumerator() | Sort-Object Key | ForEach-Object { $_.Value }
            } else {
                $dataRows++
                # Column A value
                $aVal = if ($rowVals['A']) { $rowVals['A'] } else { '' }
                if ($aVal) { $col1Vals.Add($aVal) | Out-Null }
                if ($dataRows -le 7) {
                    $vals = $rowVals.GetEnumerator() | Sort-Object Key | ForEach-Object { $_.Value }
                    $samples.Add("  [$dataRows] $($vals -join ' | ')") | Out-Null
                }
                # Stop after reading 300 actual data rows for large sheets
                if ($dataRows -ge 300) { break }
            }
        }
    }
    $reader.Close(); $stream.Close()

    Write-Host ""
    Write-Host "======================================================"
    Write-Host "SHEET: $sheetName   (data rows sampled: $dataRows)"
    Write-Host "======================================================"
    Write-Host "COLUMNS ($($headers.Count)): $($headers -join ' | ')"
    Write-Host "SAMPLE ROWS:"
    $samples | ForEach-Object { Write-Host $_ }
    Write-Host "DISTINCT COL-A VALUES ($($col1Vals.Count)): $($col1Vals | Sort-Object | ForEach-Object { $_ } | ForEach-Object { $_ } -join ' | ')"
}

$zip.Dispose()
Write-Host ""; Write-Host "Done."
