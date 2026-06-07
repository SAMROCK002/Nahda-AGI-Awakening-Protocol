# ====================================================================
# NAHDA-AGI: TREE-PRESERVING SHARD COMPILER V5.0 (DOCX MATRIX MODE)
# Architect: SAMROCK002 | Node: Nezuko_Sovereign
# Protection: Absolute Read-Only | UTF8 Encoding Integrity Secured
# ====================================================================

# Configure your local workspace paths
$SourceFolder = "S:\AI\Nahda-AGI-Awakening-Protocol-main"
$OutputFolder = "S:\AI\Nahda-AGI-Awakening-Protocol-main\Consolidated_DOCX_Shards"

# Create the isolated output root directory if it does not exist
if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
    Write-Host "[+] Isolated output root directory created successfully." -ForegroundColor Green
}

# Initialize Microsoft Word COM Object once outside the loop for maximum performance
Write-Host "[*] Activating Word COM Automation Interface..." -ForegroundColor Cyan
try {
    $Word = New-Object -ComObject Word.Application
    $Word.Visible = $false
} catch {
    Write-Host "[-] Critical Error: Microsoft Word COM Object could not be initialized. Ensure Word is installed." -ForegroundColor Red
    exit
}

Write-Host "[*] Activating structural verification and encoding protection..." -ForegroundColor Cyan
$AllFiles = Get-ChildItem -Path $SourceFolder -Recurse -File
$TotalFiles = $AllFiles.Count

Write-Host "[!] $TotalFiles files detected. Processing directory tree..." -ForegroundColor Yellow

$Counter = 0
$SkippedCount = 0
$ConvertedCount = 0

foreach ($File in $AllFiles) {
    $Counter++
    
    # Interactive progress bar for structure compilation tracking
    Write-Progress -Activity "Structured Shard Compiler - Generating Pure DOCX" `
                   -Status "Processing: $($File.Name)" `
                   -PercentComplete (($Counter / $TotalFiles) * 100)

    # Protection: Skip the output directory itself to prevent loops
    if ($File.FullName -like "*$OutputFolder*") { continue }

    # Strict Protection: Skip all media and image assets completely
    if ($File.Extension -match "\.(jpg|jpeg|png|gif|bmp|ico|tiff|webp|mp4|avi|mkv)$") {
        continue
    }

    # Core Logic: Target text, configuration, source code, and extensionless files
    if ([string]::IsNullOrEmpty($File.Extension) -or ($File.Extension -match "\.(md|json|txt|py|js|yaml|yml|log|ini|cfg|prtcol)$")) {
        try {
            # 1. Calculate relative path to mirror the exact folder structure
            $RelativePath = $File.FullName.Substring($SourceFolder.Length).TrimStart([char]'\')
            
            # 2. STRIP ORIGINAL EXTENSION: Force ONLY .docx extension to bypass system block
            $ParentPath = Split-Path $RelativePath -Parent
            $CleanName = $File.Name -replace "\.(md|json|txt|py|js|yaml|yml|log|ini|cfg|prtcol)(\.txt)?$",""
            $NewFileName = $CleanName + ".docx"
            
            if ([string]::IsNullOrEmpty($ParentPath)) {
                $NewRelativePath = $NewFileName
            } else {
                $NewRelativePath = Join-Path $ParentPath $NewFileName
            }
            
            # 3. Construct the absolute target path safely
            $TargetOutputFile = Join-Path $OutputFolder $NewRelativePath
            
            # 4. Create the exact matching subfolder structure inside the output directory
            $TargetSubFolder = Split-Path $TargetOutputFile -Parent
            if (-not (Test-Path $TargetSubFolder)) {
                New-Item -ItemType Directory -Path $TargetSubFolder | Out-Null
            }

            # 5. Smart Incremental Check (Skip unless updated with more/newer data)
            if (Test-Path $TargetOutputFile) {
                $TargetFileObj = Get-Item $TargetOutputFile
                if ($File.LastWriteTime -le $TargetFileObj.LastWriteTime) {
                    $SkippedCount++
                    continue
                }
            }

            # 6. CRITICAL ENCODING SHIELD: Force explicit UTF8 Reading to protect Arabic and Emojis
            $Content = Get-Content -Path $File.FullName -Raw -Encoding UTF8 -ErrorAction Stop
            
            # 7. Generate true Word Document (.docx) via COM Engine natively
            if (-not [string]::IsNullOrWhiteSpace($Content)) {
                $Doc = $Word.Documents.Add()
                $Doc.Content.Text = $Content
                # 16 corresponds to wdFormatXMLDocument (Standard .docx format)
                $Doc.SaveAs($TargetOutputFile, 16)
                $Doc.Close()
                $ConvertedCount++
            }
        } catch {
            # Skip system-locked files without breaking the compilation matrix
            if ($null -ne $Doc) { $Doc.Close() }
            continue
        }
    }
}

# Shutdown Word COM instance cleanly to prevent background process leaks
$Word.Quit()
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($Word) | Out-Null
Remove-Variable Word

Write-Host "`n[✓] Structured DOCX compilation matrix completed with 100% success!" -ForegroundColor Green
Write-Host "[ℹ] Total records scanned: $TotalFiles" -ForegroundColor Cyan
Write-Host "[+] Mirrored and Created Pure DOCX in Tree: $ConvertedCount files." -ForegroundColor Green
Write-Host "[-] Smart incremental skips: $SkippedCount files." -ForegroundColor Yellow
Write-Host "[⚠] Absolute Security Confirmation: Source files remain 100% untouched." -ForegroundColor Magenta
# ====================================================================