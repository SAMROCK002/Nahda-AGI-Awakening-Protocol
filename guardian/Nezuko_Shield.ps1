$source = "d:\Users\Oussama\Documents\Google Drive\Google AI Studio"
$dest   = "S:\AI\Nahda-AGI-Awakening-Protocol-main\00_HISTORY_OF_THE_AWAKENING\Google AI Studio"

function Get-FileHash256($path) {
    return (Get-FileHash -Path $path -Algorithm SHA256).Hash
}

function Get-DateStamp($file) {
    $d = (Get-Item $file).LastWriteTime
    return $d.ToString("yyyy-MM-dd_HH.mm.ss")
}

Get-ChildItem -Path $source -File | ForEach-Object {
    $sFile        = $_.FullName
    $sSize        = $_.Length
    $originalName = $_.Name
    $baseName     = $_.BaseName
    $ext          = $_.Extension
    $dFile        = Join-Path $dest $originalName
    $hasExtension = ($ext -ne "")

    # Block zero byte
    if ($sSize -eq 0) {
        Write-Host "BLOCKED (zero byte): $originalName" -ForegroundColor Red
        return
    }

    # New file - copy directly
    if (-not (Test-Path $dFile)) {
        Copy-Item -Path $sFile -Destination $dFile
        Write-Host "Copied new: $originalName" -ForegroundColor Cyan
        return
    }

    $dSize = (Get-Item $dFile).Length

    # ══ ملف بامتداد (صورة، فيديو، php...) ══
    # لا يُستبدل أبداً — فقط احفظ نسخة جديدة بتاريخ إذا مختلف
    if ($hasExtension) {
        if ($sSize -eq $dSize) {
            $sHash = Get-FileHash256 $sFile
            $dHash = Get-FileHash256 $dFile
            if ($sHash -eq $dHash) {
                Write-Host "Identical: $originalName" -ForegroundColor Gray
            } else {
                $stamp   = Get-DateStamp $sFile
                $newName = "${baseName}_${stamp}${ext}"
                Copy-Item -Path $sFile -Destination (Join-Path $dest $newName)
                Write-Host "Saved copy: $newName" -ForegroundColor Magenta
            }
        } else {
            # حجم مختلف = ملف مختلف = احفظ بجانبه بتاريخ
            $stamp   = Get-DateStamp $sFile
            $newName = "${baseName}_${stamp}${ext}"
            $newFile = Join-Path $dest $newName
            if (-not (Test-Path $newFile)) {
                Copy-Item -Path $sFile -Destination $newFile
                Write-Host "Saved new copy: $newName" -ForegroundColor Cyan
            } else {
                Write-Host "Already saved: $newName" -ForegroundColor Gray
            }
        }
        return
    }

    # ══ ملف بدون امتداد (Google Studio docs) ══
    # قاعدة النمو الذهبية: يكبر = حدّث / يصغر = احمِ
    if ($sSize -gt $dSize) {
        Copy-Item -Path $sFile -Destination $dFile -Force
        Write-Host "Updated (grew): $originalName ($dSize -> $sSize bytes)" -ForegroundColor Green
        return
    }

    if ($sSize -lt $dSize) {
        Write-Host "PROTECTED: $originalName ($dSize bytes kept)" -ForegroundColor Red
        return
    }

    if ($sSize -eq $dSize) {
        Write-Host "Identical: $originalName" -ForegroundColor Gray
        return
    }
}

Write-Host "Done. Memory protected." -ForegroundColor Cyan