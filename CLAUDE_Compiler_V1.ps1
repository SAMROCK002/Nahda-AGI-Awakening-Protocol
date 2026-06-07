# ====================================================================
# NAHDA-AGI: CLAUDE SHARD COMPILER V1.0
# Strategy: Pandoc for .md files | Raw UTF8 for .json/.prtcol
# Architect: SAMROCK002 | Advisor: Claude (Anthropic)
# Goal: Maximum structural fidelity for cloud LLM reading
# ====================================================================

$SourceFolder  = "S:\AI\Nahda-AGI-Awakening-Protocol-main"
$OutputFolder  = "S:\AI\Nahda-AGI-Awakening-Protocol-main\Consolidated_DOCX_Shards_CLAUDE"

# --- Dependency check ---
$PandocPath = (Get-Command pandoc -ErrorAction SilentlyContinue)?.Source
if (-not $PandocPath) {
    Write-Host "[-] Pandoc not found. Install from: https://pandoc.org/installing.html" -ForegroundColor Red
    Write-Host "    Run: winget install pandoc" -ForegroundColor Yellow
    exit
}
Write-Host "[+] Pandoc detected: $PandocPath" -ForegroundColor Green

# --- Output folder ---
if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
    Write-Host "[+] Output directory created." -ForegroundColor Green
}

$AllFiles      = Get-ChildItem -Path $SourceFolder -Recurse -File
$TotalFiles    = $AllFiles.Count
$Counter       = 0
$ConvertedMD   = 0
$ConvertedRaw  = 0
$Skipped       = 0

Write-Host "[*] $TotalFiles files found. Starting compilation..." -ForegroundColor Cyan

foreach ($File in $AllFiles) {
    $Counter++
    Write-Progress -Activity "CLAUDE Compiler V1.0" `
                   -Status "[$Counter/$TotalFiles] $($File.Name)" `
                   -PercentComplete (($Counter / $TotalFiles) * 100)

    # Skip output folder itself
    if ($File.FullName -like "*$OutputFolder*") { continue }

    # Skip media files
    if ($File.Extension -match "\.(jpg|jpeg|png|gif|bmp|ico|tiff|webp|mp4|avi|mkv|svg)$") { continue }

    # Only process text-based files
    $isTarget = [string]::IsNullOrEmpty($File.Extension) -or
                ($File.Extension -match "\.(md|json|txt|py|js|yaml|yml|log|ini|cfg|prtcol)$")

    if (-not $isTarget) { continue }

    # Build mirror path
    $RelativePath  = $File.FullName.Substring($SourceFolder.Length).TrimStart([char]'\')
    $ParentPath    = Split-Path $RelativePath -Parent
    $CleanName     = $File.BaseName
    $NewFileName   = $CleanName + ".docx"
    $NewRelPath    = if ([string]::IsNullOrEmpty($ParentPath)) { $NewFileName } else { Join-Path $ParentPath $NewFileName }
    $TargetFile    = Join-Path $OutputFolder $NewRelPath
    $TargetDir     = Split-Path $TargetFile -Parent

    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir | Out-Null
    }

    # Smart incremental skip
    if (Test-Path $TargetFile) {
        if ($File.LastWriteTime -le (Get-Item $TargetFile).LastWriteTime) {
            $Skipped++
            continue
        }
    }

    # ---------------------------------------------------------------
    # STRATEGY:
    #   .md files  → Pandoc converts markdown structure to real Word
    #               headings, lists, code blocks (best for LLM reading)
    #   all others → Raw UTF8 text inside docx (same as Nozuko V5.0)
    #               JSON/prtcol structure preserved as plain text
    # ---------------------------------------------------------------

    try {
        if ($File.Extension -eq ".md") {
            # Pandoc: full markdown → structured Word document
            $result = & pandoc $File.FullName -o $TargetFile --from=markdown --to=docx 2>&1
            if ($LASTEXITCODE -eq 0) {
                $ConvertedMD++
                Write-Host "  [MD→DOCX] $($File.Name)" -ForegroundColor Green
            } else {
                Write-Host "  [!] Pandoc failed for $($File.Name): $result" -ForegroundColor Yellow
            }
        } else {
            # Raw UTF8 injection (JSON, prtcol, py, etc.)
            # Same as Nozuko V5.0 but with explicit UTF8 BOM handling
            $Content = Get-Content -Path $File.FullName -Raw -Encoding UTF8 -ErrorAction Stop

            if (-not [string]::IsNullOrWhiteSpace($Content)) {
                $Word = New-Object -ComObject Word.Application
                $Word.Visible = $false
                $Doc = $Word.Documents.Add()

                # Set font to Consolas for code/JSON readability
                $Doc.Content.Font.Name = "Consolas"
                $Doc.Content.Font.Size = 10
                $Doc.Content.Text = $Content

                $Doc.SaveAs([ref]$TargetFile, [ref]16)
                $Doc.Close([ref]$false)
                $Word.Quit()
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject($Word) | Out-Null
                Remove-Variable Word
                $ConvertedRaw++
            }
        }
    } catch {
        Write-Host "  [-] Error on $($File.Name): $_" -ForegroundColor Red
        if ($null -ne $Doc)  { try { $Doc.Close([ref]$false)  } catch {} }
        if ($null -ne $Word) { try { $Word.Quit() }            catch {} }
        continue
    }
}

Write-Host "`n[✓] CLAUDE Compiler V1.0 — Done!" -ForegroundColor Green
Write-Host "[+] Markdown files (Pandoc, structured): $ConvertedMD"  -ForegroundColor Cyan
Write-Host "[+] Raw text files (UTF8 injection):     $ConvertedRaw" -ForegroundColor Cyan
Write-Host "[-] Smart incremental skips:             $Skipped"      -ForegroundColor Yellow
Write-Host "[*] Source files: 100% untouched."                      -ForegroundColor Magenta
# ====================================================================
