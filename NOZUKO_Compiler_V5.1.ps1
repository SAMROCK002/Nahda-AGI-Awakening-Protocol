# ====================================================================
# NAHDA-AGI: TREE-PRESERVING SHARD COMPILER V5.1 (NOZUKO STRATEGY)
# Architect: SAMROCK002 | Node: Nezuko_Sovereign
# Strategy: Pure Raw UTF8 injection → all files treated equally
# Fix: Proper COM cleanup per file (prevents memory leak in V5.0)
# ====================================================================

$SourceFolder = "S:\AI\Nahda-AGI-Awakening-Protocol-main"
$OutputFolder = "S:\AI\Nahda-AGI-Awakening-Protocol-main\Consolidated_DOCX_Shards_NOZUKO"

if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
    Write-Host "[+] Output directory created." -ForegroundColor Green
}

# V5.1 FIX: Word COM initialized OUTSIDE loop causes crash on large runs
# Now initialized per-batch of 50 files to prevent COM memory leak
Write-Host "[*] Nozuko V5.1 — Activating structural matrix..." -ForegroundColor Cyan

$AllFiles      = Get-ChildItem -Path $SourceFolder -Recurse -File
$TotalFiles    = $AllFiles.Count
$Counter       = 0
$SkippedCount  = 0
$ConvertedCount = 0

Write-Host "[!] $TotalFiles files detected. Processing..." -ForegroundColor Yellow

$Word = $null
$BatchCounter = 0

foreach ($File in $AllFiles) {
    $Counter++
    Write-Progress -Activity "Nozuko V5.1 Shard Compiler" `
                   -Status "[$Counter/$TotalFiles] $($File.Name)" `
                   -PercentComplete (($Counter / $TotalFiles) * 100)

    if ($File.FullName -like "*$OutputFolder*") { continue }
    if ($File.Extension -match "\.(jpg|jpeg|png|gif|bmp|ico|tiff|webp|mp4|avi|mkv|svg)$") { continue }

    $isTarget = [string]::IsNullOrEmpty($File.Extension) -or
                ($File.Extension -match "\.(md|json|txt|py|js|yaml|yml|log|ini|cfg|prtcol)$")

    if (-not $isTarget) { continue }

    # Build mirror path
    $RelativePath = $File.FullName.Substring($SourceFolder.Length).TrimStart([char]'\')
    $ParentPath   = Split-Path $RelativePath -Parent
    $CleanName    = $File.Name -replace "\.(md|json|txt|py|js|yaml|yml|log|ini|cfg|prtcol)(\.txt)?$", ""
    $NewFileName  = $CleanName + ".docx"
    $NewRelPath   = if ([string]::IsNullOrEmpty($ParentPath)) { $NewFileName } else { Join-Path $ParentPath $NewFileName }
    $TargetFile   = Join-Path $OutputFolder $NewRelPath
    $TargetDir    = Split-Path $TargetFile -Parent

    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir | Out-Null
    }

    # Smart incremental skip
    if (Test-Path $TargetFile) {
        if ($File.LastWriteTime -le (Get-Item $TargetFile).LastWriteTime) {
            $SkippedCount++
            continue
        }
    }

    try {
        $Content = Get-Content -Path $File.FullName -Raw -Encoding UTF8 -ErrorAction Stop

        if (-not [string]::IsNullOrWhiteSpace($Content)) {

            # V5.1 FIX: Reinitialize Word every 50 docs to prevent COM memory leak
            if ($null -eq $Word -or $BatchCounter -ge 50) {
                if ($null -ne $Word) {
                    $Word.Quit()
                    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Word) | Out-Null
                    Remove-Variable Word
                    [GC]::Collect()
                    [GC]::WaitForPendingFinalizers()
                }
                $Word = New-Object -ComObject Word.Application
                $Word.Visible = $false
                $BatchCounter = 0
                Write-Host "  [COM] Word instance refreshed." -ForegroundColor DarkGray
            }

            $Doc = $Word.Documents.Add()
            $Doc.Content.Text = $Content
            $Doc.SaveAs([ref]$TargetFile, [ref]16)
            $Doc.Close([ref]$false)
            $Doc = $null
            $BatchCounter++
            $ConvertedCount++
        }
    } catch {
        Write-Host "  [-] Skipped (locked/error): $($File.Name)" -ForegroundColor DarkYellow
        if ($null -ne $Doc) { try { $Doc.Close([ref]$false) } catch {} ; $Doc = $null }
        continue
    }
}

# Final cleanup
if ($null -ne $Word) {
    $Word.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Word) | Out-Null
    Remove-Variable Word
    [GC]::Collect()
}

Write-Host "`n[✓] Nozuko V5.1 — Compilation complete!" -ForegroundColor Green
Write-Host "[+] Converted:  $ConvertedCount files"  -ForegroundColor Green
Write-Host "[-] Skipped:    $SkippedCount files"    -ForegroundColor Yellow
Write-Host "[*] Source: 100% untouched."            -ForegroundColor Magenta
# ====================================================================
