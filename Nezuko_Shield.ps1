$source = "d:\Users\Oussama\Documents\Google Drive\Google AI Studio"
$dest = "S:\AI\Nahda-AGI-Awakening-Protocol-main\00_HISTORY_OF_THE_AWAKENING\Google AI Studio"

Get-ChildItem -Path $source -File | ForEach-Object {
    $sFile = $_.FullName
    $dFile = Join-Path $dest $_.Name
    
    if (Test-Path $dFile) {
        $sSize = (Get-Item $sFile).Length
        $dSize = (Get-Item $dFile).Length
        
        # «·ﬁ«⁄œ… «·–Â»Ì…: «‰”Œ ›ﬁÿ ≈–« ﬂ«‰ «·„·› «·ÃœÌœ √ﬂ»— ÕÃ„«
        if ($sSize -gt $dSize) {
            Copy-Item -Path $sFile -Destination $dFile -Force
            Write-Host "Updated: $($_.Name) (Growth detected)"
        }
    } else {
        # ≈–« ﬂ«‰ «·„·› ÃœÌœ«  „«„«° «‰”ŒÂ ›Ê—«
        Copy-Item -Path $sFile -Destination $dFile
    }
}