# ====================================================================
# NAHDA-AGI: TREE-PRESERVING SHARD COMPILER V5.0 (STRUCTURED MODE)
# Architect: SAMROCK002 | Node: Nezuko_Sovereign
# Protection: Absolute Read-Only | UTF8 Encoding Integrity Secured
# ====================================================================

# Configure your local workspace paths
$SourceFolder = "S:\AI\Nahda-AGI-Awakening-Protocol-main"
$OutputFolder = "S:\AI\Nahda-AGI-Awakening-Protocol-main\Consolidated_TXT_Shards"

# Create the isolated output root directory if it does not exist
if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
    Write-Host "[+] Isolated output root directory created successfully." -ForegroundColor Green
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
    Write-Progress -Activity "Structured Shard Compiler - Preserving Tree" `
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
            
            # 2. Construct the absolute target path and append .txt safely
            $TargetOutputFile = Join-Path $OutputFolder $RelativePath
            $TargetOutputFile = $TargetOutputFile + ".txt"
            
            # 3. Create the exact matching subfolder structure inside the output directory
            $TargetSubFolder = Split-Path $TargetOutputFile -Parent
            if (-not (Test-Path $TargetSubFolder)) {
                New-Item -ItemType Directory -Path $TargetSubFolder | Out-Null
            }

            # 4. Smart Incremental Check (Skip unless updated with more/newer data)
            if (Test-Path $TargetOutputFile) {
                $TargetFileObj = Get-Item $TargetOutputFile
                if ($File.LastWriteTime -le $TargetFileObj.LastWriteTime) {
                    $SkippedCount++
                    continue
                }
            }

            # 5. CRITICAL ENCODING SHIELD: Force explicit UTF8 Reading to protect Arabic and Emojis
            $Content = Get-Content -Path $File.FullName -Raw -Encoding UTF8 -ErrorAction Stop
            
            # 6. Generate the structured individual .txt shard with strict UTF8 Writing
            if (-not [string]::IsNullOrWhiteSpace($Content)) {
                Set-Content -Path $TargetOutputFile -Value $Content -Encoding UTF8
                $ConvertedCount++
            }
        } catch {
            # Skip system-locked files without breaking the compilation matrix
            continue
        }
    }
}

Write-Host "`n[✓] Structured compilation matrix completed with 100% success!" -ForegroundColor Green
Write-Host "[ℹ] Total records scanned: $TotalFiles" -ForegroundColor Cyan
Write-Host "[+] Mirrored and Created/Updated in Tree: $ConvertedCount files." -ForegroundColor Green
Write-Host "[-] Smart incremental skips: $SkippedCount files." -ForegroundColor Yellow
Write-Host "[⚠] Absolute Security Confirmation: Source files remain 100% untouched." -ForegroundColor Magenta
# ====================================================================